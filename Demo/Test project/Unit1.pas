{-----------------------------------------------------------------------------
 Unit Name: Unit1
 Author:    Dancemammal
 Purpose:   Test Application to test functions
 History:   First Code Release
-----------------------------------------------------------------------------}


unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Devices, SCSITypes, CovertFuncs, StdCtrls, ComCtrls, CDSizer,
  Menus, ExtCtrls, ToolWin, scsidefs, BurnUnit, AudioImage, BinCueImage, FileImage, WaveUtils, ImgList;

type
  TBurnerForm = class(TForm)
    Button1: TButton;
    PageControl1: TPageControl;
    TabSheet6: TTabSheet;
    ReadTocListView: TListView;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    Panel1: TPanel;
    CDSize1: TCDSize;
    MainMenu1: TMainMenu;
    File1: TMenuItem;
    Options1: TMenuItem;
    Functions1: TMenuItem;
    CDCapabilities1: TMenuItem;
    ShowWriterParameters1: TMenuItem;
    SaveCDToISOImage1: TMenuItem;
    N1: TMenuItem;
    BurnISOToCD1: TMenuItem;
    BurnWaveFileToCD1: TMenuItem;
    N2: TMenuItem;
    FormatCD1: TMenuItem;
    BlankCD1: TMenuItem;
    StatusBar2: TStatusBar;
    SaveDialog1: TSaveDialog;
    OpenDialog1: TOpenDialog;
    ViewTOC1: TMenuItem;
    ImageList1: TImageList;
    ToolButton7: TToolButton;
    ISOFunctions1: TMenuItem;
    CreateISO9660File1: TMenuItem;
    ShowReadWriteSpeeds1: TMenuItem;
    GetCDDVDStructure1: TMenuItem;
    GetBufferBits1: TMenuItem;
    N4: TMenuItem;
    N5: TMenuItem;
    ToolButton8: TToolButton;
    ToolBar2: TToolBar;
    DriveCombo: TComboBox;
    Label1: TLabel;
    ToolButton9: TToolButton;
    AddTrackToTrackList1: TMenuItem;
    ToolButton6: TToolButton;
    TabSheet1: TTabSheet;
    TrackListBox: TListBox;
    CreateACUEFile1: TMenuItem;
    GetCDTEXT1: TMenuItem;
    GetCDDBIDFromAudioCD1: TMenuItem;
    AudioFunctions1: TMenuItem;
    AddTracktoList1: TMenuItem;
    ArtistPanel: TPanel;
    N3: TMenuItem;
    BurnTracksToAudioCD1: TMenuItem;
    ToolButton10: TToolButton;
    ToolButton11: TToolButton;
    N6: TMenuItem;
    BurnDAOCueFile1: TMenuItem;
    Procedure CDChanged(Sender: TObject);
    Procedure CDRemoved(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure CDCapabilities1Click(Sender: TObject);
    procedure ShowWriterParameters1Click(Sender: TObject);
    procedure SaveCDToISOImage1Click(Sender: TObject);
    procedure ViewTOC1Click(Sender: TObject);
    procedure BurnWaveFileToCD1Click(Sender: TObject);
    procedure BurnISOToCD1Click(Sender: TObject);
    procedure CDSize1OverBurn(Sender: TObject);
    procedure BlankCD1Click(Sender: TObject);
    procedure ShowReadWriteSpeeds1Click(Sender: TObject);
    procedure GetCDDVDStructure1Click(Sender: TObject);
    procedure GetBufferBits1Click(Sender: TObject);
    procedure CreateACUEFile1Click(Sender: TObject);
    procedure GetCDTEXT1Click(Sender: TObject);
    procedure GetCDDBIDFromAudioCD1Click(Sender: TObject);
    procedure AddTracktoList1Click(Sender: TObject);
    procedure AddTrackToTrackList1Click(Sender: TObject);
    procedure CreateISO9660File1Click(Sender: TObject);
    procedure ToolButton11Click(Sender: TObject);
  private
    { Private declarations }
    Procedure ShowLastError;
    Procedure RefreshTrackList;
    function GetCapabilityText: string;  //to take out ???
  public
    { Public declarations }
    CDBurnerList : TDevices;
    AudioImage : TAudioImage;
    CurrentISOFilename,CurrentCUEFilename :String;
  end;

var
  BurnerForm: TBurnerForm;

implementation

uses ISOUnit;

{$R *.dfm}



Procedure TBurnerForm.CDChanged(Sender: TObject);
begin
    ReadTocListView.Items.Clear;
    TrackListBox.Items.Clear;
    if CDBurnerList.Items[DriveCombo.ItemIndex].DiscInfo.IsAudioDisk = True then
        GetCDDBIDFromAudioCD1Click(nil)
          else
            ViewTOC1Click(nil);
end;


Procedure TBurnerForm.CDRemoved(Sender: TObject);
begin
    ReadTocListView.Items.Clear;
    TrackListBox.Items.Clear;
end;


procedure TBurnerForm.FormCreate(Sender: TObject);
var
     Index : Integer;
begin
    CDBurnerList := TDevices.create;
   for Index := 0 to CDBurnerList.Count -1 do
   begin
       DriveCombo.Items.Add(CDBurnerList.Items[Index].DeviceInfo.VendorName);
       CDBurnerList.Items[Index].OnDriveDiskInsert := CDChanged;
       CDBurnerList.Items[Index].OnDriveDiskRemove := CDRemoved;
   end;
   DriveCombo.ItemIndex := 0;
   AudioImage := TAudioImage.Create;
end;



procedure TBurnerForm.FormDestroy(Sender: TObject);
begin
   AudioImage.Free;
   CDBurnerList.Free;
end;



procedure TBurnerForm.CDCapabilities1Click(Sender: TObject);
var
    CapString : String;
begin
    CapString := GetCapabilityText;
    Showmessage(CapString);
end;


function TBurnerForm.GetCapabilityText: string;
var
  Strings: Tstringlist;
  CDROMCap: TCdRomCapabilities;
begin
  CDROMCap := CDBurnerList.Items[DriveCombo.ItemIndex].Capability;
  Strings := Tstringlist.create;
  try
    Strings.Add('-- Device Reading Methods --');
    if cdcReadCDR in CDROMCap then
      Strings.Add('    Read CD-R media');
    if cdcReadCDRW in CDROMCap then
      Strings.Add('    Read CD-RW media');
    if cdcReadMethod2 in CDROMCap then
      Strings.Add('    Read CD-R written using fixed packets');
    if cdcReadDVD in CDROMCap then
      Strings.Add('    Read DVD-ROM media');
    if cdcReadDVDR in CDROMCap then
      Strings.Add('    Read DVD-R / DVD-RW media');
    if cdcReadDVDRAM in CDROMCap then
      Strings.Add('    Read DVD-RAM media');
    Strings.Add('-- Device Writing Methods --');
    if cdcWriteCDR in CDROMCap then
      Strings.Add('    Write CD-R media');
    if cdcWriteCDRW in CDROMCap then
      Strings.Add('    Write CD-RW media');
    if cdcWriteDVDR in CDROMCap then
      Strings.Add('    Write DVD-R / DVD-RW media');
    if cdcWriteDVDRAM in CDROMCap then
      Strings.Add('    Write DVD-RAM media');
    Strings.Add('-- Device Writing Extended Functions --');
    if cdcWriteTestMode in CDROMCap then
      Strings.Add('    Write in test mode');
    if cdcWriteBurnProof in CDROMCap then
      Strings.Add('    Can Use Burn Proof');
    Strings.Add('-- Device Extended Methods --');
    if cdcReadMode2form1 in CDROMCap then
      Strings.Add('        Capable to read Mode 2 Form 1 (CD-XA format)');
    if cdcReadMode2form2 in CDROMCap then
      Strings.Add('        Capable to read Mode 2 Form 2 (CD-XA format)');
    if cdcReadMultisession in CDROMCap then
      Strings.Add('        Capable to read PhotoCD format (multiple sessions)');
    if cdcCddaBarCode in CDROMCap then
      Strings.Add('       Capable to read CD disc bar code');
    result := Strings.Text;
  finally
    Strings.free;
  end;
end;



procedure TBurnerForm.ShowWriterParameters1Click(Sender: TObject);
Var
   TestString : String;
begin
  TestString := CDBurnerList.Items[DriveCombo.ItemIndex].DeviceBurnSettings;
  Showmessage(TestString);
  ShowLastError;
end;



Procedure TBurnerForm.ShowLastError;
Begin
      Statusbar2.Panels[0].Text := ScsiErrToString(CDBurnerList.Items[DriveCombo.ItemIndex].LastError);
      Statusbar2.Refresh;
End;



procedure TBurnerForm.SaveCDToISOImage1Click(Sender: TObject);
Var
   Filename: String;
Begin
   If Savedialog1.Execute Then
   Begin
      Filename := Savedialog1.FileName;
      BurnForm.CDBurner := CDBurnerList.Items[DriveCombo.ItemIndex];
      BurnForm.Show;
      BurnForm.DumpISOFile(FileName);
   end;
   ShowLastError;
End;



procedure TBurnerForm.ViewTOC1Click(Sender: TObject);

Var TOC: TScsiTOC;
   i: integer;
Begin
   TOC := CDBurnerList.Items[DriveCombo.ItemIndex].DeviceReader.TOC;
   ReadTocListView.Items.Clear;
   For i := 0 To TOC.TrackCount - 1 Do
      With ReadTocListView.Items.Add Do
      Begin
         Caption := IntToStr(i);
         Subitems.Add(IntToStr(TOC.Tracks[i].TrackNumber));
         Subitems.Add(IntToStr(TOC.Tracks[i].AbsAddress));
         Subitems.Add(SetToStr(TypeInfo(TScsiSubQinfoFlags), TOC.Tracks[i].Flags));
      End;
End;



procedure TBurnerForm.BurnWaveFileToCD1Click(Sender: TObject);
begin
    BurnForm.CDBurner := CDBurnerList.Items[DriveCombo.ItemIndex];
    BurnForm.Show;
    BurnForm.StartAudioWrite(AudioImage);
end;



procedure TBurnerForm.BurnISOToCD1Click(Sender: TObject);
Var
   FileImage : TFileImage;

begin
 Opendialog1.FilterIndex := 1;
 if opendialog1.Execute then
 begin
    CurrentISOFilename := opendialog1.filename;
    FileImage := TFileImage.Create(CurrentISOFilename);
    CDSize1.MemShaded := FileImage.ISOFileSize;
    BurnForm.CDBurner := CDBurnerList.Items[DriveCombo.ItemIndex];
    BurnForm.Show;
    BurnForm.StartDataWrite(FileImage);
    FileImage.Free;
 end;
end;


procedure TBurnerForm.CDSize1OverBurn(Sender: TObject);
begin
   showmessage('Size of data is too big!');
end;


procedure TBurnerForm.BlankCD1Click(Sender: TObject);
begin
    BurnForm.CDBurner := CDBurnerList.Items[DriveCombo.ItemIndex];
    BurnForm.Show;
    BurnForm.BlankThisCD;
end;


procedure TBurnerForm.ShowReadWriteSpeeds1Click(Sender: TObject);
var
    CapString : String;
    Strings : TStringlist;
    Maxread,maxwrite,curread,curwrite : integer;
begin
   CDBurnerList.Items[DriveCombo.ItemIndex].GetSpeed(Maxread,MaxWrite,curread,curwrite);
   Strings := Tstringlist.create;
   Strings.Add('-- Device Reading Speeds --');
   Strings.Add('       Current Read Speed = ' + inttostr(curread));
   Strings.Add('       Maximum Read Speed = ' + inttostr(Maxread));
   Strings.Add('-- Device Writing Speeds --');
   Strings.Add('       Current Write Speed = ' + inttostr(curwrite));
   Strings.Add('       Maximum Write Speed = ' + inttostr(MaxWrite));
   CapString := Strings.Text;
   Strings.Free;
   Showmessage(CapString);
end;


procedure TBurnerForm.GetCDDVDStructure1Click(Sender: TObject);
var
    Desc : TScsiDVDLayerDescriptorInfo;
    CapString : String;
begin
    Desc := CDBurnerList.Items[DriveCombo.ItemIndex].DiscInfo.DVDescriptor;
    CapString := 'Disk Type     : '+ CDBurnerList.Items[DriveCombo.ItemIndex].DiscInfo.DiscType.DType + #10#13;
    CapString := CapString + 'Capacity : '+ inttostr(CDBurnerList.Items[DriveCombo.ItemIndex].DiscInfo.Capacity) + #10#13;
    CapString := CapString + 'Book Type     : '+Desc.BookType + #10#13;
    CapString := CapString + 'Track Density : '+Desc.TrackDensity + #10#13;
    CapString := CapString + 'Disc Size     : '+Desc.DiscSize + #10#13;
    CapString := CapString + 'Maximum Rate  : '+Desc.MaximumRate + #10#13;
    CapString := CapString + 'Linear Density: '+Desc.LinearDensity + #10#13;
    CapString := CapString + 'Layer Type    : '+Desc.LayerType + #10#13;
    Showmessage(CapString);
end;


procedure TBurnerForm.GetBufferBits1Click(Sender: TObject);
begin
  CDBurnerList.items[DriveCombo.ItemIndex].CDBufferSize;
end;



Procedure TBurnerForm.RefreshTrackList;
Var
 Index : Integer;
 name,Disp : String;
 AudioCDSize, DataSize : Integer;
 AudioTrack : TCDTrackItem;
begin
  TrackListBox.Items.Clear;
  AudioCDSize := 0;
  For Index := 0 to AudioImage.TrackCount -1 do
  begin
    AudioTrack := AudioImage.Tracks[index];
    name :=  AudioTrack.CDTrack.TrackName;
    Disp :=  AudioTrack.DisplayName;
    DataSize := AudioTrack.CDTrack.DataSize;
    AudioCDSize := AudioCDSize + (DataSize div (1024*1024));
    TrackListBox.Items.Add(name + ' : '+ Disp);
  end;
    CDSize1.MemShaded := AudioCDSize;
end;


procedure TBurnerForm.CreateACUEFile1Click(Sender: TObject);
begin
   CDBurnerList.items[DriveCombo.ItemIndex].DiscInfo.CreateCUEFile('C:\Temp.bin','C:\TempCUE.cue');
   showmessage('Cue File created');
end;


procedure TBurnerForm.GetCDTEXT1Click(Sender: TObject);
var
 Text : String;
begin
  Text := CDBurnerList.items[DriveCombo.ItemIndex].DiscInfo.CDText.Artist + ' : '+ CDBurnerList.items[DriveCombo.ItemIndex].DiscInfo.CDText.Album + #10#13;
  Text := Text + CDBurnerList.items[DriveCombo.ItemIndex].DiscInfo.CDText.MusicTracks.Text;
  showmessage(Text);
end;


procedure TBurnerForm.GetCDDBIDFromAudioCD1Click(Sender: TObject);
var
  Header : String;
  Index : Integer;
begin
   TrackListBox.Items.Clear;
   Header := CDBurnerList.items[DriveCombo.ItemIndex].DiscInfo.CDDBInformation.Artist;
   Header := Header + '  /  ' + CDBurnerList.items[DriveCombo.ItemIndex].DiscInfo.CDDBInformation.Album;
   ArtistPanel.Caption := Header;
   for index := 0 to CDBurnerList.items[DriveCombo.ItemIndex].DiscInfo.CDDBInformation.Tracks.Count -1 do
      TrackListBox.Items.Add(inttostr(Index+1)+',  '+ CDBurnerList.items[DriveCombo.ItemIndex].DiscInfo.CDDBInformation.Tracks[index]);
end;


procedure TBurnerForm.AddTracktoList1Click(Sender: TObject);
var
     AudioTrack : TCDTrackItem;
     TrackIndex : Integer;
begin
   Opendialog1.FilterIndex := 2;
   if Opendialog1.Execute then
   begin
    for TrackIndex := 0 to Opendialog1.Files.Count -1 do
    begin
       AudioTrack := AudioImage.Add;
       AudioTrack.LoadWaveFile(OpenDialog1.Files[TrackIndex]);
       if not (AudioTrack.CDTrack.PCMFormat = Stereo16bit44100Hz) then
           AudioTrack.CDTrack.ConvertToPCM(Stereo16bit44100Hz);
       RefreshTrackList;
    end;
   end;
end;


procedure TBurnerForm.AddTrackToTrackList1Click(Sender: TObject);
begin
   showmessage('not yet coded');
end;

procedure TBurnerForm.CreateISO9660File1Click(Sender: TObject);
begin
  ISOForm.show;
end;

procedure TBurnerForm.ToolButton11Click(Sender: TObject);
Var
   BinImage : TBinCueImage;

begin
 Opendialog1.FilterIndex := 3;
 if opendialog1.Execute then
 begin
    CurrentCUEFilename := opendialog1.filename;
    BinImage := TBinCueImage.Create(CurrentCUEFilename);
    BinImage.SetupBINCUEImage;
    CDSize1.MemShaded := BinImage.BINFileSize;
    BurnForm.CDBurner := CDBurnerList.Items[DriveCombo.ItemIndex];
    BurnForm.Show;
    BurnForm.StartCUEDataWrite(BinImage);
    BinImage.Free;
 end;
end;


end.
