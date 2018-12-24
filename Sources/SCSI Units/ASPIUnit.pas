{-----------------------------------------------------------------------------
 Unit Name: ASPIUnit
 Author:    Sergey Kabikov
 Purpose:   ASPI Functions
 History:   Functions by Sergey Kabikov based on his code ASPI Library
      Rewritten by Dancemammal for the burning code
-----------------------------------------------------------------------------}

unit ASPIUnit;

interface

uses Windows, wnaspi32, Registry, SCSIDefs, SCSITypes, SysUtils;

type
  {CDB types for Aspi commands}
  TCDB12 = array[0..11] of BYTE;
  TCDB10 = array[0..9] of BYTE;
  TCDB6 = array[0..5] of BYTE;

  TScsiInt13info = packed record
    Support,
      DosSupport: BOOLEAN;
    DriveNumber,
      Heads,
      Sectors: BYTE;
  end;

type
  TAspiDeviceEnumCallBack
    = function(Caller: pointer; Device: TCDBurnerInfo; FoundName: string):
    boolean;

type
  TScsiDeviceType = (TSDDisk, TSDTape, TSDPrinter, TSDProcessor,
    TSDWORM, TSDCDROM, TSDScanner, TSDOptical,
    TSDChanger, TSDCommunication,
    TSDInvalid, TSDAny, TSDOther);

var
  TScsiDeviceTypeName: array[TScsiDeviceType] of string = ('Disk Drive',
    'Tape Drive', 'Printer', 'Processor', 'WORM Drive', 'CD-ROM Drive',
    'Scanner', 'Optical Drive', 'Changer', 'Communication Device',
    'Invalid', 'Any Type Device', 'Other Type Device');

function ScatterCDDevice(CDDevice: DWORD; var Adapter, Target, Lun: byte): char;
function CDDevicetoLetter(CDDevice: DWORD): char;
procedure ScatterDWORD(Arg: DWORD; var b3, b2, b1, b0: byte);
function GatherDeviceID(Adapter, Target, Lun: byte; Letter: char): TBurnerID;
procedure FillWORD(Src: WORD; var Dst: BYTE);
procedure FillDWORD(Src: DWORD; var Dst: BYTE);
function AttachLUN(var Arg: BYTE; DeviceID: TBurnerID): BYTE;
function ScatterDeviceID(DeviceID: TBurnerID;
  var Adapter, Target, Lun: byte): char;

function AspiEnumDevices(CallBack: TAspiDeviceEnumCallBack; Caller: pointer):
  integer;

function AspiCheck(Err: TScsiError): boolean;
function AspiInstalled: Integer;
function GetAdapterNumbers: Integer;
function ASPIhaInquiry(HaId: BYTE; var sh: TScsiHAinfo): TScsiError;
function GetCDRegName(ID, Target, LUN: Integer): string;
function BigEndianW(Arg: WORD): WORD;
function BigEndianD(Arg: DWORD): DWORD;
procedure BigEndian(const Source; var Dest; Count: integer);
function GatherWORD(b1, b0: byte): WORD;
function GatherDWORD(b3, b2, b1, b0: byte): DWORD;
procedure ASPIstrCopy(Src: PChar; var Dst: ShortString; Leng: Integer);

procedure ASPIsetDeviceIDflag(var DeviceID: TBurnerID;
  Flag: TAspiDeviceIDflag; Value: boolean);

function ASPIgetDeviceType(DeviceID: TBurnerID;
  var DeviceType: TScsiDeviceType): TScsiError;

function ASPIgetDriveInt13info(DeviceID: TBurnerID;
  var Info: TScsiInt13info): TScsiError;

function ASPIgetDeviceIDflag(DeviceID: TBurnerID;
  Flag: TAspiDeviceIDflag): boolean;

function GetAspiErrorSense(Status, HaStat, TargStat: BYTE;
  Sense: PscsiSenseInfo): TScsiError;

procedure ASPIabortCommand(HaId: BYTE; Psrb: pointer);

