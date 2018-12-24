{==============================================================================|
| SCSI Header for ASPI, ASAPI and SPTI/IOCTL                                   |
|==============================================================================|
|                                                                              |
| Author: Kalman Speier                                                        |
|   Mail: mail@speier.hu                                                       |
|   Home: www.speier.hu                                                        |
|  Legal: Copyright (c) 2002-2005 Speier Software                              |
|         All Rights Reserved                                                  |
|                                                                              |
|==============================================================================|
|                                                                              |
| Definitions:                                                                 |
|   SCSI = Small Computer System Interface                                     |
|   ASPI = Advanced SCSI Programming Interface (Developed by Adaptec)          |
|  ASAPI = Advanced ASPI Programming Interface (Developed by VOB/Pinnacle)     |
|   SPTI = SCSI Passthrough Interface (MS Replacement of ASPI on NT/2k/XP/2k3) |
|  IOCTL = Device Input/Output Control (WinAPI Command is DeviceIOControl)     |
|                                                                              |
|==============================================================================|
|                                                                              |
| Used Sources and Docs:                                                       |
|  Adaptec Software Developer's Kit (SDK) v2.4                                 |
|  SPC & MMC Drafts from T10.org (www.t10.org)                                 |
|  ASPI & SCSI Programming by Alvise Valsecchi (www.hochfeiler.it/alvise)      |
|                                                                              |
| Thanx to:                                                                    |
|  daNIL for WNASPI32 & SCSIDEFS 'C' Headers Translation (Project Jedi)        |
|  Sergey "KSER" Kabikov for his Delphi ASPI Library                           |
|  Farshid Mossaiby for ASPI Spy                                               |
|  Jay A. Key for AKRip                                                        |
|  Additional programming by Dancemammal                                       |
|==============================================================================}

unit skSCSI;

interface

uses
  Windows,
  SysUtils;

const
  {****************************************************************************}
  {  ASPI COMMAND CONSTANTS                                                    }
  {****************************************************************************}
  SENSE_LEN = 14; // Default sense buffer length
  SRB_DIR_SCSI = $00; // Direction determined by SCSI command
  SRB_DIR_IN = $08; // Transfer from SCSI target to host
  SRB_DIR_OUT = $10; // Transfer from host to SCSI target
  SRB_POSTING = $01; // Enable ASPI posting
  SRB_EVENT_NOTIFY = $40; // Enable ASPI event notification
  SRB_ENABLE_RESIDUAL_COUNT = $04; // Enable residual byte count reporting
  SRB_DATA_SG_LIST = $02; // Data buffer points to scatter-gather list
  WM_ASPIPOST = $4D42; // ASPI Post message
  DTYPE_CDROM = $05; // CD-ROM device type
  DTYPE_UNKNOWN = $1F; // Unknown or no device type

  {****************************************************************************}
  {  ASPI COMMAND DEFINITIONS                                                  }
  {****************************************************************************}
  SC_HA_INQUIRY = $00; // Host adapter inquiry
  SC_GET_DEV_TYPE = $01; // Get device type
  SC_EXEC_SCSI_CMD = $02; // Execute SCSI command
  SC_ABORT_SRB = $03; // Abort an SRB
  SC_RESET_DEV = $04; // SCSI bus device reset
  SC_GET_DISK_INFO = $06; // Get Disk information
  SC_SCSI_INQUIRY = $12; // SCSI inquiry

  {****************************************************************************}
  {  SRB STATUS                                                                }
  {****************************************************************************}
  SS_PENDING = $00; // SRB being processed
  SS_COMP = $01; // SRB completed without error
  SS_ABORTED = $02; // SRB aborted
  SS_ABORT_FAIL = $03; // Unable to abort SRB
  SS_ERR = $04; // SRB completed with error
  SS_INVALID_CMD = $80; // Invalid ASPI command
  SS_INVALID_HA = $81; // Invalid host adapter number
  SS_NO_DEVICE = $82; // SCSI device not installed
  SS_INVALID_SRB = $E0; // Invalid parameter set in SRB
  SS_FAILED_INIT = $E4; // ASPI for windows failed init
  SS_ASPI_IS_BUSY = $E5; // No resources available to execute cmd
  SS_BUFFER_TO_BIG = $E6; // Buffer size to big to handle!
  SS_NO_ADAPTERS = $E8; // No host adapters to manage

  {****************************************************************************}
  {  HOST ADAPTER STATUS                                                       }
  {****************************************************************************}
  HASTAT_OK = $00; // Host adapter did not detect an error
  HASTAT_SEL_TO = $11; // Selection Timeout
  HASTAT_DO_DU = $12; // Data overrun data underrun
  HASTAT_BUS_FREE = $13; // Unexpected bus free
  HASTAT_PHASE_ERR = $14; // Target bus phase sequence failure
  HASTAT_TIMEOUT = $09; // Timed out while SRB was waiting to be processed
  HASTAT_COMMAND_TIMEOUT = $0B;
  // While processing the SRB, the adapter is timed out
  HASTAT_MESSAGE_REJECT = $0D;
  // While processing SRB, the adapter received a MESSAGE REJECT
  HASTAT_BUS_RESET = $0E; // A bus reset was detected
  HASTAT_PARITY_ERROR = $0F; // A parity error was detected
  HASTAT_REQUEST_SENSE_FAILED = $10;
  // The adapter failed in issuing REQUEST SENSE

