{-----------------------------------------------------------------------------
 Unit Name: AudioImage
 Author:    Paul Fisher / Andrew Semack
 Purpose:   to create a CD image of audio wave files
 History:
-----------------------------------------------------------------------------}

unit AudioImage;

interface

uses
  CustomImage, Windows, Contnrs, SysUtils, Messages, Classes, mmSystem,
    WaveUtils,MP3Convert;

type
  TCDTrack = class(TMemoryStream)      //TMemoryStream
  private
    fDirty: Boolean;
    fValid: Boolean;
    fDataSize: DWORD;
    fDataOffset: DWORD;
    fData: Pointer;
    fWaveFormat: PWaveFormatEx;
    fOnChange: TNotifyEvent;
    FTrackFileName: string;
    FTrackName: string;
    FSectorSize: Integer;
    FSectorCount: Integer;
    function GetValid: Boolean;
    function GetData: Pointer;
    function GetDataSize: DWORD;
    function GetDataOffset: DWORD;
    function GetLength: DWORD;
    function GetBitRate: DWORD;
    function GetPeakLevel: Integer;
    function GetPCMFormat: TPCMFormat;
    function GetWaveFormat: PWaveFormatEx;
    function GetAudioFormat: string;
    procedure SetSectorSize(Sector: Integer);
  protected
    function Realloc(var NewCapacity: Longint): Pointer; override;
    function UpdateDetails: Boolean; virtual;
    function MSecToByte(MSec: DWORD): DWORD;
    procedure DoChange;
    property Dirty: Boolean read fDirty;
    function ConvertTo(const pTargetWaveFormat: PWaveFormatEx): Boolean;    
  public
    constructor Create; virtual;
    destructor Destroy; override;
    function Equals(Track: TCDTrack): Boolean;
    function SameFormat(Track: TCDTrack): Boolean;
    procedure Crop;
    function Invert: Boolean;
    function ChangeVolume(Percent: Integer): Boolean;
    function ConvertToPCM(TargetFormat: TPCMFormat): Boolean;
    function MP3Convert(FromMP3toPCM : Boolean): Boolean;
    function ConvertToMP3(TargetFormat: TPCMFormat): Boolean;
    function ConvertFromMP3(TargetFormat: TPCMFormat): Boolean;
    function Delete(Pos: DWORD; Len: DWORD): Boolean;
    function Insert(Pos: DWORD; Wave: TCDTrack): Boolean;
    function InsertSilence(Pos: DWORD; Len: DWORD): Boolean;
    function Write(const Buffer; Count: Longint): Longint; override;
    property TrackName: string read FTrackName write FTrackName;
    property TrackFileName: string read FTrackFileName write FTrackFileName;
    property Valid: Boolean read GetValid;
    property Data: Pointer read GetData;
    property DataSize: DWORD read GetDataSize;
    property DataOffset: DWORD read GetDataOffset;
    property PCMFormat: TPCMFormat read GetPCMFormat;
    property WaveFormat: PWaveFormatEx read GetWaveFormat;
    property AudioFormat: string read GetAudioFormat;
    property Length: DWORD read GetLength; // in milliseconds
    property BitRate: DWORD read GetBitRate; // in kbps
    property PeakLevel: Integer read GetPeakLevel; // in percent
    property OnChange: TNotifyEvent read fOnChange write fOnChange;
    property SectorCount: integer read FSectorCount;
    property SectorSize: integer write SetSectorSize;
  end;

  // TTrack item
  TCDTrackItem = class
  private
    FName: string;
    FCDTrack: TCDTrack;
    FTag: Integer;
    FWavFileName : String;
    FSongTitle : String;     //TITLE "How Precious"
    FPreGap : Integer;
    FPostGap : Integer;
    FTrackIndex : Integer;
    //procedure ReadData(Stream: TStream);
    //procedure WriteData(Stream: TStream);
  protected
    function GetDisplayName: string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadWaveFile(Filename: string);
    procedure SaveWaveFile(Filename: string);
  published
    property WavFileName : String read FWavFileName write FWavFileName;
    property CDTrack: TCDTrack read FCDTrack write FCDTrack;
    property Name: string read fName write fName;
    property DisplayName: string read GetDisplayName;
    property SongTitle : String read FSongTitle write FSongTitle;
    //cue file stuff
    property TrackIndex : Integer read FTrackIndex write FTrackIndex default 0;
    property PreGap : Integer read FPreGap write FPreGap default 0;
    property PostGap : Integer read FPostGap write FPostGap default 0;
    property Tag: Integer read fTag write fTag default 0;
  end;

  PCDTrackItem = ^TCDTrackItem;


