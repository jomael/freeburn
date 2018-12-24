program AudioTest;

uses
  Forms,
  TestUnit in 'TestUnit.pas' {Form1},
  AudioImage in '..\..\Sources\Image Units\AudioImage.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
