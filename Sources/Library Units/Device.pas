{-----------------------------------------------------------------------------
 Unit Name: Device
 Author:    Paul Fisher / Andrew Semack
 Purpose:   Class for CD / DVD device
 History:
          03-11-05 Changed burn properties to a record of settings
-----------------------------------------------------------------------------}

unit Device;

interface

uses
  Windows, Classes, messages, Dialogs, DeviceTypes, DeviceReader, DeviceInfo,
    DiscInfo, CustomImage, SCSIUnit, DiskNotifier, SCSITypes;

type
  TDevice = class
  private
    FInfoRecord: PCDBurnerInfo;
    FDeviceInfo: TDeviceInfo;
    FDiscInfo: TDiscInfo;
    FDeviceReader: TDeviceReader;
    FBurnSettings: TBurnSettings;
    FLastError: TScsiError;
    FDefaults: TScsiDefaults;
    // notify events
    FOnCopyStatus: TCopyStatusEvent;
    FOnCDStatus: TCDStatusEvent;
    FOnBufferProgress: TCDBufferProgressEvent;
    FOnFileBufferProgress: TCDFileBufferProgressEvent;
    FOnBufferStatus: TCDBufferStatusEvent;
    FOnWriteStatusEvent: TCDWriteStatusEvent;
    FOnDriveDiskInsert : TNotifyEvent;
    FOnDriveDiskRemove : TNotifyEvent;
    FDiskNotifier : TDiskNotifier;

    procedure DiskInserted(DriveLetter : String); // for notify
    procedure DiskRemoved(DriveLetter : String); // for notify
    function GetBurnerInfo: TCDBurnerInfo;
    function GetIsLocked: boolean;
    function GetReady: boolean;
    function GetCapability: TCdRomCapabilities;
    function GetWriteParameters: string;
    function GetBufferSize: WORD;

    procedure AutoInitialize;
    procedure AutoDestroy;
    procedure SetDefaultBurnSettings;
    Procedure GetSpecialDeviceSettings;
  protected
    property BurnerInfo: TCDBurnerInfo read GetBurnerInfo;
  public
    constructor Create(InfoRecord: PCDBurnerInfo);
    destructor Destroy; override;

    procedure Lock;
    procedure UnLock;
    procedure Load(const NoWait: boolean = True);
    procedure Eject(const NoWait: boolean = True);
    procedure GetSpeed(out MaxReadSpeed, MaxWriteSpeed, CurrentReadSpeed,
      CurrentWriteSpeed: integer);
    function SetSpeed(const ReadSpeed, WriteSpeed: integer): Boolean;
    procedure BurnFromFile(const FileName: string);
    procedure BurnFromImage(Image: TCustomImage);
    procedure Erase(const FullErase: boolean = False);
    function CloseSession: Boolean;
    procedure QuickSetAudioBurnSettings;
    procedure QuickSetISOBurnSettings;
    procedure QuickSetDAOBurnSettings;
    procedure QuickSetSAOBurnSettings;

    property BurnSettings: TBurnSettings read FBurnSettings write FBurnSettings;
    property IsLocked: boolean read GetIsLocked;
    property IsReady: boolean read GetReady;
    property Capability: TCdRomCapabilities read GetCapability;
    property DeviceBurnSettings: string read GetWriteParameters; //??
    property DeviceInfo: TDeviceInfo read FDeviceInfo;
    property DiscInfo: TDiscInfo read FDiscInfo;
    property DeviceReader: TDeviceReader read FDeviceReader;
    property LastError: TScsiError read FLastError;
    property CDBufferSize: WORD read GetBufferSize;
    // notify properties
    property OnCopyStatus: TCopyStatusEvent read FOnCopyStatus write
      FOnCopyStatus;
    property OnCDStatus: TCDStatusEvent read FOnCDStatus write FOnCDStatus;
    property OnBufferProgress: TCDBufferProgressEvent read FOnBufferProgress
      write FOnBufferProgress;
    property OnFileBufferProgress: TCDFileBufferProgressEvent read
      FOnFileBufferProgress write FOnFileBufferProgress;
    property OnBufferStatus: TCDBufferStatusEvent read FOnBufferStatus write
      FOnBufferStatus;
    property OnWriteStatusEvent: TCDWriteStatusEvent read FOnWriteStatusEvent
      write FOnWriteStatusEvent;
    property OnDriveDiskInsert : TNotifyEvent Read FOnDriveDiskInsert
      write FOnDriveDiskInsert;
    property OnDriveDiskRemove : TNotifyEvent Read FOnDriveDiskRemove
      write FOnDriveDiskRemove;
  end;



implementation

uses
  BurnerThread, EraserThread, FileImage;

{ TDevice }

procedure TDevice.BurnFromFile(const FileName: string);
var
  FileImage: TFileImage;
begin
  FileImage := TFileImage.Create(FileName);
  FileImage.ImageType := ITISOFileImage; // set a just a filename to a iso file
  try
    BurnFromImage(FileImage);
  finally
    FileImage.Free;
  end;
end;


