{-----------------------------------------------------------------------------
 Unit Name: DeviceHelper
 Author:    Andrew Semack / Dancemammal
 Purpose:   collect info about availible CD / DVD devices
 History:
-----------------------------------------------------------------------------}

unit DeviceHelper;

// TODO : There unit to help any universal SCSI functions which used in library classes }

interface

uses
  Windows, sysutils, SCSIUnit, SCSITypes, Classes,
  CDROMIOCTL, SCSIDefs, CovertFuncs;

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

type
  TSPTIWriters = record
    ActiveCdRom: Byte;
    CdRomCount: Byte;
    CdRom: array[0..25] of TSPTIWriter;
  end;

type
  SCSI_ADDRESS = record
    Length: LongInt;
    PortNumber: Byte;
    PathId: Byte;
    TargetId: Byte;
    Lun: Byte;
  end;
  PSCSI_ADDRESS = ^SCSI_ADDRESS;

function GatherDeviceID(Adapter, Target, Lun: byte; Letter: char): TBurnerID;
function GetDriveNumbers(var CDRoms: TSPTIWriters): integer;
procedure GetDriveInformation(i: byte; var CdRoms: TSPTIWriters);
function GetSPTICdRomDrives(var CdRoms: TSPTIWriters): Boolean;

implementation

function GatherDeviceID(Adapter, Target, Lun: byte; Letter: char): TBurnerID;
begin
  Result := GatherDWORD(Adapter, Target,
    ((Lun and 7) shl 5) or (ORD(Letter) and $1F), 0);
end;

function GetDriveNumbers(var CDRoms: TSPTIWriters): integer;
var
  i: integer;
  szDrives: array[0..105] of Char;
  p: PChar;
begin
  CdRoms.CdRomCount := 0;
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

end.