type
  TAudioImage = class(TCustomImage)
  private
    FTrackList: TClassList;
    FLastError: string;
    FCUESheet : TStringlist;
    FPerformer : String;
    FSongwriter : String;
    function GetItem(Index: Integer): TCDTrackItem;
    procedure SetItem(Index: Integer; Value: TCDTrackItem);
  protected
    procedure EmptyTrackList;
    procedure CreateCUEFile(TrackID : Integer);
    function GetCUESheet : TStringlist;
  public
    constructor Create;
    destructor Destroy; override;
    function GetLastError: string;
    function Add: TCDTrackItem;
    function Insert(Index: Integer): TCDTrackItem;
    function TrackCount: Integer;
    procedure ClearAllTracks;
    property CUESheet : TStringlist read GetCUESheet;
    property Performer : String read FPerformer write FPerformer;
    property Songwriter : String read FSongwriter write FSongwriter;
    property Tracks[Index: Integer]: TCDTrackItem read GetItem write SetItem;
      default;
  end;

implementation

uses covertfuncs;


{ TCDTrack }

constructor TCDTrack.Create;
begin
  inherited Create;
  fDirty := False;
  fWaveFormat := nil;
end;

destructor TCDTrack.Destroy;
begin
  if Assigned(fWaveFormat) then
    FreeMem(fWaveFormat);
  inherited Destroy;
end;

procedure TCDTrack.SetSectorSize(Sector: Integer);
var
  DataSize: Integer;
begin
  FSectorSize := Sector;
  DataSize := GetDataSize;
  if (DataSize mod FSectorSize) > 0 then
    FSectorCount := (DataSize div FSectorSize) + 1
  else // bigger so add on a full sector!
    FSectorCount := (DataSize div FSectorSize);
end;

function TCDTrack.Realloc(var NewCapacity: Integer): Pointer;
begin
  Result := inherited Realloc(NewCapacity);
  if not Dirty then
    DoChange;
end;

function TCDTrack.Write(const Buffer; Count: Integer): Longint;
begin
  Result := inherited Write(Buffer, Count);
  if not Dirty then
    DoChange;
end;

procedure TCDTrack.DoChange;
begin
  fDirty := True;
  if Assigned(fOnChange) then
    fOnChange(Self);
end;

function TCDTrack.MSecToByte(MSec: DWORD): DWORD;
begin
  with fWaveFormat^ do
    Result := MulDiv(nAvgBytesPerSec, MSec, 1000)
      and ($FFFFFFFF shl (nChannels * wBitsPerSample div 16));
end;

function TCDTrack.UpdateDetails: Boolean;
begin
  if fDirty then
  begin
    fValid := False;
    fDirty := False;
    if Assigned(fWaveFormat) then
    begin
      FreeMem(fWaveFormat);
      fWaveFormat := nil;
    end;
    if GetStreamWaveAudioInfo(Self, fWaveFormat, fDataSize, fDataOffset) then
    begin
      fData := Pointer(DWORD(Memory) + fDataOffset);
      fValid := True;
    end;
  end;
  Result := fValid;
end;

function TCDTrack.GetAudioFormat: string;
begin
  if UpdateDetails then
    Result := GetWaveAudioFormat(fWaveFormat)
  else
    Result := '';
end;

