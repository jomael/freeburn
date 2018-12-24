{-----------------------------------------------------------------------------
 Unit Name: SCSITypes
 Author:    Sergey Kabikov
 Purpose:   SCSI Types
 History:  Some Types by Sergey Kabikov based on his code ASPI/SCSI Library
    Added to by Dancemammal
-----------------------------------------------------------------------------}

unit SCSITypes;

interface

uses Windows, Wnaspi32;

const
  ScsiModePageParamsLength = 255;
  ScsiModeTemplateParamsLength = ScsiModePageParamsLength + 128;

  CDSTATUS_READ_CD_R = 1; // Device is capable to read CD-R media
  // as defined in Orange Book Part II
  CDSTATUS_READ_CD_RW = 2; // Device is capable to read CD-RW media
  // as defined in Orange Book Part III
  CDSTATUS_READ_METHOD2 = 4; // Device is capable to read CD-R written
  // using fixed packet tracks (Addressing Method 2)
  CDSTATUS_READ_DVD_ROM = 8; // Device is capable to read DVD media
  CDSTATUS_READ_DVD_R = $10; // Device is capable to read DVD-R media
  CDSTATUS_READ_DVD_RAM = $20; // Device is capable to read DVD-RAM media

  // ====== Bit constants for TScsiModePageCdStatus.Flags[1] ======
  CDSTATUS_WRITE_CD_R = 1; // Device is capable to write CD-R media
  CDSTATUS_WRITE_CD_RW = 2; // Device is capable to write CD-RW media
  CDSTATUS_TEST_MODE = 4; // If this flag is set, device shall only
  // accept data and not write to the media
  CDSTATUS_WRITE_DVD_R = $10; // Device is capable to write DVD-R media
  CDSTATUS_WRITE_DVD_RAM = $20; // Device is capable to write DVD-RAM media

  // ====== Bit constants for TScsiModePageCdStatus.Flags[2] ======
  CDSTATUS_AUDIO_PLAY = 1; // Device is capable to AUDIO PLAY
  CDSTATUS_AUDIO_COMPOSITE = 2; // Device is capable of delivering a
  // composite audio and video data stream
  CDSTATUS_AUDIO_DIGIPORT1 = 4; // Device supports digital output
  CDSTATUS_AUDIO_DIGIPORT2 = 8; //   (IEC958) on port 1/2
  CDSTATUS_READ_MODE2_FORM1 = $10; // Device is capable to read Mode 2
  // Form 1 fomat (eXtended Audio, CD-XA format)
  CDSTATUS_READ_MODE2_FORM2 = $20; // Device is capable to read Mode 2
  // Form 2 format
  CDSTATUS_READ_MULTISESSION = $40; // Device is capable to read PhotoCD
  // format with multiple sessions on disc
  CDSTATUS_BURN_PROOF = $80; // DEVICE HAS BURN PROOF INSTALLED ??

  // ====== Bit constants for TScsiModePageCdStatus.Flags[3] ======
  CDSTATUS_CDDA_CAPABLE = 1; // Device supports an audio CD
  // (Red Book) reading using READ CD command
  CDSTATUS_CDDA_STREAM_ACCURATE = 2; // Device returns to an audio
  // location without losing place to continue reading
  CDSTATUS_CDDA_RW_SUPPORT = 4; // Device supports an audio CD
  // subchannel combined R-W information reading
  CDSTATUS_CDDA_RW_CORRECTED = 8; // The R-W subchannel data will
  // be returned de-interleaved and error-corrected
  CDSTATUS_CDDA_C2_POINTERS = $10; // Device is capable to return
  // C2 Error Pointers and C2 Block Error Flags
  CDSTATUS_CDDA_ISRC = $20; // Device can return the
  // International Standard Recording Code information
  CDSTATUS_CDDA_UPC = $40; // Device can return the
  // Media Catalog Number (UPC) for an audio CD
  CDSTATUS_CDDA_BARCODE = $80; // Device can read disc bar code

  // ====== Bit constants for TScsiModePageCdStatus.Flags[4] ======
  CDSTATUS_LOCK_CAPABLE = 1; // Device is capable to execute the
  // PREVENT/ALLOW MEDIA REMOVAL command and performs
  // an actually locking the media into drive
  CDSTATUS_LOCK_STATE = 2; // Current state of device (1=locked)
  CDSTATUS_PREVENT_JUMPER = 4; // Current state of the (optional)
  // Prevent/Allow media removal jumper.
  CDSTATUS_EJECT_CAPABLE = 8; // Device is capable to eject media
  // via the START/STOP command with LoEj bit set.
