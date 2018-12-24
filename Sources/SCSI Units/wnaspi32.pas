{-----------------------------------------------------------------------------
 Unit Name: wnaspi32
 Author:    Unknown
 Purpose:
 History:
-----------------------------------------------------------------------------}

unit wnaspi32;

interface

uses Windows;

type
  LPSRB = Pointer;

const

  SENSE_LEN = 14; // Default sense buffer length
  SRB_DIR_SCSI = $00; // Direction determined by SCSI command
  SRB_DIR_IN = $08; // Transfer from SCSI target to host
  SRB_DIR_OUT = $10; // Transfer from host to SCSI target
  SRB_NODIR = $00; // No data I/O is performed
  SRB_POSTING = $01; // Enable ASPI posting
  SRB_EVENT_NOTIFY = $40; // Enable ASPI event notification
  SRB_ENABLE_RESIDUAL_COUNT = $04; // Enable residual byte count reporting
  SRB_DATA_SG_LIST = $02; // Data buffer points to scatter-gather list

  WM_ASPIPOST = $4D42; // ASPI Post message

  //***************************************************************************
  //						 %%% ASPI Command Definitions %%%
  //***************************************************************************

  SC_HA_INQUIRY = $00; // Host adapter inquiry
  SC_GET_DEV_TYPE = $01; // Get device type
  SC_EXEC_SCSI_CMD = $02; // Execute SCSI command
  SC_ABORT_SRB = $03; // Abort an SRB
  SC_RESET_DEV = $04; // SCSI bus device reset
  SC_GET_DISK_INFO = $06; // Get Disk information

  //***************************************************************************
  //								  %%% SRB Status %%%
  //***************************************************************************

  SS_PENDING = $00; // SRB being processed
  SS_COMP = $01; // SRB completed without error
  SS_ABORTED = $02; // SRB aborted
  SS_ABORT_FAIL = $03; // Unable to abort SRB
  SS_ERR = $04; // SRB completed with error

  SS_INVALID_CMD = $80; // Invalid ASPI command
  SS_INVALID_HA = $81; // Invalid host adapter number
  SS_NO_DEVICE = $82; // SCSI device not installed

  SS_INVALID_SRB = $E0; // Invalid parameter set in SRB
  SS_BUFFER_ALIGN = $E1; // Buffer not aligned (replaces OLD_MANAGER in Win32)
  SS_ILLEGAL_MODE = $E2; // Unsupported Windows mode
  SS_NO_ASPI = $E3; // No ASPI managers resident

  SS_FAILED_INIT = $E4; // ASPI for windows failed init
  SS_ASPI_IS_BUSY = $E5; // No resources available to execute cmd
  SS_BUFFER_TO_BIG = $E6; // Buffer size to big to handle!

  SS_MISMATCHED_COMPONENTS = $E7; // The DLLs/EXEs of ASPI don't version check
  SS_NO_ADAPTERS = $E8; // No host adapters to manage
  SS_INSUFFICIENT_RESOURCES = $E9; // Couldn't allocate resources needed to init
  SS_ASPI_IS_SHUTDOWN = $EA; // Call came to ASPI after PROCESS_DETACH
  SS_BAD_INSTALL = $EB; // The DLL or other components are installed wrong

  //***************************************************************************
  //							%%% Host Adapter Status %%%
  //***************************************************************************

  HASTAT_OK = $00; // Host adapter did not detect an 															// error
  HASTAT_SEL_TO = $11; // Selection Timeout
  HASTAT_DO_DU = $12; // Data overrun data underrun
  HASTAT_BUS_FREE = $13; // Unexpected bus free
  HASTAT_PHASE_ERR = $14; // Target bus phase sequence 																// failure
  HASTAT_TIMEOUT = $09;
  // Timed out while SRB was 																	waiting to beprocessed.
  HASTAT_COMMAND_TIMEOUT = $0B; // While processing the SRB, the
  HASTAT_BUFFER_ALIGN = $E1;
  // Buffer not aligned (replaces OLD_MANAGER in Win32)
// adapter timed out.
  HASTAT_MESSAGE_REJECT = $0D;
  // While processing SRB, the 																// adapter received a MESSAGE 															// REJECT.
  HASTAT_BUS_RESET = $0E; // A bus reset was detected.
  HASTAT_PARITY_ERROR = $0F; // A parity error was detected.
  HASTAT_REQUEST_SENSE_FAILED = $10; // The adapter failed in issuing
  //   REQUEST SENSE.

type
  PscsiSenseInfo = ^TscsiSenseInfo;
  TscsiSenseInfo = array[0..127] of BYTE;
  TAspiDeviceIDflag = (ADIDmodeSense6, ADIDmodeSenseDBD);

