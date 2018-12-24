{-----------------------------------------------------------------------------
 Unit Name: AudioACM
 Author:    Dancemammal
 Purpose:   Wave Utils and conversion functions
 History:   First release
-----------------------------------------------------------------------------}


unit AudioACM;

interface

uses
  Windows, Messages, Classes, SysUtils, mmSystem;



const
// addons for extra codecs
  WAVE_FORMAT_MSG723 = 66;
  WAVE_FORMAT_MPEGLAYER3 = 85;
  MPEGLAYER3_WFX_EXTRA_BYTES = 12;

  MPEGLAYER3_ID_UNKNOWN = 0;
  MPEGLAYER3_ID_MPEG = 1;
  MPEGLAYER3_ID_CONSTANTFRAMESIZE = 2;

  MPEGLAYER3_FLAG_PADDING_ISO = $00000000;
  MPEGLAYER3_FLAG_PADDING_ON = $00000001;
  MPEGLAYER3_FLAG_PADDING_OFF = $00000002;

type

  // Milliseconds to string format specifiers
  TMS2StrFormat = (
    msHMSh, // Hour:Minute:Second.Hunderdth
    msHMS,  // Hour:Minute:Second
    msMSh,  // Minute:Second.Hunderdth
    msMS,   // Minute:Second
    msSh,   // Second.Hunderdth
    msS,    // Second
    msAh,   // Best format with hunderdth of second
    msA);   // Best format without hunderdth of second

  // Standard PCM Audio Format
  TPCMChannel = (cMono, cStereo);
  TPCMSamplesPerSec = (ss8000Hz, ss11025Hz, ss22050Hz, ss44100Hz, ss48000Hz);
  TPCMBitsPerSample = (bs8Bit, bs16Bit);

  TPCMFormat = (nonePCM, Mono8Bit8000Hz, Stereo8bit8000Hz, Mono16bit8000Hz,
    Stereo16bit8000Hz, Mono8bit11025Hz, Stereo8bit11025Hz, Mono16bit11025Hz,
    Stereo16bit11025Hz, Mono8bit22050Hz, Stereo8bit22050Hz, Mono16bit22050Hz,
    Stereo16bit22050Hz, Mono8bit44100Hz, Stereo8bit44100Hz, Mono16bit44100Hz,
    Stereo16bit44100Hz, Mono8bit48000Hz, Stereo8bit48000Hz, Mono16bit48000Hz,
    Stereo16bit48000Hz);

 // TMP3Bitrates = (96kBits,112kBits,128kBits,160kBits,192kBits,224kBits,256kBits,320kBits)


  // Wave Device Supported PCM Formats
  TWaveDeviceFormats = set of TPCMFormat;

  // Wave Out Device Supported Features
  TWaveOutDeviceSupport = (dsVolume, dsStereoVolume, dsPitch, dsPlaybackRate, dsPosition, dsAsynchronize, dsDirectSound);
  TWaveOutDeviceSupports = set of TWaveOutDeviceSupport;

  // Wave Out Options
  TWaveOutOption = (woSetVolume, woSetPitch, woSetPlaybackRate);
  TWaveOutOptions = set of TWaveOutOption;

  // Wave Audio Exceptions
  EWaveAudioError = class(Exception);
  EWaveAudioSysError = class(EWaveAudioError);
  EWaveAudioInvalidOperation = class(EWaveAudioError);



function GetWaveAudioInfo(mmIO: HMMIO; out pWaveFormat: PWaveFormatEx;
  out DataSize, DataOffset: DWORD): Boolean;

function CreateWaveAudio(mmIO: HMMIO; const pWaveFormat: PWaveFormatEx;
  out ckRIFF, ckData: TMMCKInfo): Boolean;

procedure CloseWaveAudio(mmIO: HMMIO; var ckRIFF, ckData: TMMCKInfo);

function GetStreamWaveAudioInfo(Stream: TStream; out pWaveFormat: PWaveFormatEx;
  out DataSize, DataOffset: DWORD): Boolean;

function CreateStreamWaveAudio(Stream: TStream; const pWaveFormat: PWaveFormatEx;
  out ckRIFF, ckData: TMMCKInfo): HMMIO;

function OpenStreamWaveAudio(Stream: TStream): HMMIO;

function CalcWaveBufferSize(const pWaveFormat: PWaveFormatEx; Duration: DWORD): DWORD;

function GetWaveAudioFormat(const pWaveFormat: PWaveFormatEx): String;

function GetWaveAudioLength(const pWaveFormat: PWaveFormatEx; DataSize: DWORD): DWORD;

function GetWaveAudioBitRate(const pWaveFormat: PWaveFormatEx): DWORD;

function GetWaveAudioPeakLevel(const Data: Pointer; DataSize: DWORD;
  BitsPerSample: WORD): Integer;

procedure InvertWaveAudio(const Data: Pointer; DataSize: DWORD;
  BitsPerSample: WORD);

procedure SilenceWaveAudio(const Data: Pointer; DataSize: DWORD;
  BitsPerSample: WORD);

procedure ChangeWaveAudioVolume(const Data: Pointer; DataSize: DWORD;
  BitsPerSample: WORD; Percent: Integer);

function ConvertWaveFormat(const srcFormat: PWaveFormatEx; srcData: Pointer; srcDataSize: DWORD;
  const dstFormat: PWaveFormatEx; out dstData: Pointer; out dstDataSize: DWORD): Boolean;

