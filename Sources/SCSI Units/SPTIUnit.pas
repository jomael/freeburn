{-----------------------------------------------------------------------------
 Unit Name: SptiFunctions
 Author:    Dancemammal
 Purpose:   w2k spti functions version
 History:  First Code Release

-----------------------------------------------------------------------------}

unit SptiUnit;

interface

uses Windows, CovertFuncs, wnaspi32, skSCSI, CDROMIOCTL, dialogs, SCSITypes,
  scsidefs, sysutils, Registry;

{Const //=======  Possible values of Direction parameter ========
   SRB_NODIR = 2; // No data I/O is performed
   SRB_DIR_IN = 1; // Transfer from SCSI target to host
   SRB_DIR_OUT = 0; // Transfer from host to SCSI target
}

type
  SCSI_ADDRESS = record
    Length: LongInt;
    PortNumber: Byte;
    PathId: Byte;
    TargetId: Byte;
    Lun: Byte;
  end;
  PSCSI_ADDRESS = ^SCSI_ADDRESS;

  ENotAdmin = Exception;

  NTSCSIDRIVE = record
    ha: byte;
    tgt: byte;
    lun: byte;
    driveLetter: Char; //Was byte
    bUsed: Bool;
    hDevice: THandle;
    inqData: array[0..36 - 1] of byte;
  end;
  PNTSCSIDRIVE = ^NTSCSIDRIVE;

type

  {CDB types for Spti commands}
  TCDB12 = array[0..11] of BYTE;
  PCDB12 = ^TCDB12;
  TCDB10 = array[0..9] of BYTE;
  PCDB10 = ^TCDB10;
  TCDB6 = array[0..5] of BYTE;
  PCDB6 = ^TCDB6;

type
  TScsiInt13info = packed record
    Support,
      DosSupport: BOOLEAN;
    DriveNumber,
      Heads,
      Sectors: BYTE;
  end;

  // Request for information about host adapter.
type
  TScsiHAinfo = packed record
    ScsiId: BYTE; // SCSI Id of selected host adapter
    MaxTargetCount: BYTE; // Max target count for selected HA
    ResidualSupport: BOOLEAN; // True if HA supports residual I/O
    MaxTransferLength: DWORD; // Max transfer length in bytes
    BufferAlignMask: WORD; // Buffer for data I/O must be aligned by:
    // 0=byte, 1=word, 3=dword, 7=8-byte, etc. 65536 bytes max
    ScsiManagerId, // MustBe = 'ASPI for WIN32'
    HostAdapterId: string[16]; // String describing selected HA
  end;

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

  {Aspi Functions}

function GetAdaptorName(ID: Integer): string;
function GetSCSIID(ID: Integer): string;
function ISCDROM(ID, Target, LUN: Integer): Boolean;
function GetCDRegName(ID, Target, LUN: Integer): string;
function ResetAspi(ID, Target, LUN: Integer): Boolean;
function AttachLUN(var Arg: BYTE; DeviceID: TBurnerID): BYTE;

function CloseDriveHandle(DeviceID: TCDBurnerInfo): Boolean;
function GetDriveTempHandle(DeviceID: TCDBurnerInfo): Thandle;
procedure GetDriveHandle(var DeviceID: TCDBurnerInfo);

// =================== Helper routines ======================
// Intel/Windows/Delphi <-> Motorola/ASPI format conversion routines
function BigEndianW(Arg: WORD): WORD;
function BigEndianD(Arg: DWORD): DWORD;
procedure BigEndian(const Source; var Dest; Count: integer);
function GatherWORD(b1, b0: byte): WORD;
function GatherDWORD(b3, b2, b1, b0: byte): DWORD;
procedure ScatterDWORD(Arg: DWORD; var b3, b2, b1, b0: byte);
procedure ASPIstrCopy(Src: PChar; var Dst: ShortString; Leng: Integer);

// ASPI Error decoding routines
function GetAspiError(Status, HaStat, TargStat: BYTE): TScsiError;
function GetAspiErrorSense(Status, HaStat, TargStat: BYTE;
  Sense: PscsiSenseInfo): TScsiError;
function AspiCheck(Err: TScsiError): boolean;

// TBurnerID helper definitions and functions

procedure FillWORD(Src: WORD; var Dst: BYTE);
procedure FillDWORD(Src: DWORD; var Dst: BYTE);

function GatherDeviceID(Adapter, Target, Lun: byte; Letter: char): TBurnerID;