type
  TScsiDeviceType = (TSDDisk, TSDTape, TSDPrinter, TSDProcessor,
    TSDWORM, TSDCDROM, TSDScanner, TSDOptical,
    TSDChanger, TSDCommunication,
    TSDInvalid, TSDAny, TSDOther);

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

  //***************************************************************************
  //			 %%% SRB - Get Type of Device - SRB_GetDeviceType %%%
  //***************************************************************************
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

  //***************************************************************************
  //			 %%% SRB - Interupt 13 Info - SRB_Int13info %%%
  //***************************************************************************
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

  //***************************************************************************
  //			 %%% SRB - INQUIRY - SC_INQUIRY %%%
  //***************************************************************************

type
  SRB_Inquiry = packed record
    SRB_Cmd: BYTE; // ASPI command code = 0 = SC_HA_INQUIRY
    SRB_Status: BYTE; // ASPI command status byte
    SRB_HaId: BYTE; // ASPI host adapter number
    SRB_Flags: BYTE; // Reserved
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_HA_Count: BYTE; // same as in GetASPIsupportInfo
    SRB_HA_SCSIID: BYTE; // SCSI Id of selected host adapter
    SRB_ManagerID, // MustBe = 'ASPI for WIN32'
    SRB_AdapterID: array[0..15] of char; // String describing selected HA
    SRB_BufAlign: WORD; // Buffer alignment mask: 0=byte, 1=word,
    // 3=dword, 7=8-byte, etc. 65536 bytes max
    SRB_Residual: BYTE; // Bit1 = residual count support flag
    SRB_Targets: BYTE; // Max target count for selected HA
    SRB_TransfLen: DWORD; // Max transfer length in bytes
    SRB_Rsvd: array[0..9] of byte;
  end;

  //***************************************************************************
  //			 %%% SRB - HOST ADAPTER INQUIRY - SC_HA_INQUIRY %%%
  //***************************************************************************
type
  SRB_HAInquiry = record
    SRB_Cmd, // ASPI command code = SC_HA_INQUIRY
    SRB_Status, // ASPI command status byte
    SRB_HaId, // ASPI host adapter number
    SRB_Flags: BYTE; // ASPI request flags
    SRB_Hdr_Rsvd: DWORD; // Reserved, MUST = 0
    HA_Count, // Number of host adapters present
    HA_SCSI_ID: byte; // SCSI ID of host adapter
    HA_ManagerId, // String describing the manager
    HA_Identifier, // String describing the host adapter
    HA_Unique: array[0..15] of Char; // Host Adapter Unique parameters
    HA_Rsvd1: WORD;
  end;

  PSRB_HAInquiry = ^SRB_HAInquiry;
  TSRB_HAInquiry = SRB_HAInquiry;

  //***************************************************************************
  //			  %%% SRB - GET DEVICE TYPE - SC_GET_DEV_TYPE %%%
  //***************************************************************************
type
  SRB_GDEVBlock = record
    SRB_Cmd, // ASPI command code = SC_GET_DEV_TYPE
    SRB_Status, // ASPI command status byte
    SRB_HaId, // ASPI host adapter number
    SRB_Flags: BYTE; // Reserved
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_Target, // Target's SCSI ID
    SRB_Lun, // Target's LUN number
    SRB_DeviceType, // Target's peripheral device type
    SRB_Rsvd1: BYTE;
  end;

  TSRB_GDEVBlock = SRB_GDEVBlock;
  PSRB_GDEVBlock = ^SRB_GDEVBlock;

  //***************************************************************************
  //		  %%% SRB - EXECUTE SCSI COMMAND - SC_EXEC_SCSI_CMD %%%
  //***************************************************************************

type
  SRB_ExecSCSICmd = packed record
    SRB_Cmd: BYTE; // ASPI command code= 2 =SC_EXEC_SCSI_CMD
    SRB_Status: BYTE; // ASPI command status byte
    SRB_HaId: BYTE; // ASPI host adapter number
    SRB_Flags: BYTE; // ASPI request flags
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_Target: BYTE; // Target's SCSI ID
    SRB_Lun: BYTE; // Target's LUN number
    SRB_Rsvd1: WORD; // Reserved for Alignment
    SRB_BufLen: DWORD; // Data Allocation Length
    SRB_BufPtr: POINTER; // Data Buffer Pointer
    SRB_SenseLen: BYTE; // Sense Allocation Length
    SRB_CDBLen: BYTE; // CDB Length
    SRB_HaStat: BYTE; // Host Adapter Status
    SRB_TargStat: BYTE; // Target Status
    SRB_PostProc: THandle; // Post routine
    SRB_Rsvd2: POINTER; // Reserved
    SRB_Rsvd3: array[0..15] of BYTE; // Reserved for alignment
    SRB_CDBByte: array[0..15] of BYTE; // SCSI CDB
    SRB_Sense: TscsiSenseInfo; // Request Sense buf
  end;

  //***************************************************************************
  //				  %%% SRB - ABORT AN SRB - SC_ABORT_SRB %%%
  //***************************************************************************
