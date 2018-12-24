program DVDVideoTest;

uses
  Forms,
  DVDUnit in 'DVDUnit.pas' {ISOForm},
  DVDImage in '..\..\Sources\Image Units\DVDImage.pas',
  PopulateMicroUDFRecords in '..\..\Sources\Image Units\PopulateMicroUDFRecords.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TISOForm, ISOForm);
  Application.Run;
end.
