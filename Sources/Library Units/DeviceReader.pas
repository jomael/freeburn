{-----------------------------------------------------------------------------
 Unit Name: DeviceReader
 Author:    Paul Fisher
 Purpose:   Class to help with disk reading and ripping
 History:
-----------------------------------------------------------------------------}

unit DeviceReader;

interface

uses
  Windows, Messages, Forms, DeviceTypes, MMSystem, CovertFuncs, SCSIDefs,
    SysUtils, SCSITypes, SCSIUnit, Classes, Resources;

const
  WaveHeaderSize = 44;
  MAX_DATABLOCKS = 16;

type
  TWaveHeader = record
    { RIFF file header }
    RIFFHeader: array[1..4] of Char; { Must be "RIFF" }
    FileSize: Integer; { Must be "RealFileSize - 8" }
    WAVEHeader: array[1..4] of Char; { Must be "WAVE" }
    { Format information }
    FormatHeader: array[1..4] of Char; { Must be "fmt " }
    FormatSize: Integer; { Must be 16 (decimal) }
    FormatCode: Word; { Must be 1 }
    ChannelNumber: Word; { Number of channels }
    SampleRate: Integer; { Sample rate (hz) }
    BytesPerSecond: Integer; { Bytes per second }
    BytesPerSample: Word; { Bytes per Sample }
    BitsPerSample: Word; { Bits per sample }
    { Data area }
    DataHeader: array[1..4] of Char; { Must be "data" }
    DataSize: Integer; { Data size }
  end;

type
  TCDStatusEvent = procedure(CurrentStatus: string) of object;
  TCopyStatusEvent = procedure(CurrentSector, PercentDone: Integer) of object;

type
  TDeviceReader = class
  private
    FInfoRecord: PCDBurnerInfo;
    FLastError: TScsiError;
    FDefaults: TScsiDefaults;
    FOnCDStatus: TCDStatusEvent;
    FOnCopyStatus: TCopyStatusEvent;
    FBytesWritten: Longint;
    FsectorWrite: LongInt;
    FWaveHeader: TWaveHeader;
    function GetBurnerInfo: TCDBurnerInfo;
    function GetTOC: TScsiTOC;
    function CreateWaveHeader: TWaveHeader;
  protected
    procedure Log(Status: string);
    property BurnerInfo: TCDBurnerInfo read GetBurnerInfo;
  public
    constructor Create(InfoRecord: PCDBurnerInfo);
    destructor Destroy; override;
    function Seek(GLBA: DWORD): Boolean;
    function ReadData(GLBA, SectorCount: DWORD; BUF: Pointer; BUFLen: DWORD):
      Boolean;
    function ReadAudio(GLBA, SectorCount: DWORD; BUF: Pointer; BUFLen: DWORD):
      Boolean;
    function RipDiskToISOImage(ISOFilename: string): boolean;
    function RipAllAudioTracks(TracksFilename: string): boolean;
    function RipAudioTrack(TrackNo: Integer; TracksFilename: string): boolean;
  published
    property TOC: TScsiTOC read GetTOC;
    property OnCDStatus: TCDStatusEvent read FOnCDStatus write FOnCDStatus;
    property OnCopyStatus: TCopyStatusEvent read FOnCopyStatus write
      FOnCopyStatus;
  end; {DeviceReader}

implementation

constructor TDeviceReader.Create(InfoRecord: PCDBurnerInfo);
begin
  FinfoRecord := InfoRecord;
  FDefaults := SCSI_DEF;
end;

destructor TDeviceReader.Destroy;
begin
  inherited;
end;

procedure TDeviceReader.Log(Status: string);
begin
  if Assigned(FOnCDStatus) then
    FOnCDStatus(Status);
end;

function TDeviceReader.GetBurnerInfo: TCDBurnerInfo;
begin
  Result := FInfoRecord^;
end;