// ====== Bit constants for TScsiModePageCdStatus.Flags[5] ======
  CDSTATUS_SEPARATE_VOLUME = 1; // Device supports the separate audio
  // level control for each channel
  CDSTATUS_SEPARATE_MUTE = 2; // Device supports the independent
  // mute capability for each channel
  CDSTATUS_REPORTS_HAVE_DISK = 4; // The response to the MECHANISM STATUS
  // command will contain valid DiscPresent field.
  CDSTATUS_SLOT_SELECTION = 8; // Controls the behavior of LOAD/UNLOAD
  // command when trying to load a Slot with no disc
  CDSTATUS_SIDE_CHANGE = $10; // Device is capable to select both
  // sides of disc (for disc changers only)
  CDSTATUS_CDDA_RW_LEAD_IN = $20; // Device supports an audio CD R-W
  // subchannel information reading from the Lead-in
// ====== Bit constants for TScsiModePageCdStatus.DigiPortFormat ======
  CDSTATUS_DIGIPORT_BCKF = 2; // Port data valid on rising(0) or
  // falling(1) edge of BCK signal.
  CDSTATUS_DIGIPORT_RCK = 4; // HIGH on LRCK indicates right(0)
  // or left(1) channel.
  CDSTATUS_DIGIPORT_LSBF = 8; // Data are sent MSB(0) or LSB(1) first.
  CDSTATUS_DIGIPORT_BCKLEN0 = $10; //  Two bits indicates length in BCKs :
  CDSTATUS_DIGIPORT_BCKLEN1 = $20; //   00=32, 01=16, 10=24, 11=24(FS)

type
  TBurnerID = DWORD;

type
  TCDBurnerInfo = record
    DriveIndex: Integer;
    DriveLetter: Char;
    DriveID: DWORD;
    ProductID: string;
    VendorID: string;
    VendorName: string;
    VendorSpec: string;
    Revision: string;
    SptiHandle: THandle;
    HaId: Byte;
    Target: Byte;
    Lun: Byte;
  end;

  TCdRomModePageType = (MPTcurrent, MPTchangeable, MPTdefault, MPTsaved);

type
  TScsiError = {======== Errors from SRB_Status field ========}
  (Err_None, Err_Aborted, Err_InvalidRequest,
    Err_HAerror, Err_InvalidHostAdapter, Err_NoDevice,
    Err_InvalidSrb, Err_BufferAlign, Err_AspiIsBusy,
    Err_BufferTooBig, Err_Unknown,
    {======== Errors from SRB_HaStat field ========}
    Err_CommandTimeout,
    Err_SrbTimeout,
    Err_MessageReject,
    Err_BusReset,
    Err_ParityError,
    Err_RequestSenseFailed,
    Err_SelectionTimeout,
    Err_DataOverrun, //... or underrun
    Err_UnexpectedBusFree,
    Err_BusPhaseSequence, //... failure
    {======== Errors from SRB_TargStat field ========}
    Err_CheckCondition,
    Err_TargetBusy,
    Err_TargetReservationConflict,
    Err_TargetQueueFull,
    {======== Errors of SendScsiCommand ========}
    Err_InvalidDevice, // Trying to exec SCSI command for non-exist device
    Err_NoEvent, // Unable to get event handle for notification
    Err_NotifyTimeout, // WaitForSingleObject result was unacceptable
    {======== Errors of SCSIxxxx() procedures =======}
    Err_InvalidArgument,
    {======== Errors from SRB_Sense area ========}
    Err_SenseUnknown, // Unknown SRB_Sense.ErrorCode value
    Err_SenseFileMark,
    Err_SenseEndOfMedia,
    Err_SenseIllegalLength,
    Err_SenseIncorrectLength,
    Err_SenseNoSense, // There is no sense key info to be reported
    Err_SenseRecoveredError, // Last command completed successfully with
    // some recovery action performed by the target.
    Err_SenseNotReady, // Unit addressed cannot be accessed.
    //  Operator intervention may be required.
    Err_SenseMediumError, // Command terminated with a non-recovered
    // error condition that was probably caused by a flaw
    // in the medium or an error in the recorded data.
    Err_SenseHardwareError, // Non-recoverable hardware failure detected
    Err_SenseIllegalRequest, // Illegal parameter detected in the command
    // descriptor block or in the additional parameters.
    Err_SenseUnitAttention, // Removable medium may have been changed or
    // the target has been reset.
    Err_SenseDataProtect, // Read/Write Command was applied to the
    // block that is protected from this operation.
    Err_SenseBlankCheck, // Write-once device or a sequential-access
    // device encountered blank medium or end-of-data
    // indication while reading or a write-once device
    // encountered a non-blank medium while writing.
    Err_SenseVendorSpecific,
    Err_SenseCopyAborted, // COPY, COMPARE, or COPY AND VERIFY command
    // was aborted due to an error condition on the source
    // device, the destination device, or both.
    Err_SenseAbortedCommand, // Target aborted the command. Host may be
    // able to recover by trying the command again.
    Err_SenseEqual, // SEARCH DATA has satisfied an equal comparison.
    Err_SenseVolumeOverflow, // Buffered peripheral device has reached
    // the end-of-partition and data may remain in the
    // buffer that has not been written to the medium.
    // RECOVER BUFFERED DATA command may be issued to read
    // the unwritten data from the buffer.
    Err_SenseMiscompare, // Source data did not match the data read
    // from the medium.
    Err_SenseReserved
    );

  PScsiDefaults = ^TScsiDefaults;

  TASPIcommandSendingEvent = procedure(
    DeviceID: TCDBurnerInfo;
    Pcdb: pointer;
    CdbLen: DWORD;
    Pbuf: pointer;
    BufLen: DWORD;
    Direction: DWORD;
    pSDF: PScsiDefaults;
    AspiResult: TScsiError) of object;

  TScsiDefaults = record
    Timeout: DWORD; // Timeout for all "fast" commands in milliseconds
    ReadTimeout: DWORD; // Same for CD media reading commands
    AudioTimeout: DWORD; // Same for audio CD commands
    SpindleTimeout: DWORD; // Same for SCSIstartStopUnit()
    fOnCommandSending, // ASPIsendScsiCommand() logging events
    fOnCommandSent: TASPIcommandSendingEvent;
    ModePageType: TCdRomModePageType; // For MODE SENSE/MODE SELECT cmds
    Sense: TscsiSenseInfo; // Command resulting Sense info
  end;

