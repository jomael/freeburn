{-----------------------------------------------------------------------------
 Unit Name: DiskNotifier
 Author:    Paul Fisher / Andrew Semack
 Purpose:   Class for New Disk Insert notify
 History:
-----------------------------------------------------------------------------}

{$WARN SYMBOL_DEPRECATED OFF}
unit DiskNotifier;

interface

uses
  Windows, Messages, SysUtils, Classes, Forms;

type
  PDevBroadcastHdr = ^DEV_BROADCAST_HDR;
  DEV_BROADCAST_HDR = packed record
    dbch_size: DWORD;
    dbch_devicetype: DWORD;
    dbch_reserved: DWORD;
  end;

  PDevBroadcastDeviceInterface = ^DEV_BROADCAST_DEVICEINTERFACE;
  DEV_BROADCAST_DEVICEINTERFACE = record
    dbcc_size: DWORD;
    dbcc_devicetype: DWORD;
    dbcc_reserved: DWORD;
    dbcc_classguid: TGUID;
    dbcc_name: short;
  end;

  PDevBroadcastVolume = ^TDevBroadcastVolume;
  TDevBroadcastVolume = packed record
    dbcv_size: DWORD;
    dbcv_devicetype: DWORD;
    dbcv_reserved: DWORD;
    dbcv_unitmask: DWORD;
    dbcv_flags: Word;
  end;


  TCDInsertDiskStatusEvent = procedure(DriveLetter : String) of object;
  TCDRemoveDiskStatusEvent = procedure(DriveLetter : String) of object;


const
  DBT_DEVICEARRIVAL = $8000; // system detected a new device
  DBT_DEVICEREMOVECOMPLETE = $8004; // device is gone
  DBT_DEVTYP_DEVICEINTERFACE = $00000005; // device interface class
  DBTF_MEDIA = $0001;
  DBT_DEVTYP_VOLUME = $0002;



type
  TDiskNotifier = class(TComponent)
  private
    FWindowHandle: HWND;
    FOnNewDiskInserted: TCDInsertDiskStatusEvent;
    FOnDiskRemoved : TCDRemoveDiskStatusEvent;
    FHandle: pointer;
    procedure WndProc(var Msg: TMessage);
  protected
    procedure WMDeviceChange(var Msg: TMessage); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnDiskInserted : TCDInsertDiskStatusEvent read FOnNewDiskInserted write FOnNewDiskInserted;
    property OnDiskRemoved : TCDRemoveDiskStatusEvent read FOnDiskRemoved write FOnDiskRemoved;
  end;


implementation

constructor TDiskNotifier.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHandle := nil;
  FWindowHandle := AllocateHWnd(WndProc);
end;


destructor TDiskNotifier.Destroy;
begin
  DeallocateHWnd(FWindowHandle);
  inherited Destroy;
end;


procedure TDiskNotifier.WndProc(var Msg: TMessage);
begin
  if (Msg.Msg = WM_DEVICECHANGE) then
  begin
    try
      WMDeviceChange(Msg);
    except
      Application.HandleException(Self);
    end;
  end
  else
    Msg.Result := DefWindowProc(FWindowHandle, Msg.Msg, Msg.wParam, Msg.lParam);
end;


function GetDrive(pDBVol: PDevBroadcastVolume): string;
var
  i: Byte;
  Maske: DWORD;
begin
  if (pDBVol^.dbcv_flags and DBTF_Media) = DBTF_Media then
  begin
    Maske := pDBVol^.dbcv_unitmask;
    for i := 0 to 25 do
    begin
      if (Maske and 1) = 1 then
        Result := Char(i + Ord('A'));
      Maske := Maske shr 1;
    end;
  end;
end;




procedure TDiskNotifier.WMDeviceChange(var Msg: TMessage);
var
  devType: Integer;
  Datos: PDevBroadcastHdr;
  Drive: string;
begin
  if (Msg.wParam = DBT_DEVICEARRIVAL) then
  begin
    Datos := PDevBroadcastHdr(Msg.lParam);
    devType := Datos^.dbch_devicetype;
    if devType = DBT_DEVTYP_VOLUME then
    begin
        Drive := GetDrive(PDevBroadcastVolume(Msg.lParam));
        if Assigned(FOnNewDiskInserted) then FOnNewDiskInserted(Drive);
    end;
  end;

  if (Msg.wParam = DBT_DEVICEREMOVECOMPLETE) then
  begin
    Datos := PDevBroadcastHdr(Msg.lParam);
    devType := Datos^.dbch_devicetype;
    if devType = DBT_DEVTYP_VOLUME then
    begin
        Drive := GetDrive(PDevBroadcastVolume(Msg.lParam));
        if Assigned(FOnDiskRemoved) then FOnDiskRemoved(Drive);
    end;
  end;
end;


end.