procedure TDevice.BurnFromImage(Image: TCustomImage);
var
  BurnerThread: TBurnerThread;
begin
  SetSpeed(SCDS_MAXSPEED, SCDS_MAXSPEED);
  BurnerThread := TBurnerThread.Create(FInfoRecord, Image);
  BurnerThread.OnCDStatus := FOnCdStatus;
  BurnerThread.OnCopyStatus := FOnCopyStatus;
  BurnerThread.OnBufferProgress := FOnBufferProgress;
  BurnerThread.OnFileBufferProgress := FOnFilebufferProgress;
  BurnerThread.OnBufferStatus := FOnBufferStatus;
  BurnerThread.OnWriteStatusEvent := FOnWriteStatusEvent;
  BurnerThread.BurnSettings := FBurnSettings;
  BurnerThread.Resume;
end;



Procedure TDevice.GetSpecialDeviceSettings;
begin
   FBurnSettings.SpecialDeviceType.PDVR103 := False;
   FBurnSettings.SpecialDeviceType.SonyCRX100E := False;
   FBurnSettings.SpecialDeviceType.TEAC512EB := False;
   FBurnSettings.SpecialDeviceType.SonyPowerBurn := False;
   FBurnSettings.SpecialDeviceType.FlmmedCT := False;

   if (BurnerInfo.ProductID = 'CRX175E') or (BurnerInfo.ProductID = 'CD-RW CRX800E') then
     FBurnSettings.SpecialDeviceType.SonyPowerBurn := True;

   if (BurnerInfo.ProductID = 'CD-RW CRX800E') then
     FBurnSettings.SpecialDeviceType.SonyCRX100E := True;

   if (BurnerInfo.ProductID = 'CDRW321040X') then
     FBurnSettings.SpecialDeviceType.FlmmedCT := True;

   if (BurnerInfo.ProductID = 'DVD-RW DVR-103') or (BurnerInfo.ProductID = 'DVD-RW DVR-103') then
   Begin
     FBurnSettings.SpecialDeviceType.PDVR103 := True;
     FBurnSettings.SpecialDeviceType.FlmmedCT := True;
   End;
end;




procedure TDevice.QuickSetISOBurnSettings;
begin
  FBurnSettings.DataBlockType := btMODE_1;
  FBurnSettings.WriteType := wtTRACK_AT_ONCE;
  FBurnSettings.TrackMode := tmCDR_MODE_DATA;
  FBurnSettings.SessionType := stCDROM_CDDA;
  FBurnSettings.EraseType := etBLANK_DISC;
  FBurnSettings.BurnProof := True;
  FBurnSettings.TestWrite := False;
  FBurnSettings.CloseSession := True;
  FBurnSettings.AudioPause := 150;
  FBurnSettings.PacketSize := 0;
  GetSpecialDeviceSettings;
end;


procedure TDevice.QuickSetAudioBurnSettings;
begin
  FBurnSettings.DataBlockType := btRAW_DATA_BLOCK;
  FBurnSettings.WriteType := wtTRACK_AT_ONCE;
  FBurnSettings.TrackMode := tmCDR_MODE_AUDIO;
  FBurnSettings.SessionType := stCDROM_CDDA;
  FBurnSettings.EraseType := etBLANK_DISC;
  FBurnSettings.BurnProof := True;
  FBurnSettings.TestWrite := False;
  FBurnSettings.CloseSession := True;
  FBurnSettings.AudioPause := 150;
  FBurnSettings.PacketSize := 0;
  GetSpecialDeviceSettings;
end;


procedure TDevice.QuickSetDAOBurnSettings; //looks like it is wrong
begin
  FBurnSettings.DataBlockType := btRAW_DATA_BLOCK;
  FBurnSettings.WriteType := wtSESSION_AT_ONCE;
  FBurnSettings.TrackMode := tmCDR_MODE_DATA;
  FBurnSettings.SessionType := stCDROM_CDDA;
  FBurnSettings.EraseType := etBLANK_DISC;
  FBurnSettings.BurnProof := True;
  FBurnSettings.TestWrite := False;
  FBurnSettings.CloseSession := True;
  FBurnSettings.AudioPause := 0;
  FBurnSettings.PacketSize := 0;
  FBurnSettings.SessionAtOnce := True;
  FBurnSettings.DiskAtOnce := True;
  GetSpecialDeviceSettings;
end;


procedure TDevice.QuickSetSAOBurnSettings;
begin
  FBurnSettings.DataBlockType := btRAW_DATA_BLOCK;
  FBurnSettings.WriteType := wtSESSION_AT_ONCE;
  FBurnSettings.TrackMode := tmCDR_MODE_DAO_96;
  FBurnSettings.SessionType := stCDROM_CDDA;
  FBurnSettings.EraseType := etBLANK_DISC;
  FBurnSettings.BurnProof := True;
  FBurnSettings.TestWrite := False;
  FBurnSettings.CloseSession := True;
  FBurnSettings.AudioPause := 0;
  FBurnSettings.PacketSize := 0;
  FBurnSettings.SessionAtOnce := True;
  FBurnSettings.DiskAtOnce := False;
  GetSpecialDeviceSettings;