type
  TLogicalUnitWriteSpeedTable = packed record
    Reserved: Byte;
    RotationControl: Byte;
    WriteSpeedSupported: Word;
  end;

  TModeParametersHeader = packed record
    ModeDataLength: Word;
    Reserved1: Byte;
    Reserved2: Byte;
    Reserved3: Byte;
    Reserved4: Byte;
    BlockDescriptorLength: Word;
  end;

type
  TScsiModePageCdStatus = packed record
    // ModeParametersHeader : TModeParametersHeader;  //8
    PSPageCode: byte; {PS bit 7} {PageCode bits 0-6}
    PageLength: byte; {=$32}
    // Resv                 : array[0..6] of BYTE;
    Flags: array[0..5] of BYTE; // BitSet - see above
    MaxReadSpeed: WORD; // Obsolete
    MaxVolumeLevels: WORD; // Number of discrete levels for audio volume.
    // If the device only supports turning audio on
    // and off, this field shall be set to 2.
    MaxBufferSize: WORD; // Size of buffer dedicated to the data stream
    // in kilobytes. Zero means device have no cache.
    CurrentReadSpeed: WORD; // Obsolete
    Reserved3: BYTE;
    DigiPortFormat: BYTE; // BitSet - see above. Dexcribes the format
    // of digital output (IEC958). Valid only if one
    // of CDSTATUS_AUDIO_DIGIPORTn flags is set.
    MaxWriteSpeed: WORD; // Obsolete
    CurWriteSpeed_Res: WORD; // Obsolete
    CopyMgRevision: WORD; // Copy Management Revision Version supported
    // by device (DVD devices only, zero for all others)
    Reserved6: BYTE;
    Reserved7: BYTE;
    RotationControlSpeed: Byte;
    CurrentWriteSpeed: Word;
    NoWriteSpeedDescTables: Word;
    WriteSpeeds: array[0..99] of TLogicalUnitWriteSpeedTable;
  end;

type
  PScsiModePageRecord = ^TScsiModePageRecord;
  TScsiModePageRecord = packed record
    PageCode: BYTE; // six LSBs of page code plus
    //  MSbit is PSAV flag (MODE SENSE only)
    ParamLength: BYTE;
    Params: array[0..ScsiModePageParamsLength - 1] of BYTE;
  end;

type
  TScsiModePageTemplate10 = packed record
    ModeDataLength10: WORD; // full record length except itself
    MediumType10: BYTE; // Reserved - OBSOLETE
    DeviceSpecific10: BYTE; // Reserved - OBSOLETE
    Reserved10: WORD;
    DescriptorLength10: WORD; // equal to 8*Number of Block Descriptors
    // must be zero when DBD = TRUE
    Params10: array[0..ScsiModeTemplateParamsLength - 1] of BYTE;
  end;

type
  TScsiModePageTemplate2 = packed record
    ModeDataLength10: WORD; // full record length except itself
    MediumType10: BYTE; // Reserved - OBSOLETE
    DeviceSpecific10: BYTE; // Reserved - OBSOLETE
    Reserved10: WORD;
    DescriptorLength10: WORD; // equal to 8*Number of Block Descriptors
    // must be zero when DBD = TRUE
    Params10: array[0..51] of BYTE;
  end;

