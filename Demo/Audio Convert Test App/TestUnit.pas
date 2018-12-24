unit TestUnit;

interface

uses
  Windows, Messages, SysUtils,WaveUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls,AudioImage, MP3Convert, ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    OpenDialog1: TOpenDialog;
    Button2: TButton;
    SaveDialog1: TSaveDialog;
    TrackListBox: TListBox;
    Button3: TButton;
    Button4: TButton;
    Button5: TButton;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button5Click(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
    AudioImage : TAudioImage;
    MP3Converter : TMP3Convertor;
    Procedure ListTracks;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}




Procedure TForm1.ListTracks;
Var
 Index : Integer;
begin
  TrackListBox.Items.Clear;
  For Index := 0 to AudioImage.TrackCount -1 do
  begin
    TrackListBox.Items.Add(AudioImage.Tracks[index].CDTrack.TrackName + ' : '+ AudioImage.Tracks[index].DisplayName);
  end;
end;




procedure TForm1.Button1Click(Sender: TObject);
Var
    Track : TCDTrackItem;
begin
if Opendialog1.execute then
begin
   Track := AudioImage.Add;
   Track.LoadWaveFile(Opendialog1.FileName);
   Track.CDTrack.ConvertToPCM(Stereo16bit44100Hz);
   ListTracks;
end;
end;


procedure TForm1.FormCreate(Sender: TObject);
begin
   AudioImage := TAudioImage.Create;
end;


procedure TForm1.FormDestroy(Sender: TObject);
begin
   AudioImage.Free;
end;


procedure TForm1.Button2Click(Sender: TObject);
begin
if savedialog1.Execute then
begin
   AudioImage.Tracks[0].SaveWaveFile(Savedialog1.FileName);
end;
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
   ListTracks;
end;

procedure TForm1.Button4Click(Sender: TObject);
Var
    Track : TCDTrackItem;
begin
if Opendialog1.execute then
begin
   Track := AudioImage.Add;
   Track.LoadWaveFile(Opendialog1.FileName);
   Track.CDTrack.ConvertToMP3(Stereo16bit44100Hz);
   ListTracks;
end;
end;

procedure TForm1.Button5Click(Sender: TObject);
begin
if savedialog1.Execute then
begin
   AudioImage.Tracks[0].CDTrack.ConvertFromMP3(Stereo16bit44100Hz);
   AudioImage.Tracks[0].SaveWaveFile(Savedialog1.FileName);
end;
end;

end.
