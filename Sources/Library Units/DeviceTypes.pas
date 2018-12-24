{-----------------------------------------------------------------------------
 Unit Name: DeviceTypes
 Author:    Paul Fisher / Andrew Semack
 Purpose:   Selection of types
 History:
-----------------------------------------------------------------------------}

unit DeviceTypes;

interface

uses
  Windows, SCSITypes;

const

  //TDataBlockType
  btRAW_DATA_BLOCK = $00;
  btRAW_DATA_P_Q_SUB = $01;
  btRAW_DATA_P_W_SUB = $02;
  btRAW_DATA_P_W_SUB2 = $03;
  btMODE_1 = $08;
  btMODE_2 = $09;
  btMODE_2_XA_FORM_1 = $0A;
  btMODE_2_XA_FORM_1_SUB = $0B;
  btMODE_2_XA_FORM_2 = $0C;
  btMODE_2_XA_FORM_2_SUB = $0D;

  //TSessionType
  stCDROM_CDDA = $00;
  stCDI_DISK = $01;
  stCDROM_XA = $20;

  //TEraseType
  etBLANK_DISC = $00;
  etBLANK_MINIMAL = $01;
  etBLANK_TRACK = $02;
  etUN_RESERVE_TRACK = $03;
  etBLANK_TRACK_TAIL = $04;
  etUNCLOSE_LAST_SESSION = $05;
  etERASE_SESSION = $06;
  etSESSION_FORMAT = $10;
  etGROW_SESSION = $11;
  etADD_SESSION = $12;
  etQUICK_GROW_LAST_SESSION = $13;
  etQUICK_ADD_SESSION = $14;
  etQUICK_SESSION_FORMAT = $15;
  etMRW_FULL_FORMAT = $24;
  etDVD_PLUS_RW_BASIC_FORMAT = $26;

  //TWriteType
  wtPACKET_WRITE = $00;
  wtTRACK_AT_ONCE = $01;
  wtSESSION_AT_ONCE = $02;
  wtRAW_DATA = $03;

  //TTrackMode
  tmCDR_MODE_AUDIO = $01;
  tmCDR_MODE_INCR_DATA = $01;
  tmCDR_MODE_ALLOW_COPY = $02;
  tmCDR_MODE_DATA = $04;
  tmCDR_MODE_QUAD_AUDIO = $08;
  tmCDR_MODE_DAO_96 = $3F;

  //TCDSpeeds
  SCDS_MAXSPEED = $FFFF;
  SCDS_NONE = $00;

type
  TCopyStatusEvent = procedure(CurrentSector, PercentDone: Integer) of object;
  TCDStatusEvent = procedure(CurrentStatus: string) of object;
  TCDBufferProgressEvent = procedure(Percent: Integer) of object;
  TCDFileBufferProgressEvent = procedure(Percent: Integer) of object;
  TCDBufferStatusEvent = procedure(BufferSize, FreeSize: Integer) of object;
  TCDWriteStatusEvent = procedure(BytesWritten: Integer) of object;



type
  TDiscType = (
    dtMT_UNKNOWN = $00,
    dtMT_CDROMDATA120 = $01,
    dtMT_CDAUDIO120 = $02,
    dtMT_CDROMMIXED120 = $03,
    dtMT_CDROMHYBRID120 = $04,
    dtMT_CDROMDATA80 = $05,
    dtMT_CDAUDIO80 = $06,
    dtMT_CDROMMIXED80 = $07,
    dtMT_CDROMHYBRID80 = $08,
    dtMT_CDRUNKNOWN = $10,
    dtMT_CDRDATA120 = $11,
    dtMT_CDRAUDIO120 = $12,
    dtMT_CDRMIXED120 = $13,
    dtMT_CDRHYBRID120 = $14,
    dtMT_CDRDATA80 = $15,
    dtMT_CDRAUDIO80 = $16,
    dtMT_CDRMIXED80 = $17,
    dtMT_CDRHYBRID80 = $18,
    dtMT_CDRWUNKNOWN = $20,
    dtMT_CDRWDATA120 = $21,
    dtMT_CDRWAUDIO120 = $22,
    dtMT_CDRWMIXED120 = $23,
    dtMT_CDRWHYBRID120 = $24,
    dtMT_CDRWDATA80 = $25,
    dtMT_CDRWAUDIO80 = $26,
    dtMT_CDRWMIXED80 = $27,
    dtMT_CDRWHYBRID80 = $28,
    dtMT_NODISC = $70,
    dtMT_DOOROPEN = $71
    );


type
  PCDBurnerInfo = ^TCDBurnerInfo;


// built to be able to add special types to the write settings
Type
 TSpecialDeviceType = Record
    PDVR103       : Boolean;
    SonyCRX100E   : Boolean;
    TEAC512EB     : Boolean;
    FlmmedCT      : Boolean;
    SonyPowerBurn : Boolean;
 end;


type
  TBurnSettings = record
    DataBlockType  : Integer;
    WriteType      : Integer;
    TrackMode      : Integer;
    SessionType    : Integer;
    EraseType      : Integer;
    AudioPause     : Integer;
    PacketSize     : Integer;
    TestWrite      : Boolean;
    BurnProof      : Boolean;
    CloseSession   : Boolean;
    CloseDisk      : Boolean;
    DiskAtOnce     : Boolean;
    SessionAtOnce  : Boolean;
    SpecialDeviceType : TSpecialDeviceType;
    SetError       : string;
  end;



implementation

end.