type
  TScsiModePageTemplate6 = packed record
    ModeDataLength6: BYTE; // full record length except itself
    MediumType6: BYTE; // Reserved - OBSOLETE
    DeviceSpecific6: BYTE; // Reserved - OBSOLETE
    DescriptorLength6: BYTE; // equal to 8*Number of Block Descriptors
    // must be zero when DBD=TRUE
    Params6: array[0..ScsiModeTemplateParamsLength - 1] of BYTE;
  end;

type
  TScsiModePageTemplate = packed record
    case boolean of
      True: (
        ModeDataLength6: BYTE; // full record length except itself
        MediumType6: BYTE; // Reserved - OBSOLETE
        DeviceSpecific6: BYTE; // Reserved - OBSOLETE
        DescriptorLength6: BYTE; // equal to 8*Number of Block Descriptors
        // must be zero when DBD=TRUE
        Params6: array[0..ScsiModeTemplateParamsLength - 1] of BYTE);

      False: (
        ModeDataLength10: WORD; // full record length except itself
        MediumType10: BYTE; // Reserved - OBSOLETE
        DeviceSpecific10: BYTE; // Reserved - OBSOLETE
        Reserved10: WORD;
        DescriptorLength10: WORD; // equal to 8*Number of Block Descriptors
        // must be zero when DBD=TRUE
        Params10: array[0..ScsiModeTemplateParamsLength - 1] of BYTE);
  end;

type
  TScsiPeripheralQualifier = (
    SPQconnected, // Peripheral device type is currently connected to this
    // logical unit. Especially for hot-swap devices. All fixed
    // devices shall also use this peripheral qualifier.
    SPQavailable, // The target is capable of supporting the device;
    // however, the physical device is not currently connected.
    SPQreserved2, // Reserved.
    SPQabsent, // The target is not capable of supporting a physical
    // device on this LUN. It's illegal LUN for all commands.
    SPQvendor4, SPQvendor5, SPQvendor6, SPQvendor7); // Vendor-specific codes.

  TScsiAnsiCompliance = (
    SANSInone, // The device does not claims compliance to any standard
    SANSIversion1, // The device complies to ANSI SCSI-1
    SANSIversion2, // The device complies to ANSI SCSI-2
    SANSIversion3, // The device complies to ANSI SCSI-3
    SANSIversion3a, // The device complies to ANSI SCSI-3 SPC-2/MMC-2
    SANSIreserved5, SANSIreserved6, SANSIreserved7);

  TScsiStandardCompliance = packed record
    ANSI: TScsiAnsiCompliance; // ANSI SCSI standard compliance level
    ECMA: BYTE; // 0=no compliance, 1=complies to ECMA-111
    ISO: BYTE; // 0=no compliance, 1=complies to ISO 9316:1995
  end;

  TScsiCommandSupportLevel = (
    SCSLunknown, // data about the command support is not available
    SCSLnosupport, // The requested command code is NOT supported
    SCSLreserved2,
    SCSLstandard, // Device supports the command in a standard manner
    SCSLreserved4,
    SCSLvendor, // Device supports the command in a vendor-specific
    // manner. All fields of TScsiCommandInfo are valid.
    SCSLreserved6, SCSLreserved7);

type
  TScsiDeviceCapabilities = set of (
    SDCremovableMedium, // Medium is removable
    SDCasyncEvent, // Asynchronous event reporting support
    SDCnormalACA, // Setting bit NACA in CDB to 1 support
    SDChierarchical, // Hierarchical addressing model support
    SDCsupportSCC, // Device contains an embedded storage array
    // controller (see SCSI-3 SCC-2 for details)
    SDCcommandQueuing, // tagged command queuing (all types) support
    SDCbasicQueuing, // command queuing basic task set support
    SDCenclosure, // Device contains an embedded enclosure services
    // component (see SCSI-3 SES for details)
    SDCmultiPort, // Device conforms to multi-port requirements
    SDCmediumChanger, // Device contains a meduim transport element
    SDCrelativeAddress, // Linked commands may use relative addressing
    SDClinkedCommands, // Execution of linked commands support
    SDCwideBus16, // 16-bit wide data transfers support (SPI-3 only)
    SDCaddress16, // 16-bit SCSI addressing support (SPI-3 only)
    SDCsynchTransfer, // Synchronous data transfers support (SPI-3 only)
    SDCtransferDisable // CONTINUE TASK and TARGET TRANSFER DISABLE
    ); // messages support (SPI-3 only)

