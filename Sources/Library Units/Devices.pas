{-----------------------------------------------------------------------------
 Unit Name: Devices
 Author:    Paul Fisher / Andrew Semack
 Purpose:   Container Class for TDevice
 History:
-----------------------------------------------------------------------------}

unit Devices;

interface

uses
  Windows, Classes, Device, DeviceNotifier, DeviceTypes, DeviceHelper,
  SCSITypes, SysUtils;

type
  TDevices = class
  private
    FOnDeviceInstalledEvent: TNotifyEvent;
    FOnDeviceRemovedEvent: TNotifyEvent;
    FDeviceList: TList;
    FDeviceNotifier: TDeviceNotifier;
    function GetDeviceCount: integer;
    function GetDevice(Index: integer): TDevice;
  protected
    procedure ClearDeviceList;
    procedure FormatDeviceList;
    procedure DeviceInstalled(Sender: TObject);
    procedure DeviceRemoved(Sender: TObject);
  public
    procedure Refresh;
    property Count: integer read GetDeviceCount;
    property Items[Index: integer]: TDevice read GetDevice;
    property OnDeviceInstalled: TNotifyEvent read FOnDeviceInstalledEvent write
      FOnDeviceInstalledEvent;
    property OnDeviceRemoved: TNotifyEvent read FOnDeviceRemovedEvent write
      FOnDeviceRemovedEvent;
    constructor Create;
    destructor Destroy; override;
  end;

implementation

{ TDevices }

constructor TDevices.Create;
begin
  FDeviceNotifier := TDeviceNotifier.Create(nil);
  with FDeviceNotifier do
  begin
    OnUSBArrival := DeviceInstalled;
    OnUSBRemove := DeviceRemoved;
  end;
  FDeviceList := TList.Create;
  Refresh;
end;

function TDevices.GetDevice(Index: integer): TDevice;
begin
  Result := TDevice(FDeviceList[Index])
end;

procedure TDevices.Refresh;
begin
  ClearDeviceList;
  FormatDeviceList;
end;

function TDevices.GetDeviceCount: integer;
begin
  Result := FDeviceList.Count;
end;

procedure TDevices.ClearDeviceList;
var
  i: integer;
begin
  for i := FDeviceList.Count - 1 downto 0 do
    GetDevice(i).Free;
  FDeviceList.Clear;
end;

destructor TDevices.Destroy;
begin
  ClearDeviceList;
  FDeviceNotifier.Free;
  FDeviceList.Free;
  inherited;
end;

procedure TDevices.FormatDeviceList;
var
  Info: PCDBurnerInfo;
  index: integer;
  SPTICDs: TSPTIWriters;
begin
  GetSPTICdRomDrives(SPTICDs);
  for index := 0 to SPTICDs.CdRomCount - 1 do
  begin
    New(Info);
    Info.VendorSpec := SPTICDs.CdRom[index].VendorSpec;
    Info.Revision := SPTICDs.CdRom[index].Revision;
    Info.VendorID := trim(SPTICDs.CdRom[index].Vendor);
    Info.ProductID := trim(SPTICDs.CdRom[index].ProductId);
    Info.VendorName := Format('%s %s', [Info.VendorID, Info.ProductID]);
    Info.DriveLetter := SPTICDs.CdRom[index].DriveLetter;
    Info.DriveID := GatherDeviceID(SPTICDs.CdRom[index].HaId,
      SPTICDs.CdRom[index].Target, SPTICDs.CdRom[index].Lun,
      SPTICDs.CdRom[index].DriveLetter);
    Info.Lun := SPTICDs.CdRom[index].Lun;
    Info.HaId := SPTICDs.CdRom[index].HaId;
    Info.Target := SPTICDs.CdRom[index].Target;
    Info.DriveIndex := index;
    Info.SptiHandle := SPTICDs.CdRom[index].DriveHandle;
    FDeviceList.Add(TDevice.Create(Info));
  end;
end;

procedure TDevices.DeviceRemoved(Sender: TObject);
begin
  if assigned(FOnDeviceRemovedEvent) then
    FOnDeviceRemovedEvent(Self);
end;

procedure TDevices.DeviceInstalled(Sender: TObject);
begin
  if assigned(FOnDeviceInstalledEvent) then
    FOnDeviceInstalledEvent(Self);
end;

end.