type
  TCDB = array[0..15] of Byte; // SCSI Command Descriptor Block (Max 16 bytes)

type
  {****************************************************************************}
  {  HOST ADAPTER INQUIRY - SC_HA_INQUIRY                                      }
  {****************************************************************************}
  TSRB_HAInquiry = packed record
    Cmd, // ASPI command code = SC_HA_INQUIRY
    Status, // ASPI command status byte
    HaId, // ASPI host adapter number
    Flags: BYTE; // ASPI request flags
    Hdr_Rsvd: DWORD; // Reserved, MUST = 0
    HA_Count, // Number of host adapters present
    HA_SCSI_ID: BYTE; // SCSI ID of host adapter
    HA_ManagerId, // String describing the manager
    HA_Identifier, // String describing the host adapter
    HA_Unique: array[0..15] of CHAR; // Host Adapter Unique parameters
    HA_Rsvd1: WORD;
  end;
  PSRB_HAInquiry = ^TSRB_HAInquiry;

  {****************************************************************************}
  {  GET DEVICE TYPE - SC_GET_DEV_TYPE                                         }
  {****************************************************************************}
  TSRB_GDEVBlock = packed record
    Cmd, // ASPI command code = SC_GET_DEV_TYPE
    Status, // ASPI command status byte
    HaId, // ASPI host adapter number
    Flags: BYTE; // Reserved
    Hdr_Rsvd: DWORD; // Reserved
    Target, // Target's SCSI ID
    Lun, // Target's LUN number
    DeviceType, // Target's peripheral device type
    Rsvd1: BYTE;
  end;
  PSRB_GDEVBlock = ^TSRB_GDEVBlock;

  {****************************************************************************}
  {  REQUES SENSE DATA FORMAT                                                  }
  {****************************************************************************}
  TSenseArea = packed record
    ErrorCode,
      SegmentNum,
      SenseKey,
      InfoByte0,
      InfoByte1,
      InfoByte2,
      InfoByte3,
      AddSenLen,
      ComSpecInf0,
      ComSpecInf1,
      ComSpecInf2,
      ComSpecInf3,
      AddSenseCode,
      AddSenQual,
      FieldRepUCode,
      SenKeySpec15,
      SenKeySpec16,
      SenKeySpec17: Byte;
    AddSenseBytes: array[18..$20] of Byte;
  end;

  {****************************************************************************}
  {  EXECUTE SCSI COMMAND - SC_EXEC_SCSI_CMD                                   }
  {****************************************************************************}
  TSRB_ExecSCSICmd = packed record
    Cmd, // ASPI command code = SC_EXEC_SCSI_CMD
    Status, // ASPI command status byte
    HaId, // ASPI host adapter number
    Flags: BYTE; // ASPI request flags
    Hdr_Rsvd: DWORD; // Reserved
    Target, // Target's SCSI ID
    Lun: BYTE; // Target's LUN number
    Rsvd1: WORD; // Reserved for Alignment
    BufLen: DWORD; // Data Allocation Length
    BufPointer: PCHAR; // Data Buffer Pointer
    SenseLen, // Sense Allocation Length
    CDBLen, // CDB Length
    HaStat, // Host Adapter Status
    TargStat: BYTE; // Target Status
    PostProc: THANDLE; // Post routine
    Rsvd2: POINTER; // Reserved
    Rsvd3, // Reserved for alignment
    CDBByte: TCDB; // SCSI CDB
    SenseArea: TSenseArea; // Request Sense buffer
  end;
  PSRB_ExecSCSICmd = ^TSRB_ExecSCSICmd;

  {****************************************************************************}
  {  ABORT AN SRB - SC_ABORT_SRB                                               }
  {****************************************************************************}
  TSRB_Abort = packed record
    Cmd, // ASPI command code = SC_EXEC_SCSI_CMD
    Status, // ASPI command status byte
    HaId, // ASPI host adapter number
    Flags: BYTE; // Reserved
    Hdr_Rsvd: DWORD; // Reserved
    ToAbort: POINTER; // Pointer to SRB to abort
  end;

  {****************************************************************************}
  {  BUS DEVICE RESET - SC_RESET_DEV                                           }
  {****************************************************************************}
  TSRB_BusDeviceReset = packed record
    Cmd, // ASPI command code = SC_EXEC_SCSI_CMD
    Status, // ASPI command status byte
    HaId, // ASPI host adapter number
    Flags: BYTE; // Reserved
    Hdr_Rsvd: DWORD; // Reserved
    Target, // Target's SCSI ID
    Lun: BYTE; // Target's LUN number
    Rsvd1: array[0..11] of BYTE; // Reserved for Alignment
    HaStat, // Host Adapter Status
    TargStat: BYTE; // Target Status
    PostProc: THANDLE; // Post routine
    Rsvd2: POINTER; // Reserved
    Rsvd3, // Reserved
    CDBByte: array[0..15] of BYTE; // SCSI CDB
  end;

  {****************************************************************************}
  {  GET DISK INFORMATION - SC_GET_DISK_INFO                                   }
  {****************************************************************************}
  TSRB_GetDiskInfo = packed record
    Cmd, // ASPI command code = SC_EXEC_SCSI_CMD
    Status, // ASPI command status byte
    HaId, // ASPI host adapter number
    Flags: BYTE; // Reserved
    Hdr_Rsvd: DWORD; // Reserved
    Target, // Target's SCSI ID
    Lun, // Target's LUN number
    DriveFlags, // Driver flags
    Int13HDriveInfo, // Host Adapter Status
    Heads, // Preferred number of heads translation
    Sectors: BYTE; // Preferred number of sectors translation
    Rsvd1: array[0..9] of BYTE; // Reserved
  end;
  PSRB_GetDiskInfo = ^TSRB_GetDiskInfo;