type
  TScsiDeviceInfo = packed record
    PeriphQualifier: TScsiPeripheralQualifier;
    DeviceType: TScsiDeviceType;
    Version: TScsiStandardCompliance;
    Capabilities: TScsiDeviceCapabilities;
    ResponseDataFormat: BYTE; // indicates the INQUIRY data format is:
    // 0 = as specified in SCSI-1,
    // 1 = products that were designed prior to the SCSI-2,
    // 2 = as specified in SCSI-2 or SCSI-3,
    // 3..0Fh = reserved.
    VendorID: string[8];
    ProductID: string[16];
    ProductRev: string[4]; // Hardware/firmware revision code
    VendorSpecific: string[20];
    DriveLetter: Char;
  end;

type
  TCdRomCapability =
    (cdcReadCDR, // Device is capable to read CD-R media,
    // see CDSTATUS_READ_CD_R constant
    cdcReadCDRW, // --""-- CD-RW media, CDSTATUS_READ_CD_RW
    cdcReadMethod2, // --""-- CD-R written using fixed packet
    // tracks, CDSTATUS_READ_METHOD2
    cdcReadDVD, // --""-- DVD media, CDSTATUS_READ_DVD_ROM
    cdcReadDVDR, // --""-- DVD-R media, CDSTATUS_READ_DVD_R
    cdcReadDVDRAM, // --""-- DVD-RAM media, CDSTATUS_READ_DVD_RAM
    // ====== Bit constants for TScsiModePageCdStatus.Flags[1] ======
    cdcWriteCDR, // Device is capable to write CD-R media,
    // see CDSTATUS_WRITE_CD_R constant
    cdcWriteCDRW, // --""-- CD-RW media, CDSTATUS_WRITE_CD_RW
    cdcWriteDVDR, // --""-- DVD-R media, CDSTATUS_WRITE_DVD_R
    cdcWriteDVDRAM, // --""-- DVD-RAM media, CDSTATUS_WRITE_DVD_RAM
    cdcWriteTestMode, // Device is in test mode, CDSTATUS_TEST_MODE
    cdcWriteBurnProof, // Device Has Burn Proof, CDSTATUS_BURN_PROOF
    // ====== Bit constants for TScsiModePageCdStatus.Flags[2] ======
    cdcAudioPlay, // Device is capable to audio media playback,
    // see CDSTATUS_AUDIO_PLAY constant
    cdcAudioComposite, // Device is capable of delivering a composite
    // audio/video stream, CDSTATUS_AUDIO_COMPOSITE
    cdcAudioDigiPort1, // Device supports digital output on port 1,
    // CDSTATUS_AUDIO_DIGIPORT1
    cdcAudioDigiPort2, // --""-- on port 2, CDSTATUS_AUDIO_DIGIPORT2
    cdcReadMode2form1, // Device is capable to read Mode 2 Form 1
    // (CD-XA format), CDSTATUS_READ_MODE2_FORM1
    cdcReadMode2form2, // --""-- Form 2,  CDSTATUS_READ_MODE2_FORM2
    cdcReadMultisession, // Device is capable to read PhotoCD format
    // with multiple sessions on disc, CDSTATUS_READ_MULTISESSION
// ====== Bit constants for TScsiModePageCdStatus.Flags[3] ======
    cdcCDDAread, // Device supports an audio CD reading using
    // READ CD command, CDSTATUS_CDDA_CAPABLE
    cdcCDDAaccurate, // Device returns to an audio location without
    // losing place, CDSTATUS_CDDA_STREAM_ACCURATE
    cdcSubchannelRW, // Device supports an audio CD subchannel R-W
    // data reading, CDSTATUS_CDDA_RW_SUPPORT
    cdcSubchannelCorrect, // The subchannel data will be de-interleaved
    // error-corrected, CDSTATUS_CDDA_RW_CORRECTED
    cdcC2Pointers, // Device is capable to return C2 Error Pointers
    // and C2 Block Error Flags, CDSTATUS_CDDA_C2_POINTERS
    cdcCddaISRC, // Device can return ISRC, CDSTATUS_CDDA_ISRC
    cdcCddaUPC, // --""-- UPC,  CDSTATUS_CDDA_UPC
    cdcCddaBarCode, // --""-- disc bar code, CDSTATUS_CDDA_BARCODE
    // ====== Bit constants for TScsiModePageCdStatus.Flags[4] ======
    cdcLock, // Device is capable to locking the media into
    // drive, CDSTATUS_LOCK_CAPABLE
    cdcLocked, // Media is locked, CDSTATUS_LOCK_STATE
    cdcLockJumper, // Current state of the (optional) lock jumper,
    // CDSTATUS_PREVENT_JUMPER
    cdcEject, // Device is capable to eject media,
    // CDSTATUS_EJECT_CAPABLE
// ====== Bit constants for TScsiModePageCdStatus.Flags[5] ======
    cdcSeparateVolume, // Audio level control is separate for each
    // channel, CDSTATUS_SEPARATE_VOLUME
    cdcSeparateMute, // same for mute, CDSTATUS_SEPARATE_MUTE
    cdcDiskSensor, // MECHANISM STATUS/DiscPresent field is valid,
    // CDSTATUS_REPORTS_HAVE_DISK
    cdcSlotSelect, // Behavior of LOAD/UNLOAD command control,
    // CDSTATUS_SLOT_SELECTION
    cdcSideChange, // disc changers only, CDSTATUS_SIDE_CHANGE
    cdcCddaRwLeadIn); // Device supports an audio CD R-W subchannel
  // from the Lead-in, CDSTATUS_CDDA_RW_LEAD_IN