function ASPIsendScsiCommand(DeviceID: TCDBurnerInfo;
  Pcdb: pointer; CdbLen: DWORD;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

function ASPIsend6CDB(DeviceID: TCDBurnerInfo; CDB: TCDB6; Pbuf: pointer;
  BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

function ASPIsend10CDB(DeviceID: TCDBurnerInfo; CDB: TCDB10; Pbuf: pointer;
  BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

function ASPIsend12CDB(DeviceID: TCDBurnerInfo; CDB: TCDB12; Pbuf: pointer;
  BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

implementation

uses SCSIUnit;

function AspiInstalled: Integer;
var
  AspiStatus: Cardinal;
begin
  if WNASPI_LOADED then
  begin
    AspiStatus := GetASPI32SupportInfo;
    if HIBYTE(LOWORD(AspiStatus)) = SS_COMP then
    begin
      // get number of host installed on the system
      Result := LOBYTE(LOWORD(AspiStatus));
    end
    else
      Result := -1
  end
  else
    Result := -1
end;

function GetAspiError(Status, HaStat, TargStat: BYTE): TScsiError;
begin
  result := Err_Unknown;
  case Status of
    0, 1: result := Err_None;
    2, 3: result := Err_Aborted;
    $80: result := Err_InvalidRequest;
    $81: result := Err_InvalidHostAdapter;
    $82: result := Err_NoDevice;
    $E0: result := Err_InvalidSrb;
    $E1: result := Err_BufferAlign;
    $E5: result := Err_AspiIsBusy;
    $E6: result := Err_BufferTooBig;
    4: case HaStat of
        $09: result := Err_CommandTimeout;
        $0B: result := Err_SrbTimeout;
        $0D: result := Err_MessageReject;
        $0E: result := Err_BusReset;
        $0F: result := Err_ParityError;
        $10: result := Err_RequestSenseFailed;
        $11: result := Err_SelectionTimeout;
        $12: result := Err_DataOverrun;
        $13: result := Err_UnexpectedBusFree;
        $14: result := Err_BusPhaseSequence;
        $00: case TargStat of
            0, 2: result := Err_CheckCondition;
            $08: result := Err_TargetBusy;
            $18: result := Err_TargetReservationConflict;
            $28: result := Err_TargetQueueFull;
          end;
      end;
  end;
end;

function AttachLUN(var Arg: BYTE; DeviceID: TBurnerID): BYTE;
var
  i, j, Lun: BYTE;
begin
  ScatterDeviceID(DeviceID, i, j, Lun);
  Result := ((Lun and 7) shl 5) or (Arg and $1F);
end;

procedure FillWORD(Src: WORD; var Dst: BYTE);
begin
  BigEndian(Src, Dst, 2);
end;

procedure FillDWORD(Src: DWORD; var Dst: BYTE);
begin
  BigEndian(Src, Dst, 4);
end;

procedure ASPIstrCopy(Src: PChar; var Dst: ShortString; Leng: Integer);
var
  i: integer;
begin
  i := 0;
  while (i < Leng) and (Src[i] >= ' ') do
  begin
    Dst[i + 1] := Src[i];
    inc(i);
  end;
  while (i > 0) and (Dst[i] = ' ') do
    Dec(i); // Trim it Right
  Dst[0] := CHR(i);
end;

procedure ScatterDWORD(Arg: DWORD; var b3, b2, b1, b0: byte);
begin
  b3 := (Arg shr 24) and $FF;
  b2 := (Arg shr 16) and $FF;
  b1 := (Arg shr 8) and $FF;
  b0 := Arg and $FF;
end;

function ScatterDeviceID(DeviceID: TBurnerID;
  var Adapter, Target, Lun: byte): char;
var
  Res: BYTE;
begin
  ScatterDWORD(DeviceID, Adapter, Target, Lun, Res);
  Result := CHR((Lun and $1F) or $40);
  Lun := (Lun shr 5) and 7;
end;

function ScatterCDDevice(CDDevice: DWord; var Adapter, Target, Lun: byte): char;
var
  Res: BYTE;
begin
  ScatterDWORD(CDDevice, Adapter, Target, Lun, Res);
  Result := CHR((Lun and $1F) or $40);
  Lun := (Lun shr 5) and 7;
end;

function BigEndianW(Arg: WORD): WORD;
begin
  result := ((Arg shl 8) and $FF00) or
    ((Arg shr 8) and $00FF);
end;

function BigEndianD(Arg: DWORD): DWORD;
begin
  result := ((Arg shl 24) and $FF000000) or
    ((Arg shl 8) and $00FF0000) or
    ((Arg shr 8) and $0000FF00) or
    ((Arg shr 24) and $000000FF);
end;

procedure BigEndian(const Source; var Dest; Count: integer);
var
  pSrc, pDst: PChar;
  i: integer;
begin
  pSrc := @Source;
  pDst := PChar(@Dest) + Count;
  for i := 0 to Count - 1 do
  begin
    Dec(pDst);
    pDst^ := pSrc^;
    Inc(pSrc);
  end;
end;

function GatherWORD(b1, b0: byte): WORD;
begin
  result := ((WORD(b1) shl 8) and $FF00) or
    ((WORD(b0)) and $00FF);
end;

{$WARNINGS OFF}

function GatherDWORD(b3, b2, b1, b0: byte): DWORD;
begin
  result := ((LongInt(b3) shl 24) and $FF000000) or
    ((LongInt(b2) shl 16) and $00FF0000) or
    ((LongInt(b1) shl 8) and $0000FF00) or
    ((LongInt(b0)) and $000000FF);
end;
{$WARNINGS ON}

function CDDevicetoLetter(CDDevice: DWord): char;
var
  Adapter, Target, Lun: byte;
begin
  Result := ScatterCDDevice(CDDevice, Adapter, Target, Lun);
end;

function AspiCheck(Err: TScsiError): boolean;
begin
  Result := Err in [Err_None, Err_DataOverrun, Err_SenseRecoveredError];
end;

function GatherDeviceID(Adapter, Target, Lun: byte; Letter: char): TBurnerID;
begin
  Result := GatherDWORD(Adapter, Target,
    ((Lun and 7) shl 5) or (ORD(Letter) and $1F), 0);
end;

function ASPIgetDeviceIDflag(DeviceID: TBurnerID;
  Flag: TAspiDeviceIDflag): boolean;
begin
  Result := (DeviceID and (1 shl ORD(Flag))) <> 0;
end;

function GetAdapterNumbers: Integer;
var
  AspiStatus: DWord;
  Adaptors: Byte;
begin
  try
    AspiStatus := GetASPI32SupportInfo;
    Adaptors := Lo(loword(AspiStatus));
    Result := Adaptors;
  except
    Result := 0;
  end;
end;

function GetCDRegName(ID, Target, LUN: Integer): string;
var
  DEVName: string;
  Registry: TRegistry;
  Root2000: string;
  Root98: string;
  FormatKey: string;
begin
  DEVName := 'Cannot Find Name';
  Root2000 := 'HKEY_LOCAL_MACHINE';
  Root98 := 'HKEY_LOCAL_MACHINE\Enum\Scsi';
  FormatKey := 'HARDWARE\DEVICEMAP\Scsi\Scsi Port ' + inttostr(ID) +
    '\Scsi Bus 0\Target Id ' + inttostr(Target) + '\Logical Unit Id ' +
    inttostr(LUN);
  Registry := TRegistry.Create;
  Registry.RootKey := HKEY_LOCAL_MACHINE;

  Registry.OpenKey(FormatKey, False);
  DEVName := Registry.ReadString('Identifier');
  Registry.Free;
  Result := DEVName;
end;

function AspiEnumDevices(CallBack: TAspiDeviceEnumCallBack; Caller: pointer):
  integer;
var
  DID: TCDBurnerInfo;
  DIDtype: TScsiDeviceType;
  Dadapter, Dtarget, Dlun, HAcount: BYTE;
  HAinfo: TScsiHAinfo;
  DevInfo: TScsiInt13info;
  CDName: string;
  //  ModeSenseBuf: array[0..255] of BYTE;

  function TestModeSense: boolean;
  begin
    //      Result := Not AspiCheck(SCSImodeSense(DID, $3F, @ModeSenseBuf, 255, SCSI_Def));
  end;

begin
  Result := 0;
  HAcount := GetAdapterNumbers;
  if HAcount = 0 {// no ASPI hosts, no devices} then
  begin
    Result := -1;
    exit;
  end;
  for Dadapter := 0 to HAcount - 1 do
    if ASPIhaInquiry(Dadapter, HAinfo) = Err_None then
      for Dtarget := 0 to HAinfo.MaxTargetCount - 1 do
        for Dlun := 0 to 7 do
        begin

          DID.DriveID := GatherDeviceID(Dadapter, Dtarget, Dlun, #0);
          CDName := GetCDRegName(Dadapter, Dtarget, Dlun);

          if ASPIgetDeviceType(DID.DriveID, DIDtype) = Err_None then
            //if device exists
            if (DIDtype = TSDCDROM) then
            begin

              if (ASPIgetDriveInt13info(DID.DriveID, DevInfo) = Err_None)
                and (DevInfo.DriveNumber > 0) then
                DID.DriveID := GatherDeviceID(Dadapter, Dtarget, Dlun,
                  CHR(DevInfo.DriveNumber + $41));

              if TestModeSense then
              begin
                ASPIsetDeviceIDflag(DID.DriveID, ADIDmodeSense6, True);
                if TestModeSense then
                begin
                  ASPIsetDeviceIDflag(DID.DriveID, ADIDmodeSense6, False);
                  ASPIsetDeviceIDflag(DID.DriveID, ADIDmodeSenseDBD, True);
                  if TestModeSense then
                    ASPIsetDeviceIDflag(DID.DriveID, ADIDmodeSense6, True);
                end;
              end;
              if not CallBack(Caller, DID, CDName) then
                exit;
              Inc(Result);
            end;
        end;
end;

procedure ASPIsetDeviceIDflag(var DeviceID: TBurnerID;
  Flag: TAspiDeviceIDflag; Value: boolean);
begin
  if Value then
    DeviceID := DeviceID or (1 shl ORD(Flag))
  else
    DeviceID := DeviceID and not (1 shl ORD(Flag));
end;

{$WARNINGS OFF}

function ASPIgetDeviceType(DeviceID: TBurnerID;
  var DeviceType: TScsiDeviceType): TScsiError;
var
  Gsrb: SRB_GetDeviceType;
begin
  FillChar(Gsrb, sizeof(Gsrb), 0);
  Gsrb.SRB_Cmd := 1;
  ScatterDeviceID(DeviceID, Gsrb.SRB_HaId, Gsrb.SRB_Target, Gsrb.SRB_Lun);
  SendASPI32Command(@Gsrb);
  Result := GetAspiError(Gsrb.SRB_Status, $FF, $FF);
  if (Result = Err_None) and (Gsrb.SRB_DeviceType < ORD(TSDInvalid)) then
    DeviceType := TScsiDeviceType(Gsrb.SRB_DeviceType)
  else
    DeviceType := TSDInvalid;
end;
{$WARNINGS ON}

function ASPIgetDriveInt13info(DeviceID: TBurnerID;
  var Info: TScsiInt13info): TScsiError;
var
  Isrb: SRB_Int13info;
begin
  FillChar(Isrb, sizeof(Isrb), 0);
  with Isrb do
  begin
    SRB_Cmd := 6;
    ScatterDeviceID(DeviceID, SRB_HaId, SRB_Target, SRB_Lun);
  end;
  SendASPI32Command(@Isrb);
  with Info, Isrb do
  begin
    Result := GetAspiError(SRB_Status, $FF, $FF);
    Support := (Result = Err_None) and ((SRB_DriveFlags and 3) <> 0);
    DosSupport := (Result = Err_None) and ((SRB_DriveFlags and 1) <> 0);
    DriveNumber := SRB_Int13Drive;
    Heads := SRB_Heads;
    Sectors := SRB_Sectors;
  end;
end;

function ASPIhaInquiry(HaId: BYTE; var sh: TScsiHAinfo): TScsiError;
var
  Isrb: SRB_Inquiry;
begin
  FillChar(Isrb, sizeof(Isrb), 0);
  Isrb.SRB_Cmd := 0;
  Isrb.SRB_HaId := HaId;
  SendASPI32Command(@Isrb);
  with Isrb do
  begin
    Result := GetAspiError(SRB_Status, $FF, $FF);
    sh.ScsiId := SRB_HA_SCSIID;
    ASPIstrCopy(SRB_ManagerID, sh.ScsiManagerId, 16);
    ASPIstrCopy(SRB_AdapterID, sh.HostAdapterId, 16);
    sh.BufferAlignMask := SRB_BufAlign;
    sh.ResidualSupport := (SRB_Residual and 2) <> 0;
    if SRB_Targets = 0 then
      sh.MaxTargetCount := 8
    else
      sh.MaxTargetCount := SRB_Targets;
    sh.MaxTransferLength := SRB_TransfLen;
  end;
end;

function ResetAspi(ID, Target, LUN: Integer): Boolean;
var
  AdaptorSRB: PSRB_GDEVBlock;
  //  ASPI_Status: DWord;
begin
  //  result := False;
  New(AdaptorSRB);
  FillChar(AdaptorSRB^, Sizeof(SRB_HAInquiry), #0);
  AdaptorSRB^.SRB_Cmd := SC_RESET_DEV;
  AdaptorSRB^.SRB_HaId := ID;
  AdaptorSRB^.SRB_Target := Target;
  AdaptorSRB^.SRB_Lun := LUN;
  AdaptorSRB^.SRB_Flags := 0;
  AdaptorSRB^.SRB_Hdr_Rsvd := 0;
  //  ASPI_Status :=
  SendASPI32Command(AdaptorSRB);

  if AdaptorSRB^.SRB_Status <> SS_COMP then
    result := False
  else
    result := True;
  Dispose(AdaptorSRB);
end;

function GetAdaptorName(ID: Integer): string;
var
  AdaptorSRB: PSRB_HAInquiry;
  //  ASPI_Status: DWord;
  Res: string;
begin
  setlength(Res, 16);
  New(AdaptorSRB);
  FillChar(AdaptorSRB^, Sizeof(SRB_HAInquiry), #0);
  AdaptorSRB^.SRB_Cmd := SC_HA_INQUIRY;
  AdaptorSRB^.SRB_HaId := ID;
  AdaptorSRB^.SRB_Flags := 0;
  AdaptorSRB^.SRB_Hdr_Rsvd := 0;
  //  ASPI_Status :=
  SendASPI32Command(AdaptorSRB);

  if AdaptorSRB^.SRB_Status <> SS_COMP then
    RES := 'Inquery Error'
  else
  begin
    Res := AdaptorSRB^.HA_Identifier;
  end;
  Result := Res;
  Dispose(AdaptorSRB);
end;

function GetAspiErrorSense(Status, HaStat, TargStat: BYTE;
  Sense: PscsiSenseInfo): TScsiError;
begin
  Result := GetAspiError(Status, HaStat, TargStat);
  if (Result = Err_CheckCondition) and Assigned(Sense) then
    if Sense^[0] = 0 then
      Result := Err_None
    else if (Sense^[0] and $7E) <> $70 {// recognized values} then
      Result := Err_SenseUnknown
    else
      case (Sense^[2] and $0F) of
        0:
          begin // Skey_NoSense
            if (Sense^[2] and $80) <> 0 {// FileMark flag} then
              Result := Err_SenseFileMark
            else if (Sense^[2] and $40) <> 0 {// EndOfMedia flag} then
              Result := Err_SenseEndOfMedia
            else if (Sense^[2] and $20) <> 0 {// IllegalLength flag} then
              Result := Err_SenseIllegalLength
            else if (Sense^[3] and $80) <> 0 {// ResidualCount < 0} then
              Result := Err_SenseIncorrectLength
            else
              Result := Err_SenseNoSense;
          end;
        1: Result := Err_SenseRecoveredError; //Skey_RecoveredError
        2: Result := Err_SenseNotReady; //Skey_NotReady
        3: Result := Err_SenseMediumError; //Skey_MediumError
        4: Result := Err_SenseHardwareError; //Skey_HardwareError
        5: Result := Err_SenseIllegalRequest; //Skey_IllegalRequest
        6: Result := Err_SenseUnitAttention; //Skey_UnitAttention
        7: Result := Err_SenseDataProtect; //Skey_DataProtect
        8: Result := Err_SenseBlankCheck; //Skey_BlankCheck
        9: Result := Err_SenseVendorSpecific; // Skey_VendorSpecific
        10: Result := Err_SenseCopyAborted; // Skey_CopyAborted
        11: Result := Err_SenseAbortedCommand; // Skey_AbortedCommand
        12: Result := Err_SenseEqual; // Skey_Equal
        13: Result := Err_SenseVolumeOverflow; // Skey_VolumeOverflow
        14: Result := Err_SenseMiscompare; // Skey_Miscompare
        15: Result := Err_SenseReserved; // Skey_Reserved
      end;
end;

function ASPIsend12CDB(DeviceID: TCDBurnerInfo; CDB: TCDB12; Pbuf: pointer;
  BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
begin
  if Assigned(Pbuf) and (Direction = SRB_DIR_IN) then
    FillChar(Pbuf^, BufLen, 0);
  Result := ASPIsendScsiCommand(DeviceID, @cdb, 12, Pbuf, BufLen, Direction,
    Sdf);
end;

function ASPIsend10CDB(DeviceID: TCDBurnerInfo; CDB: TCDB10; Pbuf: pointer;
  BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
begin
  if Assigned(Pbuf) and (Direction = SRB_DIR_IN) then
    FillChar(Pbuf^, BufLen, 0);
  Result := ASPIsendScsiCommand(DeviceID, @cdb, 10, Pbuf, BufLen, Direction,
    Sdf);
end;

function ASPIsend6CDB(DeviceID: TCDBurnerInfo; CDB: TCDB6; Pbuf: pointer;
  BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
begin
  if Assigned(Pbuf) and (Direction = SRB_DIR_IN) then
    FillChar(Pbuf^, BufLen, 0);
  Result := ASPIsendScsiCommand(DeviceID, @cdb, 6, Pbuf, BufLen, Direction,
    Sdf);
end;

function ASPIsend6(DeviceID: TCDBurnerInfo;
  OpCode: BYTE; Lba: DWORD; Byte4: BYTE;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
var
  cdb: array[0..5] of BYTE;
begin
  if Assigned(Pbuf) and (Direction = SRB_DIR_IN) then
    FillChar(Pbuf^, BufLen, 0);

  cdb[5] := 0;
  cdb[4] := Byte4;
  FillDWORD(LBA, cdb[0]);
  cdb[1] := AttachLUN(cdb[1], DeviceID.DriveID);
  cdb[0] := OpCode;

  Result := ASPIsendScsiCommand(DeviceID, @cdb, 6, Pbuf, BufLen, Direction,
    Sdf);
end;

function ASPIsend10(DeviceID: TCDBurnerInfo; OpCode: BYTE;
  Byte1: BYTE; Lba: DWORD; Byte6: BYTE; Word7: WORD;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
var
  cdb: array[0..9] of BYTE;
begin
  if Assigned(Pbuf) and (Direction = SRB_DIR_IN) then
    FillChar(Pbuf^, BufLen, 0);

  cdb[9] := 0;
  FillWORD(Word7, cdb[7]);
  cdb[6] := Byte6;
  FillDWORD(LBA, cdb[2]);
  cdb[1] := AttachLUN(Byte1, DeviceID.DriveID);
  cdb[0] := OpCode;
  Result := ASPIsendScsiCommand(DeviceID, @cdb, 10, Pbuf, BufLen, Direction,
    Sdf);
end;

function ASPIsend12(DeviceID: TCDBurnerInfo; OpCode: BYTE;
  Byte1: BYTE; Lba: DWORD; TLength: DWORD; Byte10: BYTE;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
var
  cdb: array[0..11] of BYTE;
begin
  if Assigned(Pbuf) and (Direction = SRB_DIR_IN) then
    FillChar(Pbuf^, BufLen, 0);
  cdb[11] := 0;
  cdb[10] := Byte10;
  FillDWORD(TLength, cdb[6]);
  FillDWORD(LBA, cdb[2]);
  cdb[1] := AttachLUN(Byte1, DeviceID.DriveID);
  cdb[0] := OpCode;
  Result := ASPIsendScsiCommand(DeviceID, @cdb, 12, Pbuf, BufLen, Direction,
    Sdf);
end;

function ASPIsendScsiCommandInternal(DeviceID: TCDBurnerInfo;
  Pcdb: pointer; CdbLen: DWORD;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

var
  Esrb: SRB_ExecSCSICmd;
  hEvent: THandle;
begin
  Result := Err_None;
  hEvent := CreateEvent(nil, true, false, nil); // event to notify completion
  if hEvent = 0 then
  begin
    Result := Err_NoEvent;
    exit;
  end;
  ResetEvent(hEvent);
  FillChar(Esrb, sizeof(Esrb), 0); // Scsi Request Block init
  with Esrb do
  begin
    SRB_Cmd := 2; // SC_EXEC_SCSI_CMD
    ScatterDeviceID(DeviceID.DriveID, SRB_HaId, SRB_Target, SRB_Lun);
    SRB_Flags := Direction or $40; // set SRB_EVENT_NOTIFY flag
    SRB_BufLen := BufLen;
    SRB_BufPtr := Pbuf;
    SRB_SenseLen := sizeof(TscsiSenseInfo) - 2;
    if CdbLen > 16 then
      SRB_CDBLen := 16
    else
      SRB_CDBLen := CdbLen;
    SRB_PostProc := hEvent;
    Move(Pcdb^, SRB_CDBByte, SRB_CDBLen);
  end;
  SendASPI32Command(@Esrb); // send command to aspi
  if Esrb.SRB_Status = 0 then
  begin // signaled SS_PENDING  >> WAIT !
    if WaitForSingleObject(hEvent, Sdf.Timeout) <> WAIT_OBJECT_0 then
    begin
      Result := Err_NotifyTimeout;
      ASPIabortCommand(Esrb.SRB_HaId, @Esrb);
    end;
  end;
  if Esrb.SRB_Status <> 1 then
    Result := Err_NoDevice;

  CloseHandle(hEvent);
  if Result = Err_None then
    with Esrb do
    begin
      Sdf.Sense := SRB_Sense;
      Result := GetAspiErrorSense(SRB_Status, SRB_HaStat,
        SRB_TargStat, @SRB_Sense);
    end;
end;

function ASPIsendScsiCommand(DeviceID: TCDBurnerInfo;
  Pcdb: pointer; CdbLen: DWORD;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
begin
  //  Result := Err_None;
  FillChar(Sdf.Sense, sizeof(TscsiSenseInfo), 0);

  Result := ASPIsendScsiCommandInternal(DeviceID,
    Pcdb, CdbLen, Pbuf, BufLen, Direction, Sdf);

  if Assigned(Sdf.fOnCommandSent) then
    Sdf.fOnCommandSent(DeviceID, Pcdb, CdbLen, Pbuf, BufLen, Direction, @Sdf,
      Result);
end;

procedure ASPIabortCommand(HaId: BYTE; Psrb: pointer);
var
  Asrb: SRB_Abort;
begin
  FillChar(Asrb, sizeof(Asrb), 0);
  Asrb.SRB_Cmd := 3;
  Asrb.SRB_HaId := HaId;
  Asrb.SRB_ToAbort := Psrb;
  SendASPI32Command(@Asrb);
end;

end.