procedure SetPCMAudioFormat(const pWaveFormat: PWaveFormatEx; Channels: TPCMChannel;
  SamplesPerSec: TPCMSamplesPerSec; BitsPerSample: TPCMBitsPerSample);

procedure SetPCMAudioFormatS(const pWaveFormat: PWaveFormatEx; PCMFormat: TPCMFormat);

function GetPCMAudioFormat(const pWaveFormat: PWaveFormatEx): TPCMFormat;

procedure SetMP3AudioFormatS(const pWaveFormat: PWaveFormatEx; PCMFormat: TPCMFormat);

function GetMP3AudioFormat(const pWaveFormat: PWaveFormatEx): TPCMFormat;

function MS2Str(Milliseconds: DWORD; Fmt: TMS2StrFormat): String;

function WaitForSyncObject(SyncObject: THandle; Timeout: DWORD): DWORD;

function mmioStreamProc(lpmmIOInfo: PMMIOInfo; uMsg, lParam1, lParam2: DWORD): LRESULT; stdcall;






implementation

const
  // acmStreamConvert flags
  ACM_STREAMCONVERTF_BLOCKALIGN = $00000004;
  ACM_STREAMCONVERTF_START      = $00000010;
  ACM_STREAMCONVERTF_END        = $00000020;

  // acmStreamOpen flags
  ACM_STREAMOPENF_QUERY         = $00000001;
  ACM_STREAMOPENF_ASYNC         = $00000002;
  ACM_STREAMOPENF_NONREALTIME   = $00000004;

  // acmStreamSize flags
  ACM_STREAMSIZEF_SOURCE        = $00000000;
  ACM_STREAMSIZEF_DESTINATION   = $00000001;

type
  // ACM Driver Handle
  HACMDRIVER = DWORD;

  // ACM Stream Handle
  HACMSTREAM = DWORD;

  // ACM Stream Header
  PACMSTREAMHEADER = ^TACMSTREAMHEADER;
  TACMSTREAMHEADER = packed record
    cbStruct: DWORD;
    fdwStatus: DWORD;
    dwUser: DWORD;
    pbSrc: PBYTE;
    cbSrcLength: DWORD;
    cbSrcLengthUsed: DWORD;
    dwSrcUser: DWORD;
    pbDst: PBYTE;
    cbDstLength: DWORD;
    cbDstLengthUsed: DWORD;
    dwDstUser: DWORD;
    dwReservedDriver: array[0..9] of DWORD;
  end;

  // ACM Wave Filter
  PWAVEFILTER = ^TWAVEFILTER;
  TWAVEFILTER = packed record
    cbStruct: DWORD;
    dwFilterTag: DWORD;
    fdwFilter: DWORD;
    dwReserved: array[0..4] of DWORD;
  end;

function acmStreamOpen(var phas: HACMSTREAM; had: HACMDRIVER;
  pwfxSrc: PWAVEFORMATEX; pwfxDst: PWAVEFORMATEX; pwfltr: PWAVEFILTER;
  dwCallback: DWORD; dwInstance: DWORD; fdwOpen: DWORD): MMRESULT; stdcall;
  external 'msacm32.dll';

function acmStreamClose(has: HACMSTREAM; fdwClose: DWORD): MMRESULT; stdcall;
  external 'msacm32.dll';

function acmStreamPrepareHeader(has: HACMSTREAM; var pash: TACMSTREAMHEADER;
  fdwPrepare: DWORD): MMRESULT; stdcall;
  external 'msacm32.dll';

function acmStreamUnprepareHeader(has: HACMSTREAM; var pash: TACMSTREAMHEADER;
  fdwUnprepare: DWORD): MMRESULT; stdcall;
  external 'msacm32.dll';

function acmStreamConvert(has: HACMSTREAM; var pash: TACMSTREAMHEADER;
  fdwConvert: DWORD): MMRESULT; stdcall;
  external 'msacm32.dll';

function acmStreamSize(has: HACMSTREAM; cbInput: DWORD;
  var pdwOutputBytes: DWORD; fdwSize: DWORD): MMRESULT; stdcall;
  external 'msacm32.dll';

{ Global Procedures }

// To open a stream using mmIO API functions, use the following code sample:
//
//    FillChar(mmioInfo, SizeOf(mmioInfo), 0);
//    mmioInfo.pIOProc := @mmioStreamProc;
//    mmioInfo.adwInfo[0] := DWORD(your_stream_instance);
//    mmIO := mmioOpen(nil, @mmioInfo, dwOpenFlags);
//
// The flags specified by the dwOpenFlags parameter of mmioOpen function can
// be only one of MMIO_READ, MMIO_WRITE, and MMIO_READWRITE flags. If you use
// another flags, simply they will be ignored by this user defined function.

function mmIOStreamProc(lpmmIOInfo: PMMIOInfo; uMsg, lParam1, lParam2: DWORD): LRESULT; stdcall;
var
  Stream: TStream;