function TCDTrack.GetBitRate: DWORD;
begin
  if UpdateDetails then
    Result := GetWaveAudioBitRate(fWaveFormat)
  else
    Result := 0;
end;

function TCDTrack.GetPeakLevel: Integer;
begin
  if PCMFormat <> nonePCM then
    Result := GetWaveAudioPeakLevel(fData, fDataSize, fWaveFormat.wBitsPerSample)
  else
    Result := -1;
end;

function TCDTrack.GetLength: DWORD;
begin
  if UpdateDetails then
    Result := GetWaveAudioLength(fWaveFormat, fDataSize)
  else
    Result := 0;
end;

function TCDTrack.GetData: Pointer;
begin
  if UpdateDetails then
    Result := fData
  else
    Result := nil;
end;

function TCDTrack.GetDataSize: DWORD;
begin
  if UpdateDetails then
    Result := fDataSize
  else
    Result := 0;
end;

function TCDTrack.GetDataOffset: DWORD;
begin
  if UpdateDetails then
    Result := fDataOffset
  else
    Result := 0;
end;

function TCDTrack.GetValid: Boolean;
begin
  Result := UpdateDetails;
end;

function TCDTrack.GetPCMFormat: TPCMFormat;
begin
  if UpdateDetails then
    Result := GetPCMAudioFormat(fWaveFormat)
  else
    Result := nonePCM;
end;

function TCDTrack.GetWaveFormat: PWaveFormatEx;
begin
  if UpdateDetails then
    Result := fWaveFormat
  else
    Result := nil;
end;

function TCDTrack.Equals(Track: TCDTrack): Boolean;
begin
  if Valid = Track.Valid then
    if fValid and Track.fValid then
      Result :=
        (fDataSize = Track.fDataSize) and
        (fWaveFormat^.cbSize = Track.fWaveFormat^.cbSize) and
        CompareMem(fWaveFormat, Track.fWaveFormat,
        SizeOf(TWaveFormatEx) + fWaveFormat^.cbSize) and
        CompareMem(fData, Track.fData, fDataSize)
    else
      Result :=
        (Size = Track.Size) and
        CompareMem(Memory, Track.Memory, Size)
  else
    Result := False;
end;

function TCDTrack.SameFormat(Track: TCDTrack): Boolean;
begin
  if Valid and Track.Valid then
    Result :=
      (fWaveFormat^.cbSize = Track.fWaveFormat^.cbSize) and
      CompareMem(fWaveFormat, Track.fWaveFormat,
      SizeOf(TWaveFormatEx) + fWaveFormat^.cbSize)
  else
    Result := False;
end;

procedure TCDTrack.Crop;
begin
  Size := DataOffset + DataSize;
end;

function TCDTrack.Invert: Boolean;
begin
  Result := False;
  if PCMFormat <> nonePCM then
  begin
    InvertWaveAudio(fData, fDataSize, fWaveFormat.wBitsPerSample);
    Result := True;
  end;
end;

function TCDTrack.ChangeVolume(Percent: Integer): Boolean;
begin
  Result := False;
  if PCMFormat <> nonePCM then
  begin
    ChangeWaveAudioVolume(fData, fDataSize, fWaveFormat.wBitsPerSample,
      Percent);
    Result := True;
  end;
end;

function TCDTrack.ConvertTo(const pTargetWaveFormat: PWaveFormatEx): Boolean;
var
  NewData: Pointer;
  NewDataSize: DWORD;
  ckInfo, ckData: TMMCKInfo;
  mmIO: HMMIO;
begin
  Result := False;
  if Valid then
  begin
    if (fWaveFormat.cbSize <> pTargetWaveFormat^.cbSize) or
      not CompareMem(fWaveFormat, pTargetWaveFormat, SizeOf(TWaveFormatEx) +
        fWaveFormat.cbSize) then
    begin
      if ConvertWaveFormat(fWaveFormat, fData, fDataSize, pTargetWaveFormat,
        NewData, NewDataSize) then
      try
        mmIO := CreateStreamWaveAudio(Self, pTargetWaveFormat, ckInfo, ckData);
        try
          mmioWrite(mmIO, NewData, NewDataSize);
        finally
          CloseWaveAudio(mmio, ckInfo, ckData);
        end;
        Result := True;
      finally
        ReallocMem(NewData, 0);
      end;
    end
    else
      Result := True;
  end;