type
  TCdRomCapabilities = set of TCdRomCapability;

type
  TCDReadWriteSpeeds = packed record
    MaxReadSpeed: byte;
    CurrentReadSpeed: byte;
    MaxWriteSpeed: byte;
    CurrentWriteSpeed: byte;
    BufferSize: Byte;
  end;

type
  TScsiSubQinfoFlags = set of
    // ssqfADRxxx flags are mutually exclusive
  (ssqfADRnone, // Q sub-channel mode information not supplied
    ssqfADRposition, // --"-- encodes track, index, abs. & rel. addresses
    ssqfADRcatalogue, // --"-- encodes Media catalogue number
    ssqfADRISRC, // --"-- encodes ISRC
    ssqfPreEmphasis, // Audio track - recorded w/pre-emphasis of 50/15 uS,
    // Data track  - recorded incremental
    ssqfCopyPermit, // Audio track Digital copy permitted
    ssqfDataTrack, // Track is Data
    ssqfAudioTrack, // Track is Audio
    ssqfQuadAudio); // Track is 4-channel (? - reserved in CD-R/RW)

type
  TScsiTrackDescriptor = packed record
    Flags: TScsiSubQinfoFlags;
    TrackNumber: byte;
    AbsAddress: DWORD;
  end;

  TScsiTOC = packed record
    FirstTrack: integer;
    LastTrack: integer;
    TrackCount: integer; // Total tracks amount
    Tracks: array[0..99] of TScsiTrackDescriptor;
  end;

type
  TScsiSessionInfo = packed record
    Flags: TScsiSubQinfoFlags; // of sector where this TOC entry was found
    FirstSession, // 1st complete session number, should be =1
    LastSession, // last complete session number
    FirstTrack: BYTE; // 1st track in last complete session number
    FirstTrackLBA: DWORD; // ---"--- starting LBA as read from the TOC
  end;

type
  TScsiCDBufferInfo = packed record
    DataLength: Word;
    Reserved1: BYTE;
    Reserved2: BYTE;
    SizeOfBuffer: DWORD;
    BlankLength: DWORD;
  end;

type
  TScsiTrackDescriptorTemplate = packed record
    Reserved1: byte;
    ADR: byte;
    TrackNumber: byte;
    Reserved2: byte;
    AbsAddress: DWORD;
  end;

  TScsiTOCtemplate = packed record
    Length: WORD;
    FirstTrack: byte;
    LastTrack: byte;
    Tracks: array[0..99] of TScsiTrackDescriptorTemplate;
  end;

type
  TCDTextPacket = packed record
    idType: Byte; // packet type
    idTrk: Byte; // track number
    idSeq: Byte; // sequence
    idFlg: Byte; // flags
    txt: array[0..11] of Byte; // Text data (ASCII)
    CRC: array[0..1] of Byte; // CRC (Cyclic Redundancy Check)
  end;

type
  TDiscTrack = record
    StartAddress: DWord;
    StartAddressStr: ShortString;
    Length: DWord;
    LengthStr: ShortString;
    EndAddress: DWord;
    EndAddressStr: ShortString;
    fSizeMB: DWord;
    fType: DWord;
    fTypeStr: ShortString;
  end;

type
  TDiscSession = record
    fSize: DWord;
    fSizeMB: DWord;
    FirstTrack: Byte;
    LastTrack: Byte;
    Tracks: array[1..99] of TDiscTrack;
  end;

type
  TDiscLayout = record
    FirstSession: Byte;
    LastSession: Byte;
    Sessions: array of TDiscSession;
  end;

type
  TCDText = packed record
    dummy: array[0..3] of Byte; // Header
    CDText: array[0..255] of TCDTextPacket; // CD-Text packets
  end;

type
  TScsiReadCdSectorType =
    (csfAnyType, // no checking of data type is performed by device
    csfAudio, // only IEC 908:1987 (CD-DA) sectors
    csfDataMode1, // only Yellow Book (user data of 2048 bytes)
    csfDataMode2, // only Yellow Book (expanded user data of 2336 bytes)
    csfXaForm1, // only CD-XA Mode 2 Form1 (user data of 2048 bytes)
    csfXaForm2); // same, Form2 (user data of 2324 bytes + 4 spare bytes)