function TDeviceReader.GetTOC: TScsiTOC;
begin
  FLastError := SCSIgetTOC(BurnerInfo, Result, fDefaults);
end;

function TDeviceReader.Seek(GLBA: DWORD): Boolean;
begin
  FLastError := SCSIseek10(BurnerInfo, GLBA, FDefaults);
  Result := FLastError = Err_None;
end;

function TDeviceReader.ReadData(GLBA, SectorCount: DWORD; BUF: Pointer; BUFLen:
  DWORD): Boolean;
begin
  fLastError := SCSIread10(BurnerInfo, GLBA, SectorCount, Buf, BufLen,
    fDefaults);
  Result := fLastError = Err_None;
end;

function TDeviceReader.ReadAudio(GLBA, SectorCount: DWORD; BUF: Pointer; BUFLen:
  DWORD): Boolean;
begin
  fLastError := SCSIreadCdEx(BurnerInfo, GLBA, SectorCount, csfAudio,
    [cffUserData], BUF, BUFLen, fDefaults);
  Result := fLastError = Err_None;
end;

function TDeviceReader.RipDiskToISOImage(ISOFilename: string): boolean;
var
  ISOStream: TFileStream;
  Buf: pointer;
  BufLen: integer;
  DataBlocks, SectorSize: Integer;
  IndexBlock: integer;
  LastBlock: integer;

begin
  SectorSize := ConvertDataBlock(MODE_1);
  BufLen := MAX_DATABLOCKS * SectorSize;
  Result := True;
  LastBlock := TOC.Tracks[TOC.TrackCount - 1].AbsAddress;
  Log(resGetLastLBA + inttostr(LastBlock));
  ISOStream := TFileStream.Create(ISOFilename, fmCreate);
  try
    if LastBlock < 1 then exit;
    Log(resMemAlloc);
    Buf := nil;
    ReAllocMem(Buf, BufLen);
    Log(resStreamStart);
    IndexBlock := 0;
    DataBlocks := MAX_DATABLOCKS;

    while IndexBlock < LastBlock - 1 do
    begin
      if ((LastBlock - IndexBlock) < DataBlocks) then
      begin
        DataBlocks := (LastBlock - IndexBlock);
        BufLen := DataBlocks * SectorSize;
      end;

      if ReadData(IndexBlock, DataBlocks, Buf, BufLen) then
            FBytesWritten := ISOStream.Write(pchar(Buf)^, BufLen);

      FsectorWrite := IndexBlock;
      IndexBlock := IndexBlock + DataBlocks;

      if Assigned(FOnCopyStatus) then
        FOnCopyStatus(FsectorWrite, (FsectorWrite div ((LastBlock - 1) div
          100)));

      Forms.Application.ProcessMessages;    
    end;

    Log(resMemDeAlloc);
    ReallocMem(Buf, 0);
    Log(resCloseStream);
  finally
    ISOStream.Free;
  end;
end;


function TDeviceReader.CreateWaveHeader: TWaveHeader;
var
  Waveheader: TWaveHeader;
begin
  FillChar(WaveHeader, Sizeof(TWaveHeader), 0);
  Waveheader.RIFFHeader := 'RIFF'; { Must be "RIFF" }
  Waveheader.FileSize := 0; { Must be "RealFileSize - 8" }
  Waveheader.WAVEHeader := 'WAVE'; { Must be "WAVE" }
  { Format information }
  Waveheader.FormatHeader := 'fmt '; { Must be "fmt " }
  Waveheader.FormatSize := 16; { Must be 16 (decimal) }
  Waveheader.FormatCode := WAVE_FORMAT_PCM; { Must be 1 }
  Waveheader.ChannelNumber := 2; { Number of channels }
  Waveheader.SampleRate := 44100; { Sample rate (hz) }
  Waveheader.BytesPerSample := MulDiv(Waveheader.ChannelNumber,
    Waveheader.FormatSize, 8); { Bytes per Sample }
  Waveheader.BytesPerSecond := (Waveheader.SampleRate *
    Waveheader.BytesPerSample); { Bytes per second }
  Waveheader.BitsPerSample := Waveheader.FormatSize; { Bits per sample }
  { Data area }
  Waveheader.DataHeader := 'data'; { Must be "data" }
  Waveheader.DataSize := 0; { Data size }
  Result := Waveheader;