end;

function TCDTrack.ConvertToPCM(TargetFormat: TPCMFormat): Boolean;
var
  NewWaveFormat: TWaveFormatEx;
begin
  Result := False;
  if TargetFormat <> nonePCM then
  begin
    SetPCMAudioFormatS(@NewWaveFormat, TargetFormat);
    Result := ConvertTo(@NewWaveFormat);
  end;
end;



function TCDTrack.MP3Convert(FromMP3toPCM : Boolean): Boolean;
var
  NewData: Pointer;
  NewDataSize: DWORD;
  Converter : TMP3Convertor;
  HasConverted : Boolean;
begin
  Result := False;
  UpdateDetails;
  NewDataSize := 0;
  Converter := TMP3Convertor.Create(nil);
  try
  if FromMP3toPCM = False then
     HasConverted := Converter.ConvertToMP3Format(self.Memory,fDataSize,NewData,NewDataSize)
      else
      HasConverted := Converter.ConvertFromMP3Format(self.Memory,fDataSize,NewData,NewDataSize);
        try
          if HasConverted = True then
          begin
            self.Clear;
            self.Seek(soFromBeginning,0);
            self.Write(Newdata^,NewDataSize);
            Result := True;
          end;
        finally
          ReallocMem(NewData, 0);
        end;
   finally
    Converter.Free;
   end;
end;



function TCDTrack.ConvertToMP3(TargetFormat: TPCMFormat): Boolean;
var
  NewWaveFormat: TWaveFormatEx;
begin
  Result := False;
  if TargetFormat <> nonePCM then
  begin
    SetPCMAudioFormatS(@NewWaveFormat, TargetFormat);
    Result := MP3Convert(False);
  end;
end;


function TCDTrack.ConvertFromMP3(TargetFormat: TPCMFormat): Boolean;
var
  NewWaveFormat: TWaveFormatEx;
begin
  Result := False;
  if TargetFormat <> nonePCM then
  begin
    SetPCMAudioFormatS(@NewWaveFormat, TargetFormat);
    Result := MP3Convert(True);
  end;
end;




function TCDTrack.Delete(Pos, Len: DWORD): Boolean;
var
  Index: DWORD;
  NewWave: TCDTrack;
  ckInfo, ckData: TMMCKInfo;
  mmIO: HMMIO;
begin
  Result := False;
  if Valid and (Len > 0) and (Pos < Length) then
  begin
    NewWave := TCDTrack.Create;
    try
      mmIO := CreateStreamWaveAudio(NewWave, fWaveFormat, ckInfo, ckData);
      try
        Index := MSecToByte(Pos);
        if Index > fDataSize then
          Index := fDataSize;
        if Index > 0 then
          mmioWrite(mmIO, fData, Index);
        Inc(Index, MSecToByte(Len));
        if Index < fDataSize then
          mmioWrite(mmIO, Pointer(DWORD(fData) + Index), fDataSize - Index);
      finally
        CloseWaveAudio(mmio, ckInfo, ckData);
      end;
      LoadFromStream(NewWave);
      Result := True;
    finally
      NewWave.Free;
    end;
  end;
end;

function TCDTrack.Insert(Pos: DWORD; Wave: TCDTrack): Boolean;
var
  Index: DWORD;
  NewWave: TCDTrack;
  ckInfo, ckData: TMMCKInfo;
  mmIO: HMMIO;
