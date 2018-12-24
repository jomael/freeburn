program Project1;

uses
  Forms,
  Unit1 in 'Unit1.pas' {Form1},
  Bin2ISO in '..\..\Sources\Library Units\Bin2ISO.pas',
  CDBufferedStream in '..\..\Sources\Common\CDBufferedStream.pas',
  Resources in '..\..\Sources\Common\Resources.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