begin
  if Assigned(lpmmIOInfo) and (lpmmIOInfo^.adwInfo[0] <> 0) then
  begin
    Stream := TStream(lpmmIOInfo^.adwInfo[0]);
    case uMsg of
      MMIOM_OPEN:
      begin
        if TObject(lpmmIOInfo^.adwInfo[0]) is TStream then
        begin
          Stream.Seek(0, SEEK_SET);
          lpmmIOInfo^.lDiskOffset := 0;
          Result := MMSYSERR_NOERROR;
        end
        else
          Result := -1;
      end;
      MMIOM_CLOSE:
        Result := MMSYSERR_NOERROR;
      MMIOM_SEEK:
        try
          if lParam2 = SEEK_CUR then
            Stream.Seek(lpmmIOInfo^.lDiskOffset, SEEK_SET);
          Result := Stream.Seek(lParam1, lParam2);
          lpmmIOInfo^.lDiskOffset := Result;
        except
          Result := -1;
        end;
      MMIOM_READ:
        try
          Stream.Seek(lpmmIOInfo^.lDiskOffset, SEEK_SET);
          Result := Stream.Read(Pointer(lParam1)^, lParam2);
          lpmmIOInfo^.lDiskOffset := Stream.Seek(0, SEEK_CUR);
        except
          Result := -1;
        end;
      MMIOM_WRITE,
      MMIOM_WRITEFLUSH:
        try
          Stream.Seek(lpmmIOInfo^.lDiskOffset, SEEK_SET);
          Result := Stream.Write(Pointer(lParam1)^, lParam2);
          lpmmIOInfo^.lDiskOffset := Stream.Seek(0, SEEK_CUR);
        except
          Result := -1;
        end
    else
      Result := MMSYSERR_NOERROR;
    end;
  end
  else
    Result := -1;
end;

// Retrieves format, size, and offset of the wave audio for an open mmIO
// handle. On success when the the function returns true, it is the caller
// responsibility to free the memory allocated for the Wave Format structure.
function GetWaveAudioInfo(mmIO: HMMIO; out pWaveFormat: PWaveFormatEx;
  out DataSize, DataOffset: DWORD): Boolean;

  function GetWaveFormat(const ckRIFF: TMMCKInfo): Boolean;
  var
    ckFormat: TMMCKInfo;
  begin
    Result := False;
    ckFormat.ckid := mmioStringToFOURCC('fmt', 0);
    if (mmioDescend(mmIO, @ckFormat, @ckRIFF, MMIO_FINDCHUNK) = MMSYSERR_NOERROR) and
       (ckFormat.cksize >= SizeOf(TWaveFormat)) then
    begin
      if ckFormat.cksize < SizeOf(TWaveFormatEx) then
      begin
        GetMem(pWaveFormat, SizeOf(TWaveFormatEx));
        FillChar(pWaveFormat^, SizeOf(TWaveFormatEx), 0);
      end
      else
        GetMem(pWaveFormat, ckFormat.cksize);
      Result := (mmioRead(mmIO, PChar(pWaveFormat), ckFormat.cksize) = Integer(ckFormat.cksize));
    end;
  end;

  function GetWaveData(const ckRIFF: TMMCKInfo): Boolean;
  var
    ckData: TMMCKInfo;
  begin
    Result := False;
    ckData.ckid := mmioStringToFOURCC('data', 0);
    if (mmioDescend(mmIO, @ckData, @ckRIFF, MMIO_FINDCHUNK) = MMSYSERR_NOERROR) then
    begin
      DataSize := ckData.cksize;
      DataOffset := ckData.dwDataOffset;
      Result := True;
    end;
  end;

var
  ckRIFF: TMMCKInfo;
  OrgPos: Integer;
begin
  Result := False;
  OrgPos := mmioSeek(mmIO, 0, SEEK_CUR);
  try
    mmioSeek(mmIO, 0, SEEK_SET);
    ckRIFF.fccType := mmioStringToFOURCC('WAVE', 0);
    if (mmioDescend(mmIO, @ckRIFF, nil, MMIO_FINDRIFF) = MMSYSERR_NOERROR) then
    begin
      pWaveFormat := nil;
      if GetWaveFormat(ckRIFF) and GetWaveData(ckRIFF) then
        Result := True
      else if Assigned(pWaveFormat) then
        ReallocMem(pWaveFormat, 0);
    end
  finally
    mmioSeek(mmIO, OrgPos, SEEK_SET);
  end;
end;

// Initializes a new wave RIFF format in an open mmIO handle. The previous
// content of mmIO will be lost.
function CreateWaveAudio(mmIO: HMMIO; const pWaveFormat: PWaveFormatEx;
  out ckRIFF, ckData: TMMCKInfo): Boolean;
var
  ckFormat: TMMCKInfo;
  FormatSize: Integer;
begin
  Result := False;
  FormatSize := SizeOf(TWaveFormatEx) + pWaveFormat^.cbSize;
  mmIOSeek(mmIO, 0, SEEK_SET);
  FillChar(ckRIFF, SizeOf(TMMCKInfo), 0);
  ckRIFF.fccType := mmioStringToFOURCC('WAVE', 0);
  if mmioCreateChunk(mmIO, @ckRIFF, MMIO_CREATERIFF) = MMSYSERR_NOERROR then
  begin
    FillChar(ckFormat, SizeOf(TMMCKInfo), 0);
    ckFormat.ckid := mmioStringToFOURCC('fmt', 0);
    if (mmioCreateChunk(mmIO, @ckFormat, 0) = MMSYSERR_NOERROR) and
       (mmioWrite(mmIO, PChar(pWaveFormat), FormatSize) = FormatSize) and
       (mmioAscend(mmIO, @ckFormat, 0) = MMSYSERR_NOERROR) then
    begin
      FillChar(ckData, SizeOf(TMMCKInfo), 0);
      ckData.ckid := mmioStringToFOURCC('data', 0);
      Result := (mmioCreateChunk(mmIO, @ckData, 0) = MMSYSERR_NOERROR);
    end;
  end;
