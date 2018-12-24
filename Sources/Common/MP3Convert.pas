{-----------------------------------------------------------------------------
 Unit Name: MP3Convert
 Author:    paul fisher
 Purpose:  convert from redbook pcm to mp3 and back !
 History:  first release
-----------------------------------------------------------------------------}


unit MP3Convert;

interface

uses
   Classes, Messages, Windows, Forms, SysUtils, Controls, MSACM, MMSystem;

const
// addons for extra codecs
   WAVE_FORMAT_MSG723 = 66;
   WAVE_FORMAT_MPEGLAYER3 = 85;
   MPEGLAYER3_WFX_EXTRA_BYTES = 12;
   MP3_BLOCK_SIZE = 522;


   MPEGLAYER3_ID_UNKNOWN = 0;
   MPEGLAYER3_ID_MPEG = 1;
   MPEGLAYER3_ID_CONSTANTFRAMESIZE = 2;

   MPEGLAYER3_FLAG_PADDING_ISO = $00000000;
   MPEGLAYER3_FLAG_PADDING_ON = $00000001;
   MPEGLAYER3_FLAG_PADDING_OFF = $00000002;



type
   TMpegLayer3WaveFormat = record
      wfx: TWaveFormatEx;
      wID: WORD;
      fdwFlags: DWORD;
      nBlockSize: WORD;
      nFramesPerBlock: WORD;
      nCodecDelay: WORD;
   end;


type
   TMP3Convertor = class
   private
      FStreamHandle: HACMStream;
      FDriverName : String;
   protected
      procedure FindACMDriver(SourceFormat, DestFormat: PWaveFormatEx);
   public
      PCMFormat: TWaveFormatEx;
      MP3Format: TMpegLayer3WaveFormat;

      LastError: string;
      constructor Create(AOwner: TComponent);
      destructor Destroy; override;
      procedure InitialisePCM;
      procedure InitialiseMP3;
      function ConvertToMP3Format(srcData: Pointer; srcDataSize: DWORD;
         out dstData: Pointer; out dstDataSize: DWORD): Boolean;
      function ConvertFromMP3Format(srcData: Pointer; srcDataSize: DWORD;
         out dstData: Pointer; out dstDataSize: DWORD): Boolean;
   published
      Property ACMDriverName : String read FDriverName;
   end;



implementation

var
   TargetWaveFormat : PWaveFormatEx;
   ACMDrvDet : TACMDriverDetails;
   ACMFmtDet : PACMFormatDetails;
   WaveFormatEx : PWaveFormatEx;

   ACMDriver : HACMDRIVERID;
   DriverName : String;



constructor TMP3Convertor.Create(AOwner: TComponent);
begin
   FStreamHandle := 0;
 // red book audio in
   PCMFormat.wFormatTag := WAVE_FORMAT_PCM;
   PCMFormat.nChannels := 2;
   PCMFormat.nSamplesPerSec := 44100;
   PCMFormat.nBlockAlign := 4;
   PCMFormat.wbitspersample := 16;
   // PCMFormat.nAvgBytesPerSec:= PCMFormat.nSamplesPerSec * PCMFormat.nBlockAlign;
   PCMFormat.nAvgBytesPerSec := (((PCMFormat.nSamplesPerSec * PCMFormat.wbitspersample) * PCMFormat.nChannels) div 8);
   PCMFormat.wbitspersample := 16;
   PCMFormat.cbSize := 0;


 // MP3 audio out
   MP3Format.wfx.wFormatTag := WAVE_FORMAT_MPEGLAYER3;
   MP3Format.wfx.nChannels := PCMFormat.nChannels;
   MP3Format.wfx.nSamplesPerSec := PCMFormat.nSamplesPerSec;
   MP3Format.wfx.nAvgBytesPerSec := PCMFormat.nAvgBytesPerSec;
   MP3Format.wfx.cbSize := 0;
   MP3Format.wfx.wBitsPerSample := 0;
   MP3Format.wfx.nBlockAlign := 1;
   MP3Format.nCodecDelay := 1393;
   MP3Format.nBlockSize := MP3_BLOCK_SIZE;
   MP3Format.fdwFlags := MPEGLAYER3_FLAG_PADDING_OFF;
   MP3Format.wID := MPEGLAYER3_ID_MPEG;
end;




destructor TMP3Convertor.Destroy;
begin
   FStreamHandle := 0;
