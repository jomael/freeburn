unit DVDUnit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ExtCtrls, ComCtrls, StdCtrls, DVDImage, ISO9660MicroUDFImageTree,
  ImgList,Resources;

type
  TISOForm = class(TForm)
    StatusBar1: TStatusBar;
    MainMenu1: TMainMenu;
    mm_File: TMenuItem;
    sm_File_Open: TMenuItem;
    sm_File_Close: TMenuItem;
    sm_File_Break1: TMenuItem;
    sm_File_Quit: TMenuItem;
    dlg_OpenImage: TOpenDialog;
    SaveDialog1: TSaveDialog;
    sm_File_SaveAs: TMenuItem;
    ImageList1: TImageList;
    Panel1: TPanel;
    mem_DebugOut: TMemo;
    tv_Directory: TTreeView;
    Panel2: TPanel;
    VolIDEdit: TEdit;
    Label1: TLabel;
    PopupMenu1: TPopupMenu;
    CreateDirctory1: TMenuItem;
    N2: TMenuItem;
    DeleteDirectory1: TMenuItem;
    AddFile1: TMenuItem;
    OpenDialog2: TOpenDialog;
    NewISOImage1: TMenuItem;
    SaveDVDImageas1: TMenuItem;
    N3: TMenuItem;
    Procedure ISOStatus(CurrentStatus:String);
    procedure sm_File_QuitClick(Sender: TObject);
    procedure sm_File_OpenClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure tv_DirectoryDblClick(Sender: TObject);
    procedure sm_File_CloseClick(Sender: TObject);
    procedure tv_DirectoryChange(Sender: TObject; Node: TTreeNode);
    procedure Image1Click(Sender: TObject);
    procedure CheckDirs1Click(Sender: TObject);
    procedure CreateDVDDirctory;
    procedure CreateDirctory1Click(Sender: TObject);
    procedure AddFile1Click(Sender: TObject);
    procedure DeleteDirectory1Click(Sender: TObject);
    procedure SaveDVDImageas1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    TreeObj : TObject;

    FDVDImage  : TDVDImage;

    Procedure  BuildStructureTree(ATV: TTreeView; RootNode : TTreeNode; ADirEntry : TDirectoryEntry);

  public
    ISOFilename : String;
  end;

var
  ISOForm: TISOForm;

implementation

{$R *.DFM}

procedure TISOForm.ISOStatus(CurrentStatus:String);
begin
   mem_debugout.Lines.Add(CurrentStatus);
end;



procedure TISOForm.sm_File_QuitClick(Sender: TObject);
begin
  Close;
end;


procedure TISOForm.sm_File_OpenClick(Sender: TObject);
Var
  Node : TTreeNode;
begin
  If ( dlg_OpenImage.Execute ) Then
  Begin
    If ( Assigned(FDVDImage) ) Then  FreeAndNil(FDVDImage);

    mem_DebugOut.Clear;
    tv_Directory.Items.Clear;

    FDVDImage := TDVDImage.Create;
    Try
      FDVDImage.Filename := dlg_OpenImage.FileName;
      FDVDImage.OnDVDStatus := ISOStatus;
      //FDVDImage.OpenImage;
      Node := tv_Directory.Items.Add(Nil, FDVDImage.Volume_ID+'/');
      Node.Data := FDVDImage.Structure.RootDirectory;
      BuildStructureTree(tv_Directory, Node, FDVDImage.Structure.RootDirectory);

      sm_File_SaveAs.Enabled := True;
      sm_File_Close.Enabled := True;

    Except
         mem_DebugOut.Lines.Add('Exception: ' + Exception(ExceptObject).ClassName + ' -> ' + Exception(ExceptObject).Message);
      Raise;

    End;
  End;
end;



procedure TISOForm.FormCreate(Sender: TObject);
begin
  FDVDImage := Nil;   // not necessary, but safety first...
end;


procedure TISOForm.FormDestroy(Sender: TObject);
begin
  If ( Assigned(FDVDImage) ) Then FreeAndNil(FDVDImage);
end;



procedure TISOForm.tv_DirectoryDblClick(Sender: TObject);
Var
  Node : TTreeNode;
  Obj  : TObject;
begin
  Node := TTreeView(Sender).Selected;
  If Assigned(Node.Data) Then
  Begin
    Obj := TObject(Node.Data);
    If ( Obj Is TFileEntry ) And ( SaveDialog1.Execute ) Then
      FDVDImage.ExtractFile(TFileEntry(Obj), SaveDialog1.FileName);
  End;
end;



Procedure TISOForm.BuildStructureTree(ATV: TTreeView; RootNode : TTreeNode; ADirEntry : TDirectoryEntry);
Var
  i : Integer;
  Node : TTreeNode;
  Dir  : TDirectoryEntry;
  Fil  : TFileEntry;
Begin
  For i:=0 To ADirEntry.DirectoryCount-1 Do
  Begin
    Dir := ADirEntry.Directories[i];
    Node := ATV.Items.AddChild(RootNode, Dir.Name + '/');
    Node.ImageIndex := 1;
    Node.SelectedIndex := 1;
    Node.Data := Pointer(Dir);
    BuildStructureTree(ATV, Node, Dir);
  End;

  For i:=0 To ADirEntry.FileCount-1 Do
  Begin
    Fil := ADirEntry.Files[i];
    Node := ATV.Items.AddChild(RootNode, Fil.Name);
    Node.ImageIndex := 2;
    Node.SelectedIndex := 2;
    Node.Data := Pointer(Fil);
  End;