end;

// Updates the chunks and closes an mmIO handle.
procedure CloseWaveAudio(mmIO: HMMIO; var ckRIFF, ckData: TMMCKInfo);
begin
  mmioAscend(mmIO, @ckData, 0);
  mmioAscend(mmIO, @ckRIFF, 0);
  mmioClose(mmIO, 0);
end;

// Retrieves format, size, and offset of the wave audio for a stream. On
// success when the the function returns true, it is the caller responsibility
// to free the memory allocated for the Wave Format structure.
function GetStreamWaveAudioInfo(Stream: TStream; out pWaveFormat: PWaveFormatEx;
  out DataSize, DataOffset: DWORD): Boolean;
var
  mmIO: HMMIO;
begin
  Result := False;
  if Stream.Size <> 0 then
  begin
    mmIO := OpenStreamWaveAudio(Stream);
    if mmIO <> 0 then
      try
        Result := GetWaveAudioInfo(mmIO, pWaveFormat, DataSize, DataOffset);
      finally
        mmioClose(mmIO, MMIO_FHOPEN);
      end;
  end;
end;

// Initializes wave RIFF format in a stream and returns the mmIO handle.
// After calling this function, the previous content of the stream will be lost.
function CreateStreamWaveAudio(Stream: TStream; const pWaveFormat: PWaveFormatEx;
 out ckRIFF, ckData: TMMCKInfo): HMMIO;
begin
  Result := OpenStreamWaveAudio(Stream);
  if Result <> 0 then
  begin
    Stream.Size := 0;
    if not CreateWaveAudio(Result, pWaveFormat, ckRIFF, ckData) then
    begin
      mmioClose(Result, MMIO_FHOPEN);
      Result := 0;
    end;
  end;
end;

// Opens wave RIFF format in a stream for read and write operations and returns
// the mmIO handle.
function OpenStreamWaveAudio(Stream: TStream): HMMIO;
var
  mmIOInfo: TMMIOINFO;
begin
  FillChar(mmIOInfo, SizeOf(mmIOInfo), 0);
  mmIOInfo.pIOProc := @mmIOStreamProc;
  mmIOInfo.adwInfo[0] := DWORD(Stream);
  Result := mmioOpen(nil, @mmIOInfo, MMIO_READ or MMIO_WRITE);
end;

// Claculates the wave buffer size for the specified duration.
function CalcWaveBufferSize(const pWaveFormat: PWaveFormatEx; Duration: DWORD): DWORD;
var
  Alignment: DWORD;
begin
  Result := MulDiv(Duration, pWaveFormat^.nAvgBytesPerSec, 1000);
  if pWaveFormat^.nBlockAlign <> 0 then
  begin
    Alignment := Result mod pWaveFormat^.nBlockAlign;
    if Alignment <> 0 then Inc(Result, pWaveFormat^.nBlockAlign - Alignment);
  end;
end;

// Returns the string representation of a wave audio format.
function GetWaveAudioFormat(const pWaveFormat: PWaveFormatEx): String;
const
  Channels: array[1..2] of String = ('Mono', 'Stereo');
begin
  with pWaveFormat^ do
  begin
    if nChannels in [1..2] then
      Result := Format('%.3f kHz, %d Bit, %s', [nSamplesPerSec / 1000,
        wBitsPerSample, Channels[nChannels]])
    else
      Result := Format('%.3f kHz, %d Bit, %d Ch', [nSamplesPerSec / 1000,
        wBitsPerSample, nChannels]);
    if wFormatTag = WAVE_FORMAT_PCM then
      Result := 'PCM ' + Result;
  end;
end;

// Returns the wave's length in milliseconds.
function GetWaveAudioLength(const pWaveFormat: PWaveFormatEx; DataSize: DWORD): DWORD;
begin
  with pWaveFormat^ do
    if nAvgBytesPerSec <> 0 then
      Result := MulDiv(1000, DataSize, nAvgBytesPerSec)
    else
      Result := 0;
end;

// Returns the wave's bit rate in kbps (kilo bits per second).
function GetWaveAudioBitRate(const pWaveFormat: PWaveFormatEx): DWORD;
begin
  with pWaveFormat^ do
    Result := MulDiv(nSamplesPerSec, nChannels * wBitsPerSample, 1000);
end;

// Returns the wave data peak level in percent (PCM format only).
function GetWaveAudioPeakLevel(const Data: Pointer; DataSize: DWORD;
  BitsPerSample: WORD): Integer;

  function GetAudioPeakLevel8Bit: Integer;
  var
    pSample: PByte;
    Max: Byte;
  begin
    Max := 0;
    pSample := Data;
    while DataSize > 0 do
    begin
      if pSample^ > Max then
        Max := pSample^;
      Inc(pSample);
      Dec(DataSize);
    end;
    if ByteBool(Max and $80) then
      Max := Max and $7F
    else
      Max := 0;
    Result := (100 * Max) div $7F;
  end;

  function GetAudioPeakLevel16Bit: Integer;
  var
    pSample: PSmallInt;
    Max: SmallInt;
  begin
    Max := 0;
    pSample := Data;
    while DataSize > 0 do
    begin
      if pSample^ > Max then
        Max := pSample^;
      Inc(pSample);
      Dec(DataSize, 2);
    end;
    Result := (100 * Max) div $7FFF;
  end;