type
  TScsiReadCdFormatFlags = set of
    //  Field size in bytes for various modes :
//      Data      XA mode2      CD
//  mode1 mode2  form1 form2  audio
  (cffSync, //   12    12     12    12      --
    cffHeader, //    4     4      4     4      --
    cffSubheader, //   --    --      8     8      --
    cffUserData, //  2048  2336   2048  2324+4  2352
    cffEDCandECC, // 4+8+276 --   4+276   --      --
    cffC2errorBits, //   294   294    294   294     294
    cffBlockErrByte, //   1+1   1+1    1+1   1+1     1+1
    // Subchannel is for all types; this flags are mutually exclusive.
    cffSubchannelRaw, // Raw (not de-interleaved) P-W data
    cffSubchannelQ, // Subchannel Q only
    cffSubchannelPW); // de-interleaved and error-corrected P-W data
  // Helper function. Return value is number of bytes per sector for ReadCD
  //   command, or -1 if combination of arguments is illegal.

type
  TScsiAudioStatus =
    (sasInvalid, // Audio status byte not supported or not valid
    sasPlay, // Audio play operation in progress
    sasPause, // Audio play operation paused
    sasCompleted, // Audio play operation successfully completed
    sasError, // Audio play operation stopped due to error
    sasStop, // No current audio status to return
    sasUnknown); // ASPI returns the 'reserved' code value

type
  TScsiISRC = packed record
    Status: TScsiAudioStatus;
    Flags: TScsiSubQinfoFlags;
    IsrcNumber: string[12]; // ISRC (DIN-31-621) Number, or '' if fails
    FrameNumber: byte; // Number (0..4Ad) of frame where MCN was found
  end;

  // new added dvd functions

type
  TScsiProfileDeviceDiscTypes = record
    TypeNum: Integer;
    DType,
      SubType: string;
  end;

type
  TScsiDVDLayerDescriptor = packed record
    DataLength: Word;
    Reserved1: Byte;
    Reserved2: Byte;
    BookType_PartVersion: Byte; // BookType Nibble
    //    0000    = DVD-ROM = $00
    //    0001    = DVD-RAM = $01
    //    0010    = DVD-R   = $02
    //    0011    = DVD-RW  = $03
    //    1001    = DVD+RW  = $09
    //    1010    = DVD+R   = $0A
    //    Others  = Reserved
    DiscSize_MaximumRate: Byte; // DiscSize Nibble
    //    0000    = 120mm   = $00
    //    0001    = 80mm    = $01
    // MaximumRate Nibble
    //    0000    = 2.52 Mbps     = $00
    //    0001    = 5.04 Mbps     = $01
    //    0010    = 10.08 Mbps    = $02
    //    1111    = Not Specified = $0F
    //    Others  = Reserved
    NumberOfLayers_TrackPath_LayerType: Byte; // LayerType Bit
    //    0 = Layer contains embossed data    = $01
    //    1 = Layer contains recordable area  = $02
    //    2 = Layer contains rewritable area  = $04
    //    3 = Reserved                        = $08
    LinearDensity_TrackDensity: Byte; // LinearDensity Nibble
    //    0000    = 0.267 um/bit          = $00
    //    0001    = 0.293 um/bit          = $01
    //    0010    = 0.409 to 0.435 um/bit = $02
    //    0100    = 0.280 to 0.291 um/bit = $04
    //    1000    = 0.353 um/bit          = $08
    //    Others  = Reserved
    // TrackDensity Nibble
    //    0000    = 0.74 um/track   = $00
    //    0001    = 0.80 um/track   = $01
    //    0010    = 0.615 um/track  = $02
    //    Others  = Reserved
    StartingPhysicalSector: DWORD;
    EndPhysicalSector: DWORD;
    EndPhysicalSectorInLayerZero: DWORD;
    (*
        Reserved3                           : Byte;
        StartingPhysicalSector              : Array [0..2] of Byte;
                                                    //    30000h DVD-ROM, DVD-R/-RW, DVD+RW
                                                    //    31000h DVD-RAM
                                                    //    Others Reserved
        Reserved4                           : Byte;
        EndPhysicalSector                   : Array [0..2] of Byte;
        Reserved5                           : Byte;
        EndPhysicalSectorInLayerZero        : Array [0..2] of Byte;
    *)
    BCA: Byte;
  end;


