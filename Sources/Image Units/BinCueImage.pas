{-----------------------------------------------------------------------------
 Unit Name: BinCueImage
 Author:    Paul Fisher
 Purpose:   Class for a BIN/CUE disk at once (DAO) image
 History:
-----------------------------------------------------------------------------}


unit BinCueImage;

interface

uses
  Classes, CustomImage, SysUtils, SCSIDefs, Resources, CovertFuncs, BinCueReader;


const

      CUE_OK               = 0;
      CUE_CUEMISSING       = 1;
      CUE_BINMISSING       = 2;
      CUE_CUEFILEEXPECTED  = 3;
      CUE_BINFILEEXPECTED  = 4;
      CUE_BINARYEXPECTED   = 5;
      CUE_TRACKEXPECTED    = 6;
      CUE_TRACKNUMEXPECTED = 7;
      CUE_INDEXEXPECTED    = 8;
      CUE_INDEXNUMEXPECTED = 9;
      CUE_INDEXMSFEXPECTED = 10;
      CUE_UNKNOWN_ERROR    = 11;



type
    TBinCueImage = class(TCustomImage)
  private
      FErrorString: string;
      FErrorCode: Integer;
      FCUEFileName : String;
      FBINFileName : String;
      FSectorSize : Integer;
      FDataBlock  : Integer;
      FTrackMode  : Integer;
      CueFileReader: TBinCueReader;
      FATIPCueList : TATIPCueList;
      procedure AutoInitialize;
      procedure AutoDestroy;
      Function GetBinFileSize : Integer;
      Procedure ConvertTrackMode(BINMode : Integer);
      Procedure ReadCueFile;
  Public
      constructor Create(CUEFileName : String);
      destructor Destroy; override;
      function SetupBINCUEImage : Integer;
      property CUEFileName: String read FCUEFileName;
      Property BINFileName: String read FBINFileName;
      Property BINFileSize: Integer read GetBinFileSize;
      Property ATIPCueList : TATIPCueList Read FATIPCueList;
      property SectorSize : Integer Read FSectorSize;
      property DataBlock  : Integer Read FDataBlock;
      property TrackMode  : Integer Read FTrackMode;
    end;

implementation



Procedure TBinCueImage.ConvertTrackMode(BINMode : Integer);
begin
     if (BINMode > 5) then FTrackMode := CDR_MODE_DATA
        else
           FTrackMode := CDR_MODE_DATA;//CDR_MODE_DAO_96;
     Case BINMode of
        1 : Begin FSectorSize := 2352; FDataBlock := RAW_DATA_BLOCK; end;   //Audio
        2 : Begin FSectorSize := 2352; FDataBlock := MODE_1; end;           //'MODE1 / 2352';
        3 : Begin FSectorSize := 2352; FDataBlock := MODE_2; end;           //'MODE2 / 2352';
        4 : Begin FSectorSize := 2352; FDataBlock := MODE_2_XA_FORM_1; end; //'MODE2 FORM1 / 2352';
        5 : Begin FSectorSize := 2352; FDataBlock := MODE_2_XA_FORM_2; end; //'MODE2 FORM2 / 2352';
        6 : Begin FSectorSize := 2048; FDataBlock := MODE_1; end;           //'MODE1 / 2048';
        7 : Begin FSectorSize := 2048; FDataBlock := MODE_2; end;           //'MODE2 / 2048';
     end;
end;


procedure TBinCueImage.AutoInitialize;
begin
   FErrorCode := 0;
   FErrorString := '';
   FCUEFileName := '';
   FBINFileName := '';
   ImageType := ITBinCueImage;
   CueFileReader := TBinCueReader.Create;
end;


procedure TBinCueImage.AutoDestroy;
begin
  CueFileReader.free;
end;


Function TBinCueImage.GetBinFileSize: Integer;
begin
   Result := 0;
   if FBINFileName = '' then exit;
   if FileExists(FBINFileName) then
        Result := GetFileSize(FBINFileName) div (1024*1024);
end;


Procedure TBinCueImage.ReadCueFile;

begin
  FErrorCode := CueFileReader.OpenCueFile(FCueFileName);
  if FErrorCode <> CUE_OK then
  begin
      FErrorString := resOpenCUEError;
  end;
end;



function TBinCueImage.SetupBINCUEImage : Integer;
var
     Path : String;
begin
     ReadCueFile;
     Path := extractfilepath(FCueFileName);
     FBINFileName := Path + CueFileReader.BinFileName;
     FATIPCueList := CueFileReader.ATIPCueList;
     ConvertTrackMode(FATIPCueList.BurnMode);
end;


constructor TBinCueImage.Create(CUEFileName : String);
begin
   inherited Create;
   AutoInitialize;
   FCUEFileName := CUEFileName;
end;


destructor TBinCueImage.Destroy;
begin
   AutoDestroy;
   inherited Destroy;
end;


end.