const
  {****************************************************************************}
  {  SPTI/IOCTL CONSTANTS                                                      }
  {****************************************************************************}

  (* method codes *)
  METHOD_BUFFERED = 0;
  METHOD_IN_DIRECT = 1;
  METHOD_OUT_DIRECT = 2;
  METHOD_NEITHER = 3;

  (* file access values *)
  FILE_ANY_ACCESS = 0;
  FILE_READ_ACCESS = $0001;
  FILE_WRITE_ACCESS = $0002;
  IOCTL_CDROM_BASE = $00000002;
  IOCTL_SCSI_BASE = $00000004;

  (* constants for DataIn member of SCSI_PASS_THROUGH structures *)
  SCSI_IOCTL_DATA_OUT = 0;
  SCSI_IOCTL_DATA_IN = 1;
  SCSI_IOCTL_DATA_UNSPECIFIED = 2;

  (* standard IOCTL codes *)
  IOCTL_CDROM_READ_TOC = $24000;
  IOCTL_CDROM_GET_LAST_SESSION = $24038;
  IOCTL_SCSI_PASS_THROUGH = $4D004;
  IOCTL_SCSI_MINIPORT = $4D008;
  IOCTL_SCSI_GET_INQUIRY_DATA = $4100C;
  IOCTL_SCSI_GET_CAPABILITIES = $41010;
  IOCTL_SCSI_PASS_THROUGH_DIRECT = $4D014;
  IOCTL_SCSI_GET_ADDRESS = $41018;

type
  {****************************************************************************}
  {  STRUCT DEFINITIONS FOR SPTI                                               }
  {****************************************************************************}
  SCSI_PASS_THROUGH = record
    Length: Word;
    SCSIStatus: Byte;
    PathId: Byte;
    Target: Byte;
    Lun: Byte;
    CDBLength: Byte;
    SenseInfoLength: Byte;
    DataIn: Byte;
    DataTransferLength: ULONG;
    TimeOutValue: ULONG;
    DataBufferOffset: ULONG;
    SenseInfoOffset: ULONG;
    CDB: array[0..16 - 1] of Byte;
  end;
  PSCSI_PASS_THROUGH = ^SCSI_PASS_THROUGH;

  PVOID = Pointer;

  SCSI_PASS_THROUGH_DIRECT = record
    Length: Word;
    SCSIStatus: Byte;
    PathID: Byte;
    Target: Byte;
    Lun: Byte;
    CDBLength: Byte;
    SenseInfoLength: Byte;
    DataIn: Byte;
    DataTransferLength: ULONG;
    TimeOutValue: ULONG;
    DataBuffer: PVOID;
    SenseInfoOffset: ULONG;
    CDB: array[0..16 - 1] of Byte;
  end;
  PSCSI_PASS_THROUGH_DIRECT = ^SCSI_PASS_THROUGH_DIRECT;

  SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER = record
    SPT: SCSI_PASS_THROUGH_DIRECT;
    Filler: ULONG;
    ucSenseBuf: array[0..32 - 1] of Byte;
  end;
  PSCSI_PASS_THROUGH_DIRECT_WITH_BUFFER = ^SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;

  TSCSIDRIVE = record
    HA, Target, Lun,
      Letter: Byte;
    Used: Boolean;
    DeviceHandle: THANDLE;
    inqData: array[0..64] of Char;
  end;

  TSCSIDRIVES = record
    numAdapters: Byte;
    Drive: array[0..26] of TSCSIDRIVE;
  end;

  (* SCSI ADDRESS HA/TargetID/Lun *)
  SCSI_ADDRESS = record
    Length: LongInt;
    HA: Byte;
    PathID: Byte;
    Target: Byte;
    Lun: Byte;
  end;
  PSCSI_ADDRESS = ^SCSI_ADDRESS;

type
  {****************************************************************************}
  {  VERSION INFO CLASS                                                        }
  {****************************************************************************}
  TVersionInfo = class
  private
    FCompanyName: string;
    FFileDescription: string;
    FFileVersion: string;
    FInternalName: string;
    FLegalCopyright: string;
    FLegalTradeMarks: string;
    FOriginalFilename: string;
    FProductName: string;
    FProductVersion: string;
    FComments: string;
    constructor GetVersionInfo(FileName: string);
  public
    property CompanyName: string read FCompanyName;
    property FileDescription: string read FFileDescription;
    property FileVersion: string read FFileVersion;
    property InternalName: string read FInternalName;
    property LegalCopyright: string read FLegalCopyright;
    property LegalTradeMarks: string read FLegalTradeMarks;
    property OriginalFilename: string read FOriginalFileName;
    property ProductName: string read FProductName;
    property ProductVersion: string read FProductVersion;
    property Comments: string read FComments;
  end;