end;

function TDeviceReader.RipAudioTrack(TrackNo: Integer; TracksFilename: string):
  boolean;
var
  WaveStream: TFileStream;
  WavDataStream: TMemoryStream;
  Buf: Pointer;
  BufLen: integer;
  IndexBlock, SectorSize: integer;
  LastBlock: integer;
  DataBlocks: Integer;
  WavPath, TrackFilename: string;
  TrackIndex: integer;

begin
  FBytesWritten := 0;
  Result := True;
  SectorSize := ConvertDataBlock(RAW_DATA_BLOCK);
  BufLen := MAX_DATABLOCKS * SectorSize;
  WavPath := extractFilePath(TracksFilename);
  TrackIndex := TrackNo;
  IndexBlock := TOC.Tracks[TrackIndex - 1].AbsAddress;
  LastBlock := TOC.Tracks[TrackIndex].AbsAddress;
  Log(resLastAudioLBA + inttostr(LastBlock));
  WavDataStream := TMemoryStream.Create;
  try
    Log(resMemAlloc);
    Buf := nil;
    ReAllocMem(Buf, BufLen);
    Log(resTrackStreamStart + inttostr(TrackIndex));
    DataBlocks := MAX_DATABLOCKS;

    while IndexBlock < LastBlock do
    begin
      if ((LastBlock - IndexBlock) < DataBlocks) then
      begin
        DataBlocks := (LastBlock - IndexBlock);
        BufLen := DataBlocks * SectorSize;
      end;

      if ReadAudio(IndexBlock, DataBlocks, Buf, BufLen) then
        FBytesWritten := WavDataStream.Write(pchar(Buf)^, BufLen);
          // read audio data
      FsectorWrite := IndexBlock;
      IndexBlock := IndexBlock + DataBlocks;
      if Assigned(FOnCopyStatus) then
        FOnCopyStatus(FsectorWrite, (FsectorWrite div ((LastBlock - 1) div
          100)));
      Forms.Application.ProcessMessages;
    end; // finish ripping all data

    // create PCM wave header
    FWaveHeader := CreateWaveHeader;
    FWaveHeader.FileSize := (WaveHeaderSize + WavDataStream.Size) - 8;
    FWaveHeader.DataSize := WavDataStream.Size;

    // save wave file
    TrackFilename := IncludeTrailingBackslash(WavPath) + 'Track' +
      inttostr(TrackIndex) + '.wav';
    WaveStream := TFileStream.Create(TrackFilename, fmCreate);
    try
      WaveStream.Write(FWaveHeader, sizeof(FWaveHeader));
      if Assigned(FOnCDStatus) then
        FOnCDStatus(resSaveWaveToDisk);
      WavDataStream.SaveToStream(WaveStream); // write header to stream
    finally
      WaveStream.Free;
    end;
  finally
    Log(resMemDeAlloc);
    ReallocMem(Buf, 0);
    Log(resCloseStream);
    WavDataStream.Free;
  end;
  Log(resFinishTrackRip);
end;

function TDeviceReader.RipAllAudioTracks(TracksFilename: string): boolean;
var
  WavPath: string;
  TrackIndex: integer;

begin
  Result := True;
  WavPath := extractFilePath(TracksFilename);
  for TrackIndex := 1 to TOC.TrackCount do
  begin
    if not RipAudioTrack(TrackIndex, WavPath) then
    begin
      Result := False;
      exit;
    end;
  end;
  Log(resFinishCDRip);
end;

end.
