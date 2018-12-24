{-----------------------------------------------------------------------------
 Unit Name: DeviceInfo
 Author:    Paul Fisher / Andrew Semack
 Purpose:   Class to store device information
 History:
-----------------------------------------------------------------------------}

unit DeviceInfo;

interface

uses
  Windows, DeviceTypes, Classes, SysUtils;

type
  TDeviceInfo = class
  private
    FInfoRecord: PCDBurnerInfo;
    function GetDriveID: DWORD;
    function GetDriveIndex: Integer;
    function GetDriveLetter: Char;
    function GetHaId: Byte;
    function GetLun: Byte;
    function GetProductID: string;
    function GetRevision: string;
    function GetSptiHandle: THandle;
    function GetTarget: Byte;
    function GetVendorID: string;
    function GetVendorName: string;
    function GetVendorSpec: string;
    function GetDriveName: string;
  public
    property DriveIndex: Integer read GetDriveIndex;
    property DriveLetter: Char read GetDriveLetter;
    property DriveName: string read GetDriveName;
    property DriveID: DWORD read GetDriveID;
    property ProductID: string read GetProductID;
    property VendorID: string read GetVendorID;
    property VendorName: string read GetVendorName;
    property VendorSpec: string read GetVendorSpec;
    property Revision: string read GetRevision;
    property SptiHandle: THandle read GetSptiHandle;
    property HaId: Byte read GetHaId;
    property Target: Byte read GetTarget;
    property Lun: Byte read GetLun;
    constructor Create(InfoRecord: PCDBurnerInfo);
  end;

implementation

{ TInfoRecord }

constructor TDeviceInfo.Create(InfoRecord: PCDBurnerInfo);
begin
  FInfoRecord := InfoRecord;
end;

function TDeviceInfo.GetDriveIndex: Integer;
begin
  Result := FInfoRecord.DriveIndex;
end;

function TDeviceInfo.GetDriveLetter: Char;
begin
  Result := FInfoRecord.DriveLetter;
end;

function TDeviceInfo.GetRevision: string;
begin
  Result := FInfoRecord.Revision;
end;

function TDeviceInfo.GetVendorID: string;
begin
  Result := FInfoRecord.VendorID;
end;

function TDeviceInfo.GetLun: Byte;
begin
  Result := FInfoRecord.Lun;
end;

function TDeviceInfo.GetProductID: string;
begin
  Result := FInfoRecord.ProductID;
end;

function TDeviceInfo.GetTarget: Byte;
begin
  Result := FInfoRecord.Target;
end;

function TDeviceInfo.GetVendorName: string;
begin
  Result := FInfoRecord.VendorName;
end;

function TDeviceInfo.GetHaId: Byte;
begin
  Result := FInfoRecord.HaId;
end;

function TDeviceInfo.GetVendorSpec: string;
begin
  Result := FInfoRecord.VendorSpec;
end;

function TDeviceInfo.GetSptiHandle: THandle;
begin
  Result := FInfoRecord.SptiHandle;
end;

function TDeviceInfo.GetDriveID: DWORD;
begin
  Result := FInfoRecord.DriveID;
end;

function TDeviceInfo.GetDriveName: string;
begin
  Result := Format('%s:', [FInfoRecord.DriveLetter]);
end;

end.