begin
  case BitsPerSample of
    8: Result := GetAudioPeakLevel8Bit;
    16: Result := GetAudioPeakLevel16Bit;
  else
    Result := -1;
  end;
end;

// Inverts the wave data (PCM format only).
procedure InvertWaveAudio(const Data: Pointer; DataSize: DWORD;
  BitsPerSample: WORD);

  procedure Invert8Bit;
  var
    pStart, pEnd: PByte;
  begin
    pStart := Data;
    pEnd := PByte(DWORD(pStart) + DataSize - SizeOf(Byte));
    while DWORD(pStart) < DWORD(pEnd) do
    begin
      pStart^ := pStart^ xor pEnd^;
      pEnd^ := pStart^ xor pEnd^;
      pStart^ := pStart^ xor pEnd^;
      Inc(pStart);
      Dec(pEnd);
    end;
  end;

  procedure Invert16Bit;
  var
    pStart, pEnd: PSmallInt;
  begin
    pStart := Data;
    pEnd := PSmallInt(DWORD(pStart) + DataSize - SizeOf(SmallInt));
    while DWORD(pStart) < DWORD(pEnd) do
    begin
      pStart^ := pStart^ xor pEnd^;
      pEnd^ := pStart^ xor pEnd^;
      pStart^ := pStart^ xor pEnd^;
      Inc(pStart);
      Dec(pEnd);
    end;
  end;

begin
  case BitsPerSample of
    8: Invert8Bit;
    16: Invert16Bit;
  end;
end;

// Fills the wave data with silence
procedure SilenceWaveAudio(const Data: Pointer; DataSize: DWORD;
  BitsPerSample: WORD);
begin
  case BitsPerSample of
    8: FillChar(Data^, DataSize, $7F);
    16: FillChar(Data^, DataSize, 0);
  end;
end;

// Increases/Decreases the wave data volume by the specified percentage (PCM format only).
procedure ChangeWaveAudioVolume(const Data: Pointer; DataSize: DWORD;
  BitsPerSample: WORD; Percent: Integer);

  procedure ChangeVolume8Bit;
  var
    pSample: PByte;
    Value: Integer;
  begin
    pSample := Data;
    while DataSize > 0 do
    begin
      Value := pSample^ + (pSample^ * Percent) div 100;
      if Value > High(Byte) then
        Value := High(Byte)
      else if Value < 0 then
        Value := 0;
      pSample^ := Value;
      Inc(pSample);
      Dec(DataSize, SizeOf(Byte));
    end;
  end;

  procedure ChangeVolume16Bit;
  var
    pSample: PSmallInt;
    Value: Integer;
  begin
    pSample := Data;
    while DataSize > 0 do
    begin
      Value := pSample^ + (pSample^ * Percent) div 100;
      if Value > High(SmallInt) then
        Value := High(SmallInt)
      else if Value < -High(SmallInt) then
        Value := -High(SmallInt);
      pSample^ := Value;
      Inc(pSample);
      Dec(DataSize, SizeOf(SmallInt));
    end;
  end;

begin
  case BitsPerSample of
    8: ChangeVolume8Bit;
    16: ChangeVolume16Bit;
  end;
end;

// Converts the wave data to the specified format. The caller is responsible to
// release the memory allocated for the converted wave data buffer.

function ConvertWaveFormat(const srcFormat: PWaveFormatEx; srcData: Pointer; srcDataSize: DWORD;
  const dstFormat: PWaveFormatEx; out dstData: Pointer; out dstDataSize: DWORD): Boolean;
var
  hStream: HACMSTREAM;
  Header: TACMSTREAMHEADER;
begin
  Result := False;
  if acmStreamOpen(hStream, 0, srcFormat, dstFormat, nil, 0, 0, ACM_STREAMOPENF_NONREALTIME) = 0 then
  begin
    try
      if acmStreamSize(hStream, srcDataSize, dstDataSize, ACM_STREAMSIZEF_SOURCE) = 0 then
      begin
        dstData := nil;
        FillChar(Header, SizeOf(Header), 0);
        ReallocMem(dstData, dstDataSize);
        try
          Header.cbStruct := SizeOf(Header);
          Header.pbSrc := srcData;
          Header.cbSrcLength := srcDataSize;
          Header.pbDst := dstData;
          Header.cbDstLength := dstDataSize;
          if acmStreamPrepareHeader(hStream, Header, 0) = 0 then
            try
              Result := (acmStreamConvert(hStream, Header, ACM_STREAMCONVERTF_START or ACM_STREAMCONVERTF_END) = 0);
            finally
              acmStreamUnprepareHeader(hStream, Header, 0);
            end;
        finally
          ReallocMem(dstData, Header.cbDstLengthUsed);
          dstDataSize := Header.cbDstLengthUsed;
        end;
      end;
    finally
      acmStreamClose(hStream, 0);
    end;
  end;
end;





// Initializes a standard MP3 wave format header. The size of memory referenced
// by the pWaveFormat parameter must not be less than the size of TWaveFormatEx
// record.
procedure SetMP3AudioFormat(const pWaveFormat: PWaveFormatEx;
  Channels: TPCMChannel; SamplesPerSec: TPCMSamplesPerSec;
  BitsPerSample: TPCMBitsPerSample);
