{-----------------------------------------------------------------------------
 Unit Name: FileImage
 Author:    Paul Fisher
 Purpose:   Fake class for a ISO image on HD 
 History:
-----------------------------------------------------------------------------}


unit FileImage;

interface

uses
  Classes, CustomImage, SysUtils, CovertFuncs;

type
    TFileImage = class(TCustomImage)
  private
      FISOFileName : String;
      FISOFileSize : Integer;
      Function GetImageSize(ISOFilename : String): Integer;
  Public
      constructor Create(FileName : String);
      destructor Destroy; override;
      property ISOFileName: String read FISOFileName;
      Property ISOFileSize: Integer read FISOFileSize;
    end;

implementation


constructor TFileImage.Create(FileName : String);
begin
   inherited Create;
   FISOFileName := FileName;
   ImageType := ITISOFileImage;
   FISOFileSize := GetImageSize(FISOFileName);
end;

destructor TFileImage.Destroy;
begin
   FISOFileName := '';
   inherited Destroy;
end;

Function TFileImage.GetImageSize(ISOFilename : String): Integer;
begin
   Result := 0;
   if FileExists(ISOFilename) then
      Result := GetFileSize(ISOFilename) div (1024*1024);
end;

end.