function ScatterDeviceID(DeviceID: TBurnerID;
  var Adapter, Target, Lun: byte): char;

function DeviceIDtoLetter(DeviceID: TBurnerID): char;

function ASPIgetDeviceIDflag(DeviceID: TBurnerID;
  Flag: TAspiDeviceIDflag): boolean;

procedure ASPIsetDeviceIDflag(var DeviceID: TBurnerID;
  Flag: TAspiDeviceIDflag; Value: boolean);

// ============= Base-level ASPI request routines ==============

function ASPIhaInquiry(HaId: BYTE; var sh: TScsiHAinfo): TScsiError;
// Request for device type.
function ASPIgetDeviceType(DeviceID: TBurnerID;
  var DeviceType: TScsiDeviceType): TScsiError;
// SCSI command execution.
//   DeviceID     identifies the device to be accessed.
//   Pcdb/CdbLen  SCSI Command Descriptor Block pointer/size
//   Pbuf/BufLen  Data buffer pointer/size.
//                Must be nil/0 if command does not requires data I/O.
//   Direction    Data transfer direction. Must be one of SRB_DIR constants.
function ASPIsendScsiCommand(DeviceID: TCDBurnerInfo;
  Pcdb: pointer; CdbLen: DWORD;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
// Abort issued by ASPIsendScsiCommand() request for a given host adapter.
procedure ASPIabortCommand(HaId: BYTE; Psrb: pointer);
// Soft reset for the given device.
function ASPIresetDevice(DeviceID: TCDBurnerInfo; Timeout: DWORD): TScsiError;
// Retrieves some DOS-related info about device.

function ASPIgetDriveInt13info(DeviceID: TCDBurnerInfo;
  var Info: TScsiInt13info): TScsiError;

//=================== Device enumerator routine ====================
//  Callback function definition.
//    lpUserData  specifies the user-defined value given in AspiEnumDevices
//    Device      identifies the device found
//    Return Value  To continue enumeration, the callback function must
//                  return TRUE; to stop enumeration, it must return FALSE.
//  Enumerator routine definition.
//    DeviceType  Type of devices to enumerate. Set it to TSDAny to
//                obtain all devices available.
//    CallBack    Points to an user-defined callback function (see above).
//    lpUserData  Specifies a user-defined value to be passed to the callback.
//    Return Value  Number of devices found. Zero if no devices of specified
//                  type exists, -1 if search fails.
type
  TAspiDeviceEnumCallBack
    = function(lpUserData: pointer; Device: TCDBurnerInfo; FoundName: string):
    boolean;

  // ================== Mid-level SCSI request routines ================
  // Three most frequent cases of ASPISendScsiCommand(),
  // for CDB of 6, 10 and 12 bytes length.
function ASPIsend6(DeviceID: TCDBurnerInfo;
  OpCode: BYTE; Lba: DWORD; Byte4: BYTE;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

function ASPIsend10(DeviceID: TCDBurnerInfo; OpCode: BYTE;
  Byte1: BYTE; Lba: DWORD; Byte6: BYTE; Word7: WORD;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

function ASPIsend12(DeviceID: TCDBurnerInfo; OpCode: BYTE;
  Byte1: BYTE; Lba: DWORD; TLength: DWORD; Byte10: BYTE;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

{With new TCDB command struct}
function ASPIsend6CDB(DeviceID: TCDBurnerInfo; CDB: TCDB6; Pbuf: pointer;
  BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

function ASPIsend10CDB(DeviceID: TCDBurnerInfo; CDB: TCDB10; Pbuf: pointer;
  BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

function ASPIsend12CDB(DeviceID: TCDBurnerInfo; CDB: TCDB12; Pbuf: pointer;
  BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;

// ++++++++++++++base SPTI commands all new+++++++++++++++++++

type
  TSPTIWriter = record
    HaId: Byte;
    Target: Byte;
    Lun: Byte;
    Vendor: ShortString;
    ProductId: ShortString;
    Revision: ShortString;
    VendorSpec: ShortString;
    Description: ShortString;
    DriveLetter: Char;
    DriveHandle: Thandle;
  end;

  TSPTIWriters = record
    ActiveCdRom: Byte;
    CdRomCount: Byte;
    CdRom: array[0..25] of TSPTIWriter;
  end;

function ScsiErrToString(Err: TScsiError): string;
function ScsiErrToStr(Err: TScsiError): string;
function ScsiDeviceIDtoStr(Device: TBurnerID): string;

function GetDriveNumbers(var CDRoms: TSPTIWriters): integer;
function GetSPTICdRomDrives(var CdRoms: TSPTIWriters): Boolean;
procedure GetDriveInformation(i: byte; var CdRoms: TSPTIWriters);

implementation

uses Scsiunit;

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

function ScsiErrToString(Err: TScsiError): string;
begin
  Result := EnumToStr(TypeInfo(TScsiError), Err);
end;

function ScsiErrToStr(Err: TScsiError): string;
begin
  Result := '() result is ' + ScsiErrToString(Err);
end;

function ScsiDeviceIDtoStr(Device: TBurnerID): string;
var
  Adapter, Target, Lun: byte;
  Letter: Char;
begin
  Letter := ScatterDeviceID(Device, Adapter, Target, Lun);
  if Letter < 'A' then
    Letter := '?';
  Result := IntToStr(Adapter) + ','
    + IntToStr(Target) + ','
    + IntToStr(Lun) + ','
    + Letter + ': ';
end;

{*******************************************************************************
                                                                    AspiIntalled
*******************************************************************************}

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

function CheckAspiLayer: Boolean;
begin
  Result := True;
  if AspiInstalled = -1 then
    Result := False;
end;

function GetDriveNumbers(var CDRoms: TSPTIWriters): integer;
var
  i: integer;
  szDrives: array[0..105] of Char;
  p: PChar;
begin
  GetLogicalDriveStrings(105, szDrives);
  p := szDrives;
  i := 0;
  while p^ <> '' do
  begin
    if GetDriveType(p) = DRIVE_CDROM then
    begin
      CdRoms.CdRom[i].DriveLetter := p^; // + ':\';
      i := CdRoms.CdRomCount + 1;
      CdRoms.CdRomCount := CdRoms.CdRomCount + 1;
    end;
    p := p + lstrlen(p) + 1;
  end;
  Result := CdRoms.CdRomCount;
end;

function GetAdaptorName(ID: Integer): string;
begin
  Result := EmptyStr;
end;

function GetSCSIID(ID: Integer): string;
begin
  Result := EmptyStr;
end;

function ISCDROM(ID, Target, LUN: Integer): Boolean;
begin
  Result := false;
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

function ResetAspi(ID, Target, LUN: Integer): Boolean;
begin
  Result := False;
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

procedure ScatterDWORD(Arg: DWORD; var b3, b2, b1, b0: byte);
begin
  b3 := (Arg shr 24) and $FF;
  b2 := (Arg shr 16) and $FF;
  b1 := (Arg shr 8) and $FF;
  b0 := Arg and $FF;
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

function GetAspiError(Status, HaStat, TargStat: BYTE): TScsiError;
begin
  result := Err_Unknown;
  case Status of
    0, 1: result := Err_None; // No error, all OK
    2, 3: result := Err_Aborted;
    $80: result := Err_InvalidRequest; // This command is
    // not supported by ASPI manager
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

function AspiCheck(Err: TScsiError): boolean;
begin
  Result := Err in [Err_None, Err_DataOverrun, Err_SenseRecoveredError];
end;

function GatherDeviceID(Adapter, Target, Lun: byte; Letter: char): TBurnerID;
begin
  Result := GatherDWORD(Adapter, Target,
    ((Lun and 7) shl 5) or (ORD(Letter) and $1F), 0);
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

function DeviceIDtoLetter(DeviceID: TBurnerID): char;
var
  Adapter, Target, Lun: byte;
begin
  Result := ScatterDeviceID(DeviceID, Adapter, Target, Lun);
end;

function ASPIgetDeviceIDflag(DeviceID: TBurnerID;
  Flag: TAspiDeviceIDflag): boolean;
begin
  Result := (DeviceID and (1 shl ORD(Flag))) <> 0;
end;

procedure ASPIsetDeviceIDflag(var DeviceID: TBurnerID;
  Flag: TAspiDeviceIDflag; Value: boolean);
begin
  if Value then
    DeviceID := DeviceID or (1 shl ORD(Flag))
  else
    DeviceID := DeviceID and not (1 shl ORD(Flag));
end;

function ASPIhaInquiry(HaId: BYTE; var sh: TScsiHAinfo): TScsiError;
begin
  Result := Err_None;
end;

{$WARNINGS OFF}

function ASPIgetDeviceType(DeviceID: TBurnerID;
  var DeviceType: TScsiDeviceType): TScsiError;
type
  SRB_GetDeviceType = packed record
    SRB_Cmd: BYTE; // ASPI command code = 1 = SC_GET_DEV_TYPE
    SRB_Status: BYTE; // ASPI command status byte
    SRB_HaId: BYTE; // ASPI host adapter number
    SRB_Flags: BYTE; // Reserved
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_Target: BYTE; // Target number for specified HA
    SRB_Lun: BYTE; // Logical unit number of selected target
    SRB_DeviceType: BYTE; // Selected HA/Target/Lun device type
    SRB_Rsvd: BYTE; // Reserved for alignment
  end;
var
  Gsrb: SRB_GetDeviceType;
begin
  FillChar(Gsrb, sizeof(Gsrb), 0);
  Gsrb.SRB_Cmd := 1;
  ScatterDeviceID(DeviceID, Gsrb.SRB_HaId, Gsrb.SRB_Target, Gsrb.SRB_Lun);
  //   SendASPI32Command(@Gsrb);
  Result := GetAspiError(Gsrb.SRB_Status, $FF, $FF);
  if (Result = Err_None) and (Gsrb.SRB_DeviceType < ORD(TSDInvalid)) then
    DeviceType := TScsiDeviceType(Gsrb.SRB_DeviceType)
  else
    DeviceType := TSDInvalid;
end;
{$WARNINGS ON}

procedure GetDriveHandle(var DeviceID: TCDBurnerInfo);
var
  fh: THandle;
  buf2: array[0..31] of Char;
  DriveLetter: Char;
  dwFlags: DWord;
begin
  dwFlags := GENERIC_READ;
  if getOsVersion >= OS_WIN2K then
    dwFlags := dwFlags or GENERIC_WRITE;
  DriveLetter := DeviceIDtoLetter(DeviceID.DriveID);
  StrPCopy(@buf2, Format('\\.\%s:', [DriveLetter]));
  fh := CreateFile(buf2, dwFlags, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if fh = INVALID_HANDLE_VALUE then
  begin
    showmessage('cannot use need admin');
    CloseHandle(fh);
    Exit;
  end;
end;

function GetDriveTempHandle(DeviceID: TCDBurnerInfo): Thandle;
var
  DriveLetter: Char;
begin
  DriveLetter := DeviceIDtoLetter(DeviceID.DriveID);
  Result := CreateFile(PChar('\\.\' + DriveLetter + ':'),
    GENERIC_READ or GENERIC_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE,
    nil,
    OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL,
    0);
end;

function CloseDriveHandle(DeviceID: TCDBurnerInfo): Boolean;
begin
  Result := CloseHandle(DeviceID.SptiHandle);
end;

{seperate test function}

function ASPIsendScsiCommandInternal(DeviceID: TCDBurnerInfo;
  Pcdb: pointer; CdbLen: DWORD;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
var
  status: Byte;
  dwFlags: Cardinal;
  //  ErrorInt: Integer;
  skSCSI: TskSCSI;
  CDB: TCDB;
  CDBSize: Cardinal;
begin
  status := 1;
  Result := Err_None;
  skSCSI := TskSCSI.Create;
  if skSCSI.InitOK then
  begin
    CDBSize := CDBLen;
    Move(TCDB(pcdb^), CDB, CDBSize);
    dwFlags := Direction;
    status := skSCSI.ExecCmd(Deviceid.HaId, DeviceID.Target, DeviceID.Lun, CDB,
      CDBSize, dwFlags, pbuf, BufLen);
    skSCSI.Destroy;
  end;

  // Move(TCDB12(Pcdb^), pswb^.spt.Cdb, pswb^.spt.CdbLength);

  if not status = 0 then
  begin
    //    ErrorInt := GetLastError;
    Result := Err_Unknown;
    Exit;
  end;
end;

function ASPIsendScsiCommand(DeviceID: TCDBurnerInfo;
  Pcdb: pointer; CdbLen: DWORD;
  Pbuf: pointer; BufLen: DWORD;
  Direction: DWORD; var Sdf: TScsiDefaults): TScsiError;
begin
  Result := Err_None;
  FillChar(Sdf.Sense, sizeof(TscsiSenseInfo), 0);
  if Assigned(Sdf.fOnCommandSending) then
    Sdf.fOnCommandSending(DeviceID, Pcdb, CdbLen, Pbuf, BufLen,
      Direction, @Sdf, Result);

  Result := ASPIsendScsiCommandInternal(DeviceID,
    Pcdb, CdbLen, Pbuf, BufLen, Direction, Sdf);

  if Assigned(Sdf.fOnCommandSent) then
    Sdf.fOnCommandSent(DeviceID, Pcdb, CdbLen, Pbuf, BufLen,
      Direction, @Sdf, Result);
end;

procedure ASPIabortCommand(HaId: BYTE; Psrb: pointer);
type
  SRB_Abort = packed record
    SRB_Cmd: BYTE; // ASPI command code = 3 = SC_ABORT_SRB
    SRB_Status: BYTE; // ASPI command status byte
    SRB_HaId: BYTE; // ASPI host adapter number
    SRB_Flags: BYTE; // Reserved
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_ToAbort: pointer; // Pointer to SRB to abort
  end;
var
  Asrb: SRB_Abort;
begin
  FillChar(Asrb, sizeof(Asrb), 0);
  Asrb.SRB_Cmd := 3;
  Asrb.SRB_HaId := HaId;
  Asrb.SRB_ToAbort := Psrb;
  //   SendASPI32Command(@Asrb);
end;

function ASPIresetDevice(DeviceID: TCDBurnerInfo; Timeout: DWORD): TScsiError;
type
  SRB_ResetDevice = packed record
    SRB_Cmd: BYTE; // ASPI command code = 4 = SC_RESET_DEV
    SRB_Status: BYTE; // ASPI command status byte
    SRB_HaId: BYTE; // ASPI host adapter number
    SRB_Flags: BYTE; // Reserved
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_Target: BYTE; // Target's SCSI ID
    SRB_Lun: BYTE; // Target's LUN number
    SRB_Rsvd1: array[0..11] of BYTE; // Reserved for Alignment
    SRB_HaStat: BYTE; // Host Adapter Status
    SRB_TargStat: BYTE; // Target Status
    SRB_PostProc: THandle; // Post routine
    SRB_Rsvd2: POINTER; // Reserved
    SRB_Rsvd3: array[0..31] of BYTE; // Reserved for alignment
  end;
var
  Rsrb: SRB_ResetDevice;
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
  FillChar(Rsrb, sizeof(Rsrb), 0);
  with Rsrb do
  begin
    SRB_Cmd := 4; //  SC_RESET_DEV
    ScatterDeviceID(DeviceID.DriveID, SRB_HaId, SRB_Target, SRB_Lun);
    SRB_PostProc := hEvent;
  end;
  {   If SendASPI32Command(@Rsrb) = 0 Then Begin // SS_PENDING
        If WaitForSingleObject(hEvent, Timeout) <> WAIT_OBJECT_0
           Then Begin
           Result := Err_NotifyTimeout;
           ASPIabortCommand(Rsrb.SRB_HaId, @Rsrb);
        End;
     End Else Result := Err_NoDevice;
     }

  CloseHandle(hEvent);
  if Result = Err_None then
    with Rsrb do
      Result := GetAspiError(SRB_Status, SRB_HaStat, SRB_TargStat);
end;

function ASPIgetDriveInt13info(DeviceID: TCDBurnerInfo;
  var Info: TScsiInt13info): TScsiError;
type
  SRB_Int13info = packed record
    SRB_Cmd: BYTE; // ASPI command code=6=SC_GET_DISK_INFO
    SRB_Status: BYTE; // ASPI command status byte
    SRB_HaId: BYTE; // ASPI host adapter number
    SRB_Flags: BYTE; // Reserved
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_Target: BYTE; // Target's SCSI ID
    SRB_Lun: BYTE; // Target's LUN number
    SRB_DriveFlags: BYTE; // Driver flags
    SRB_Int13Drive: BYTE; // Host Adapter Status
    SRB_Heads: BYTE; // Preferred number of heads translation
    SRB_Sectors: BYTE; // Preferred number of sectors translation
    SRB_Rsvd: array[0..9] of BYTE; // Reserved
  end;
var
  Isrb: SRB_Int13info;
begin
  FillChar(Isrb, sizeof(Isrb), 0);
  with Isrb do
  begin
    SRB_Cmd := 6;
    ScatterDeviceID(DeviceID.DriveID, SRB_HaId, SRB_Target, SRB_Lun);
  end;
  //   SendASPI32Command(@Isrb);
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

function GetSPTICdRomDrives(var CdRoms: TSPTIWriters): Boolean;
var
  Index: integer;
begin
  Result := False;
  if GetDriveNumbers(CdRoms) > 0 then
  begin
    for Index := 0 to CdRoms.CdRomCount - 1 do
    begin
      GetDriveInformation(Index, CdRoms);
    end;
    Result := True;
  end;
end;

procedure GetDriveInformation(i: byte; var CdRoms: TSPTIWriters);
var
  fh: THandle;
  buf: array[0..1023] of Char;
  buf2: array[0..31] of Char;
  status: Bool;
  pswb: PSCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  pscsiAddr: PSCSI_ADDRESS;
  length, returned: integer;
  inqData: array[0..99] of Char; // was array[0..99] of Byte;
  dwFlags: DWord;
  DriveString: PChar;
begin
  dwFlags := GENERIC_READ;
  if getOsVersion >= OS_WIN2K then
    dwFlags := dwFlags or GENERIC_WRITE;
  StrPCopy(@buf2, Format('\\.\%s:', [CdRoms.CdRom[i].DriveLetter]));
  fh := CreateFile(buf2, dwFlags, FILE_SHARE_READ or FILE_SHARE_WRITE, nil,
    OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if fh = INVALID_HANDLE_VALUE then
  begin
    // It seems that with no Administrator privileges
    // the handle value will be invalid
    Exit;
  end;

  (*
   * Get the drive inquiry data
   *)
  ZeroMemory(@buf, 1024);
  ZeroMemory(@inqData, 100);
  pswb := PSCSI_PASS_THROUGH_DIRECT_WITH_BUFFER(@buf);
  pswb^.spt.Length := sizeof(SCSI_PASS_THROUGH);
  pswb^.spt.CdbLength := 6;
  pswb^.spt.SenseInfoLength := 24;
  pswb^.spt.DataIn := SCSI_IOCTL_DATA_IN;
  pswb^.spt.DataTransferLength := 100;
  pswb^.spt.TimeOutValue := 2;
  pswb^.spt.DataBuffer := @inqData;
  pswb^.spt.SenseInfoOffset := SizeOf(pswb^.spt) + SizeOf(pswb^.Filler);
  pswb^.spt.Cdb[0] := $12;
  pswb^.spt.Cdb[4] := $64;

  length := sizeof(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);
  status := DeviceIoControl(fh,
    IOCTL_SCSI_PASS_THROUGH_DIRECT,
    pswb,
    length,
    pswb,
    length,
    Cardinal(returned),
    nil);

  if not status then
  begin
    // CloseHandle( fh );
    Exit;
  end;

  DriveString := @inqData;
  Inc(DriveString, 8);

  CdRoms.CdRom[i].Vendor := Copy(DriveString, 1, 8); // Vendor
  CdRoms.CdRom[i].ProductId := Copy(DriveString, 8 + 1, 16);
  // Product ID
  CdRoms.CdRom[i].Revision := Copy(DriveString, 24 + 1, 4);
  // Revision
  CdRoms.CdRom[i].VendorSpec := Copy(DriveString, 28 + 1, 20);
  // Vendor Spec.
  CdRoms.CdRom[i].Description := CdRoms.CdRom[i].Vendor +
    CdRoms.CdRom[i].ProductId + CdRoms.CdRom[i].Revision;
  CdRoms.CdRom[i].DriveHandle := fh;
  (*
   * get the address (path/tgt/lun) of the drive via IOCTL_SCSI_GET_ADDRESS
   *)
  ZeroMemory(@buf, 1024);
  pscsiAddr := PSCSI_ADDRESS(@buf);
  pscsiAddr^.Length := sizeof(SCSI_ADDRESS);
  if (DeviceIoControl(fh, IOCTL_SCSI_GET_ADDRESS, nil, 0,
    pscsiAddr, sizeof(SCSI_ADDRESS), Cardinal(returned),
    nil)) then
  begin
    CDRoms.CdRom[i].HaId := pscsiAddr^.PortNumber;
    CDRoms.CdRom[i].Target := pscsiAddr^.TargetId;
    CDRoms.CdRom[i].Lun := pscsiAddr^.Lun;
  end
  else
  begin
    Exit;
  end;

  // CloseHandle( fh );
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
  Result := ASPIsendScsiCommand(DeviceID, @cdb, 6,
    Pbuf, BufLen, Direction, Sdf);
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
  Result := ASPIsendScsiCommand(DeviceID, @cdb, 10,
    Pbuf, BufLen, Direction, Sdf);
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
  Result := ASPIsendScsiCommand(DeviceID, @cdb, 12,
    Pbuf, BufLen, Direction, Sdf);
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

end.