begin
{
        .nChannels = wfxIN.nChannels
        .nSamplesPerSec = wfxIN.nSamplesPerSec
        .wFormatTag = WAVE_FORMAT_MPEGLAYER3}
  with pWaveFormat^ do
  begin
    wFormatTag := WAVE_FORMAT_MPEGLAYER3;
    case Channels of
      cMono: nChannels := 1;
      cStereo: nChannels := 2;
    end;
    case SamplesPerSec of
      ss8000Hz: nSamplesPerSec := 8000;
      ss11025Hz: nSamplesPerSec := 11025;
      ss22050Hz: nSamplesPerSec := 22050;
      ss44100Hz: nSamplesPerSec := 44100;
      ss48000Hz: nSamplesPerSec := 48000;
    end;
 {   case BitsPerSample of
      bs8Bit: wBitsPerSample := 8;
      bs16Bit: wBitsPerSample := 16;
    end;
    nBlockAlign := MulDiv(nChannels, wBitsPerSample, 8);
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize := 0; }
  end;
end;



// Initializes a standard MP3 wave format header (shorcut form). The size of
// memory referenced by the pWaveFormat parameter must not be less than the
// size of TWaveFormatEx record.
procedure SetMP3AudioFormatS(const pWaveFormat: PWaveFormatEx; PCMFormat: TPCMFormat);
begin
  case PCMFormat of
    Mono8Bit8000Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss8000Hz, bs8Bit);
    Mono8Bit11025Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss11025Hz, bs8Bit);
    Mono8Bit22050Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss22050Hz, bs8Bit);
    Mono8Bit44100Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss44100Hz, bs8Bit);
    Mono8Bit48000Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss48000Hz, bs8Bit);
    Mono16Bit8000Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss8000Hz, bs16Bit);
    Mono16Bit11025Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss11025Hz, bs16Bit);
    Mono16Bit22050Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss22050Hz, bs16Bit);
    Mono16Bit44100Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss44100Hz, bs16Bit);
    Mono16Bit48000Hz:
      SetMP3AudioFormat(pWaveFormat, cMono, ss48000Hz, bs16Bit);
    Stereo8bit8000Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss8000Hz, bs8Bit);
    Stereo8bit11025Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss11025Hz, bs8Bit);
    Stereo8bit22050Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss22050Hz, bs8Bit);
    Stereo8bit44100Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss44100Hz, bs8Bit);
    Stereo8bit48000Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss48000Hz, bs8Bit);
    Stereo16bit8000Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss8000Hz, bs16Bit);
    Stereo16bit11025Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss11025Hz, bs16Bit);
    Stereo16bit22050Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss22050Hz, bs16Bit);
    Stereo16bit44100Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss44100Hz, bs16Bit);
    Stereo16bit48000Hz:
      SetMP3AudioFormat(pWaveFormat, cStereo, ss48000Hz, bs16Bit);
  end;
end;


// Returns the standard MP3 format specifier of a wave format.
function GetMP3AudioFormat(const pWaveFormat: PWaveFormatEx): TPCMFormat;
begin
  Result := nonePCM;
  with pWaveFormat^ do
    if wFormatTag = WAVE_FORMAT_MPEGLAYER3 then
    begin
      if (nChannels = 1) and (nSamplesPerSec = 8000) and (wBitsPerSample = 8) then
        Result := Mono8Bit8000Hz
      else if (nChannels = 2) and (nSamplesPerSec = 8000) and (wBitsPerSample = 8) then
        Result := Stereo8Bit8000Hz
      else if (nChannels = 1) and (nSamplesPerSec = 8000) and (wBitsPerSample = 16) then
        Result := Mono16bit8000Hz
      else if (nChannels = 2) and (nSamplesPerSec = 8000) and (wBitsPerSample = 16) then
        Result := Stereo16Bit8000Hz
      else if (nChannels = 1) and (nSamplesPerSec = 11025) and (wBitsPerSample = 8) then
        Result := Mono8Bit11025Hz
      else if (nChannels = 2) and (nSamplesPerSec = 11025) and (wBitsPerSample = 8) then
        Result := Stereo8Bit11025Hz
      else if (nChannels = 1) and (nSamplesPerSec = 11025) and (wBitsPerSample = 16) then
        Result := Mono16bit11025Hz
      else if (nChannels = 2) and (nSamplesPerSec = 11025) and (wBitsPerSample = 16) then
        Result := Stereo16Bit11025Hz
      else if (nChannels = 1) and (nSamplesPerSec = 22050) and (wBitsPerSample = 8) then
        Result := Mono8Bit22050Hz
      else if (nChannels = 2) and (nSamplesPerSec = 22050) and (wBitsPerSample = 8) then
        Result := Stereo8Bit22050Hz
      else if (nChannels = 1) and (nSamplesPerSec = 22050) and (wBitsPerSample = 16) then
        Result := Mono16bit22050Hz
      else if (nChannels = 2) and (nSamplesPerSec = 22050) and (wBitsPerSample = 16) then
        Result := Stereo16Bit22050Hz
      else if (nChannels = 1) and (nSamplesPerSec = 44100) and (wBitsPerSample = 8) then
        Result := Mono8Bit44100Hz
      else if (nChannels = 2) and (nSamplesPerSec = 44100) and (wBitsPerSample = 8) then
        Result := Stereo8Bit44100Hz
      else if (nChannels = 1) and (nSamplesPerSec = 44100) and (wBitsPerSample = 16) then
        Result := Mono16bit44100Hz
      else if (nChannels = 2) and (nSamplesPerSec = 44100) and (wBitsPerSample = 16) then
        Result := Stereo16Bit44100Hz
      else if (nChannels = 1) and (nSamplesPerSec = 48000) and (wBitsPerSample = 8) then
        Result := Mono8Bit48000Hz
      else if (nChannels = 2) and (nSamplesPerSec = 48000) and (wBitsPerSample = 8) then
        Result := Stereo8Bit48000Hz
      else if (nChannels = 1) and (nSamplesPerSec = 48000) and (wBitsPerSample = 16) then
        Result := Mono16bit48000Hz
      else if (nChannels = 2) and (nSamplesPerSec = 48000) and (wBitsPerSample = 16) then
        Result := Stereo16Bit48000Hz
    end;
