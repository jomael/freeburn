unit ReadWave;


interface

uses SysUtils, Windows, MMSystem, Dialogs;


type
  PWaveInformation = ^tWaveInformation;
  TWaveInformation = record
    WaveFormat: Word;         { Wave format identifier }
    Channels: Word;         { Mono=1, Stereo=2 }
    SampleRate: Longint;      { Sample rate in Hertz }
    BytesPerSecond : Longint;
    BitsPerSample: Word;         { Resolution, e.g. 8 or 16 Bit }
    SamplesNumber: Longint;      { Number of samples }
    Length: Extended;     { Sample length in seconds }
    SectorCount : Integer;   { Data length }
    ValidWave: bool;         { Specifies if the file could be read }
  end;

const                            { Constants for wave format identifier }
  WAVE_FORMAT_PCM = $0001;   { Windows PCM }
  WAVE_FORMAT_G723_ADPCM = $0014;   { Antex ADPCM }
  WAVE_FORMAT_ANTEX_ADPCME = $0033;   { Antex ADPCME }
  WAVE_FORMAT_G721_ADPCM = $0040;   { Antex ADPCM }
  WAVE_FORMAT_APTX = $0025;   { Audio Processing Technology }
  WAVE_FORMAT_AUDIOFILE_AF36 = $0024;   { Audiofile, Inc. }
  WAVE_FORMAT_AUDIOFILE_AF10 = $0026;   { Audiofile, Inc. }
  WAVE_FORMAT_CONTROL_RES_VQLPC = $0034;   { Control Resources Limited }
  WAVE_FORMAT_CONTROL_RES_CR10 = $0037;   { Control Resources Limited }
  WAVE_FORMAT_CREATIVE_ADPCM = $0200;   { Creative ADPCM }
  WAVE_FORMAT_DOLBY_AC2 = $0030;   { Dolby Laboratories }
  WAVE_FORMAT_DSPGROUP_TRUESPEECH = $0022;   { DSP Group, Inc }
  WAVE_FORMAT_DIGISTD = $0015;   { DSP Solutions, Inc. }
  WAVE_FORMAT_DIGIFIX = $0016;   { DSP Solutions, Inc. }
  WAVE_FORMAT_DIGIREAL = $0035;   { DSP Solutions, Inc. }
  WAVE_FORMAT_DIGIADPCM = $0036;   { DSP Solutions ADPCM }
  WAVE_FORMAT_ECHOSC1 = $0023;   { Echo Speech Corporation }
  WAVE_FORMAT_FM_TOWNS_SND = $0300;   { Fujitsu Corp. }
  WAVE_FORMAT_IBM_CVSD = $0005;   { IBM Corporation }
  WAVE_FORMAT_OLIGSM = $1000;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_OLIADPCM = $1001;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_OLICELP = $1002;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_OLISBC = $1003;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_OLIOPR = $1004;   { Ing C. Olivetti & C., S.p.A. }
  WAVE_FORMAT_IMA_ADPCM = $0011;   { Intel ADPCM }
  WAVE_FORMAT_DVI_ADPCM = $0011;   { Intel ADPCM }
  WAVE_FORMAT_UNKNOWN = $0000;
  WAVE_FORMAT_ADPCM = $0002;   { Microsoft ADPCM }
  WAVE_FORMAT_ALAW = $0006;   { Microsoft Corporation }
  WAVE_FORMAT_MULAW = $0007;   { Microsoft Corporation }
  WAVE_FORMAT_GSM610 = $0031;   { Microsoft Corporation }
  WAVE_FORMAT_MPEG = $0050;   { Microsoft Corporation }
  WAVE_FORMAT_NMS_VBXADPCM = $0038;   { Natural MicroSystems ADPCM }
  WAVE_FORMAT_OKI_ADPCM = $0010;   { OKI ADPCM }
  WAVE_FORMAT_SIERRA_ADPCM = $0013;   { Sierra ADPCM }
  WAVE_FORMAT_SONARC = $0021;   { Speech Compression }
  WAVE_FORMAT_MEDIASPACE_ADPCM = $0012;   { Videologic ADPCM }
  WAVE_FORMAT_YAMAHA_ADPCM = $0020;   { Yamaha ADPCM }