End;



procedure TISOForm.sm_File_CloseClick(Sender: TObject);
begin
  If ( Assigned(FDVDImage) ) Then FDVDImage.CloseImage;
  sm_File_Close.Enabled  := False;
  sm_File_SaveAs.Enabled := False;
end;



procedure TISOForm.tv_DirectoryChange(Sender: TObject; Node: TTreeNode);

begin
  If Assigned(Node) Then
  Begin
    TreeObj := TObject(Node.Data);
 End;
end;







procedure TISOForm.Image1Click(Sender: TObject);

var
     DirEntry : TDirectoryEntry;
     FileEntry : TFileEntry;

begin
    If ( Assigned(FDVDImage) ) Then FreeAndNil(FDVDImage);
    FDVDImage := TDVDImage.Create;
    FDVDImage.OnDVDStatus := ISOStatus;
    CheckDirs1Click(nil);
    CreateDVDDirctory;
end;





procedure TISOForm.CheckDirs1Click(Sender: TObject);
Var
  Node : TTreeNode;
begin
    tv_Directory.Items.Clear;
    Try
      Node := tv_Directory.Items.Add(Nil, '/');
      Node.ImageIndex := 0;
      Node.Data := FDVDImage.Structure.RootDirectory;
      BuildStructureTree(tv_Directory, Node, FDVDImage.Structure.RootDirectory);
      tv_Directory.Items[0].Expand(true);
    Except
      mem_DebugOut.Lines.Add('Exception: ' + Exception(ExceptObject).ClassName + ' -> ' + Exception(ExceptObject).Message);
      Raise;
    End;
end;



procedure TISOForm.CreateDVDDirctory;
var
        DirName : String;
        DirEntry : TDirectoryEntry;
begin
        DirEntry := FDVDImage.Structure.RootDirectory;
        DirName := 'VIDEO_TS';
        if DirName <> '' then
        begin
           DirEntry := TDirectoryEntry.Create(FDVDImage.Structure,DirEntry,dsfFromImage);
           DirEntry.Name := DirName;
        end;

        DirEntry := FDVDImage.Structure.RootDirectory;
        DirName := 'AUDIO_TS';
        if DirName <> '' then
        begin
           DirEntry := TDirectoryEntry.Create(FDVDImage.Structure,DirEntry,dsfFromImage);
           DirEntry.Name := DirName;
        end;
        CheckDirs1Click(nil);
end;



procedure TISOForm.CreateDirctory1Click(Sender: TObject);
var
        DirName : String;
        DirEntry : TDirectoryEntry;
begin
    If Assigned(TreeObj) Then
    Begin
      If ( TreeObj Is TDirectoryEntry ) Then
      Begin
        DirEntry := TDirectoryEntry(TreeObj);
        DirName := InputBox('New Dir : ','Dir : ','');
        if DirName <> '' then
        begin
           DirEntry := TDirectoryEntry.Create(FDVDImage.Structure,DirEntry,dsfFromImage);
           DirEntry.Name := DirName;
        end;
        CheckDirs1Click(nil);
      End;
    End;
end;



procedure TISOForm.AddFile1Click(Sender: TObject);
var
        DirName : String;
        DirEntry : TDirectoryEntry;
        FileEntry : TFileEntry;
begin
    If Assigned(TreeObj) Then
    Begin
      If ( TreeObj Is TDirectoryEntry ) Then
      Begin
        DirEntry := TDirectoryEntry(TreeObj);
        if OpenDialog2.execute then
        begin
           FileEntry := TFileEntry.Create(DirEntry,dsfFromLocal);
           FileEntry.Name := ExtractFilename(Opendialog2.filename);
           FileEntry.SourceFileName := Opendialog2.filename;
        end;
        CheckDirs1Click(nil);
      End;
    End;
end;



procedure TISOForm.DeleteDirectory1Click(Sender: TObject);
var
        DirName : String;
        DirEntry : TDirectoryEntry;
begin
    If Assigned(TreeObj) Then
    Begin
      If ( TreeObj Is TDirectoryEntry ) Then
      Begin
        DirEntry := TDirectoryEntry(TreeObj).Parent;
        DirEntry.DelDirectory(TDirectoryEntry(TreeObj));
        CheckDirs1Click(nil);
      End;
    End;
end;

procedure TISOForm.SaveDVDImageas1Click(Sender: TObject);
begin
    savedialog1.Title := resFileDialogTitle;
    if savedialog1.execute then
    begin
       ISOFilename := savedialog1.filename;
       FDVDImage.Filename := ISOFilename;
       FDVDImage.Volume_ID := VolIDEdit.text;
       FDVDImage.SaveDVDImageToDisk;
       ShowMessage(resISOSaved);
    end;
end;

procedure TISOForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
If ( Assigned(FDVDImage) ) Then FreeAndNil(FDVDImage);
end;

end.