end;




function FormatEnumProc(hACMDrvId: HACMDRIVERID;
   NewACMFmtDet: PAcmFormatDetails;
   dwInstance: DWord; fdwSupport: DWord): longbool; stdcall;

begin
try
   Result := True;
   if NewACMFmtDet^.pwfx^.wFormatTag = TargetWaveFormat.wFormatTag then
   begin
      if NewACMFmtDet^.pwfx^.nSamplesPerSec = TargetWaveFormat.nSamplesPerSec then
         if NewACMFmtDet^.pwfx^.nChannels = TargetWaveFormat.nChannels then
         //   if NewACMFmtDet^.pwfx^.nAvgBytesPerSec = TargetWaveFormat.nAvgBytesPerSec then
          // store driver handle and format structure
            begin
               ACMDriver := hACMDrvId;
               TargetWaveFormat := NewACMFmtDet^.pwfx;
               Result := False;
            end;
   end;
   except
      Result := False;
   end;
end;




function DriverEnumProc(hACMDrvId: HACMDRIVERID;
   dwInstance: DWord; fdwSupport: DWord): bool; stdcall;
var

   MaxSize: Word;
   hACMDrv: HACMDriver;

begin
  try
   Result := True;
   if (fdwSupport = ACMDRIVERDETAILS_SUPPORTF_CODEC) then
   begin
      FillChar(WaveFormatEx^, SizeOf(TWaveFormatEx), #0);
      FillChar(ACMFmtDet^, SizeOf(TACMFormatDetails), #0);
      {get the driver and enumerate the formats}
      hACMDrv := nil;
      {get driver details}
      ACMDrvDet.cbStruct := SizeOf(ACMDrvDet);
      if acmDriverDetails(hACMDrvId, ACMDrvDet, 0) = 0 then
        DriverName := ACMDrvDet.szLongName;

      if acmDriverOpen(hACMDrv, hACMDrvId, 0) = 0 then
      begin
         MaxSize := 0;
         acmMetrics(HACMOBJ(hACMDrv), ACM_METRIC_MAX_SIZE_FORMAT, MaxSize);
         if MaxSize < SizeOf(TWaveFormatEx) then MaxSize := SizeOf(TWaveFormatEx);
         WaveFormatEx^.cbSize := LoWord(MaxSize) - SizeOf(TWaveFormatEx);
         WaveFormatEx^.wFormatTag := 0;
       {set up format details to receive enumerations}
         ACMFmtDet^.cbStruct := SizeOf(TACMFormatDetails);
         ACMFmtDet^.pwfx := WaveFormatEx;
         ACMFmtDet^.cbwfx := MaxSize;
         ACMFmtDet^.dwFormatTag := 0;
       {start enumerating formats}
         acmFormatEnum(hACMDrv, ACMFmtDet^, @FormatEnumProc, integer(hACMDrvId), 0);
       {close the driver}
         acmDriverClose(hACMDrv, 0);
      end
       else
          Result := False;
   end;
   except
      Result := False;
   end;
end;



procedure TMP3Convertor.FindACMDriver(SourceFormat, DestFormat: PWaveFormatEx);
begin
   TargetWaveFormat := DestFormat;
   new(WaveFormatEx);
   new(ACMFmtDet);
   acmDriverEnum(DriverEnumProc, integer(Self), 0);
   FDriverName := DriverName;
   DestFormat := TargetWaveFormat;

  // dispose(WaveFormatEx);
 //  dispose(ACMFmtDet);
end;




procedure TMP3Convertor.InitialiseMP3;
begin
   FindACMDriver(@PCMFormat, @MP3Format.wfx);
end;



procedure TMP3Convertor.InitialisePCM;
begin
   FindACMDriver(@MP3Format.wfx, @PCMFormat);
end;



// Converts the wave data to the specified format. The caller is responsible to
// release the memory allocated for the converted wave data buffer.

function TMP3Convertor.ConvertToMP3Format(srcData: Pointer; srcDataSize: DWORD;
   out dstData: Pointer; out dstDataSize: DWORD): Boolean;
var
   hStream: HACMSTREAM;
   Header: TACMSTREAMHEADER;
   Converted: Integer;
   hACMDrv: HACMDriver;

begin
   Result := False;
   LastError := '';
   InitialiseMP3;
  if acmDriverOpen(hACMDrv, ACMDriver, 0) = 0 then
  begin
  try
   if acmStreamOpen(hStream, hACMDrv, PCMFormat, MP3Format.wfx, nil, 0, 0, ACM_STREAMOPENF_NONREALTIME) = 0 then
   begin
      try
         if acmStreamSize(hStream, srcDataSize, dstDataSize, ACM_STREAMSIZEF_SOURCE) = 0 then
         begin
            dstData := nil;
            FillChar(Header, SizeOf(Header), 0);
            dstDataSize := dstDataSize + (dstDataSize div 2);  // add a bit for good measure
            ReallocMem(dstData, dstDataSize);
            try
               Header.cbStruct := SizeOf(Header);
               Header.pbSrc := srcData;
               Header.cbSrcLength := srcDataSize;
               Header.pbDst := dstData;
               Header.cbDstLength := dstDataSize;
               if acmStreamPrepareHeader(hStream, Header, 0) = 0 then
               try
                  Converted := acmStreamConvert(hStream, Header, ACM_STREAMCONVERTF_START or ACM_STREAMCONVERTF_END);
                  case Converted of
                     ACMERR_NotPossible: LastError := 'The requested operation cannot be performed.';
                     ACMERR_BUSY: LastError := 'The stream header specified in pash is currently in use and cannot be reused.';
                     ACMERR_UNPREPARED: LastError := 'The stream header specified in pash is currently not prepared by the acmStreamPrepareHeader function.';
                     MMSYSERR_INVALFLAG: LastError := 'At least one flag is invalid.';
                     MMSYSERR_INVALHANDLE: LastError := 'The specified handle is invalid.';
                     MMSYSERR_INVALPARAM: LastError := 'At least one parameter is invalid.';
                     MMSYSERR_NoMem: LastError := 'The system is unable to allocate resources.';
                     MMSYSERR_NoDriver: LastError := 'A suitable driver is not available to provide valid format selections.';
                     MMSYSERR_ALLOCATED: LastError := 'The specified resource is already in use.';
                     MMSYSERR_BADDEVICEID: LastError := 'The specified resource does not exist.';
                     WAVERR_BADFORMAT: LastError := 'Unsupported audio format.';
                     WAVERR_SYNC: LastError := 'The specified device does not support asynchronous operation.';
                  end;
                  Result := (Converted = 0);
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
   finally
      acmDriverClose(hACMDrv, 0);
   end;
  end;
end;


// Converts the wave data to the specified format. The caller is responsible to
// release the memory allocated for the converted wave data buffer.

function TMP3Convertor.ConvertFromMP3Format(srcData: Pointer; srcDataSize: DWORD;
   out dstData: Pointer; out dstDataSize: DWORD): Boolean;
var
   hStream: HACMSTREAM;
   Header: TACMSTREAMHEADER;
   Converted: Integer;
begin
   Result := False;
   LastError := '';
   if acmStreamOpen(hStream, nil, MP3Format.wfx, PCMFormat, nil, 0, 0, ACM_STREAMOPENF_NONREALTIME) = 0 then
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
                  Converted := acmStreamConvert(hStream, Header, ACM_STREAMCONVERTF_START or ACM_STREAMCONVERTF_END);
                  case Converted of
                     ACMERR_NotPossible: LastError := 'The requested operation cannot be performed.';
                     ACMERR_BUSY: LastError := 'The stream header specified in pash is currently in use and cannot be reused.';
                     ACMERR_UNPREPARED: LastError := 'The stream header specified in pash is currently not prepared by the acmStreamPrepareHeader function.';
                     MMSYSERR_INVALFLAG: LastError := 'At least one flag is invalid.';
                     MMSYSERR_INVALHANDLE: LastError := 'The specified handle is invalid.';
                     MMSYSERR_INVALPARAM: LastError := 'At least one parameter is invalid.';
                     MMSYSERR_NoMem: LastError := 'The system is unable to allocate resources.';
                     MMSYSERR_NoDriver: LastError := 'A suitable driver is not available to provide valid format selections.';
                     MMSYSERR_ALLOCATED: LastError := 'The specified resource is already in use.';
                     MMSYSERR_BADDEVICEID: LastError := 'The specified resource does not exist.';
                     WAVERR_BADFORMAT: LastError := 'Unsupported audio format.';
                     WAVERR_SYNC: LastError := 'The specified device does not support asynchronous operation.';
                  end;
                  Result := (Converted = 0);
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

end.