end;



procedure TDevice.SetDefaultBurnSettings;
begin
  QuickSetISOBurnSettings;
end;

procedure TDevice.AutoInitialize; // Initialize variables
begin
  FDeviceInfo := TDeviceInfo.Create(FInfoRecord);
  FDiscInfo := TDiscInfo.Create(FInfoRecord);
  FDeviceReader := TDeviceReader.Create(FInfoRecord);
  FDiskNotifier := TDiskNotifier.Create(nil);
  FDiskNotifier.OnDiskInserted := DiskInserted;
  FDiskNotifier.OnDiskRemoved := DiskRemoved;
  SetDefaultBurnSettings;
  FDefaults := SCSI_DEF;
  FLastError := Err_None;
  SetSpeed($FFFF, $FFFF);
end;

constructor TDevice.Create(InfoRecord: PCDBurnerInfo);
begin
  FInfoRecord := InfoRecord;
  AutoInitialize;
end;

{ Method to free any objects created by AutoInitialize }

procedure TDevice.AutoDestroy;
begin
  FDiskNotifier.free;
  if assigned(FDiscInfo) then
    FDiscInfo.Free;
  if assigned(FDeviceInfo) then
    FDeviceInfo.Free;
  if assigned(FInfoRecord) then
    Dispose(FInfoRecord);
end;

destructor TDevice.Destroy;
begin
  AutoDestroy;
  inherited;
end;



procedure TDevice.DiskInserted(DriveLetter : String); // for disk notify
Begin
 if (DriveLetter = FDeviceInfo.DriveLetter) then
 begin
    if assigned(FDiscInfo) then FDiscInfo.RefreshInfo;
    if assigned(FOnDriveDiskInsert) then FOnDriveDiskInsert(self);
 end;
end;


procedure TDevice.DiskRemoved(DriveLetter : String); // for disk notify
Begin
 if (DriveLetter = FDeviceInfo.DriveLetter) then
 begin
    if assigned(FDiscInfo) then FDiscInfo.RefreshInfo;
    if assigned(OnDriveDiskRemove) then OnDriveDiskRemove(self);
 end;
end;


procedure TDevice.Eject(const NoWait: boolean);
begin
  FLastError := SCSIstartStopUnit(BurnerInfo, False, True, NoWait, fDefaults);
end;

procedure TDevice.Erase(const FullErase: boolean);
begin
  // create thread to erase disk
end;

function TDevice.GetBurnerInfo: TCDBurnerInfo;
begin
  Result := FInfoRecord^;
end;

function TDevice.GetIsLocked: boolean; //to do
begin
  Result := False;
end;

procedure TDevice.Load(const NoWait: boolean);
begin
  FLastError := SCSIstartStopUnit(BurnerInfo, True, True, NoWait, fDefaults);
end;

procedure TDevice.GetSpeed(out MaxReadSpeed, MaxWriteSpeed, CurrentReadSpeed,
  CurrentWriteSpeed: integer);
var
  CDROMSpeeds: TCDReadWriteSpeeds;
begin
  SCSIGetDriveSpeeds(BurnerInfo, CDROMSpeeds, fDefaults);
  MaxReadSpeed := CDRomSpeeds.MaxReadSpeed;
  MaxWriteSpeed := CDRomSpeeds.MaxWriteSpeed;
  CurrentReadSpeed := CDRomSpeeds.CurrentReadSpeed;
  CurrentWriteSpeed := CDRomSpeeds.CurrentWriteSpeed;
end;

function TDevice.GetWriteParameters: string;
var
  Params: string;
  // TBurnSettings
begin
  FLastError := ScsiGetWriteParams(BurnerInfo, 0, Params, fDefaults);
  Result := Params;
end;

procedure TDevice.Lock;
begin
  FLastError := SCSIpreventMediumRemoval(BurnerInfo, True, fDefaults);
end;

procedure TDevice.UnLock;
begin
  FLastError := SCSIpreventMediumRemoval(BurnerInfo, False, fDefaults);
end;

function TDevice.SetSpeed(const ReadSpeed, WriteSpeed: integer): Boolean;
begin
  FLastError := SCSISetSpeed(BurnerInfo, ReadSpeed, WriteSpeed, fDefaults);
  Result := FLastError = Err_None;
end;

function TDevice.GetReady: boolean;
begin
  FLastError := SCSItestReady(BurnerInfo, fDefaults);
  Result := FLastError = Err_None;
end;

function TDevice.GetCapability: TCdRomCapabilities;
begin
  FLastError := SCSIgetCdRomCapabilities(BurnerInfo, Result, fDefaults);
end;


function TDevice.CloseSession: Boolean;
begin
  FLastError := SCSICloseSession(BurnerInfo, fDefaults);
  Result := FLastError = Err_None;
end;

function TDevice.GetBufferSize: WORD;
var
  Temp: Word;
begin
  Temp := 0;
  FLastError := SCSIgetBufferSize(BurnerInfo, Temp, fDefaults);
  Result := Temp;
end;

end.