begin
  Result := False;
  if SameFormat(Wave) then
  begin
    NewWave := TCDTrack.Create;
    try
      mmIO := CreateStreamWaveAudio(NewWave, fWaveFormat, ckInfo, ckData);
      try
        Index := MSecToByte(Pos);
        if Index > fDataSize then
          Index := fDataSize;
        if Index > 0 then
          mmioWrite(mmIO, fData, Index);
        mmioWrite(mmIO, Wave.fData, Wave.fDataSize);
        if Index < fDataSize then
          mmioWrite(mmIO, Pointer(DWORD(fData) + Index), fDataSize - Index);
      finally
        CloseWaveAudio(mmio, ckInfo, ckData);
      end;
      LoadFromStream(NewWave);
      Result := True;
    finally
      NewWave.Free;
    end;
  end;
end;

function TCDTrack.InsertSilence(Pos, Len: DWORD): Boolean;
var
  Index: DWORD;
  SilenceBytes: DWORD;
  Silence: Byte;
  NewWave: TCDTrack;
  ckInfo, ckData: TMMCKInfo;
  mmIO: HMMIO;
begin
  Result := False;
  if (PCMFormat <> nonePCM) and (Len > 0) then
  begin
    NewWave := TCDTrack.Create;
    try
      mmIO := CreateStreamWaveAudio(NewWave, fWaveFormat, ckInfo, ckData);
      try
        Index := MSecToByte(Pos);
        if Index > fDataSize then
          Index := fDataSize;
        if Index > 0 then
          mmioWrite(mmIO, fData, Index);
        if fWaveFormat.wBitsPerSample = 8 then
          Silence := 128
        else
          Silence := 0;
        SilenceBytes := MSecToByte(Len);
        while SilenceBytes > 0 do
        begin
          mmioWrite(mmIO, PChar(@Silence), 1);
          Dec(SilenceBytes);
        end;
        if Index < fDataSize then
          mmioWrite(mmIO, Pointer(DWORD(fData) + Index), fDataSize - Index);
      finally
        CloseWaveAudio(mmio, ckInfo, ckData);
      end;
      LoadFromStream(NewWave);
      Result := True;
    finally
      NewWave.Free;
    end;
  end;
end;

// CDTracks

constructor TCDTrackItem.Create;
begin
  inherited Create;
  FCDTrack := TCDTrack.Create;
end;

destructor TCDTrackItem.Destroy;
begin
  FCDTrack.Free;
  inherited Destroy;
end;

procedure TCDTrackItem.LoadWaveFile(Filename: string);
begin
  if FileExists(Filename) then
  begin
    CDTrack.LoadFromFile(Filename);
    CDTrack.TrackFileName := Filename;
    CDTrack.TrackName := ExtractFileName(Filename);
    SongTitle := CDTrack.TrackName;
    WavFileName := Filename;
    CDTrack.UpdateDetails;
  end
  else
    CDTrack.Clear;
end;

procedure TCDTrackItem.SaveWaveFile(Filename: string);
begin
  CDTrack.SaveToFile(Filename);
  CDTrack.TrackFileName := Filename;
  CDTrack.TrackName := ExtractFileName(Filename);
end;

{procedure TCDTrackItem.ReadData(Stream: TStream);
begin
   CDTrack.LoadFromStream(Stream);
end;

procedure TCDTrackItem.WriteData(Stream: TStream);
begin
   CDTrack.SaveToStream(Stream);
end;
}

function TCDTrackItem.GetDisplayName: string;
var
  WaveInfo: string;
begin
  if (CDTrack <> nil) and (CDTrack.Size <> 0) then
  begin
    if CDTrack.Valid then
      WaveInfo := CDTrack.AudioFormat + ', ' +
        IntToStr(CDTrack.BitRate) + ' kbps, ' +
        MS2Str(CDTrack.Length, msAh) + ' sec.'
    else
      WaveInfo := 'Invalid Content';
  end
  else
    WaveInfo := 'Empty Wave File';
  Result := Name + ' (' + WaveInfo + ')';
end;

{ TAudioImage }

constructor TAudioImage.Create;
begin
  inherited Create;
  FTrackList := TClassList.Create;
  FCUESheet := TStringList.Create;
  ImageType := ITAudioImage;
end;

