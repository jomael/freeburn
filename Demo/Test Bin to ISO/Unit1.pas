unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, Bin2ISO, Buttons;

type
  TForm1 = class(TForm)
    binedit: TEdit;
    isoedit: TEdit;
    Button1: TButton;
    Button2: TButton;
    ProgressBar1: TProgressBar;
    OpenDialog1: TOpenDialog;
    BitBtn1: TBitBtn;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Progress(PercentDone: Integer; Var Cancel : Boolean);
    procedure BitBtn1Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    BIN2ISO : TBIN2ISO;
    Finish : Boolean;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Progress(PercentDone: Integer; Var Cancel : Boolean);
begin
  progressbar1.Position := PercentDone;
  Cancel := Finish;
end;



procedure TForm1.Button1Click(Sender: TObject);
var
 isofilename : string;
begin
if opendialog1.Execute then
begin
  Binedit.Text := Opendialog1.FileName;
  isofilename := changefileext(Opendialog1.FileName,'.ISO');
  isoedit.Text := isofilename;
end;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
  BIN2ISO := TBIN2ISO.Create;
  Finish := False;
  BIN2ISO.BINFileName := binedit.Text;
  BIN2ISO.ISOFileName := isoedit.Text;
  BIN2ISO.OnProgress := Progress;
  BIN2ISO.ConvertFile;
  BIN2ISO.Free;
end;


procedure TForm1.BitBtn1Click(Sender: TObject);
begin
   Finish := True;
end;

end.