type
  {****************************************************************************}
  {  SCSI INTERFACE CLASS                                                      }
  {****************************************************************************}
  TInterfaceType = (ifASPI, ifASAPI, ifSPTI);
  TskSCSI = class
  private
    FInitOK: Boolean; // Will be TRUE if Initialization was OK (Handle <> 0)
    FifType: TInterfaceType; // The Type of Interface in Use
    FosName: ShortString; // The Name of the Operating System
    FviASPI: TVersionInfo; // Version Info of ASPI or ASAPI DLL (NIL for SPTI)
  public
    constructor Create;
    destructor Destroy; override;
    function ExecCmd(HaId, Target, Lun: Byte; CDB: TCDB; CDBLen: Cardinal;
      Flags: Cardinal; Buffer: Pointer; BufferLen: Cardinal): Byte;
    function AbortCmd(FSRB_ExecSCSICmd: TSRB_ExecSCSICmd): Boolean;
    function InterfaceNameShort: string;
    function InterfaceNameLong: string;
    function InterfaceDeveloper: string;
    property InitOK: Boolean read FInitOK;
    property InterfaceType: TInterfaceType read FifType;
    property osName: ShortString read FosName;
    property viASPI: TVersionInfo read FviASPI;
    // Version Info of ASPI or ASAPI DLL (NIL for SPTI)
  end;

var
  {****************************************************************************}
  {  PUBLIC VARIABLES                                                          }
  {****************************************************************************}

  // Public to direct use, Named "ASPI", but we use for ASAPI or SPTI too
  GetASPI32SupportInfo: function: DWord; cdecl;
  SendASPI32Command: function(LPSRB: Pointer): DWord; cdecl;

implementation

const
  {****************************************************************************}
  {  CONSTANTS                                                                 }
  {****************************************************************************}
  ASPI = 'wnaspi32.dll';
  ASAPI = 'asapi.dll';
  SPTI = 'skSCSI'; // Dummy for Manager ID and Inquiry Data

var
  {****************************************************************************}
  {  VARIABLES                                                                 }
  {****************************************************************************}
  SCSIHandle: THandle; // DLL Handle if Using ASPI or ASAPI (1 if USING SPTI)
  SCSIDrives: TSCSIDRIVES;
  TGN: Byte = 0;
  inqData: array[0..1024] of Char = SPTI;

  {****************************************************************************}
  {  SPTI COMMANDS BEGIN                                                       }
  {****************************************************************************}

function SPTI_GetASPI32SupportInfo: DWord;
begin
  if SCSIDrives.numAdapters = 0 then
    Result := MAKEWORD(0, SS_NO_ADAPTERS)
  else
    Result := MAKEWORD(SCSIDrives.numAdapters, SS_COMP);
end;

function SPTI_HaInquiry(FPSRB: Pointer): DWord;
var
  PSRB: PSRB_HAInquiry;
begin
  PSRB := FPSRB;
  PSRB.HA_Count := SCSIDrives.numAdapters;
  if PSRB.HaId >= SCSIDrives.numAdapters then
  begin
    PSRB.Status := SS_INVALID_HA;
    Result := SS_INVALID_HA;
    Exit;
  end;
  PSRB.HA_SCSI_ID := 7;
  PSRB.HA_ManagerId := SPTI;
  PSRB.HA_Identifier := 'SPTI  '#0#0#0#0#0#0#0#0#0;
  PSRB.HA_Identifier[5] := Char($30 + PSRB.HaId);
  FillChar(PSRB.HA_Unique, 13, 0);
  PSRB.HA_Unique[0] := #7; // buffer alignment
  PSRB.HA_Unique[3] := #8; // scsi targets
  PSRB.HA_Unique[4] := #00;
  PSRB.HA_Unique[5] := #00;
  PSRB.HA_Unique[6] := #$FF;
  PSRB.Status := SS_COMP;
  Result := SS_COMP;
end;

function SPTI_GetDevIndex(H, T, L: Byte): Byte;
var
  i: Byte;
  Drv: TSCSIDRIVE;
begin
  for i := 2 to 26 do
  begin
    if SCSIDrives.Drive[i].Used then
    begin
      Drv := SCSIDrives.Drive[i];
      if (Drv.Ha = H) and (Drv.Target = T) and (Drv.Lun = L) then
      begin
        Result := i;
        Exit;
      end;
    end
  end;
  Result := 0;
end;

function SPTI_GetDevType(FPSRB: Pointer): DWord;
var
  PSRB: PSRB_GDEVBlock;
begin
  PSRB := FPSRB;
  PSRB.Status := SS_NO_DEVICE;
  if SPTI_GetDevIndex(PSRB.HaId, PSRB.Target, PSRB.Lun) <> 0 then
    PSRB.Status := SS_COMP;
  if PSRB.Status = SS_COMP then
    PSRB.DeviceType := DTYPE_CDROM
  else
    PSRB.DeviceType := DTYPE_UNKNOWN;
  Result := PSRB.Status;
end;

function SPTI_GetDiskInfo(FPSRB: Pointer): DWord;
var
  PSRB: PSRB_GetDiskInfo;
begin
  PSRB := FPSRB;
  PSRB.Int13HDriveInfo := SPTI_GetDevIndex(PSRB.HaId, PSRB.Target, PSRB.Lun);
  PSRB.Status := SS_COMP;
  Result := SS_COMP;
end;

function SPTI_GetDriveHandle(i: Byte): LongWord;
var
  Path: string;
