program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {BurnerForm},
  Resources in '..\..\Sources\Common\Resources.pas',
  Constants in '..\..\Sources\Common\Constants.pas',
  CovertFuncs in '..\..\Sources\Common\CovertFuncs.pas',
  HandledThread in '..\..\Sources\Common\HandledThread.pas',
  ISOImage in '..\..\Sources\Image Units\ISOImage.pas',
  AudioImage in '..\..\Sources\Image Units\AudioImage.pas',
  CustomImage in '..\..\Sources\Image Units\CustomImage.pas',
  FileImage in '..\..\Sources\Image Units\FileImage.pas',
  EraserThread in '..\..\Sources\Library Units\EraserThread.pas',
  BurnerThread in '..\..\Sources\Library Units\BurnerThread.pas',
  Device in '..\..\Sources\Library Units\Device.pas',
  DeviceHelper in '..\..\Sources\Library Units\DeviceHelper.pas',
  DeviceInfo in '..\..\Sources\Library Units\DeviceInfo.pas',
  DiskNotifier in '..\..\Sources\Library Units\DiskNotifier.pas',
  Devices in '..\..\Sources\Library Units\Devices.pas',
  DeviceTypes in '..\..\Sources\Library Units\DeviceTypes.pas',
  DiscInfo in '..\..\Sources\Library Units\DiscInfo.pas',
  wnaspi32 in '..\..\Sources\SCSI Units\wnaspi32.pas',
  CDROMIOCTL in '..\..\Sources\SCSI Units\CDROMIOCTL.pas',
  SCSIDefs in '..\..\Sources\SCSI Units\SCSIDefs.pas',
  SCSITypes in '..\..\Sources\SCSI Units\SCSITypes.pas',
  SCSIUnit in '..\..\Sources\SCSI Units\SCSIUnit.pas',
  skSCSI in '..\..\Sources\SCSI Units\skSCSI.pas',
  SPTIUnit in '..\..\Sources\SCSI Units\SPTIUnit.pas',
  DeviceReader in '..\..\Sources\Library Units\DeviceReader.pas',
  CDDAText in '..\..\Sources\Library Units\CDDAText.pas',
  CDBufferedStream in '..\..\Sources\Common\CDBufferedStream.pas',
  AudioACM in '..\..\Sources\Common\AudioACM.pas',
  MP3Convert in '..\..\Sources\Common\MP3Convert.pas',
  MSAcm in '..\..\Sources\Common\MSAcm.pas',
  WaveUtils in '..\..\Sources\Common\WaveUtils.pas',
  DVDImage in '..\..\Sources\Image Units\DVDImage.pas',
  BurnUnit in 'BurnUnit.pas' {BurnForm},
  CDSizer in '..\..\Sources\Common\CDSizer.pas',
  DiskCDDBInfo in '..\..\Sources\Library Units\DiskCDDBInfo.pas',
  ISOUnit in 'ISOUnit.pas' {ISOForm},
  DeviceNotifier in '..\..\Sources\Library Units\DeviceNotifier.pas',
  BinCueImage in '..\..\Sources\Image Units\BinCueImage.pas',
  BinCueReader in '..\..\Sources\Library Units\BinCueReader.pas',
  ReadWave in '..\..\Sources\Common\ReadWave.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TBurnerForm, BurnerForm);
  Application.CreateForm(TBurnForm, BurnForm);
  Application.CreateForm(TISOForm, ISOForm);
  Application.Run;
end.
