{-----------------------------------------------------------------------------
 Unit Name: SCSIUnit
 Author:    Sergey Kabikov + Dancemammal
 Purpose:   SCSI Functions Unit
 History:  Some Functions by Sergey Kabikov based on his code ASPI/SCSI Library
    rewritten by Dancemammal for the burning code
-----------------------------------------------------------------------------}

unit SCSIUnit;

interface

uses Windows, SCSITypes, SCSIDefs, CovertFuncs, Sysutils, SPTIUnit, wnaspi32;

function SCSIinquiryDeviceInfo(DeviceID: TCDBurnerInfo;
  var Info: TScsiDeviceInfo; var Sdf: TScsiDefaults): TScsiError;

function SCSIinquiryEX(DeviceID: TCDBurnerInfo;
  Buf: pointer; BufLen: DWORD;
  CmdDt, EVPD: BOOLEAN; PageCode: BYTE;
  var Sdf: TScsiDefaults): TScsiError;

function SCSImodeSense(DeviceID: TCDBurnerInfo;
  PAGE: BYTE; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSImodeSensePage(DeviceID: TCDBurnerInfo; PageCode: BYTE;
  Buf: pointer; var BufLen: DWORD; BufPos: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSImodeSelectEX(DeviceID: TCDBurnerInfo;
  Buf: pointer; BufLen: DWORD;
  PF, SP: BOOLEAN;
  var Sdf: TScsiDefaults): TScsiError;

function SCSImodeSelect(DeviceID: TCDBurnerInfo;
  Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSImodeSelectPage(DeviceID: TCDBurnerInfo; PageCode: BYTE;
  Buf: pointer; var BufLen: DWORD; BufPos: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSImodeSenseParameter(DeviceID: TCDBurnerInfo; PageCode: BYTE;
  Param: pointer; ParamLen, ParamPos: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSImodeSenseCdStatus(DeviceID: TCDBurnerInfo;
  var ModePage: TScsiModePageCdStatus;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIgetCdRomCapabilities(DeviceID: TCDBurnerInfo;
  var Value: TCdRomCapabilities;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIGetDriveSpeeds(DeviceID: TCDBurnerInfo;
  var Value: TCDReadWriteSpeeds;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIpreventMediumRemoval(DeviceID: TCDBurnerInfo;
  MustLock: boolean; var Sdf: TScsiDefaults): TScsiError;

function SCSIstartStopUnit(DeviceID: TCDBurnerInfo;
  Start, LoadEject, DontWait: boolean;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIreadCdFlagsToSize(SectorType: TScsiReadCdSectorType;
  Flags: TScsiReadCdFormatFlags): integer;

function SCSIseek10(DeviceID: TCDBurnerInfo;
  GLBA: DWORD; var Sdf: TScsiDefaults): TScsiError;

function SCSIread10EX(DeviceID: TCDBurnerInfo;
  DisablePageOut, ForceUnitAccess: boolean;
  GLBA, SectorCount: DWORD; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIread10(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: DWORD; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIreadCdEX(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: DWORD;
  SectorType: TScsiReadCdSectorType;
  Flags: TScsiReadCdFormatFlags;
  Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIWriteCdEX(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: DWORD;
  SectorType: TScsiReadCdSectorType;
  Flags: TScsiReadCdFormatFlags;
  Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIBlankCD(DeviceID: TCDBurnerInfo; BlankType: byte; LBA: longint;
  var Sdf: TScsiDefaults): TScsiError;
function SCSIgetMaxBufferSize(DeviceID: TCDBurnerInfo;
  var Value: WORD; var Sdf: TScsiDefaults): TScsiError;
function SCSIgetBufferSize(DeviceID: TCDBurnerInfo;
  var Value: WORD; var Sdf: TScsiDefaults): TScsiError;
function SCSIgetBufferCapacity(DeviceID: TCDBurnerInfo;
  var Value: TScsiCDBufferInfo; var Sdf: TScsiDefaults): TScsiError;
function SCSIReadBuffer(DeviceID: TCDBurnerInfo;
  Buf: pointer; var Sdf: TScsiDefaults): TScsiError;

function SCSIReadBufferCapacity(DeviceID: TCDBurnerInfo;
  Buf: pointer; var Sdf: TScsiDefaults): TScsiError;
function SCSICloseSession(DeviceID: TCDBurnerInfo; var Sdf: TScsiDefaults):
  TScsiError;

function SCSICloseTrack(DeviceID: TCDBurnerInfo; Track: byte;
  var Sdf: TScsiDefaults): TScsiError;

function SCSISYNCCACHE(DeviceID: TCDBurnerInfo; var Sdf: TScsiDefaults):
  TScsiError;

function SCSIFormatCD(DeviceID: TCDBurnerInfo; BlankType: byte; LBA: longint;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIWrite10EX(DeviceID: TCDBurnerInfo;
  DisablePageOut, ForceUnitAccess: boolean;
  GLBA, SectorCount: WORD; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIWrite10(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: WORD; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIWriteCDDA(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: DWORD;
  SectorType: TScsiReadCdSectorType;
  Flags: TScsiReadCdFormatFlags;
  Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function ScsiGetWriteParams(DevID: TCDBurnerInfo; Size: Integer; var Param:
  string;
  var Sdf: TScsiDefaults): TScsiError;

function SCSISetWriteParameters(DevID: TCDBurnerInfo; Size: Integer;
  Write_Type, Data_Block_type, Track_Mode, Session_Format: integer;
  Packet_Size, Audio_Pause_Length: integer; Test_Write, Burn_Proof: Boolean;
  var Sdf: TScsiDefaults): TScsiError;

function SCSISetSpeed(DevID: TCDBurnerInfo; ReadSpeed, WriteSpeed: Integer;
  var Sdf: TScsiDefaults): TScsiError;

function SCSISendCUESheet(DeviceID: TCDBurnerInfo;
  Buf: pointer; BufSize : Longint; var Sdf: TScsiDefaults): TScsiError;

function SCSItestReady(DeviceID: TCDBurnerInfo;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIreadSubChannelEx(DeviceID: TCDBurnerInfo;
  InMSF: boolean; // Form of resulting GLBA
  GetSubQ: boolean; // requests the Q sub-channel data if True
  RequestType: BYTE;
  TrackNumber: BYTE;
  Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIadrByteToSubQinfoFlags(Arg: BYTE): TScsiSubQinfoFlags;

function SCSIreadCapacity(DeviceID: TCDBurnerInfo;
  var LastLBA: DWORD; var Sdf: TScsiDefaults): TScsiError;

function SCSIgetSessionInfo(DeviceID: TCDBurnerInfo;
  var Info: TScsiSessionInfo;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIgetLayoutInfo(DeviceID: TCDBurnerInfo;
  var Info: TDiscLayout;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIgetISRC(DeviceID: TCDBurnerInfo; TrackNumber: BYTE;
  var Info: TScsiISRC;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIreadHeaderEx(DeviceID: TCDBurnerInfo;
  InMSF: boolean; // Form of GLBA as result
  var GLBA: DWORD; // at enter: LBA to read, at exit: address of
  //   block processed, in LBA (InMSF=False) or
  //   MSF (InMSF=True) form.
  var SectorType: TScsiReadCdSectorType; // type of block, may
  // be csfAudio, csfDataMode1, csfDataMode2,
  // or csfAnyType (if error occurs) only
  var Sdf: TScsiDefaults): TScsiError;

function SCSIreadHeader(DeviceID: TCDBurnerInfo; GLBA: DWORD;
  var SectorType: TScsiReadCdSectorType; // type of block, may
  // be csfAudio, csfDataMode1, csfDataMode2,
  // or csfAnyType (if error occurs) only
  var Sdf: TScsiDefaults): TScsiError;

function SCSIreadTocPmaAtipEx(DeviceID: TCDBurnerInfo;
  InMSF: boolean;
  RequestType: BYTE;
  TrackNumber: BYTE;
  Buf: pointer; BufLen: WORD;
  var Sdf: TScsiDefaults): TScsiError;

function SCSIgetTOC(DeviceID: TCDBurnerInfo; var TOC: TScsiTOC; var Sdf:
  TScsiDefaults): TScsiError;
function SCSIgetTOCCDText(DeviceID: TCDBurnerInfo; var TOCText: TCDText; var
  Sdf: TScsiDefaults): TScsiError;

function SCSIReadTrackInformation(DeviceID: TCDBurnerInfo; const ATrack: Byte;
  var TrackInformation: TTrackInformation; var Sdf: TScsiDefaults): TScsiError;
function SCSIReadFormatCapacity(DeviceID: TCDBurnerInfo; var FormatCapacity:
  TFormatCapacity; var Sdf: TScsiDefaults): TScsiError;
function SCSIReadDiscInformation(DeviceID: TCDBurnerInfo; var DiscInformation:
  TDiscInformation; var Sdf: TScsiDefaults): TScsiError;
function SCSIReadDVDStructure(DeviceID: TCDBurnerInfo; var DescriptorStr:
  TScsiDVDLayerDescriptorInfo; var Sdf: TScsiDefaults): TScsiError;
function SCSIGetDevConfigProfileMedia(DeviceID: TCDBurnerInfo; var
  ProfileDevDiscType: TScsiProfileDeviceDiscTypes; var Sdf: TScsiDefaults):
  TScsiError;

implementation

function SCSImodeSense(DeviceID: TCDBurnerInfo;
  PAGE: BYTE; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
var
  Arg1: byte;
  Arg2: DWORD;
  CDB: TCDB10;
begin
  if ASPIgetDeviceIDflag(DeviceID.DriveID, ADIDmodeSenseDBD) then
    Arg1 := 0
  else
    Arg1 := 8;

  Arg2 := ((Ord(Sdf.ModePageType) and 3) shl 6) or (PAGE and $3F);

  FillChar(cdb, 10, 0);
  if ASPIgetDeviceIDflag(DeviceID.DriveID, ADIDmodeSense6) then
  begin
    Arg2 := (Arg2 shl 8) or (Arg1 shl 16);
    Result := ASPIsend6(DeviceID, $1A, Arg2, BufLen,
      Buf, BufLen, SRB_DIR_IN, Sdf);
  end
  else
  begin
    { FillChar(cdb,10,0);
     Lba := Arg2 SHL 24;                      // send as CDB 10
     cdb [ 0 ] := SCSI_MODE_SEN10;
     cdb [ 2 ] := $2A;
     cdb [ 7 ] := HiByte(BufLen);
     cdb [ 8 ] := LoByte(BufLen);
     Result := ASPIsend10CDB(DeviceID,CDB,Buf,BufLen,SRB_DIR_IN,Sdf);  }
    Result := ASPIsend10(DeviceID, $5A, Arg1, Arg2 shl 24, 0, BufLen,
      Buf, BufLen, SRB_DIR_IN, Sdf);
  end;
end;

function SCSImodeSelectEX(DeviceID: TCDBurnerInfo;
  Buf: pointer; BufLen: DWORD;
  PF, SP: BOOLEAN;
  var Sdf: TScsiDefaults): TScsiError;
var
  Arg1: byte;
  Arg2: DWORD;
  cdb6: Tcdb6;
  cdb10: TCDB10;

begin
  FillChar(cdb6, 6, 0); // clear cdb
  FillChar(cdb10, 10, 0); // clear cdb
  if PF then
    Arg1 := $10
  else
    Arg1 := 0;
  if SP then
    Arg1 := Arg1 or 1;
  if ASPIgetDeviceIDflag(DeviceID.DriveID, ADIDmodeSense6) then
  begin
    Arg2 := (Arg1 shl 16); // send as CDB 6
    cdb6[0] := SCSI_MODE_SEL6;
    cdb6[1] := AttachLUN(cdb6[1], DeviceID.DriveID);
    cdb6[4] := Arg2;
    Result := ASPIsend6CDB(DeviceID, CDB6, Buf, BufLen, SRB_DIR_OUT, Sdf);
  end
  else
  begin
    // cdr CDB:  55 10 00 00 00 00 00 00 3C 00
    cdb10[0] := SCSI_MODE_SEL10;
    cdb10[1] := AttachLUN(Arg1, DeviceID.DriveID);
    FillWORD(BufLen, cdb10[7]); //test 7 to 8
    Result := ASPIsend10CDB(DeviceID, CDB10, Buf, BufLen, SRB_DIR_OUT, Sdf);
  end;
end;

function SCSImodeSelect(DeviceID: TCDBurnerInfo;
  Buf: pointer; BufLen: DWORD; var Sdf: TScsiDefaults): TScsiError;
begin
  Result := SCSImodeSelectEX(DeviceID, Buf, BufLen, TRUE, FALSE, Sdf);
end;

{function SCSImodeSensePage(DeviceID : TCDBurnerInfo; PageCode : BYTE;
                Buf : pointer; var BufLen : DWORD; BufPos : DWORD;
                var Sdf : TScsiDefaults) : TScsiError;

var Src10 : TScsiModePageTemplate10;
    Src6 : TScsiModePageTemplate6;
    ps  : PScsiModePageRecord;
    mp  : integer;
begin
   if not Assigned(Buf)  then begin
      Result := Err_InvalidArgument;
      exit;
   end;

  // fillchar(Src10,sizeof(Src10),0);

   if ASPIgetDeviceIDflag(DeviceID.DriveID, ADIDmodeSense6) then
    begin
       Result := SCSImodeSense(DeviceID, PageCode, @Src6, BufLen, Sdf);
        if Result <> Err_None then
        begin
              BufLen := 0;
              exit;
        end;
      ps := PScsiModePageRecord(@Src6.Params6[Src6.DescriptorLength6]);
      mp := ScsiModeTemplateParamsLength - 1 - Src6.DescriptorLength6;
   end
    else
    begin
       Result := SCSImodeSense(DeviceID, PageCode, @Src10, BufLen, Sdf);
        if Result <> Err_None then
         begin
            BufLen := 0;
            exit;
         end;
      ps := PScsiModePageRecord(@Src10.Params10[Src10.DescriptorLength10]);
      mp := ScsiModeTemplateParamsLength - 1 - Src10.DescriptorLength10;
   end;
   if (mp <= integer(BufPos)) or (ps^.ParamLength <= BufPos) then
    begin
      Result := Err_Unknown;
      BufLen := 0;
      exit;
   end;
   if mp > ps^.ParamLength then mp := ps^.ParamLength;
   Dec(mp, BufPos);
   if BufLen > DWORD(mp) then BufLen := DWORD(mp);
   if Assigned(Buf) then
   BEGIN
     System.Move(ps^.Params, Buf^, BufLen);
   END;
end;  }

function SCSImodeSensePage(DeviceID: TCDBurnerInfo; PageCode: BYTE;
  Buf: pointer; var BufLen: DWORD; BufPos: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

var
  Src6: TScsiModePageTemplate6;
  Src10: TScsiModePageTemplate10;
  pp, ps: PScsiModePageRecord;
  mp, len, dblen: integer;

begin
  if not Assigned(Buf) then
  begin
    Result := Err_InvalidArgument;
    exit;
  end;
  fillchar(Src10, sizeof(Src10), 0);

  Result := SCSImodeSense(DeviceID, PageCode, @Src10, BufLen, Sdf);
  if Result <> Err_None then
  begin
    BufLen := 0;
    exit;
  end;
  // Exclude block descriptors if exists
  if ASPIgetDeviceIDflag(DeviceID.DriveID, ADIDmodeSense6) then
  begin
    dblen := Src6.DescriptorLength6;
    len := Src6.ModeDataLength6 - dblen;
    Src6.ModeDataLength6 := len;
    Inc(len, SizeOf(Src6.ModeDataLength6)); // Full length of record
    pp := PScsiModePageRecord(@Src6.Params6[0]);
    ps := PScsiModePageRecord(@Src6.Params6[dblen]);
    //    gs := PScsiModePageRecord(@Chg6.Params6[Chg6.DescriptorLength6]);
    mp := ScsiModeTemplateParamsLength - 1 - dblen;
  end
  else
  begin
    dblen := Integer(BigEndianW(Src10.DescriptorLength10));
    // 2nd break point - dblen=integer & BigIndian returns DWORD
    len := BigEndianW(Src10.ModeDataLength10) - dblen;
    Src10.ModeDataLength10 := BigEndianW(len);
    Inc(len, SizeOf(Src10.ModeDataLength10)); // Full length of record
    pp := PScsiModePageRecord(@Src10.Params10[0]);
    ps := PScsiModePageRecord(@Src10.Params10[dblen]);
    //    gs := PScsiModePageRecord(@Chg10.Params10[BigEndianW(Chg10.DescriptorLength10)]);
    mp := ScsiModeTemplateParamsLength - 1 - dblen;
  end;
  if (mp <= Integer(BufPos)) or (ps^.ParamLength <= BufPos) or (len <= 0) then
  begin
    Result := Err_Unknown;
    BufLen := 0;
    exit;
  end;
  if mp > Integer(ps^.ParamLength) then
    mp := Integer(ps^.ParamLength); // 3rd break point
  if BufLen > (DWORD(mp) - BufPos) then
    BufLen := (DWORD(mp) - BufPos);
  System.Move(pp^, Buf^, BufLen);
end;

{
function SCSImodeSelectPage(DeviceID : TCDBurnerInfo; PageCode : BYTE;
                Buf : pointer; var BufLen : DWORD; BufPos : DWORD;
                var Sdf : TScsiDefaults) : TScsiError;
var
    Src6, Chg6   : TScsiModePageTemplate6;
    Chg10 ,Src10 : TScsiModePageTemplate10;
    SdfTemp    : TCdRomModePageType;
    pp, ps, gs : PScsiModePageRecord;
    i, mp, len, dblen : integer;
begin
   if not Assigned(Buf)  then begin
      Result := Err_InvalidArgument;
      exit;
   end;
   Result := SCSImodeSense(DeviceID, PageCode, @Src10, sizeof(Src10), Sdf);
   if Result <> Err_None then begin
      BufLen := 0;
      exit;
   end;

   SdfTemp := Sdf.ModePageType;
   Sdf.ModePageType := MPTchangeable;
   Result := SCSImodeSense(DeviceID, PageCode, @Chg10, sizeof(Chg10), Sdf);
   Sdf.ModePageType := SdfTemp;
   if Result <> Err_None then begin
      BufLen := 0;
      exit;
   end;
       // Exclude block descriptors if exists
   if ASPIgetDeviceIDflag(DeviceID.DriveID, ADIDmodeSense6) then begin
      dblen := Src6.DescriptorLength6;
      len   := Src6.ModeDataLength6 - dblen;
      Src6.ModeDataLength6 := len;
      Src6.MediumType6       := 0;
      Src6.DeviceSpecific6   := 0;
      Src6.DescriptorLength6 := 0;
      Inc(len, SizeOf(Src6.ModeDataLength6));      // Full length of record
      pp := PScsiModePageRecord(@Src6.Params6[0]);
      ps := PScsiModePageRecord(@Src6.Params6[dblen]);
      gs := PScsiModePageRecord(@Chg6.Params6[Chg6.DescriptorLength6]);
      mp := ScsiModeTemplateParamsLength - 1 - dblen;
   end else begin
      dblen := BigEndianW(Src10.DescriptorLength10);
      len   := BigEndianW(Src10.ModeDataLength10) - dblen;
      Src10.ModeDataLength10 := BigEndianW(len);
      Src10.MediumType10       := 0;
      Src10.DeviceSpecific10   := 0;
      Src10.Reserved10         := 0;
      Src10.DescriptorLength10 := 0;
      Inc(len, SizeOf(Src10.ModeDataLength10));   // Full length of record
      pp := PScsiModePageRecord(@Src10.Params10[0]);
      ps := PScsiModePageRecord(@Src10.Params10[dblen]);
      gs := PScsiModePageRecord(@Chg10.Params10[
                     BigEndianW(Chg10.DescriptorLength10)]);
      mp := ScsiModeTemplateParamsLength - 1 - dblen;
   end;
   if (mp <= BufPos) or (ps^.ParamLength <= BufPos) or (len <= 0) then begin
      Result := Err_Unknown;
      BufLen := 0;
      exit;
   end;
   if mp > ps^.ParamLength  then mp := ps^.ParamLength;
   if dblen <> 0 then System.Move(ps^, pp^, mp+2);
   if BufLen > (mp - BufPos) then BufLen := (mp - BufPos);
   System.Move(Buf^, pp^, BufLen);
  // for i := 0 to mp-1 do
  //  pp^.Params[i] := pp^.Params[i] AND gs^.Params[i];
   Result := SCSImodeSelect(DeviceID, @Src10, len, Sdf);
end; }

{$WARNINGS OFF}

function SCSImodeSelectPage(DeviceID: TCDBurnerInfo; PageCode: BYTE;
  Buf: pointer; var BufLen: DWORD; BufPos: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
var
  Src10: TScsiModePageTemplate2;
  pp, ps: PScsiModePageRecord;
  mp, len, dblen: integer;
begin
  if not Assigned(Buf) then
  begin
    Result := Err_InvalidArgument;
    exit;
  end;
  Result := SCSImodeSense(DeviceID, PageCode, @Src10, sizeof(Src10), Sdf);
  if Result <> Err_None then
  begin
    BufLen := 0;
    exit;
  end;
  begin
    dblen := BigEndianW(Src10.DescriptorLength10);
    len := BigEndianW(Src10.ModeDataLength10) - dblen;
    Src10.ModeDataLength10 := BigEndianW(len);
    Src10.MediumType10 := 0;
    Src10.DeviceSpecific10 := 0;
    Src10.Reserved10 := 0;
    Src10.DescriptorLength10 := 0;
    Inc(len, SizeOf(Src10.ModeDataLength10)); // Full length of record
    pp := PScsiModePageRecord(@Src10.Params10[0]);
    ps := PScsiModePageRecord(@Src10.Params10[dblen]);
    mp := ScsiModeTemplateParamsLength - 1 - dblen;
  end;
  if (mp <= BufPos) or (ps^.ParamLength <= BufPos) or (len <= 0) then
  begin
    Result := Err_Unknown;
    BufLen := 0;
    exit;
  end;
  if mp > ps^.ParamLength then
    mp := ps^.ParamLength;
  if dblen <> 0 then
    System.Move(ps^, pp^, mp + 2);
  if BufLen > (mp - BufPos) then
    BufLen := (mp - BufPos);
  System.Move(Buf^, pp^, BufLen);
  Result := SCSImodeSelect(DeviceID, @Src10, len, Sdf);
end;
{$WARNINGS ON}

function SCSImodeSenseCdStatus(DeviceID: TCDBurnerInfo;
  var ModePage: TScsiModePageCdStatus;
  var Sdf: TScsiDefaults): TScsiError;
var
  PageSize: DWORD;
begin
  ZeroMemory(@ModePage, SizeOf(ModePage));
  PageSize := SizeOf(ModePage);
  Result := SCSImodeSensePage(DeviceID, $2A, @ModePage, PageSize, 0, Sdf);
end;

{$WARNINGS OFF}

function SCSImodeSenseParameter(DeviceID: TCDBurnerInfo; PageCode: BYTE;
  Param: pointer; ParamLen, ParamPos: DWORD;
  var Sdf: TScsiDefaults): TScsiError;

var
  tp: array[0..ScsiModePageParamsLength - 1] of BYTE;
  len: DWORD;
begin
  if ((ParamPos + ParamLen) > ScsiModePageParamsLength)
    or (ParamPos < 0) or (ParamLen <= 0)
    or not Assigned(Param) then
  begin
    Result := Err_InvalidArgument;
    exit;
  end;
  len := ParamLen;
  Result := SCSImodeSensePage(DeviceID, PageCode, @tp, len, ParamPos, Sdf);
  if Result = Err_None then
  begin
    if len = ParamLen then
      BigEndian(tp, Param^, ParamLen)
    else
      Result := Err_InvalidArgument;
  end;
end;
{$WARNINGS ON}

function SCSIGetDriveSpeeds(DeviceID: TCDBurnerInfo;
  var Value: TCDReadWriteSpeeds;
  var Sdf: TScsiDefaults): TScsiError;
var
  ModePage: TScsiModePageCdStatus;
begin
  Result := SCSImodeSenseCdStatus(DeviceID, ModePage, Sdf);
  Value.MaxReadSpeed := Round(SwapWord(ModePage.MaxReadSpeed) / 176.46);
  Value.CurrentReadSpeed := Round(SwapWord(ModePage.CurrentReadSpeed) / 176.46);
  Value.MaxWriteSpeed := Round(SwapWord(ModePage.MaxWriteSpeed) / 176.46);
  Value.CurrentWriteSpeed := Round(SwapWord(ModePage.CurWriteSpeed_Res) /
    176.46);
  Value.buffersize := Round(SwapWord(ModePage.MaxBufferSize));
end;

function SCSIgetCdRomCapabilities(DeviceID: TCDBurnerInfo;
  var Value: TCdRomCapabilities;
  var Sdf: TScsiDefaults): TScsiError;

var
  ModePage: TScsiModePageCdStatus;
  FB: BYTE;
begin
  ZeroMemory(@ModePage, SizeOf(ModePage));
  Result := SCSImodeSenseCdStatus(DeviceID, ModePage, Sdf);
  Value := [];
  FB := ModePage.Flags[0];
  if (FB and CDSTATUS_READ_CD_R) <> 0 then
    Include(Value, cdcReadCDR);
  if (FB and CDSTATUS_READ_CD_RW) <> 0 then
    Include(Value, cdcReadCDRW);
  if (FB and CDSTATUS_READ_METHOD2) <> 0 then
    Include(Value, cdcReadMethod2);
  if (FB and CDSTATUS_READ_DVD_ROM) <> 0 then
    Include(Value, cdcReadDVD);
  if (FB and CDSTATUS_READ_DVD_R) <> 0 then
    Include(Value, cdcReadDVDR);
  if (FB and CDSTATUS_READ_DVD_RAM) <> 0 then
    Include(Value, cdcReadDVDRAM);

  FB := ModePage.Flags[1];
  if (FB and CDSTATUS_WRITE_CD_R) <> 0 then
    Include(Value, cdcWriteCDR);
  if (FB and CDSTATUS_WRITE_CD_RW) <> 0 then
    Include(Value, cdcWriteCDRW);
  if (FB and CDSTATUS_WRITE_DVD_R) <> 0 then
    Include(Value, cdcWriteDVDR);
  if (FB and CDSTATUS_WRITE_DVD_RAM) <> 0 then
    Include(Value, cdcWriteDVDRAM);
  if (FB and CDSTATUS_TEST_MODE) <> 0 then
    Include(Value, cdcWriteTestMode);

  FB := ModePage.Flags[2];
  if (FB and CDSTATUS_AUDIO_PLAY) <> 0 then
    Include(Value, cdcAudioPlay);
  if (FB and CDSTATUS_AUDIO_COMPOSITE) <> 0 then
    Include(Value, cdcAudioComposite);
  if (FB and CDSTATUS_AUDIO_DIGIPORT1) <> 0 then
    Include(Value, cdcAudioDigiPort1);
  if (FB and CDSTATUS_AUDIO_DIGIPORT2) <> 0 then
    Include(Value, cdcAudioDigiPort2);
  if (FB and CDSTATUS_READ_MODE2_FORM1) <> 0 then
    Include(Value, cdcReadMode2form1);
  if (FB and CDSTATUS_READ_MODE2_FORM2) <> 0 then
    Include(Value, cdcReadMode2form2);
  if (FB and CDSTATUS_READ_MULTISESSION) <> 0 then
    Include(Value, cdcReadMultisession);
  if (FB and CDSTATUS_BURN_PROOF) <> 0 then
    Include(Value, cdcWriteBurnProof);

  FB := ModePage.Flags[3];
  if (FB and CDSTATUS_CDDA_CAPABLE) <> 0 then
    Include(Value, cdcCDDAread);
  if (FB and CDSTATUS_CDDA_STREAM_ACCURATE) <> 0 then
    Include(Value, cdcCDDAaccurate);
  if (FB and CDSTATUS_CDDA_RW_SUPPORT) <> 0 then
    Include(Value, cdcSubchannelRW);
  if (FB and CDSTATUS_CDDA_RW_CORRECTED) <> 0 then
    Include(Value, cdcSubchannelCorrect);
  if (FB and CDSTATUS_CDDA_C2_POINTERS) <> 0 then
    Include(Value, cdcC2Pointers);
  if (FB and CDSTATUS_CDDA_ISRC) <> 0 then
    Include(Value, cdcCddaISRC);
  if (FB and CDSTATUS_CDDA_UPC) <> 0 then
    Include(Value, cdcCddaUPC);
  if (FB and CDSTATUS_CDDA_BARCODE) <> 0 then
    Include(Value, cdcCddaBarCode);

  FB := ModePage.Flags[4];
  if (FB and CDSTATUS_LOCK_CAPABLE) <> 0 then
    Include(Value, cdcLock);
  if (FB and CDSTATUS_LOCK_STATE) <> 0 then
    Include(Value, cdcLocked);
  if (FB and CDSTATUS_PREVENT_JUMPER) <> 0 then
    Include(Value, cdcLockJumper);
  if (FB and CDSTATUS_EJECT_CAPABLE) <> 0 then
    Include(Value, cdcEject);

  FB := ModePage.Flags[5];
  if (FB and CDSTATUS_SEPARATE_VOLUME) <> 0 then
    Include(Value, cdcSeparateVolume);
  if (FB and CDSTATUS_SEPARATE_MUTE) <> 0 then
    Include(Value, cdcSeparateMute);
  if (FB and CDSTATUS_REPORTS_HAVE_DISK) <> 0 then
    Include(Value, cdcDiskSensor);
  if (FB and CDSTATUS_SLOT_SELECTION) <> 0 then
    Include(Value, cdcSlotSelect);
  if (FB and CDSTATUS_SIDE_CHANGE) <> 0 then
    Include(Value, cdcSideChange);
  if (FB and CDSTATUS_CDDA_RW_LEAD_IN) <> 0 then
    Include(Value, cdcCddaRwLeadIn);
end;

function SCSIinquiryEX(DeviceID: TCDBurnerInfo;
  Buf: pointer; BufLen: DWORD;
  CmdDt, EVPD: BOOLEAN; PageCode: BYTE;
  var Sdf: TScsiDefaults): TScsiError;
var
  aLBA: DWORD;
  cdb: Tcdb6;
begin
  FillChar(CDB, 6, 0);

  aLBA := PageCode;
  aLBA := aLBA shl 8;
  if EVPD then
    aLBA := aLBA or $10000;
  if CmdDt then
    aLBA := aLBA or $20000;

  cdb[5] := 0;
  FillDWORD(aLBA, cdb[0]);
  cdb[4] := BufLen;
  cdb[1] := AttachLUN(cdb[1], DeviceID.DriveID);
  cdb[0] := SCSI_INQUIRY;
  Result := ASPIsend6CDB(DeviceID, cdb, Buf, BufLen, SRB_DIR_IN, Sdf);
end;

function SCSIstartStopUnit(DeviceID: TCDBurnerInfo;
  Start, LoadEject, DontWait: boolean;
  var Sdf: TScsiDefaults): TScsiError;
var
  Arg1: DWORD;
  Arg2: byte;
  SdfTemp: DWORD;
  cdb: Tcdb6;
begin
  FillChar(CDB, 6, 0);
  Arg1 := 0;
  if DontWait then
    Arg1 := $10000;
  Arg2 := 0;
  if LoadEject then
    Arg2 := 2;
  if Start then
    Arg2 := Arg2 or 1;
  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.SpindleTimeout;

  cdb[5] := 0;
  FillDWORD(Arg1, cdb[0]);
  cdb[4] := Arg2;
  cdb[1] := AttachLUN(cdb[1], DeviceID.DriveID);
  cdb[0] := SCSI_START_STP;
  Result := ASPIsend6CDB(deviceid, cdb, nil, 0, SRB_NODIR, Sdf);
  Sdf.Timeout := SdfTemp;
end;

function SCSItestReady(DeviceID: TCDBurnerInfo;
  var Sdf: TScsiDefaults): TScsiError;

var
  cdb: Tcdb6;
begin
  FillChar(CDB, 6, 0);

  cdb[1] := AttachLUN(cdb[1], DeviceID.DriveID);

  Result := ASPIsend6CDB(deviceid, cdb, nil, 0, SRB_NODIR, Sdf);
end;

procedure InquiryDecodePeripherals(Arg: BYTE; var PQ: TScsiPeripheralQualifier;
  var DeviceType: TScsiDeviceType);
begin
  PQ := TScsiPeripheralQualifier((Arg shr 5) and 7);
  Arg := Arg and $1F;
  case Arg of
    0..9: DeviceType := TScsiDeviceType(Arg);
    $1F: DeviceType := TSDInvalid
  else
    DeviceType := TSDother;
  end;
end;

procedure InquiryDecodeCompliance(Arg: BYTE;
  var Version: TScsiStandardCompliance);
begin
  with Version do
  begin
    ISO := (Arg shr 6) and 3;
    ECMA := (Arg shr 3) and 7;
    ANSI := TScsiAnsiCompliance(Arg and 7);
  end;
end;

function SCSIinquiryDeviceInfo(DeviceID: TCDBurnerInfo;
  var Info: TScsiDeviceInfo; var Sdf: TScsiDefaults): TScsiError;
const
  BufSize = 255;
var
  Buf: array[0..BufSize - 1] of BYTE;

begin

  Result := SCSIinquiryEX(DeviceID, @Buf, SizeOf(Buf),
    False, False, 0, Sdf);
  with Info do
  begin
    //      InquiryDecodePeripherals(Buf[0], PeriphQualifier, Info.DeviceType);
    Capabilities := [];
    if (Buf[1] and $80) <> 0 then
      Include(Capabilities, SDCremovableMedium);
    InquiryDecodeCompliance(Buf[2], Version);
    if (Buf[3] and $80) <> 0 then
      Include(Capabilities, SDCasyncEvent);
    if (Buf[3] and $20) <> 0 then
      Include(Capabilities, SDCnormalACA);
    if (Buf[3] and $10) <> 0 then
      Include(Capabilities, SDChierarchical);
    ResponseDataFormat := Buf[3] and $0F;
    if (Buf[5] and $80) <> 0 then
      Include(Capabilities, SDCsupportSCC);
    if (Buf[6] and $80) <> 0 then
      Include(Capabilities, SDCbasicQueuing);
    if (Buf[6] and $40) <> 0 then
      Include(Capabilities, SDCenclosure);
    if (Buf[6] and $10) <> 0 then
      Include(Capabilities, SDCmultiPort);
    if (Buf[6] and $08) <> 0 then
      Include(Capabilities, SDCmediumChanger);
    if (Buf[6] and $01) <> 0 then
      Include(Capabilities, SDCaddress16);
    if (Buf[7] and $80) <> 0 then
      Include(Capabilities, SDCrelativeAddress);
    if (Buf[7] and $20) <> 0 then
      Include(Capabilities, SDCwideBus16);
    if (Buf[7] and $10) <> 0 then
      Include(Capabilities, SDCsynchTransfer);
    if (Buf[7] and $08) <> 0 then
      Include(Capabilities, SDClinkedCommands);
    if (Buf[7] and $04) <> 0 then
      Include(Capabilities, SDCtransferDisable);
    if (Buf[7] and $02) <> 0 then
      Include(Capabilities, SDCcommandQueuing);
    ASPIstrCopy(PChar(@Buf[8]), VendorID, 8);
    ASPIstrCopy(PChar(@Buf[16]), ProductID, 16);
    ASPIstrCopy(PChar(@Buf[32]), ProductRev, 4);
    ASPIstrCopy(PChar(@Buf[36]), VendorSpecific, 20);

  end;
end;

function SCSIpreventMediumRemoval(DeviceID: TCDBurnerInfo;
  MustLock: boolean; var Sdf: TScsiDefaults): TScsiError;
var
  cdb: TCDB6;
begin
  FillChar(cdb, 6, 0);
  cdb[0] := SCSI_MED_REMOVL; {command, No Remove}
  cdb[1] := AttachLUN(cdb[1], DeviceID.DriveID);
  cdb[4] := ORD(MustLock);
  cdb[5] := 0;
  Result := ASPIsend6CDB(DeviceID, CDB, nil, 0, SRB_NODIR, Sdf);
end;

function SCSIadrByteToSubQinfoFlags(Arg: BYTE): TScsiSubQinfoFlags;
begin
  case Arg shr 4 of
    0: Result := [ssqfADRnone];
    1: Result := [ssqfADRposition];
    2: Result := [ssqfADRcatalogue];
    3: Result := [ssqfADRISRC]
  else
    Result := [];
  end;
  if (Arg and 1) <> 0 then
    Include(Result, ssqfPreEmphasis);
  if (Arg and 2) <> 0 then
    Include(Result, ssqfCopyPermit);
  case (Arg shr 2) and 3 of
    0: Include(Result, ssqfAudioTrack);
    1: Include(Result, ssqfDataTrack);
    2:
      begin
        Include(Result, ssqfAudioTrack);
        Include(Result, ssqfQuadAudio);
      end;
  end;
end;

function SCSIseek10(DeviceID: TCDBurnerInfo; GLBA: DWORD; var Sdf:
  TScsiDefaults): TScsiError;
var
  CDB: TCDB10;
begin
  FillChar(cdb, 10, 0);
  cdb[0] := SCSI_SEEK10;
  cdb[1] := AttachLUN(cdb[1], DeviceID.DriveID);
  FillDWORD(GLBA, cdb[2]);
  Result := ASPIsend10CDB(DeviceID, CDB, nil, 0, SRB_DIR_IN, Sdf);
end;

function SCSIreadCapacity(DeviceID: TCDBurnerInfo;
  var LastLBA: DWORD; var Sdf: TScsiDefaults): TScsiError;
var
  Buf: array[0..1] of DWORD;
  CDB: TCDB10;
begin
  //cdr CDB:  25 00 00 00 00 00 00 00 00 00
  FillChar(Buf, sizeof(Buf), 0);
  FillChar(cdb, 10, 0);
  cdb[0] := SCSI_RD_CAPAC;
  cdb[1] := AttachLUN(cdb[1], DeviceID.DriveID);
  FillWORD(SizeOf(Buf), cdb[7]);
  Result := ASPIsend10CDB(DeviceID, CDB, @Buf, SizeOf(Buf), SRB_DIR_IN, Sdf);
  LastLBA := BigEndianD(Buf[0]);
end;

function SCSIreadTocPmaAtipEx(DeviceID: TCDBurnerInfo;
  InMSF: boolean;
  RequestType: BYTE;
  TrackNumber: BYTE;
  Buf: pointer; BufLen: WORD;
  var Sdf: TScsiDefaults): TScsiError;
var
  Byte1: BYTE;
  DwLBA: DWORD;
  CDB: TCDB10;
begin
  FillChar(cdb, 10, 0);
  if InMSF then
    Byte1 := 2
  else
    Byte1 := 0;
  DwLBA := RequestType shl 24;

  cdb[0] := SCSI_READ_TOC;
  cdb[1] := AttachLUN(Byte1, DeviceID.DriveID);
  FillDWORD(DwLBA, cdb[2]);
  cdb[6] := TrackNumber;
  FillWORD(BufLen, cdb[7]);
  Result := ASPIsend10CDB(DeviceID, CDB, Buf, BufLen, SRB_DIR_IN, Sdf);
end;

function SCSIgetTOC(DeviceID: TCDBurnerInfo; var TOC: TScsiTOC; var Sdf:
  TScsiDefaults): TScsiError;

var
  Buf: TScsiTOCtemplate;
  i: integer;
begin
  FillChar(TOC, SizeOf(TOC), 0);
  Result := SCSIreadTocPmaAtipEx(DeviceID, False, 0, 0, @Buf, SizeOf(Buf), Sdf);
  TOC.FirstTrack := Buf.FirstTrack;
  TOC.LastTrack := Buf.LastTrack;
  TOC.TrackCount := (BigEndianW(Buf.Length) div
    SizeOf(TScsiTrackDescriptorTemplate));
  for i := 0 to Toc.TrackCount - 1 do
  begin
    TOC.Tracks[i].Flags := SCSIadrByteToSubQinfoFlags(Buf.Tracks[i].ADR);
    TOC.Tracks[i].TrackNumber := Buf.Tracks[i].TrackNumber;
    TOC.Tracks[i].AbsAddress := BigEndianD(Buf.Tracks[i].AbsAddress);
  end;
end;

function SCSIgetTOCCDText(DeviceID: TCDBurnerInfo; var TOCText: TCDText; var
  Sdf: TScsiDefaults): TScsiError;
begin
  FillChar(TOCText, SizeOf(TOCText), 0);
  Result := SCSIreadTocPmaAtipEx(DeviceID, False, $05, 0, @TOCText,
    SizeOf(TOCText), Sdf);
end;

function SCSIgetSessionInfo(DeviceID: TCDBurnerInfo;
  var Info: TScsiSessionInfo;
  var Sdf: TScsiDefaults): TScsiError;
var
  Buf: TScsiSessionInfoTemplate;
begin
  FillChar(Info, SizeOf(Info), 0);
  Result := SCSIreadTocPmaAtipEx(DeviceID, False, 1, 0, @Buf, SizeOf(Buf), Sdf);
  Info.Flags := SCSIadrByteToSubQinfoFlags(Buf.ADR);
  Info.FirstSession := Buf.FirstSession;
  Info.LastSession := Buf.LastSession;
  Info.FirstTrack := Buf.TrackNumber;
  Info.FirstTrackLBA := BigEndianD(Buf.AbsAddress);
end;

{$WARNINGS OFF}

function SCSIgetLayoutInfo(DeviceID: TCDBurnerInfo;
  var Info: TDiscLayout;
  var Sdf: TScsiDefaults): TScsiError;
var
  TempSessions: TScsiSessionInfo;
  TempTracks: TScsiTOC;
  TrackInformation, TrackInfoNext: TTrackInformation;
  BlockSize, Counter: Integer;
  TrackNo, SessionNo, Reminder: integer;
  TrStart, TrLength, TrEnd, TrSize: Integer;

begin
  SCSIgetSessionInfo(DeviceID, TempSessions, SDF);
  SetLength(Info.Sessions, TempSessions.LastSession + 1);
  Info.FirstSession := TempSessions.FirstSession;
  Info.LastSession := TempSessions.LastSession;

  SCSIgetTOC(DeviceID, TempTracks, SDF);
  BlockSize := ConvertDataBlock(MODE_1);
  Reminder := 1;

  for Counter := TempTracks.FirstTrack to TempTracks.LastTrack do
  begin
    SCSIReadTrackInformation(DeviceID, Counter, TrackInformation, SDF);
    SessionNo := TrackInformation.SessionNumber;
    if SessionNo > Reminder then
    begin
      Reminder := SessionNo;
      TrackNo := 1;
    end
    else
      TrackNo := Counter;

    if TrackInformation.TrackMode = $00 then { Audio }
    begin
      BlockSize := ConvertDataBlock(RAW_DATA_BLOCK); //BLOCK_AUDIO;
      Info.Sessions[SessionNo].Tracks[TrackNo].fType := BlockSize;
      Info.Sessions[SessionNo].Tracks[TrackNo].fTypeStr := 'Audio';
    end;
    if TrackInformation.TrackMode = $04 then { Data }
    begin
      if TrackInformation.DataMode = $01 then { Data Mode 1 }
      begin
        BlockSize := ConvertDataBlock(MODE_1);
        Info.Sessions[SessionNo].Tracks[TrackNo].fType := BlockSize;
        Info.Sessions[SessionNo].Tracks[TrackNo].fTypeStr := 'Data (Mode 1)';
      end;
      if TrackInformation.DataMode = $02 then { Data Mode 2 }
      begin
        BlockSize := ConvertDataBlock(MODE_2);
        Info.Sessions[SessionNo].Tracks[TrackNo].fType := BlockSize;
        Info.Sessions[SessionNo].Tracks[TrackNo].fTypeStr := 'Data (Mode 2)';
      end;
    end;

    TrStart := TrackInformation.TrackStartAddress;
    TrLength := TrackInformation.TrackSize;
    if SCSIReadTrackInformation(DeviceID, Counter + 1, TrackInfoNext, SDF) =
      Err_None then
      if TrackInformation.SessionNumber = TrackInfoNext.SessionNumber then
        TrLength := TrackInfoNext.TrackStartAddress -
          TrackInformation.TrackStartAddress;

    TrEnd := TrStart + TrLength;

    TrSize := LBA2MB(TrLength, BlockSize);

    Info.Sessions[SessionNo].fSize := Info.Sessions[SessionNo].fSize + TrLength;
    Info.Sessions[SessionNo].fSizeMB := LBA2MB(Info.Sessions[SessionNo].fSize,
      BlockSize);
    Info.Sessions[SessionNo].FirstTrack := 1;
    Info.Sessions[SessionNo].LastTrack := TrackNo;
    Info.Sessions[SessionNo].Tracks[TrackNo].StartAddress := TrStart;
    Info.Sessions[SessionNo].Tracks[TrackNo].Length := TrLength;
    Info.Sessions[SessionNo].Tracks[TrackNo].EndAddress := TrEnd;
    Info.Sessions[SessionNo].Tracks[TrackNo].fSizeMB := TrSize;
    Info.Sessions[SessionNo].Tracks[TrackNo].StartAddressStr :=
      LBA2HMSF(TrStart);
    Info.Sessions[SessionNo].Tracks[TrackNo].LengthStr := LBA2HMSF(TrLength);
    Info.Sessions[SessionNo].Tracks[TrackNo].EndAddressStr := LBA2HMSF(TrEnd);
  end; //track loop
end;
{$WARNINGS ON}

function SCSIreadHeaderEx(DeviceID: TCDBurnerInfo;
  InMSF: boolean; // Form of GLBA as result
  var GLBA: DWORD; // at enter: LBA to read, at exit: address of
  //   block processed, in LBA (InMSF=False) or
  //   MSF (InMSF=True) form.
  var SectorType: TScsiReadCdSectorType; // type of block, may
  // be csfAudio, csfDataMode1, csfDataMode2,
  // or csfAnyType (if error occurs) only
  var Sdf: TScsiDefaults): TScsiError;
var
  Buf: array[0..1] of DWORD;
  Byte1: BYTE;
  CDB: TCDB10;
begin
  FillChar(Buf, sizeof(Buf), 0);
  FillChar(cdb, 10, 0);
  if InMSF then
    Byte1 := 2
  else
    Byte1 := 0;

  cdb[0] := SCSI_READHEADER;
  cdb[1] := AttachLUN(Byte1, DeviceID.DriveID);
  FillDWORD(GLBA, cdb[2]);
  cdb[6] := 0;
  FillWORD(SizeOf(Buf), cdb[7]);
  cdb[9] := 0;

  Result := ASPIsend10CDB(DeviceID, CDB, @Buf, SizeOf(Buf), SRB_DIR_IN, Sdf);

  case Buf[0] and $FF of
    0: SectorType := csfAudio;
    1: SectorType := csfDataMode1;
    2: SectorType := csfDataMode2
  else
    SectorType := csfAnyType;
  end;
  GLBA := BigEndianD(Buf[1]);
end;

function SCSIreadHeader(DeviceID: TCDBurnerInfo; GLBA: DWORD;
  var SectorType: TScsiReadCdSectorType; // type of block, may
  // be csfAudio, csfDataMode1, csfDataMode2,
  // or csfAnyType (if error occurs) only
  var Sdf: TScsiDefaults): TScsiError;
var
  iLBA: Cardinal;
begin
  iLBA := GLBA;
  Result := SCSIreadHeaderEx(DeviceID, False, iLBA, SectorType, Sdf);
end;

function SCSIreadSubChannelEx(DeviceID: TCDBurnerInfo;
  InMSF: boolean; // Form of resulting GLBA
  GetSubQ: boolean; // requests the Q sub-channel data if True
  RequestType: BYTE;
  TrackNumber: BYTE;
  Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
var
  Byte1: BYTE;
  DwLBA: DWORD;
  CDB: TCDB10;
begin
  FillChar(Buf^, BufLen, 0);
  FillChar(cdb, 10, 0);
  if InMSF then
    Byte1 := 2
  else
    Byte1 := 0;
  DwLBA := RequestType shl 16;
  if GetSubQ then
    DwLBA := DwLBA or $40000000;

  cdb[0] := SCSI_SUBCHANNEL;
  cdb[1] := AttachLUN(Byte1, DeviceID.DriveID);
  FillDWORD(DwLBA, cdb[2]);
  cdb[6] := TrackNumber;
  FillWORD(SizeOf(Buf), cdb[7]);
  cdb[9] := 0;

  Result := ASPIsend10CDB(DeviceID, CDB, @Buf, SizeOf(Buf), SRB_DIR_IN, Sdf);

end;

{function SCSIread10EX(DeviceID: TCDBurnerInfo;
  DisablePageOut, ForceUnitAccess: boolean;
  GLBA, SectorCount: DWORD; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
var
  Arg1: byte;
  SdfTemp: DWORD;
  CDB: TCDB10;
begin
  FillChar(cdb, 10, 0);
  Arg1 := 0;
  if DisablePageOut then Arg1 := $10;
  if ForceUnitAccess then Arg1 := Arg1 or 8;
  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;

  cdb[0] := SCSI_READ10;
  cdb[1] := AttachLUN(Arg1, DeviceID.DriveID);
  FillDWORD(GLBA, cdb[2]);
  cdb[6] := 0;
  FillWORD(SectorCount, cdb[7]);
  cdb[9] := 0;
  Result := ASPIsend10CDB(DeviceID, CDB, Buf, SizeOf(Buf), SRB_DIR_IN, Sdf);
  Sdf.Timeout := SdfTemp;
end;   }

function SCSIread10EX(DeviceID : TCDBurnerInfo;
              DisablePageOut, ForceUnitAccess : boolean;
              GLBA, SectorCount : DWORD; Buf : pointer; BufLen : DWORD;
              var Sdf : TScsiDefaults) : TScsiError;
var Arg1    : byte;
    SdfTemp : DWORD;
begin
   Arg1 := 0;
   if DisablePageOut  then Arg1 := $10;
   if ForceUnitAccess then Arg1 := Arg1 OR 8;
   SdfTemp     := Sdf.Timeout;
   Sdf.Timeout := Sdf.ReadTimeout;
   Result := ASPIsend10(DeviceID, $28, Arg1, GLBA, 0, SectorCount,
                        Buf, BufLen, SRB_DIR_IN, Sdf);
   Sdf.Timeout := SdfTemp;
end;

function SCSIread10(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: DWORD; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
begin
  Result := SCSIread10EX(DeviceID, False, False,
    GLBA, SectorCount, Buf, BufLen, Sdf);
end;

function SCSIheaderByteToAudioStatus(Arg: BYTE): TScsiAudioStatus;
begin
  case Arg and $FF of
    0: Result := sasInvalid;
    $11: Result := sasPlay;
    $12: Result := sasPause;
    $13: Result := sasCompleted;
    $14: Result := sasError;
    $15: Result := sasStop;
  else
    Result := sasUnknown;
  end;
end;

function SCSIgetISRC(DeviceID: TCDBurnerInfo; TrackNumber: BYTE;
  var Info: TScsiISRC;
  var Sdf: TScsiDefaults): TScsiError;
var
  Buf: TScsiISRCTemplate;
  SdfTemp: DWORD;
begin
  FillChar(Info, SizeOf(Info), 0);
  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;
  Result := SCSIreadSubChannelEx(DeviceID, False, True, 3, TrackNumber,
    @Buf, SizeOf(Buf), Sdf);
  Sdf.Timeout := SdfTemp;
  Info.Status := SCSIheaderByteToAudioStatus(Buf.sitStatus);
  Info.Flags := SCSIadrByteToSubQinfoFlags(Buf.sitADR);
  if (Buf.sitValid and $80) <> 0 then
  begin // MCN is valid
    ASPIstrCopy(@Buf.sitNumber[0], Info.IsrcNumber, 12);
    Info.FrameNumber := Buf.sitAFrame;
  end;
end;

function SCSIreadCdFlagsToByte9(Flags: TScsiReadCdFormatFlags): BYTE;
begin
  Result := 0;
  if cffSync in Flags then
    Result := Result or $80;
  if cffSubheader in Flags then
    Result := Result or $40;
  if cffHeader in Flags then
    Result := Result or $20;
  if cffUserData in Flags then
    Result := Result or $10;
  if cffEDCandECC in Flags then
    Result := Result or 8;
  if cffC2errorBits in Flags then
  begin
    if cffBlockErrByte in Flags then
      Result := Result or 4
    else
      Result := Result or 2;
  end;
end;

function SCSIreadCdFlagsToSize(SectorType: TScsiReadCdSectorType;
  Flags: TScsiReadCdFormatFlags): integer;
const
  SectorSize: array[0..31, 0..3] of integer =
  ((-1, -1, -1, -1), (-1, -1, -1, -1), (2048, 2336, 2048, 2328), (2336, 2336,
    2328, 2328),
    (4, 4, 4, 4), (-1, -1, -1, -1), (2052, 2340, -1, -1), (2340, 2340, -1, -1),
    (0, 0, 8, 8), (-1, -1, -1, -1), (2048, 2336, 2056, 2336), (2336, 2336, 2336,
    2336),
    (4, 4, 12, 12), (-1, -1, -1, -1), (2052, 2340, 2060, 2340), (2340, 2340,
    2340, 2340),
    (-1, -1, -1, -1), (-1, -1, -1, -1), (-1, -1, -1, -1), (-1, -1, -1, -1),
    (16, 16, 16, 16), (-1, -1, -1, -1), (2064, 2352, -1, -1), (2352, 2352, -1,
    -1),
    (-1, -1, -1, -1), (-1, -1, -1, -1), (-1, -1, -1, -1), (-1, -1, -1, -1),
    (16, 16, 24, 24), (-1, -1, -1, -1), (2064, 2352, 2072, 2352), (2352, 2352,
    2352, 2352));
begin
  if SectorType in [csfAnyType, csfAudio] then
    Result := 2352
  else
    Result :=
      SectorSize[SCSIreadCdFlagsToByte9(Flags) shr 3, ORD(SectorType) - 2];
  if Result = -1 then
    exit;
  if cffC2errorBits in Flags then
  begin
    Inc(Result, 294);
    if cffBlockErrByte in Flags then
      Inc(Result, 2);
  end;
  if cffSubchannelQ in Flags then
  begin
    if (cffSubchannelRaw in Flags) or (cffSubchannelPW in Flags) then
      Result := -1
    else
      Inc(Result, 16);
  end
  else
  begin
    if cffSubchannelRaw in Flags then
    begin
      if cffSubchannelPW in Flags then
        Result := -1
      else
        Inc(Result, 96);
    end
    else if cffSubchannelPW in Flags then
      Inc(Result, 96);
  end;
end;

{$WARNINGS OFF}

function SCSIWriteCdEX(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: DWORD;
  SectorType: TScsiReadCdSectorType;
  Flags: TScsiReadCdFormatFlags;
  Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
var
  CDB: TCDB12;
  dummy: byte;
  i: integer;
  SdfTemp: DWORD;
begin
  FillChar(cdb, 12, 0);
  cdb[9] := SCSIreadCdFlagsToByte9(Flags);
  i := SCSIreadCdFlagsToSize(SectorType, Flags);
  if (i <= 0) or (SectorCount <= 0)
    or (BufLen < (SectorCount * i))
    or not Assigned(Buf) then
  begin
    Result := Err_InvalidArgument;
    exit;
  end;
  FillChar(Buf^, BufLen, 0);
  cdb[0] := $BE;
  cdb[1] := ORD(SectorType) shl 2;
  ScatterDWORD(GLBA, cdb[2], cdb[3], cdb[4], cdb[5]);
  ScatterDWORD(SectorCount, dummy, cdb[6], cdb[7], cdb[8]);
  if cffSubchannelRaw in Flags then
    cdb[10] := 1
  else if cffSubchannelQ in Flags then
    cdb[10] := 2
  else if cffSubchannelPW in Flags then
    cdb[10] := 4
  else
    cdb[10] := 0;
  cdb[11] := 0;
  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;
  Result := ASPIsend12CDB(DeviceID, CDB, @Buf, SizeOf(Buf), SRB_DIR_OUT, Sdf);
  Sdf.Timeout := SdfTemp;
end;
{$WARNINGS ON}

{$WARNINGS OFF}

function SCSIreadCdEX(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: DWORD;
  SectorType: TScsiReadCdSectorType;
  Flags: TScsiReadCdFormatFlags;
  Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
var
  CDB: TCDB12;
  dummy: byte;
  i: integer;
  SdfTemp: DWORD;
begin
  FillChar(cdb, 12, 0);
  cdb[9] := SCSIreadCdFlagsToByte9(Flags);
  i := SCSIreadCdFlagsToSize(SectorType, Flags);
  if (i <= 0) or (SectorCount <= 0)
    or (BufLen < (SectorCount * i))
    or not Assigned(Buf) then
  begin
    Result := Err_InvalidArgument;
    exit;
  end;
  FillChar(Buf^, BufLen, 0);
  cdb[0] := $BE;
  cdb[1] := ORD(SectorType) shl 2;
  ScatterDWORD(GLBA, cdb[2], cdb[3], cdb[4], cdb[5]);
  ScatterDWORD(SectorCount, dummy, cdb[6], cdb[7], cdb[8]);
  if cffSubchannelRaw in Flags then
    cdb[10] := 1
  else if cffSubchannelQ in Flags then
    cdb[10] := 2
  else if cffSubchannelPW in Flags then
    cdb[10] := 4
  else
    cdb[10] := 0;
  cdb[11] := 0;
  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;

  Result := ASPIsend12CDB(DeviceID, CDB, Buf, BufLen, SRB_DIR_IN, Sdf);
  Sdf.Timeout := SdfTemp;
end;
{$WARNINGS ON}

//+++++++++++++++++++++++++ writing functions +++++++++++++++++++++++++

{Function SCSISetWriteParameters(DevID :TCDBurnerInfo;Size: Integer;
Write_Type,Data_Block_type,Track_Mode,Session_Format : integer;
Packet_Size,Audio_Pause_Length : integer; Test_Write, Burn_Proof : Boolean;
                     var Sdf : TScsiDefaults) : TScsiError;

var
   Buf : TScsiWriteModePage;
   bufsize : DWord;
   BufPos : Cardinal;
   BurnProofTestWrite : Byte;

begin
   BufSize := 60;
   BurnProofTestWrite := 0;

//CDB:  55 10 00 00 00 00 00 00 3C 00
//Sending 60 (0x3C) bytes of data.
//Write Data:  00 00 20 00 00 00 00 00 05 32 01 04 08 00 00 00 00 00 00 00 00 00 00 96 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00

   FillChar(Buf,Sizeof(Buf),0);
  // Result := SCSImodeSensePage(DevID,$05,@Buf,BufSize,0,Sdf);
   Result := SCSImodeSense(DevID,$05,@Buf,BufSize,sdf);

   BufPos := 0;
   if Result <> Err_None then exit;
          FillChar(Buf.ResvBytes,Sizeof(Buf.ResvBytes),0);
          Buf.ResvBytes[3] := $20;
          Buf.PSPageCode := $05;
          Buf.PageLength := $32;       //lsb
          BufSize := 60;
         // if (Test_Write = True) then BurnProofTestWrite := 16;
         // if (Burn_Proof = True) then BurnProofTestWrite := BurnProofTestWrite + 64;

          Buf.TestFlagWriteType :=  Write_Type + BurnProofTestWrite;
          Buf.MSFPCopyTrackMode := Track_Mode;
          Buf.DataBlockType := Data_Block_type;
          Buf.HostApplicationCode := 0;
          Buf.SessionFormat := Session_Format;
          Buf.PacketSize := Packet_Size;
          Buf.AudioPauseLength := Audio_Pause_Length;

          FillChar(Buf.MediaCatalogNumber,Sizeof(Buf.MediaCatalogNumber),0);
          FillChar(Buf.InternationalStandardRecordingCode,
            SizeOf(Buf.InternationalStandardRecordingCode),0);
          FillChar(Buf.SubHeader,Sizeof(Buf.SubHeader),0);
          sdf.ModePageType := MPTchangeable;
          Result := SCSImodeSelect(DevID,@Buf,BufSize,sdf);
          //Result := SCSImodeSelectPage(DevID,$05,@Buf,BufSize,0,sdf);
end;  }

function SCSISetWriteParameters(DevID: TCDBurnerInfo; Size: Integer;
  Write_Type, Data_Block_type, Track_Mode, Session_Format: integer;
  Packet_Size, Audio_Pause_Length: integer; Test_Write, Burn_Proof: Boolean;
  var Sdf: TScsiDefaults): TScsiError;

var
  Buf: TScsiWriteModePage;
  bufsize: DWord;
begin
  BufSize := sizeof(Buf);
  {get current params}
  Result := SCSImodeSensePage(DevID, $05, @Buf, BufSize, 0, Sdf);
  {reset params to new settings}
  Sdf.ModePageType := MPTchangeable;
  if Result <> Err_None then
    exit;
  Buf.PSPageCode := $05;
  Buf.PageLength := $32; //$32;
  Buf.TestFlagWriteType := Write_Type; //Write_Type;

  if Test_Write = True then
    Buf.TestFlagWriteType := BitOn(Buf.TestFlagWriteType, 4)
  else if IsBitSet(Buf.TestFlagWriteType, 4) then
    BitOFF(Buf.TestFlagWriteType, 4);

  if Burn_Proof = True then
    Buf.TestFlagWriteType := BitOn(Buf.TestFlagWriteType, 6)
  else if IsBitSet(Buf.TestFlagWriteType, 6) then
    BitOFF(Buf.TestFlagWriteType, 6);

  Buf.MSFPCopyTrackMode := Track_Mode;

  Buf.DataBlockType := Data_Block_type;
  Buf.HostApplicationCode := 0;
  Buf.SessionFormat := Session_Format;
  Buf.PacketSize := Packet_Size;
  Buf.AudioPauseLength := SwapWord(Audio_Pause_Length);

  FillChar(Buf.MediaCatalogNumber, Sizeof(Buf.MediaCatalogNumber), 0);
  FillChar(Buf.InternationalStandardRecordingCode,
    SizeOf(Buf.InternationalStandardRecordingCode), 0);
  FillChar(Buf.SubHeader, Sizeof(Buf.SubHeader), 0);
  {Reset to new parameters }
  Result := SCSImodeSelectPage(DevID, $05, @Buf, BufSize, 0, sdf);
end;


function SCSIWrite10EX(DeviceID: TCDBurnerInfo;
  DisablePageOut, ForceUnitAccess: boolean;
  GLBA, SectorCount: WORD; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
var
  Arg1: byte;
  SdfTemp: DWORD;
  CDB: TCDB10;
begin
  //cdr CDB:  2A 00 00 00 00 00 00 00 1F 00
  FillChar(cdb, 10, 0);
  Arg1 := 0;
  if DisablePageOut then
    Arg1 := $10;
  if ForceUnitAccess then
    Arg1 := Arg1 or 8;
  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;

  cdb[0] := SCSI_WRITE10;
  cdb[1] := AttachLUN(Arg1, DeviceID.DriveID);
  FillDWORD(GLBA, cdb[2]);
  cdb[7] := HiByte(SectorCount);
  cdb[8] := LoByte(SectorCount);

  Result := ASPIsend10CDB(DeviceID, CDB, Buf, BufLen, SRB_DIR_OUT, Sdf);
  Sdf.Timeout := SdfTemp;
end;

function SCSIWrite10(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: WORD; Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
begin
  Result := SCSIWrite10EX(DeviceID, False, False,
    GLBA, SectorCount, Buf, BufLen, Sdf);
end;

function SCSIWriteCDDA(DeviceID: TCDBurnerInfo;
  GLBA, SectorCount: DWORD;
  SectorType: TScsiReadCdSectorType;
  Flags: TScsiReadCdFormatFlags;
  Buf: pointer; BufLen: DWORD;
  var Sdf: TScsiDefaults): TScsiError;
var
  SdfTemp: DWORD;
begin
  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;
  Result := SCSIWrite10EX(DeviceID, False, False,
    GLBA, SectorCount, Buf, BufLen, Sdf);
  Sdf.Timeout := SdfTemp;
end;

function SCSIBlankCD(DeviceID: TCDBurnerInfo; BlankType: byte; LBA: longint;
  var Sdf: TScsiDefaults): TScsiError;
var
  cdb: TCDB6;
  m_lba: longint;
begin
  m_lba := LBA;
  FillChar(cdb, 6, 0);
  cdb[0] := AC_BLANK; {command, Blank}
  cdb[1] := BlankType; {blanktype}
  cdb[2] := (m_lba shr 24) and $FF;
  cdb[3] := (m_lba shr 16) and $FF;
  cdb[4] := (m_lba shr 8) and $FF;
  cdb[5] := m_lba and $FF;
  Result := ASPIsend6CDB(DeviceID, CDB, nil, 0, SRB_DIR_IN, Sdf);
end;

function SCSIReadBuffer(DeviceID: TCDBurnerInfo;
  Buf: pointer; var Sdf: TScsiDefaults): TScsiError;
var
  CDB: TCDB10;

begin
  FillChar(cdb, 10, 0);
  cdb[0] := SCSI_READ_BUFF;
  cdb[1] := $00;
  cdb[2] := $00;
  Result := ASPIsend10CDB(DeviceID, CDB, Buf, SizeOf(Buf), SRB_DIR_IN, Sdf);
end;

function SCSIReadBufferCapacity(DeviceID: TCDBurnerInfo;
  Buf: pointer; var Sdf: TScsiDefaults): TScsiError;
var
  CDB: TCDB10;

begin
  FillChar(cdb, 10, 0);
  cdb[0] := SCSI_READ_BUFFER_CAP;
  cdb[8] := SizeOf(TScsiCDBufferInfo);
  Result := ASPIsend10CDB(DeviceID, CDB, Buf, SizeOf(TScsiCDBufferInfo),
    SRB_DIR_IN, Sdf);
end;

function SCSIgetMaxBufferSize(DeviceID: TCDBurnerInfo;
  var Value: WORD; var Sdf: TScsiDefaults): TScsiError;
begin
  Result := SCSIReadBufferCapacity(DeviceID, @Value, Sdf);
end;

function SCSIgetBufferCapacity(DeviceID: TCDBurnerInfo;
  var Value: TScsiCDBufferInfo; var Sdf: TScsiDefaults): TScsiError;
begin
  Result := SCSIReadBufferCapacity(DeviceID, @Value, sdf);
end;

function SCSIgetBufferSize(DeviceID: TCDBurnerInfo;
  var Value: WORD; var Sdf: TScsiDefaults): TScsiError;
begin
  Result := SCSIReadBuffer(DeviceID, @Value, Sdf);
end;

function SCSICloseSession(DeviceID: TCDBurnerInfo; var Sdf: TScsiDefaults):
  TScsiError;
var
  cdb: TCDB6;
begin
  FillChar(cdb, 6, 0);
  cdb[0] := AC_CLOSETRACKSESSION; {command}
  cdb[1] := $01;
  cdb[2] := CLOSE_SESSION;
  Result := ASPIsend6CDB(DeviceID, CDB, nil, 0, SRB_DIR_IN, Sdf);
end;

function SCSICloseTrack(DeviceID: TCDBurnerInfo; Track: byte;
  var Sdf: TScsiDefaults): TScsiError;
var
  cdb: TCDB6;
begin
  FillChar(cdb, 6, 0);
  cdb[0] := AC_CLOSETRACKSESSION; {command}
  cdb[1] := $01;
  cdb[2] := CLOSE_TRACK;
  cdb[5] := Track;
  Result := ASPIsend6CDB(DeviceID, CDB, nil, 0, SRB_DIR_IN, Sdf);
end;

function SCSISYNCCACHE(DeviceID: TCDBurnerInfo; var Sdf: TScsiDefaults):
  TScsiError;
var
  cdb: TCDB10;
begin
  FillChar(cdb, 10, 0);
  cdb[0] := SCSI_SYNC_CACHE; {command}
  cdb[1] := $01;
  Result := ASPIsend10CDB(DeviceID, CDB, nil, 0, SRB_DIR_IN, Sdf);
end;


function SCSIFormatCD(DeviceID: TCDBurnerInfo; BlankType: byte; LBA: longint;
  var Sdf: TScsiDefaults): TScsiError;
var
  cdb: TCDB6;
  m_lba: longint;
begin
  m_lba := LBA;
  FillChar(cdb, 6, 0);
  cdb[0] := SCSI_FORMAT; {command}
  cdb[1] := BlankType; {blanktype}
  cdb[2] := (m_lba shr 24) and $FF;
  cdb[3] := (m_lba shr 16) and $FF;
  cdb[4] := (m_lba shr 8) and $FF;
  cdb[5] := m_lba and $FF;
  Result := ASPIsend6CDB(DeviceID, CDB, nil, 0, SRB_DIR_IN, Sdf);
end;


function SCSISendCUESheet(DeviceID: TCDBurnerInfo;
  Buf: pointer; BufSize : Longint; var Sdf: TScsiDefaults): TScsiError;
var
  CDB: TCDB10;
begin
  FillChar(cdb, 10, 0);
  cdb[0] := SCSI_SEND_CUE_SHEET;
  cdb[6] := (BufSize shr 16) and $FF;
  cdb[7] := (BufSize shr 8) and $FF;
  cdb[8] :=  BufSize and $FF;
  Result := ASPIsend10CDB(DeviceID, CDB, Buf, BufSize, SRB_DIR_IN, Sdf);
end;



function SCSISetSpeed(DevID: TCDBurnerInfo; ReadSpeed, WriteSpeed: Integer;
  var Sdf: TScsiDefaults): TScsiError;
var
  cdb: TCDB12;
  Lun: Byte;
begin
  //cdr CDB:  BB 00 FF FF 08 4C 00 00 00 00 00 00
  Lun := 0;
  FillChar(cdb, 12, 0);
  cdb[0] := AC_SETCDSPEED; {command }
  cdb[1] := AttachLUN(Lun, DevID.DriveID);
  cdb[2] := (ReadSpeed shr 8);
  cdb[3] := ReadSpeed;
  cdb[4] := (WriteSpeed shr 8);
  cdb[5] := WriteSpeed;
  Result := ASPIsend12CDB(Devid, CDB, nil, 0, SRB_DIR_OUT, Sdf);
end;

function ScsiGetWriteParams(DevID: TCDBurnerInfo; Size: Integer; var Param:
  string;
  var Sdf: TScsiDefaults): TScsiError;
var
  ModePage: TScsiWriteModePage;
  BufSize: DWord;
begin
  BufSize := sizeof(ModePage);
  fillchar(ModePage, Bufsize, 0);
  {get current params}
  Sdf.ModePageType := MPTcurrent;
  Result := SCSImodeSensePage(DevID, $05, @ModePage, BufSize, 0, Sdf);

  Param := 'Get CD/DVD Writer Parameters : Failed';
  if Result <> Err_None then
    exit;

  Param := 'Test Write :  ';
  if IsBitSet(ModePage.TestFlagWriteType, 4) = true then
    Param := Param + 'Test Write is ON' + #10#13
  else
    Param := Param + 'Test Write is OFF' + #10#13;

  Param := Param + 'Buffer Underrun :  ';
  if IsBitSet(ModePage.TestFlagWriteType, 6) = true then
    Param := Param + 'BurnProof is ON' + #10#13
  else
    Param := Param + 'BurnProof is OFF' + #10#13;

  Param := Param + 'Write Type :  ';
  case (ModePage.TestFlagWriteType and $0F) of
    0: Param := Param + 'Packet/Incremental' + #10#13;
    1: Param := Param + 'Track At Once (TAO)' + #10#13;
    2: Param := Param + 'Session At Once (SAO)' + #10#13;
    3: Param := Param + 'Raw Data Burn' + #10#13;
  else
    Param := Param + 'Unknown Write Mode' + #10#13;
  end; //Case

  Param := Param + 'Multisession :  ';

  case (ModePage.MSFPCopyTrackMode shr 6) of
    3: Param := Param + 'Next Session Allowed / ON' + #10#13;
  else
    Param := Param + 'Next Session Not Allowed / OFF' + #10#13;

  end; //Case

  Param := Param + 'Packet Type :  ';
  case (ModePage.MSFPCopyTrackMode and $20) of
    1: Param := Param + 'Fixed Size Packets' + #10#13;
  else
    Param := Param + 'Variable Size Packets' + #10#13;

  end; //Case
  Param := Param + 'Packet Size :  ' + inttostr(ModePage.PacketSize) + #10#13;

  Param := Param + 'Session Type :  ';
  case (ModePage.SessionFormat) of
    $00: Param := Param + 'CD-DA or CDROM Disk' + #10#13;
    $01: Param := Param + 'CDI Video Disk' + #10#13;
    $32: Param := Param + 'CDROM XA Disk' + #10#13;
  else
    Param := Param + 'Unknown Session Mode' + #10#13;
  end; //Case
  Param := Param + 'Audio Pause Length :  ' +
    inttostr(SwapWord(ModePage.AudioPauseLength)) + #10#13;
  Param := Param + 'Data Block :  ' + inttostr(ModePage.DataBlockType) + #10#13;
end;

//+++++++++++++++++++++++++ End writing functions +++++++++++++++++++++++++

//New Added DVD Functions

function SCSIGetDevConfigProfileMedia(DeviceID: TCDBurnerInfo; var
  ProfileDevDiscType: TScsiProfileDeviceDiscTypes; var Sdf: TScsiDefaults):
  TScsiError;
var
  cdb: array[0..9] of BYTE;
  Buf: Pointer;
  BufLen, CdbLen, SdfTemp: DWORD;
  DeviceConfigHeader: TScsiDeviceConfigHeader;
begin
  ZeroMemory(@DeviceConfigHeader, SizeOf(DeviceConfigHeader));
  Buf := @DeviceConfigHeader;
  BufLen := SizeOf(DeviceConfigHeader);
  cdbLen := DWORD(10);
  cdb[0] := $46;
  cdb[1] := $02;
  cdb[3] := $00;
  cdb[7] := ((SizeOf(DeviceConfigHeader) shr 8) and $FF);
  cdb[8] := (SizeOf(DeviceConfigHeader) and $FF);

  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;

  Result := ASPIsendScsiCommand(DeviceID, @cdb, CdbLen,
    Buf, BufLen, SRB_DIR_IN, Sdf);
  Sdf.Timeout := SdfTemp;

  if Result = Err_SenseIllegalRequest then
    Exit;

  //  from Profile features in MS-DDK header ntddmmc.h
  case ((DeviceConfigHeader.CurrentProfile shl 8) and $FF00) or
    ((DeviceConfigHeader.CurrentProfile shr 8) and $00FF) of
    $0000:
      begin
        ProfileDevDiscType.SubType := 'pdtNoCurrentProfile';
        ProfileDevDiscType.DType := 'NONE';
        ProfileDevDiscType.TypeNum := 0;
      end;
    $0001:
      begin
        ProfileDevDiscType.SubType := 'pdtNonRemovableDisk';
        ProfileDevDiscType.DType := 'NonRemovable';
        ProfileDevDiscType.TypeNum := 1;
      end;
    $0002:
      begin
        ProfileDevDiscType.SubType := 'pdtRemovableDisk';
        ProfileDevDiscType.DType := 'Removable';
        ProfileDevDiscType.TypeNum := 2;
      end;
    $0003:
      begin
        ProfileDevDiscType.SubType := 'pdtMagnetoOptical_Erasable';
        ProfileDevDiscType.DType := 'Erasable';
        ProfileDevDiscType.TypeNum := 3;
      end;
    $0004:
      begin
        ProfileDevDiscType.SubType := 'pdtOptical_WriteOnce';
        ProfileDevDiscType.DType := 'WriteOnce';
        ProfileDevDiscType.TypeNum := 4;
      end;
    $0005:
      begin
        ProfileDevDiscType.SubType := 'pdfAS-MO';
        ProfileDevDiscType.DType := 'AS-MO';
        ProfileDevDiscType.TypeNum := 5;
      end;
    $0008:
      begin
        ProfileDevDiscType.SubType := 'pdfCD-ROM';
        ProfileDevDiscType.DType := 'CD-ROM';
        ProfileDevDiscType.TypeNum := 6;
      end;
    $0009:
      begin
        ProfileDevDiscType.SubType := 'pdfCD-R';
        ProfileDevDiscType.DType := 'CD-R';
        ProfileDevDiscType.TypeNum := 7;
      end;
    $000A:
      begin
        ProfileDevDiscType.SubType := 'pdfCD-RW';
        ProfileDevDiscType.DType := 'CD-RW';
        ProfileDevDiscType.TypeNum := 8;
      end;
    $0010:
      begin
        ProfileDevDiscType.SubType := 'pdfDVD-ROM';
        ProfileDevDiscType.DType := 'DVD-ROM';
        ProfileDevDiscType.TypeNum := 9;
      end;
    $0011:
      begin
        ProfileDevDiscType.SubType := 'pdfDVD-R';
        ProfileDevDiscType.DType := 'DVD-R';
        ProfileDevDiscType.TypeNum := 10;
      end;
    $0012:
      begin
        ProfileDevDiscType.SubType := 'pdfDVD-RAM';
        ProfileDevDiscType.DType := 'DVD-RAM';
        ProfileDevDiscType.TypeNum := 11;
      end;
    $0013:
      begin
        ProfileDevDiscType.SubType := 'pdfDVD-RW Restricted';
        ProfileDevDiscType.DType := 'DVD-RW Restricted Overwrite';
        ProfileDevDiscType.TypeNum := 13;
      end;
    $0014:
      begin
        ProfileDevDiscType.SubType := 'pdfDVD-RW Sequential';
        ProfileDevDiscType.DType := 'DVD-RW Sequential Recording';
        ProfileDevDiscType.TypeNum := 14;
      end;
    $001A:
      begin
        ProfileDevDiscType.SubType := 'pdfDVD+RW';
        ProfileDevDiscType.DType := 'DVD+RW';
        ProfileDevDiscType.TypeNum := 15;
      end;
    $001B:
      begin
        ProfileDevDiscType.SubType := 'pdfDVD+R';
        ProfileDevDiscType.DType := 'DVD+R';
        ProfileDevDiscType.TypeNum := 16;
      end;
    $0020:
      begin
        ProfileDevDiscType.SubType := 'pdfDDCD-ROM';
        ProfileDevDiscType.DType := 'DDCD-ROM';
        ProfileDevDiscType.TypeNum := 17;
      end;
    $0021:
      begin
        ProfileDevDiscType.SubType := 'pdfDDCD-R';
        ProfileDevDiscType.DType := 'DDCD-R';
        ProfileDevDiscType.TypeNum := 18;
      end;
    $0022:
      begin
        ProfileDevDiscType.SubType := 'pdfDDCD-RW';
        ProfileDevDiscType.DType := 'DDCD-RW';
        ProfileDevDiscType.TypeNum := 19;
      end;
    $FFFF:
      begin
        ProfileDevDiscType.SubType := 'pdfUNKNOWN';
        ProfileDevDiscType.DType := 'UNKNOWN';
        ProfileDevDiscType.TypeNum := 20;
      end;
  end;
end;


function SwapDWord(const AValue: LongWord): LongWord;
begin
  Result := ((AValue shl 24) and $FF000000) or
    ((AValue shl 8) and $00FF0000) or
    ((AValue shr 8) and $0000FF00) or
    ((AValue shr 24) and $000000FF);
end;


function EndianToIntelBytes(const AValue: array of Byte; Count: Byte): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Result := (AValue[I] shl ((Count - (I + 1)) * 8) or Result);
  end;
end;

function SCSIReadDVDStructure(DeviceID: TCDBurnerInfo; var DescriptorStr:
  TScsiDVDLayerDescriptorInfo; var Sdf: TScsiDefaults): TScsiError;
var
  cdb: array[0..9] of BYTE;
  Buf: Pointer;
  BufLen, CdbLen, SdfTemp: DWORD;
  DVDLayerDescriptor: TScsiDVDLayerDescriptor;
  Value: Byte;

begin
  // 1st time we query length of returned data
  ZeroMemory(@DVDLayerDescriptor, SizeOf(DVDLayerDescriptor));
  Buf := @DVDLayerDescriptor;
  BufLen := SizeOf(DVDLayerDescriptor);
  cdbLen := DWORD(10);
  cdb[0] := $AD;
  cdb[6] := 0; //* First layer
  cdb[7] := 0;
  cdb[8] := ((SizeOf(DVDLayerDescriptor) shr 8) and $FF);
  cdb[9] := (SizeOf(DVDLayerDescriptor) and $FF);

  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;

  Result := ASPIsendScsiCommand(DeviceID, @cdb, CdbLen,
    Buf, BufLen, SRB_DIR_IN, Sdf);
  Sdf.Timeout := SdfTemp;

  if Result = Err_SenseIllegalRequest then
    Exit;

  // now we do the real query
  ZeroMemory(@DVDLayerDescriptor, SizeOf(DVDLayerDescriptor));
  Buf := @DVDLayerDescriptor;
  BufLen := SizeOf(DVDLayerDescriptor);
  CdbLen := DWORD(10);
  cdb[0] := $AD;
  cdb[6] := 0; //* First layer
  cdb[7] := 0;
  cdb[8] := ((SizeOf(DVDLayerDescriptor) shr 8) and $FF);
  cdb[9] := (SizeOf(DVDLayerDescriptor) and $FF);

  Result := ASPIsendScsiCommand(DeviceID, @cdb, CdbLen,
    Buf, BufLen, SRB_DIR_IN, Sdf);
  Sdf.Timeout := SdfTemp;

  Value := (DVDLayerDescriptor.BookType_PartVersion shr 4) and $0F;
  case Value of
    $00: DescriptorStr.BookType := 'DVD-ROM';
    $01: DescriptorStr.BookType := 'DVD-RAM';
    $02: DescriptorStr.BookType := 'DVD-R';
    $03: DescriptorStr.BookType := 'DVD-RW';
    $09: DescriptorStr.BookType := 'DVD+RW';
    $0A: DescriptorStr.BookType := 'DVD+R';
  else
    DescriptorStr.BookType := 'Unknown';
  end;

  Value := (DVDLayerDescriptor.DiscSize_MaximumRate shr 4) and $0F;
  case Value of
    $00: DescriptorStr.DiscSize := '120mm';
    $01: DescriptorStr.DiscSize := '80mm';
  else
    DescriptorStr.DiscSize := 'Unknown';
  end;

  Value := (DVDLayerDescriptor.DiscSize_MaximumRate and $0F);
  case Value of
    $00: DescriptorStr.MaximumRate := '2.52 Mbps';
    $01: DescriptorStr.MaximumRate := '5.04 Mbps';
    $02: DescriptorStr.MaximumRate := '10.08 Mbps';
    $0F: DescriptorStr.MaximumRate := 'Not Specified';
  else
    DescriptorStr.MaximumRate := 'Unknown';
  end;

  Value := (DVDLayerDescriptor.LinearDensity_TrackDensity shr 4) and $0F;
  case Value of
    $00: DescriptorStr.LinearDensity := '0.267 um/bit';
    $01: DescriptorStr.LinearDensity := '0.293 um/bit';
    $02: DescriptorStr.LinearDensity := '0.409 to 0.435 um/bit';
    $04: DescriptorStr.LinearDensity := '0.280 to 0.291 um/bit';
    $08: DescriptorStr.LinearDensity := '0.353 um/bit';
  else
    DescriptorStr.LinearDensity := 'Reserved';
  end;

  Value := (DVDLayerDescriptor.LinearDensity_TrackDensity and $0F);
  case Value of
    $00: DescriptorStr.TrackDensity := '0.74 um/track';
    $01: DescriptorStr.TrackDensity := '0.80 um/track';
    $02: DescriptorStr.TrackDensity := '0.615 um/track';
  else
    DescriptorStr.TrackDensity := 'Reserved';
  end;

  DescriptorStr.NoLayer :=
    IntToStr((DVDLayerDescriptor.NumberOfLayers_TrackPath_LayerType shr 5) and
    $03);
  //    0 = Layer contains embossed data    = $01
  //    1 = Layer contains recordable area  = $02     ?? I question these
  //    2 = Layer contains rewritable area  = $04
  //    3 = Reserved                        = $08
  //   0001b Read-only layer  >> convert to hex How ??
  //   0010b Recordable layer
  //   0100b ReWritable layer
  //   others Reservec
  Value := (DVDLayerDescriptor.NumberOfLayers_TrackPath_LayerType and $0F);
  case Value of
    $01: DescriptorStr.LayerType := 'Read-only layer';
    $02: DescriptorStr.LayerType := 'Recordable layer';
    $04: DescriptorStr.LayerType := 'Re-Writable layer';
    $08: DescriptorStr.LayerType := 'Reserved';
  else
    DescriptorStr.LayerType := 'Unknown';
  end;

  DescriptorStr.Sectors := (SwapDWord(DVDLayerDescriptor.EndPhysicalSector)) -
    (SwapDWord(DVDLayerDescriptor.StartingPhysicalSector));
end;

function SCSIReadDiscInformation(DeviceID: TCDBurnerInfo; var DiscInformation:
  TDiscInformation; var Sdf: TScsiDefaults): TScsiError;
var
  cdb: array[0..9] of BYTE;
  Buf: Pointer;
  BufLen, CdbLen, SdfTemp: DWORD;
begin

  ZeroMemory(@DiscInformation, SizeOf(TDiscInformation));
  Buf := @DiscInformation;
  BufLen := SizeOf(DiscInformation);
  cdbLen := DWORD(10);
  cdb[0] := $51;
  cdb[7] := ((SizeOf(DiscInformation) shr 8) and $FF);
  cdb[8] := (SizeOf(DiscInformation) and $FF);
  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;
  Result := ASPIsendScsiCommand(DeviceID, @cdb, CdbLen, Buf, BufLen, SRB_DIR_IN,
    Sdf);
  Sdf.Timeout := SdfTemp;
  DiscInformation.DiscInformationLength :=
    ((DiscInformation.DiscInformationLength shl 8) and $FF00) or
    ((DiscInformation.DiscInformationLength shr 8) and $00FF);
end;

//  requires scsi-2 or higher

function SCSIReadFormatCapacity(DeviceID: TCDBurnerInfo; var FormatCapacity:
  TFormatCapacity; var Sdf: TScsiDefaults): TScsiError;
var
  cdb: array[0..9] of BYTE;
  Buf: Pointer;
  i: Integer;
  BufLen, CdbLen, SdfTemp: DWORD;
begin
  ZeroMemory(@FormatCapacity, SizeOf(FormatCapacity));
  Buf := @FormatCapacity;
  BufLen := SizeOf(FormatCapacity);
  cdbLen := DWORD(10);
  cdb[0] := $23;
  cdb[7] := ((SizeOf(FormatCapacity) shr 8) and $FF);
  cdb[8] := (SizeOf(FormatCapacity) and $FF);

  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;

  Result := ASPIsendScsiCommand(DeviceID, @cdb, CdbLen,
    Buf, BufLen, SRB_DIR_IN, Sdf);
  Sdf.Timeout := SdfTemp;

  for i := 0 to 32 do
  begin
    FormatCapacity.FormattableCD[I].NumberOfBlocks :=
      SwapDWord(FormatCapacity.FormattableCD[I].NumberOfBlocks);
    FormatCapacity.FormattableCD[I].FormatType :=
      FormatCapacity.FormattableCD[I].FormatType shr 2;
  end;
  FormatCapacity.CapacityDescriptor.NumberOfBlocks :=
    SwapDWord(FormatCapacity.CapacityDescriptor.NumberOfBlocks);
end;

function SCSIReadTrackInformation(DeviceID: TCDBurnerInfo; const ATrack: Byte;
  var TrackInformation: TTrackInformation; var Sdf: TScsiDefaults): TScsiError;
var
  cdb: array[0..9] of BYTE;
  Buf: Pointer;
  BufLen, CdbLen, SdfTemp: DWORD;
begin

  ZeroMemory(@TrackInformation, SizeOf(TTrackInformation));
  Buf := @TrackInformation;
  BufLen := SizeOf(TrackInformation);
  cdbLen := DWORD(10);

  cdb[0] := $52;
  cdb[1] := $01;
  cdb[2] := HiByte(HiWord(ATrack));
  cdb[3] := LoByte(HiWord(ATrack));
  cdb[4] := HiByte(LoWord(ATrack));
  cdb[5] := LoByte(LoWord(ATrack));
  cdb[7] := HiByte(SizeOf(TTrackInformation));
  cdb[8] := LoByte(SizeOf(TTrackInformation));

  SdfTemp := Sdf.Timeout;
  Sdf.Timeout := Sdf.ReadTimeout;

  Result := ASPIsendScsiCommand(DeviceID, @cdb, CdbLen, Buf, BufLen, SRB_DIR_IN,
    Sdf);
  Sdf.Timeout := SdfTemp;

  with TrackInformation do
  begin
    Datalength := ((Datalength shl 8) and $FF00) or ((Datalength shr 8) and
      $00FF); //SwapWord(Datalength);
    TrackSize := SwapDWord(TrackSize);
    FreeBlocks := SwapDWord(FreeBlocks);
    TrackStartAddress := SwapDWord(TrackStartAddress);
    NextWritableAddress := SwapDWord(NextWritableAddress);
    FixedpacketSize := SwapDWord(FixedpacketSize);
    LastRecordedAddress := SwapDWord(LastRecordedAddress);
  end;
end;






end.