begin
  Path := '\\.\' + Char(i + 65) + ':'#0;
  Result := CreateFile(@Path[1], GENERIC_WRITE or GENERIC_READ, FILE_SHARE_READ
    or FILE_SHARE_WRITE, nil, OPEN_EXISTING, FILE_ATTRIBUTE_NORMAL, 0);
  if Result = INVALID_HANDLE_VALUE then
    Result := CreateFile(@Path[1], GENERIC_READ, FILE_SHARE_READ, nil,
      OPEN_EXISTING, 0, 0);
end;

function SPTI_SendASPI32Command_Internal(PSRB: PSRB_ExecSCSICmd; Again:
  Boolean): DWord;
var
  Status: Boolean;
  SPTI_WBUFFER: SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  Length, Returned: Cardinal;
  Index: Byte;
label
  ExecSCSICmd;
begin
  if PSRB = nil then
  begin
    Result := SS_ERR;
    Exit;
  end;
  case PSRB^.Cmd of
    SC_EXEC_SCSI_CMD:
      goto ExecSCSICmd;
    SC_HA_INQUIRY:
      begin
        Result := SPTI_HaInquiry(PSRB);
        Exit;
      end;
    SC_GET_DEV_TYPE:
      begin
        Result := SPTI_GetDevType(PSRB);
        Exit;
      end;
    SC_GET_DISK_INFO:
      begin
        Result := SPTI_GetDiskInfo(PSRB);
        Exit;
      end;
  else
    begin
      PSRB^.Status := SS_ERR;
      Result := SS_ERR;
      Exit;
    end;
  end;
  ExecSCSICmd:
  Index := SPTI_GetDevIndex(PSRB^.HaId, PSRB^.Target, PSRB^.Lun);
  if Index = 0 then
  begin
    PSRB^.Status := SS_NO_DEVICE;
    Result := SS_NO_DEVICE;
    Exit;
  end;
  if PSRB^.CDBByte[0] = SC_SCSI_INQUIRY then
  begin
    if PSRB^.HaId >= SCSIDrives.numAdapters then
    begin
      PSRB^.Status := SS_INVALID_HA;
      Result := SS_INVALID_HA;
      Exit;
    end;
    PSRB^.Status := SS_COMP;
    Move(SCSIDrives.Drive[Index].inqData, PSRB^.BufPointer[0], 36);
    Result := SS_COMP;
    Exit;
  end;
  if (SCSIDrives.Drive[Index].DeviceHandle = INVALID_HANDLE_VALUE) then
    SCSIDrives.Drive[Index].DeviceHandle :=
      SPTI_GetDriveHandle(SCSIDrives.Drive[Index].Letter);
  FillChar(SPTI_WBUFFER, SizeOf(SPTI_WBUFFER), 0);
  if PSRB^.Flags and SRB_DIR_IN <> 0 then
    SPTI_WBUFFER.SPT.DataIn := SCSI_IOCTL_DATA_IN
  else if PSRB^.Flags and SRB_DIR_OUT <> 0 then
    SPTI_WBUFFER.SPT.DataIn := SCSI_IOCTL_DATA_OUT
  else
    SPTI_WBUFFER.SPT.DataIn := SCSI_IOCTL_DATA_UNSPECIFIED;
  with SPTI_WBUFFER.SPT do
  begin
    Length := SizeOf(SCSI_PASS_THROUGH_DIRECT);
    CdbLength := PSRB^.CDBLen;
    SenseInfoLength := PSRB^.SenseLen;
    DataTransferLength := PSRB^.BufLen;
    TimeOutValue := 120;
    DataBuffer := PSRB^.BufPointer;
    SenseInfoOffset := 48;
  end;
  Move(PSRB^.CDBByte[0], SPTI_WBUFFER.SPT.CDB, PSRB^.CDBLen);
  Length := SizeOf(SPTI_WBUFFER);
  Status := DeviceIoControl(SCSIDrives.Drive[Index].DeviceHandle,
    IOCTL_SCSI_PASS_THROUGH_DIRECT, @SPTI_WBUFFER, Length, @SPTI_WBUFFER,
      Length,
    Returned, nil);
  if ((SPTI_WBUFFER.SPT.SenseInfoLength = 0) or (SPTI_WBUFFER.SPT.SenseInfoLength
    = 32))
    and (SPTI_WBUFFER.SPT.SCSIStatus = 0) and Status then
    PSRB^.Status := SS_COMP
  else
  begin
    PSRB^.Status := SS_ERR;
    Move(SPTI_WBUFFER.ucSenseBuf, PSRB^.SenseArea,
      SPTI_WBUFFER.SPT.SenseInfoLength);
    PSRB^.TargStat := SPTI_WBUFFER.SPT.SCSIStatus;
  end;
  if SCSIDrives.Drive[Index].DeviceHandle <> INVALID_HANDLE_VALUE then
  begin
    if CloseHandle(SCSIDrives.Drive[Index].DeviceHandle) then
      SCSIDrives.Drive[Index].DeviceHandle := INVALID_HANDLE_VALUE;
  end;
  Result := PSRB^.Status;
end;

function SPTI_SendASPI32Command(PSRB: PSRB_ExecSCSICmd): DWord;
begin
  Result := SPTI_SendASPI32Command_Internal(PSRB, False);
end;