function GetWaveInformationFromFile(FileName: string): pWaveInformation;

implementation

type
  TCommWaveFmtHeader = record
    wFormatTag: Word;                  { Fixed, must be 1 }
    nChannels: Word;                  { Mono=1, Stereo=2 }
    nSamplesPerSec: Longint;               { SampleRate in Hertz }
    nAvgBytesPerSec: Longint;
    nBlockAlign: Word;
    nBitsPerSample: Word;                  { Resolution, e.g. 8 or 16 }
    cbSize: Longint;               { Size of extra information in the extended fmt Header }
  end;

function GetWaveInformationFromFile(FileName: string): pWaveInformation;
var
  hdmmio: HMMIO;
  mmckinfoParent: TMMCKInfo;
  mmckinfoSubchunk: TMMCKInfo;
  Fmt: TCommWaveFmtHeader;
  Samples: Longint;
  Info: pWaveInformation;
begin
  New(Info);
  FillChar(Info^, SizeOf(TWaveInformation), #0); { Initialize first }
  hdmmio := mmioOpen(PChar(FileName), nil, MMIO_READ);
  if (hdmmio = 0) then
    Exit;
      {* Locate a 'RIFF' chunk with a 'WAVE' form type
       * to make sure it's a WAVE file.
       *}
  mmckinfoParent.fccType := mmioStringToFOURCC('WAVE', MMIO_TOUPPER);
  if (mmioDescend(hdmmio, PMMCKINFO(@mmckinfoParent), nil, MMIO_FINDRIFF) <> 0) then
    Exit;
      {* Now, find the format chunk (form type 'fmt '). It should be
       * a subchunk of the 'RIFF' parent chunk.
       *}
  mmckinfoSubchunk.ckid := mmioStringToFOURCC('fmt ', 0);
  if (mmioDescend(hdmmio, @mmckinfoSubchunk, @mmckinfoParent, MMIO_FINDCHUNK) <> 0) then
    Exit;

  // Read the format chunk.
  if (mmioRead(hdmmio, PChar(@fmt), Longint(SizeOf(TCommWaveFmtHeader))) <>
    Longint(SizeOf(TCommWaveFmtHeader))) then
    Exit;
  Info^.WaveFormat    := fmt.wFormatTag;
  Info^.Channels      := fmt.nChannels;
  Info^.SampleRate    := fmt.nSamplesPerSec;
  Info^.BitsPerSample := fmt.nBitsPerSample;
  Info^.BytesPerSecond := fmt.nAvgBytesPerSec;
  mmioAscend(hdmmio, @mmckinfoSubchunk, 0); // Ascend out of the format subchunk.
  mmckinfoSubchunk.ckid := mmioStringToFOURCC('data', 0); // Find the data subchunk.
  if (mmioDescend(hdmmio, @mmckinfoSubchunk, @mmckinfoParent, MMIO_FINDCHUNK) <> 0) then
    Exit;
  Info^.SamplesNumber := mmckinfoSubchunk.cksize; // Get the size of the data subchunk.

 if (Info^.SamplesNumber mod 2352) > 0 then
    Info^.SectorCount := (Info^.SamplesNumber div 2352) + 1
  else // bigger so add on a full sector!
    Info^.SectorCount := (Info^.SamplesNumber div 2352);

  Samples      := (Info^.SamplesNumber * 8 * Info^.Channels) div Info^.BitsPerSample;
  Info^.Length := (Samples / Info^.BytesPerSecond) * 75;

  mmioClose(hdmmio, 0); // We're done with the file, close it.
  Info^.ValidWave := True;
  Result          := Info;
end;

end.


 