destructor TAudioImage.Destroy;
begin
  EmptyTrackList;
  FCUESheet.Free;
  FTrackList.Free;
  inherited Destroy;
end;



procedure TAudioImage.EmptyTrackList;
var
  Index: Integer;
begin
  try
    for Index := 0 to (FTrackList.Count - 1) do
      TCDTrackItem(FTrackList.Items[Index]).Destroy;
  finally
    FTrackList.Clear;
  end;
end;

procedure TAudioImage.ClearAllTracks;
begin
  EmptyTrackList;
end;

function TAudioImage.GetLastError: string;
begin
  Result := FLastError;
end;

function TAudioImage.TrackCount: Integer;
begin
  Result := FTrackList.Count;
end;

function TAudioImage.Add: TCDTrackItem;
var
  NewTrackItem: TCDTrackItem;
begin
  Result := nil;
  try
    NewTrackItem := TCDTrackItem.Create;
    FTrackList.Add(TClass(NewTrackItem));
    Result := NewTrackItem;
  except
    on e: exception do
      FLastError := e.Message;
  end;
end;

function TAudioImage.Insert(Index: Integer): TCDTrackItem;
var
  Track: TCDTrackItem;
begin
  Result := nil;
  try
    if Index <= (FTrackList.Count - 1) then
    begin
      Track := TCDTrackItem.Create;
      FTrackList.Insert(Index, TClass(Track));
      Result := Track;
    end
    else
      FLastError := 'Insert Index Too Large!';
  except
    on e: exception do
      FLastError := e.Message;
  end;
end;

function TAudioImage.GetItem(Index: Integer): TCDTrackItem;
var
  Track: TCDTrackItem;
begin
  Result := nil;
  try
    if Index <= (FTrackList.Count - 1) then
    begin
      Track := TCDTrackItem(FTrackList.Items[Index]);
      result := Track;
    end
    else
      FLastError := 'Item Index Too Large!';
  except
    on e: exception do
      FLastError := e.Message
  end;
end;

procedure TAudioImage.SetItem(Index: Integer; Value: TCDTrackItem);
var
  Track: TCDTrackItem;
begin
  if Index <= (FTrackList.Count - 1) then
  begin
    try // remove the track
      Track := TCDTrackItem(FTrackList.Items[Index]);
      Track.Destroy;
    except
      on e: exception do
        FLastError := e.Message
    end;

    try
      FTrackList.Insert(Index, TClass(Value));
    except
      on e: exception do
        FLastError := e.Message;
    end;
  end
  else
    FLastError := 'Item Index Too Large!';
end;




procedure TAudioImage.CreateCUEFile(TrackID : Integer);
var
  Gap: integer;
  k : string;
begin
  FCUESheet.Add(' TITLE "'+Tracks[trackid].SongTitle+'"');
  FCUESheet.Add(' PERFORMER "'+Performer+'"');
  FCUESheet.Add(' SONGWRITER "'+Songwriter+'"');
  FCUESheet.Add('');
  FCUESheet.Add('FILE "' + Tracks[trackid].CDTrack.TrackFileName + '" WAVE');
  k := Format('%02.02d', [TrackID + 1]);
  FCUESheet.Add('  TRACK ' + k + ' AUDIO');
  Gap := Tracks[trackid].PreGap;
  if (TrackID <> 0) then
      FCUESheet.Add('    PREGAP ' + LBA2HMSF(Gap));
  Gap := Tracks[trackid].TrackIndex;
  FCUESheet.Add('    INDEX 01 ' + LBA2HMSF(Gap));
  Gap := Tracks[trackid].PostGap;
  FCUESheet.Add('    POSTGAP ' + LBA2HMSF(Gap));
end;




function TAudioImage.GetCUESheet : TStringlist;
var
   Index : Integer;
begin
  FCUESheet.Clear;
  For Index := 0 to Self.TrackCount -1 do
   CreateCUEFile(Index);
  FCUESheet.SaveToFile('C:\BurnCUE.cue');
  Result := FCUESheet;
end;



end.