procedure SPTI_GetDriveInfo(i: Byte; var pDrive: TSCSIDRIVE);
var
  Handle: THandle;
  Buffer: array[0..1023] of Char;
  P_SCSI_WBUFFER: PSCSI_PASS_THROUGH_DIRECT_WITH_BUFFER;
  P_SCSI_ADDRESS: PSCSI_ADDRESS;
  Length, Returned: Cardinal;
  Status: Boolean;
begin
  Handle := SPTI_GetDriveHandle(i);
  if (Handle = INVALID_HANDLE_VALUE) then
    Exit;
  ZeroMemory(@Buffer, 1024);
  ZeroMemory(@inqData, SizeOf(inqData));
  P_SCSI_WBUFFER := @Buffer;
  with P_SCSI_WBUFFER.SPT do
  begin
    Length := SizeOf(SCSI_PASS_THROUGH);
    CDBLength := 6;
    SenseInfoLength := 24;
    DataIn := SCSI_IOCTL_DATA_IN;
    DataTransferLength := 96;
    TimeOutValue := 120;
    DataBuffer := @inqData;
    SenseInfoOffset := 48;
    CDB[0] := SC_SCSI_INQUIRY;
    CDB[4] := 96;
  end;
  Length := SizeOf(SCSI_PASS_THROUGH_DIRECT_WITH_BUFFER);
  Status := DeviceIoControl(Handle, IOCTL_SCSI_PASS_THROUGH_DIRECT,
    P_SCSI_WBUFFER, Length, P_SCSI_WBUFFER, Length, Returned, nil);
  if not Status then
  begin
    CloseHandle(Handle);
    Exit;
  end;
  Move(inqData, pDrive.inqData, 40);
  FillChar(Buffer, Sizeof(Buffer), 0);
  P_SCSI_ADDRESS := @Buffer;
  P_SCSI_ADDRESS.Length := SizeOf(SCSI_ADDRESS);
  if DeviceIoControl(Handle, IOCTL_SCSI_GET_ADDRESS, nil, 0, P_SCSI_ADDRESS,
    SizeOf(SCSI_ADDRESS), Returned, nil) then
  begin
    pDrive.Used := True;
    pDrive.Ha := P_SCSI_ADDRESS.Ha;
    pDrive.Target := P_SCSI_ADDRESS.Target;
    pDrive.Lun := P_SCSI_ADDRESS.Lun;
    pDrive.Letter := i;
    pDrive.DeviceHandle := INVALID_HANDLE_VALUE;
  end
  else
  begin
    pDrive.Used := True;
    pDrive.Ha := 0;
    pDrive.Target := TGN;
    pDrive.Lun := 250;
    pDrive.Letter := i;
    pDrive.DeviceHandle := INVALID_HANDLE_VALUE;
    Inc(TGN);
  end;
  CloseHandle(Handle);
end;

function SPTI_GetNumAdapters: Byte;
var
  i, numAdapters: Byte;
begin
  numAdapters := 0;
  for i := 1 to 26 do
  begin
    if numAdapters < SCSIDrives.Drive[i].Ha then
      numAdapters := SCSIDrives.Drive[i].Ha;
  end;
  Inc(numAdapters);
  Result := numAdapters;
  Exit;
end;

function InitSPTI: Byte;
var
  s: string;
  i, uDriveType, Return: Byte;
begin
  Return := 0;
  TGN := 0;
  FillChar(SCSIDrives, SizeOf(SCSIDrives), 0);
  for i := 2 to 26 do
    SCSIDrives.Drive[i].DeviceHandle := INVALID_HANDLE_VALUE;
  for i := 2 to 26 do
  begin
    s := Char(65 + i) + ':\';
    uDriveType := GetDriveType(@s[1]);
    if uDriveType = DRIVE_CDROM then
    begin
      SPTI_GetDriveInfo(i, SCSIDrives.Drive[i]);
      if SCSIDrives.Drive[i].Used then
        Inc(Return);
    end;
  end;
  SCSIDrives.numAdapters := SPTI_GetNumAdapters;
  if TGN <> 0 then
  begin
    for i := 2 to 26 do
    begin
      if SCSIDrives.Drive[i].Used then
        if ScsiDrives.drive[i].Lun = 250 then
        begin
          SCSIDrives.Drive[i].Lun := 0;
          SCSIDrives.Drive[i].Ha := SCSIDrives.numAdapters;
        end;
    end;
    SCSIDrives.numAdapters := SPTI_GetNumAdapters;
  end;
  Result := Return;
end;

function DeInitSPTI: Integer;
var
  i: integer;
begin
  for i := 2 to 26 do
    if (SCSIDrives.Drive[i].Used) then
      if SCSIDrives.Drive[i].DeviceHandle <> INVALID_HANDLE_VALUE then
        CloseHandle(SCSIDrives.Drive[i].DeviceHandle);
  SCSIDrives.numAdapters := SPTI_GetNumAdapters();
  FillChar(SCSIDrives, SizeOf(SCSIDrives), 0);
  Result := -1;
end;