end;





// Initializes a standard PCM wave format header. The size of memory referenced
// by the pWaveFormat parameter must not be less than the size of TWaveFormatEx
// record.
procedure SetPCMAudioFormat(const pWaveFormat: PWaveFormatEx;
  Channels: TPCMChannel; SamplesPerSec: TPCMSamplesPerSec;
  BitsPerSample: TPCMBitsPerSample);
begin
  with pWaveFormat^ do
  begin
    wFormatTag := WAVE_FORMAT_PCM;
    case Channels of
      cMono: nChannels := 1;
      cStereo: nChannels := 2;
    end;
    case SamplesPerSec of
      ss8000Hz: nSamplesPerSec := 8000;
      ss11025Hz: nSamplesPerSec := 11025;
      ss22050Hz: nSamplesPerSec := 22050;
      ss44100Hz: nSamplesPerSec := 44100;
      ss48000Hz: nSamplesPerSec := 48000;
    end;
    case BitsPerSample of
      bs8Bit: wBitsPerSample := 8;
      bs16Bit: wBitsPerSample := 16;
    end;
    nBlockAlign := MulDiv(nChannels, wBitsPerSample, 8);
    nAvgBytesPerSec := nSamplesPerSec * nBlockAlign;
    cbSize := 0;
  end;
end;




// Initializes a standard PCM wave format header (shorcut form). The size of
// memory referenced by the pWaveFormat parameter must not be less than the
// size of TWaveFormatEx record.
procedure SetPCMAudioFormatS(const pWaveFormat: PWaveFormatEx; PCMFormat: TPCMFormat);
begin
  case PCMFormat of
    Mono8Bit8000Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss8000Hz, bs8Bit);
    Mono8Bit11025Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss11025Hz, bs8Bit);
    Mono8Bit22050Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss22050Hz, bs8Bit);
    Mono8Bit44100Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss44100Hz, bs8Bit);
    Mono8Bit48000Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss48000Hz, bs8Bit);
    Mono16Bit8000Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss8000Hz, bs16Bit);
    Mono16Bit11025Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss11025Hz, bs16Bit);
    Mono16Bit22050Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss22050Hz, bs16Bit);
    Mono16Bit44100Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss44100Hz, bs16Bit);
    Mono16Bit48000Hz:
      SetPCMAudioFormat(pWaveFormat, cMono, ss48000Hz, bs16Bit);
    Stereo8bit8000Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss8000Hz, bs8Bit);
    Stereo8bit11025Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss11025Hz, bs8Bit);
    Stereo8bit22050Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss22050Hz, bs8Bit);
    Stereo8bit44100Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss44100Hz, bs8Bit);
    Stereo8bit48000Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss48000Hz, bs8Bit);
    Stereo16bit8000Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss8000Hz, bs16Bit);
    Stereo16bit11025Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss11025Hz, bs16Bit);
    Stereo16bit22050Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss22050Hz, bs16Bit);
    Stereo16bit44100Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss44100Hz, bs16Bit);
    Stereo16bit48000Hz:
      SetPCMAudioFormat(pWaveFormat, cStereo, ss48000Hz, bs16Bit);
  end;
end;