type
  TScsiDeviceConfigHeader = packed record
    // from ntddmmc.h - MMC 3 Feature structures
    DataLength: Cardinal;
    Reserved: Word;
    CurrentProfile: Word; // further described with TScsiProfileDiscTypes below
    FeatureCode: Word;
    Version: Byte;
    AdditionalLength: Byte;
    OtherData: array[0..101] of Byte;
  end;



  TDiscInformation = packed record
    DiscInformationLength: Word;
    Status: Byte;
    NumberOfFirstTrack: Byte;
    NumberOfSessionsLSB: Byte;
    FirstTrackInLastSessionLSB: Byte;
    LastTrackInLastSessionLSB: Byte;
    DiscInfo: Byte;
    DiscType: Byte;
    NumberOfSessionsMSB: Byte;
    FirstTrackInLastSessionMSB: Byte;
    LastTrackInLastSessionMSB: Byte;
    DiscIdentification: Cardinal;
    LastSessionLeadinStartAddress: Cardinal;
    LastPossibleLeadoutStartAddress: Cardinal;
    DiscBarCode: array[0..7] of Byte;
    DiscApplicationCode: Byte;
    NumberOfOPCTables: Byte;
  end;

  TScsiDVDLayerDescriptorInfo = record
    BookType,
      DiscSize,
      MaximumRate,
      LinearDensity,
      TrackDensity,
      LayerType,
      NoLayer: string;
    Sectors: Integer;
    // total sectors - result of  (EndPhysicalSector minus StartingPhysicalSector)
  end;

  TCapacityListHeader = packed record
    Reserved1: Byte;
    Reserved2: Byte;
    Reserved3: Byte;
    CapacityListLength: Byte;
  end;

  TCurrentMaximumCapacityDescriptor = packed record
    NumberOfBlocks: Cardinal;
    DescriptorType: Byte;
    BlockLength: array[0..2] of Byte;
  end;

  TFormattableCD = packed record
    NumberOfBlocks: Cardinal;
    FormatType: Byte;
    TypeDependentParamter: array[0..2] of Byte;
  end;

  TFormatCapacity = packed record
    CapacityListHeader: TCapacityListHeader;
    CapacityDescriptor: TCurrentMaximumCapacityDescriptor;
    FormattableCD: array[0..32] of TFormattableCD;
    Unused: Byte;
  end;

  TTrackInformation = packed record
    DataLength: Word;
    TrackNumber: Byte;
    SessionNumber: Byte;
    Reserved: Byte;
    TrackMode: Byte;
    DataMode: Byte;
    Reserved2: Byte;
    TrackStartAddress: LongWord;
    NextWritableAddress: LongWord;
    FreeBlocks: LongWord;
    FixedPacketSize: LongWord;
    TrackSize: LongWord;
    LastRecordedAddress: LongWord;
    TrackNumber2: Byte;
    SessionNumber2: Byte;
    Reserved3: Byte;
    Reserved4: Byte;
    Reserved5: Byte;
    Reserved6: Byte;
  end; // this is for DVD minus RW & CD-RW discs - DVD plus RWs write-over previous session/track

type
  TScsiSessionInfoTemplate = packed record
    Length: WORD;
    FirstSession: byte;
    LastSession: byte;
    Reserved1: byte;
    ADR: byte;
    TrackNumber: byte;
    Reserved2: byte;
    AbsAddress: DWORD;
  end;

type
  TScsiISRCTemplate = packed record
    sitReserved,
      sitStatus: BYTE;
    sitLength: WORD;
    sitFormat,
      sitADR,
      sitTrackNumber,
      sitReserved2,
      sitValid: BYTE;
    sitNumber: array[0..11] of Char;
    sitReserved3,
      sitAFrame,
      sitReserved4: BYTE;
  end;

type
  TScsiWriteModePage = packed record
    PSPageCode: byte; {8 PS bit 7} {PageCode bits 0-6}
    PageLength: byte; {9 page length = $32}
    TestFlagWriteType: byte; {10 Write type bits 0-3} {TestFlag bit 4}
    {link size bit 5}{buffer free bit 6}
    MSFPCopyTrackMode: byte; {11 MS (Multisession) bits 6-7} {FP bit 5}
    {Copy bit 4}{Track mode bits 0-3}
    DataBlockType: byte; {12 datablock type bits 0-3}
    LinkSize: Byte; {13 link size = 7}
    Reserved1: Byte; {14}
    HostApplicationCode: byte; {15 bits 0-5}
    SessionFormat: byte; {16}
    Reserved2: byte; {17}
    PacketSize: LongWord; {18 19 20 21}
    AudioPauseLength: Word;
    MediaCatalogNumber: array[1..16] of byte;
    InternationalStandardRecordingCode: array[1..14] of Char;
    SubHeader: array[1..4] of byte;
    Vendor_uniq: array[1..4] of byte;
  end;

var
  SCSI_DEF: TScsiDefaults =
  (Timeout: 1000;
    ReadTimeout: 10000;
    AudioTimeout: 10000;
    SpindleTimeout: 10000;
    fOnCommandSending: nil;
    fOnCommandSent: nil;
    ModePageType: MPTcurrent;
    Sense: (0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
    0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0));

implementation

end.
