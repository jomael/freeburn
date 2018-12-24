unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,BinCueReader, ComCtrls, ToolWin, ImgList;

type
  TForm1 = class(TForm)
    OpenDialog1: TOpenDialog;
    ListBox1: TListBox;
    ToolBar1: TToolBar;
    ToolButton1: TToolButton;
    ToolButton2: TToolButton;
    ToolButton3: TToolButton;
    ToolButton4: TToolButton;
    ToolButton5: TToolButton;
    ToolButton6: TToolButton;
    ToolButton7: TToolButton;
    ImageList1: TImageList;
    ATIPMemo: TMemo;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure ToolButton4Click(Sender: TObject);
    procedure ToolButton6Click(Sender: TObject);
    procedure ToolButton7Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    BinReader : TBinCueReader;
    Procedure ResetList;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
begin
   BinReader := TBinCueReader.Create;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  BinReader.Destroy;
end;


Procedure TForm1.ResetList;
var
  index : integer;
  trackstr : string;
begin
   ListBox1.Items.Clear;
   for index := 0 to BinReader.BinTrackList.Count -1 do
   begin
      trackstr := 'Track : '+ inttostr(index+1)+'    '+ BinReader.BinTrackList.Tracks[index].ModeDesc +'  '+
      inttostr( BinReader.BinTrackList.Tracks[index].Index[0].LBA) +'  '+ BinReader.BinTrackList.Tracks[index].FileType;
      ListBox1.Items.Add(trackstr);
   end;
end;



procedure TForm1.Button1Click(Sender: TObject);
begin
if opendialog1.execute then
    BinReader.OpenCueFile(opendialog1.FileName);
    ResetList;
end;

procedure TForm1.ToolButton4Click(Sender: TObject);
begin
   ResetList;
end;

procedure TForm1.ToolButton6Click(Sender: TObject);
begin
{CREATE NEW CUE}
   BinReader.SaveATIPCueToFile('C:\ATIPCUE.cue');
   ATIPMemo.Lines.LoadFromFile('C:\ATIPCUE.cue');
end;

procedure TForm1.ToolButton7Click(Sender: TObject);
begin
  CLOSE;
end;

end.