// Returns the standard PCM format specifier of a wave format.
function GetPCMAudioFormat(const pWaveFormat: PWaveFormatEx): TPCMFormat;
begin
  Result := nonePCM;
  with pWaveFormat^ do
    if wFormatTag = WAVE_FORMAT_PCM then
    begin
      if (nChannels = 1) and (nSamplesPerSec = 8000) and (wBitsPerSample = 8) then
        Result := Mono8Bit8000Hz
      else if (nChannels = 2) and (nSamplesPerSec = 8000) and (wBitsPerSample = 8) then
        Result := Stereo8Bit8000Hz
      else if (nChannels = 1) and (nSamplesPerSec = 8000) and (wBitsPerSample = 16) then
        Result := Mono16bit8000Hz
      else if (nChannels = 2) and (nSamplesPerSec = 8000) and (wBitsPerSample = 16) then
        Result := Stereo16Bit8000Hz
      else if (nChannels = 1) and (nSamplesPerSec = 11025) and (wBitsPerSample = 8) then
        Result := Mono8Bit11025Hz
      else if (nChannels = 2) and (nSamplesPerSec = 11025) and (wBitsPerSample = 8) then
        Result := Stereo8Bit11025Hz
      else if (nChannels = 1) and (nSamplesPerSec = 11025) and (wBitsPerSample = 16) then
        Result := Mono16bit11025Hz
      else if (nChannels = 2) and (nSamplesPerSec = 11025) and (wBitsPerSample = 16) then
        Result := Stereo16Bit11025Hz
      else if (nChannels = 1) and (nSamplesPerSec = 22050) and (wBitsPerSample = 8) then
        Result := Mono8Bit22050Hz
      else if (nChannels = 2) and (nSamplesPerSec = 22050) and (wBitsPerSample = 8) then
        Result := Stereo8Bit22050Hz
      else if (nChannels = 1) and (nSamplesPerSec = 22050) and (wBitsPerSample = 16) then
        Result := Mono16bit22050Hz
      else if (nChannels = 2) and (nSamplesPerSec = 22050) and (wBitsPerSample = 16) then
        Result := Stereo16Bit22050Hz
      else if (nChannels = 1) and (nSamplesPerSec = 44100) and (wBitsPerSample = 8) then
        Result := Mono8Bit44100Hz
      else if (nChannels = 2) and (nSamplesPerSec = 44100) and (wBitsPerSample = 8) then
        Result := Stereo8Bit44100Hz
      else if (nChannels = 1) and (nSamplesPerSec = 44100) and (wBitsPerSample = 16) then
        Result := Mono16bit44100Hz
      else if (nChannels = 2) and (nSamplesPerSec = 44100) and (wBitsPerSample = 16) then
        Result := Stereo16Bit44100Hz
      else if (nChannels = 1) and (nSamplesPerSec = 48000) and (wBitsPerSample = 8) then
        Result := Mono8Bit48000Hz
      else if (nChannels = 2) and (nSamplesPerSec = 48000) and (wBitsPerSample = 8) then
        Result := Stereo8Bit48000Hz
      else if (nChannels = 1) and (nSamplesPerSec = 48000) and (wBitsPerSample = 16) then
        Result := Mono16bit48000Hz
      else if (nChannels = 2) and (nSamplesPerSec = 48000) and (wBitsPerSample = 16) then
        Result := Stereo16Bit48000Hz
    end;
end;

// Converts milliseconds to string
function MS2Str(Milliseconds: DWORD; Fmt: TMS2StrFormat): String;
var
  HSecs, Secs, Mins, Hours: DWORD;
begin
  HSecs := Milliseconds div 10;
  Secs := HSecs div 100;
  Mins := Secs div 60;
  Hours := Mins div 60;
  if Fmt in [msAh, msA] then
  begin
    if Hours <> 0 then
      if Fmt = msAh then Fmt := msHMSh  else Fmt := msHMS
    else if Mins <> 0 then
      if Fmt = msAh then Fmt := msMSh else Fmt := msMS
    else
      if Fmt = msAh then Fmt := msSh else Fmt := msS
  end;
  case Fmt of
    msHMSh:
      Result := Format('%u%s%2.2u%s%2.2u%s%2.2u',
        [Hours, TimeSeparator, Mins mod 60, TimeSeparator, Secs mod 60, DecimalSeparator, HSecs mod 100]);
    msHMS:
      Result := Format('%u%s%2.2u%s%2.2u',
        [Hours, TimeSeparator, Mins mod 60, TimeSeparator, Secs mod 60]);
    msMSh:
      Result := Format('%u%s%2.2u%s%2.2u',
        [Mins, TimeSeparator, Secs mod 60, DecimalSeparator, HSecs mod 100]);
    msMS:
      Result := Format('%u%s%2.2u',
        [Mins, TimeSeparator, Secs mod 60]);
    msSh:
      Result := Format('%u%s%2.2u',
        [Secs, DecimalSeparator, HSecs mod 100]);
    msS:
      Result := Format('%u', [Secs]);
  else
    Result := IntToStr(Milliseconds);
  end;
end;

// Waits for the scnchronize object while lets the caller thread processes
// its messages.
function WaitForSyncObject(SyncObject: THandle; Timeout: DWORD): DWORD;
const
  EVENTMASK = QS_PAINT or QS_TIMER or QS_SENDMESSAGE or QS_POSTMESSAGE;
var
  Msg: TMsg;
  StartTime: DWORD;
  EllapsedTime: DWORD;
  Handle: THandle;
begin
  Handle := SyncObject;
  if (SyncObject = GetCurrentThread) or (SyncObject = GetCurrentProcess) then
    DuplicateHandle(GetCurrentProcess, SyncObject, GetCurrentProcess, @Handle, SYNCHRONIZE, False, 0);
  try
    repeat
      StartTime := GetTickCount;
      Result := MsgWaitForMultipleObjects(1, Handle, False, Timeout, EVENTMASK);
      if Result = WAIT_OBJECT_0 + 1 then
      begin
        while PeekMessage(Msg, 0, 0, 0, PM_REMOVE) do
        begin
          if ((Msg.message < WM_KEYFIRST) or (Msg.message > WM_KEYLAST)) and
             ((Msg.message < WM_MOUSEFIRST) or (Msg.message > WM_MOUSELAST)) then
          begin
            TranslateMessage(Msg);
            DispatchMessage(Msg);
            if Msg.message = WM_QUIT then Exit;
          end;
        end;
        if Timeout <> INFINITE then
        begin
          EllapsedTime := GetTickCount - StartTime;
          if EllapsedTime < Timeout then
            Dec(Timeout, EllapsedTime)
          else
            Timeout := 0;
        end;
      end;
    until Result <> WAIT_OBJECT_0 + 1;
  finally
    if SyncObject <> Handle then
      CloseHandle(Handle);
  end;
end;


end.
