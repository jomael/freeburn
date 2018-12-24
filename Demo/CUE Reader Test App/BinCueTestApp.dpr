program BinCueTestApp;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  BinCueReader in '..\..\Sources\Library Units\BinCueReader.pas',
  ReadWave in '..\..\Sources\Common\ReadWave.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