type
  SRB_Abort = packed record
    SRB_Cmd: BYTE; // ASPI command code = 3 = SC_ABORT_SRB
    SRB_Status: BYTE; // ASPI command status byte
    SRB_HaId: BYTE; // ASPI host adapter number
    SRB_Flags: BYTE; // Reserved
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_ToAbort: pointer; // Pointer to SRB to abort
  end;

  TSRB_Abort = SRB_Abort;
  PSRB_Abort = ^SRB_Abort;

  //***************************************************************************
  //				%%% SRB - BUS DEVICE RESET - SC_RESET_DEV %%%
  //***************************************************************************
  SRB_BusDeviceReset = record
    SRB_Cmd, // ASPI command code = SC_EXEC_SCSI_CMD
    SRB_Status, // ASPI command status byte
    SRB_HaId, // ASPI host adapter number
    SRB_Flags: BYTE; // Reserved
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_Target, // Target's SCSI ID
    SRB_Lun: BYTE; // Target's LUN number
    SRB_Rsvd1: array[0..11] of byte; // Reserved for Alignment
    SRB_HaStat, // Host Adapter Status
    SRB_TargStat: BYTE; // Target Status
    SRB_PostProc, // Post routine
    SRB_Rsvd2: Pointer; // Reserved
    SRB_Rsvd3, // Reserved
    CDBByte: array[0..15] of byte; // SCSI CDB
  end;

  TSRB_BusDeviceReset = SRB_BusDeviceReset;
  PSRB_BusDeviceReset = ^SRB_BusDeviceReset;

  //***************************************************************************
  //				%%% SRB - GET DISK INFORMATION - SC_GET_DISK_INFO %%%
  //***************************************************************************
  SRB_GetDiskInfo = record
    SRB_Cmd, // ASPI command code = SC_EXEC_SCSI_CMD
    SRB_Status, // ASPI command status byte
    SRB_HaId, // ASPI host adapter number
    SRB_Flags: BYTE; // Reserved
    SRB_Hdr_Rsvd: DWORD; // Reserved
    SRB_Target, // Target's SCSI ID
    SRB_Lun, // Target's LUN number
    SRB_DriveFlags, // Driver flags
    SRB_Int13HDriveInfo, // Host Adapter Status
    SRB_Heads, // Preferred number of heads translation
    SRB_Sectors: BYTE; // Preferred number of sectors translation
    SRB_Rsvd1: array[0..9] of byte; // Reserved
  end;

  TSRB_GetDiskInfo = SRB_GetDiskInfo;
  PSRB_GetDiskInfo = ^SRB_GetDiskInfo;

  //*****************************************************************************
  //          %%% ASPIBUFF - Structure For Controllng I/O Buffers %%%
  //*****************************************************************************

  ASPI32BUFF = record // Offset
    // HX/DEC
    AB_BufPointer: Byte; // 00/000 Pointer to the ASPI allocated buffer
    AB_BufLen, // 04/004 Length in bytes of the buffer
    AB_ZeroFill, // 08/008 Flag set to 1 if buffer should be zeroed
    AB_Reserved: DWord // 0C/012 Reserved
  end;

  TASPI32BUFF = ASPI32BUFF;
  PASPI32BUFF = ^ASPI32BUFF;

type

  TSendASPI32Command = function(LPSRB: Pointer): DWORD; cdecl;
  TGetASPI32SupportInfo = function: DWORD; cdecl;

var
  WNASPI_Loaded: Boolean = FALSE;

  SendASPI32Command: TSendASPI32Command = nil;
  GetASPI32SupportInfo: TGetASPI32SupportInfo = nil;

implementation

const
  WNASPI = 'WNASPI32.dll';

var
  WNASPI_HInst: THandle = 0;

initialization

  WNASPI_HInst := LoadLibrary(PChar(WNASPI));
  if WNASPI_HInst <> 0 then
  begin
    @SendASPI32Command := GetProcAddress(WNASPI_HInst, 'SendASPI32Command');
    @GetASPI32SupportInfo := GetProcAddress(WNASPI_HInst, 'GetASPI32SupportInfo'
      );
    WNASPI_Loaded := TRUE
  end
  else
    WNASPI_Loaded := FALSE;

finalization

  if WNASPI_Loaded then
  begin
    WNASPI_Loaded := FreeLibrary(WNASPI_HInst);
    WNASPI_HInst := 0;
    @SendASPI32Command := nil;
    @GetASPI32SupportInfo := nil;
  end;

end.
