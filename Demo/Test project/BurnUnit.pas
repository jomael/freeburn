unit BurnUnit;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Gauges, Devices, Device, scsidefs, Fileimage, AudioImage, BinCueImage,
  ComCtrls;

type
  TBurnForm = class(TForm)
    ListBox1: TListBox;
    Gauge1: TGauge;
    Label1: TLabel;
    Gauge2: TGauge;
    Label2: TLabel;

    StatusBar1: TStatusBar;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Gauge3: TGauge;
    procedure copystats(CurrentSector,PercentDone : Integer) ;
    Procedure CDStatus(CurrentStatus:String);
    procedure BufferProgress(Percent : Integer);
    procedure FileBufferProgress(Percent : Integer);
    procedure BufferStatus(BufferSize , FreeSize : Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    CDBurner : TDevice;
    Procedure StartDataWrite(BurnFileImage : TFileImage);
    Procedure StartCUEDataWrite(BurnFileImage : TBinCueImage);
    Procedure StartAudioWrite(BurnAudioImage : TAudioImage);
    Procedure DumpISOFile(FileName : String);
    Procedure BlankThisCD;
  end;

var
  BurnForm: TBurnForm;

implementation


{$R *.dfm}



Procedure TBurnform.StartAudioWrite(BurnAudioImage : TAudioImage);
begin
    CDBurner.OnCopyStatus := copystats;
    CDBurner.OnCDStatus := CDStatus;
    CDBurner.OnBufferProgress := BufferProgress;
    CDBurner.OnFileBufferProgress := FileBufferProgress;
    CDBurner.OnBufferStatus := BufferStatus;
    CDBurner.QuickSetAudioBurnSettings;
    CDBurner.BurnFromImage(BurnAudioImage);
end;



Procedure TBurnform.StartDataWrite(BurnFileImage : TFileImage);
begin
    CDBurner.OnCopyStatus := copystats;
    CDBurner.OnCDStatus := CDStatus;
    CDBurner.OnBufferProgress := BufferProgress;
    CDBurner.OnFileBufferProgress := FileBufferProgress;
    CDBurner.OnBufferStatus := BufferStatus;
    CDBurner.QuickSetISOBurnSettings;
    CDBurner.BurnFromImage(BurnFileImage);
end;


Procedure TBurnform.StartCUEDataWrite(BurnFileImage : TBinCueImage);
begin
    CDBurner.OnCopyStatus := copystats;
    CDBurner.OnCDStatus := CDStatus;
    CDBurner.OnBufferProgress := BufferProgress;
    CDBurner.OnFileBufferProgress := FileBufferProgress;
    CDBurner.OnBufferStatus := BufferStatus;
    CDBurner.QuickSetDAOBurnSettings;
    CDBurner.BurnFromImage(BurnFileImage);
end;


Procedure TBurnform.DumpISOFile(FileName : String);
begin
    CDBurner.OnCopyStatus := copystats;
    CDBurner.OnCDStatus := CDStatus;
    CDBurner.OnBufferProgress := BufferProgress;
    CDBurner.OnFileBufferProgress := FileBufferProgress;
    CDBurner.OnBufferStatus := BufferStatus;
    CDBurner.DeviceReader.RipDiskToISOImage(FileName);
    Showmessage('Copy Finished!');
end;



procedure TBurnForm.copystats(CurrentSector, PercentDone : Integer) ;
begin
  gauge2.progress := percentdone;
  statusbar1.simpletext := 'Sector : '+ inttostr(CurrentSector);
  statusbar1.Refresh;
end;



procedure TBurnForm.BufferProgress(Percent : Integer);
begin
    gauge1.progress := Percent;
end;



procedure TBurnForm.FileBufferProgress(Percent : Integer);
begin
    gauge3.progress := Percent;
end;



procedure TBurnForm.BufferStatus(BufferSize , FreeSize : Integer);
begin
   Label3.caption := 'Burner Buffer Size : '+ inttostr(buffersize div 1024)+ ' kb';
   Label4.caption := 'Burner Free Buffer : '+ inttostr(FreeSize div 1024)+ ' kb';
end;



Procedure TBurnForm.CDStatus(CurrentStatus:String);
begin
   ListBox1.items.Insert(0,CurrentStatus);
end;



Procedure TBurnForm.BlankThisCD;

begin
    CDBurner.OnCopyStatus := copystats;
    CDBurner.OnCDStatus := CDStatus;
    CDBurner.OnBufferProgress := BufferProgress;
    CDBurner.OnBufferStatus := BufferStatus;
 //   CDBurner.BlankCDRom(blanktype,0);
    Showmessage('Blanking Finished!');
end;

end.
