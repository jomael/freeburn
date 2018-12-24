{-----------------------------------------------------------------------------
 Unit Name: Bin2ISO
 Author:    paul fisher
 Purpose:   Convert a BIN File to ISO (2048) file
 History:   First release (not tested)
-----------------------------------------------------------------------------}


unit Bin2ISO;

interface

uses SysUtils, Classes, CDBufferedStream, Resources;

const
   BIN2ISO_OK = 0;
   BIN2ISO_UNKNOWN = 1;
   BIN2ISO_NOT_RAW = 2;
   BIN2ISO_INVALID_MODE = 3;
   BIN2ISO_CANCELED = 4;
   BIN2ISO_NOFILEFOUND = 5;

   SYNCPATTERN = '00FFFFFFFFFFFFFFFFFFFF00';


type
   TProgressEvent = procedure(PercentDone: Integer; var Cancel: Boolean) of object;




type
   TBIN2ISO = class
   private
      FProgressEvent: TProgressEvent;
      FErrorString: string;
      FErrorCode: Integer;
      FBinFileName: string;
      FISOFileName: string;
      FBinStream: TCDBufferedStream;
      FISOStream: TFileStream;
      FSeek_Header: Integer;
      FSeek_ECC: Integer;
      FSector_Size: Integer;

      procedure SetBINFilename(Filename: string);
      procedure SetISOFilename(Filename: string);
      procedure AutoInitialize;
      procedure AutoDestroy;
      function CheckSYNCPattern: Boolean;
   public
      constructor Create;
      destructor Destroy; override;
      function ConvertFile: Integer;
   published
      property OnProgress: TProgressEvent read FProgressEvent write FProgressEvent;
      property BINFileName: string read FBinFileName write SetBINFilename;
      property ISOFileName: string read FISOFileName write SetISOFilename;
   end;







implementation


procedure TBIN2ISO.AutoInitialize;
begin
   FErrorCode := BIN2ISO_OK;
   FErrorString := '';
end;


procedure TBIN2ISO.AutoDestroy;
begin
   FISOStream.Free;
   FBinStream.Free;
end;


procedure TBIN2ISO.SetBINFilename(Filename: string);
begin
   FBinFileName := Filename;
   if not Fileexists(FBinFilename) then
   begin
      FErrorCode := BIN2ISO_NOFILEFOUND;
      FErrorString := resNoBinFileFound;
   end
   else
   begin
      FBinStream := TCDBufferedStream.Create(FBinFilename, fmOpenRead);
      FBinStream.SectorSize := 2352;
      if FBinStream.ISOSectorSizeOK = False then
      begin
         FErrorCode := BIN2ISO_NOT_RAW;
         FErrorString := resBinFileNotRAW;
      end;
   end;
end;


procedure TBIN2ISO.SetISOFilename(Filename: string);
begin
   FISOFileName := Filename;
   FISOStream := TFileStream.Create(FISOFileName, fmCreate);
end;

constructor TBIN2ISO.Create;
begin
   AutoInitialize;
end;

destructor TBIN2ISO.Destroy;
begin
   AutoDestroy;
end;


function TBIN2ISO.CheckSYNCPattern: Boolean;
var
   Buffer: PChar;
   HexStr: PChar;
   Count: Integer;
   BinType: char;
begin
   Result := False;
   Count := 16;
   try
      FBinStream.Seek(0, soFromBeginning);
      GetMem(Buffer, Count);
      GetMem(HexStr, 24);

      Buffer[Count] := #0;
      HexStr[24] := #0;

      FBinStream.Read(Buffer^, Count);
      BinToHEX(buffer, HexStr, 12);

      if HexStr = SYNCPATTERN then
      begin
         Result := true;
         FSeek_Header := 8; // setup base as audio mode  ??
         FSeek_ECC := 280;
         FSector_Size := 2336;

         BinType := Buffer[15]; // get mode id code

         if BinType = #1 then // Mode1/2352
         begin
            Result := true;
            FSeek_Header := 16;
            FSeek_ECC := 288;
            FSector_Size := 2352;
         end;
         if BinType = #2 then // Mode2/2352
         begin
            Result := true;
            FSeek_Header := 24;
            FSeek_ECC := 280;
            FSector_Size := 2352;
         end;
      end;
   finally
     // freemem(buffer);
    //  Freemem(hexstr);
   end;
end;





function TBIN2ISO.ConvertFile: Integer;

var
   Progress, Divisor: Integer;
   Buffer: PChar;
   isCancel: boolean;
begin
   Result := 0;
   Progress := 0;
   isCancel := false;
   if CheckSYNCPattern = False then
   begin
      FErrorCode := BIN2ISO_INVALID_MODE;
      FErrorString := resTrackNotSupported;
      exit;
   end;
   try
      getmem(Buffer, 2048);
      FBinStream.Seek(0, soFromBeginning);
      Divisor := (FBinStream.SectorCount div 100);
  //loop
      while (Progress < FBinStream.SectorCount) do
      begin
         FBinStream.Seek(FSeek_Header, soFromCurrent);
         FBinStream.Read(Buffer^, 2048);
         FISOStream.Write(Buffer^, 2048);
         FBinStream.Seek(FSeek_ECC, soFromCurrent);
         inc(Progress);
         if Assigned(FProgressEvent) then
            FProgressEvent((Progress div Divisor), isCancel);
         if isCancel = True then exit;
      end; //end loop
   finally
     // freemem(Buffer);
   end;
end;

end.