{******************************************************************************}
{  GetVersionInfo to Determine the Currently Using ASPI/ASAPI Layer's Version  }
{******************************************************************************}

constructor TVersionInfo.GetVersionInfo(FileName: string);
type
  TTranslation = record
    LangID, Charset: Word;
  end;
var
  VerInfo: Pointer;
  VerInfoSize, Dummy: DWord;
  VerValue: Pointer;
  VerValueSize: DWord;
  VerTrans: TTranslation;
  Lang, From: string;
  function GetValue(Value: string): string;
  begin
    if VerQueryValue(VerInfo, PChar(From + Value), VerValue, VerValueSize) then
      Result := PChar(VerValue)
    else
      Result := '';
  end;
begin
  inherited Create;
  VerInfoSize := GetFileVersionInfoSize(PChar(FileName), Dummy);
  GetMem(VerInfo, VerInfoSize);
  if GetFileVersionInfo(PChar(FileName), 0, VerInfoSize, VerInfo) then
  begin
    VerQueryValue(VerInfo, '\VarFileInfo\Translation', VerValue, VerValueSize);
    Move(VerValue^, VerTrans, VerValueSize);
    Lang := IntToHex(VerTrans.LangID, 4) + IntToHex(VerTrans.Charset, 4);
    From := '\StringFileInfo\' + Lang + '\';
    FCompanyName := GetValue('CompanyName');
    FFileDescription := GetValue('FileDescription');
    FFileVersion := GetValue('FileVersion');
    FInternalName := GetValue('InternalName');
    FLegalCopyright := GetValue('LegalCopyright');
    FLegalTradeMarks := GetValue('LegalTrademarks');
    FOriginalFilename := GetValue('OriginalFilename');
    FProductName := GetValue('ProductName');
    FProductVersion := GetValue('ProductVersion');
    FComments := GetValue('Comments');
    MessageBox(0, PChar(FFileVersion), '', MB_ICONINFORMATION);
  end;
  FreeMem(VerInfo);
end;

{******************************************************************************}
{  GET THE PLATFORM AND EXACT, NAME, VERSION AND BUID OF THE CURRENT OS        }
{******************************************************************************}

function GetOS(var osName: string): DWord;
var
  OS: TOSVersionInfo;
  dwMM: array[0..1] of DWord;
  szMM: array[0..511] of Char;
  Build, Ver, SP: string;
begin
  ZeroMemory(@OS, SizeOf(OS));
  OS.dwOSVersionInfoSize := SizeOf(TOSVersionInfo);
  GetVersionEx(OS);
  Result := OS.dwPlatformId;
  dwMM[0] := OS.dwMajorVersion;
  dwMM[1] := OS.dwMinorVersion;
  wvsprintf(szMM, '%d.%d', PChar(@dwMM));
  if OS.dwPlatformId = VER_PLATFORM_WIN32_NT then
    Build := IntToHex(OS.dwBuildNumber, 4)
  else
    Build := IntToHex(Word(OS.dwBuildNumber), 4);
  Ver := ' (' + szMM + '.' + Build + ')';
  if OS.szCSDVersion <> '' then
    SP := ' ' + OS.szCSDVersion;
  // Default for Unknown or Newest Windows Versions
  osName := 'Windows' + SP + Ver;
  // Try to Determine Known OS Names and Versions
  case OS.dwPlatformId of
    VER_PLATFORM_WIN32s: osName := 'Windows 3.1' + Ver;
    VER_PLATFORM_WIN32_WINDOWS:
      case OS.dwMinorVersion of
        0:
          if OS.szCSDVersion = ' C' then
            osName := 'Windows 95 OSR2' + Ver
          else
            osName := 'Windows 95' + Ver;
        10:
          if OS.szCSDVersion = ' A' then
            osName := 'Windows 98 SE' + Ver
          else
            osName := 'Windows 98' + Ver;
        90: osName := 'Windows Me' + Ver;
      end;
    VER_PLATFORM_WIN32_NT:
      case OS.dwMajorVersion of
        3 or 4: osName := 'Windows NT ' + IntToHex(OS.dwMajorVersion, 8) + SP +
          Ver;
        5: case OS.dwMinorVersion of
            0: osName := 'Windows 2000' + SP + Ver;
            1: osName := 'Windows XP' + SP + Ver;
            2: osName := 'Windows Server 2003' + SP + Ver;
          end;
      end;
  end;
end;

{******************************************************************************}
{  EXECUTES A SCSI COMMAND                                                     }
{******************************************************************************}

function TskSCSI.ExecCmd(HaId, Target, Lun: Byte; CDB: TCDB; CDBLen: Cardinal;
  Flags: Cardinal; Buffer: Pointer; BufferLen: Cardinal): Byte;
var
  SRB_ExecSCSICmd: TSRB_ExecSCSICmd;
  SRBPointer: PSRB_ExecSCSICmd;
  FEvent: THandle;
  EventNotify: Boolean;
begin
  FillChar(SRB_ExecSCSICmd, SizeOf(SRB_ExecSCSICmd), 0);
  EventNotify := Flags and $40 = $40;
  FEvent := CreateEvent(nil, True, False, nil);
  if EventNotify then
  begin
    ResetEvent(FEvent);
    SRB_ExecSCSICmd.PostProc := FEvent
  end
  else
    SRB_ExecSCSICmd.PostProc := 0;

  SRB_ExecSCSICmd.Cmd := SC_EXEC_SCSI_CMD;
  SRB_ExecSCSICmd.Flags := Flags;
  SRB_ExecSCSICmd.HaId := HaId;
  SRB_ExecSCSICmd.Target := Target;
  SRB_ExecSCSICmd.Lun := Lun;
  SRB_ExecSCSICmd.BufLen := BufferLen;
  SRB_ExecSCSICmd.BufPointer := Buffer;
  SRB_ExecSCSICmd.SenseLen := SENSE_LEN;
  SRB_ExecSCSICmd.CDBLen := CDBLen;
  SRB_ExecSCSICmd.CDBByte := CDB;
  { for i := 0 to CDBLen - 1 do
      CDBByte[i] := CDB[i];}
  SRB_ExecSCSICmd.CDBByte[1] := ((Lun and 7) shl 5) or
    (SRB_ExecSCSICmd.CDBByte[1] and $1F);

  SRBPointer := @SRB_ExecSCSICmd;
  if SRB_ExecSCSICmd.CDBByte[0] <> $FF then
    SendASPI32Command(SRBPointer)
  else
    SRB_ExecSCSICmd.Status := SS_COMP;
  if EventNotify then
  begin
    if SRB_ExecSCSICmd.Status = SS_PENDING then
      WaitForSingleObject(FEvent, INFINITE);
  end;
  if SRB_ExecSCSICmd.Status = SS_PENDING then
  begin
    if EventNotify then
    begin
      CloseHandle(FEvent);
      ResetEvent(FEvent);
    end;
    AbortCmd(SRB_ExecSCSICmd);
    SRB_ExecSCSICmd.Status := SS_ERR;
    SRB_ExecSCSICmd.HaStat := HASTAT_TIMEOUT;
  end
  else
  begin
    CloseHandle(FEvent);
  end;
  Result := SRB_ExecSCSICmd.Status;
end;

{******************************************************************************}
{  ABORTS AN EXECUTED SCSI COMMAND                                             }
{******************************************************************************}

function TskSCSI.AbortCmd(FSRB_ExecSCSICmd: TSRB_ExecSCSICmd): Boolean;
var
  SRB_Abort: TSRB_Abort;
begin
  FillChar(SRB_Abort, SizeOf(TSRB_Abort), 0);
  with SRB_Abort do
  begin
    Cmd := SC_ABORT_SRB;
    HaId := FSRB_ExecSCSICmd.HaId;
    ToAbort := @FSRB_ExecSCSICmd;
  end;
  Result := SRB_Abort.Status = 1;
end;

{******************************************************************************}
{  INTERFACE INFORMATION ROUTINES                                              }
{******************************************************************************}

function TskSCSI.InterfaceNameShort: string;
begin
  case FifType of
    ifASPI: Result := 'ASPI';
    ifASAPI: Result := 'ASAPI';
    ifSPTI: Result := 'SPTI';
  end;
end;

function TskSCSI.InterfaceNameLong: string;
begin
  case FifType of
    ifASPI: Result := 'Advanced SCSI Programming Interface';
    ifASAPI: Result := 'Advanced ASPI Programming Interface';
    ifSPTI: Result := 'SCSI Passthrough Interface';
  end;
end;

function TskSCSI.InterfaceDeveloper: string;
begin
  case FifType of
    ifASPI: Result := 'Adaptec';
    ifASAPI: Result := 'VOB/Pinnacle';
    ifSPTI: Result := 'Microsoft';
  end;
end;

{******************************************************************************}
{  CONSTRUCTOR (LOAD ASPI OR ASAPI DLL OR USE SPTI UNDER NT/2K/XP)             }
{******************************************************************************}

constructor TskSCSI.Create;
var
  dwPlatformID: DWord;
  osName: string;
begin
  inherited Create;
  SCSIHandle := 0;
  FviASPI := nil;
  dwPlatformID := GetOS(osName);
  FosName := osName;
  (* if NT/2k/XP/2003 then use SPTI *)
  if dwPlatformID = VER_PLATFORM_WIN32_NT then
  begin
    InitSPTI;
    SCSIHandle := 1;
    FifType := ifSPTI;
    @GetASPI32SupportInfo := @SPTI_GetASPI32SupportInfo;
    @SendASPI32Command := @SPTI_SendASPI32Command;
  end;
  (* if 9x/Me then use ASPI or ASAPI if any *)
  if dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
  begin
    (* 1st try to initalize ASPI ... *)
    SCSIHandle := LoadLibrary(ASPI);
    if SCSIHandle <> 0 then
    begin
      @GetASPI32SupportInfo := GetProcAddress(SCSIHandle,
        'GetASPI32SupportInfo');
      @SendASPI32Command := GetProcAddress(SCSIHandle, 'SendASPI32Command');
      FviASPI := TVersionInfo.GetVersionInfo(ASPI);
      FifType := ifASPI;
    end
    else
    begin
      (* ... 2nd try to initalize ASAPI *)
      SCSIHandle := LoadLibrary(ASAPI);
      if SCSIHandle <> 0 then
      begin
        @GetASPI32SupportInfo := GetProcAddress(SCSIHandle,
          'GetASAPI32SupportInfo');
        @SendASPI32Command := GetProcAddress(SCSIHandle, 'SendASAPI32Command');
        FviASPI := TVersionInfo.GetVersionInfo(ASAPI);
        FifType := ifASAPI;
      end;
    end;
  end;
  if SCSIHandle <> 0 then
    FInitOK := True;
end;

{******************************************************************************}
{  DESTRUCTOR                                                                  }
{******************************************************************************}

destructor TskSCSI.Destroy;
begin
  if FifType = ifSPTI then
    DeInitSPTI;
  inherited Destroy;
end;

end.
