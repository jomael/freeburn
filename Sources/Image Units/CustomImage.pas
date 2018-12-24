{-----------------------------------------------------------------------------
 Unit Name: CustomImage
 Author:    Paul Fisher / Andrew Semack
 Purpose:   Parent of all CD Image types
 History:
-----------------------------------------------------------------------------}

unit CustomImage;

interface

uses Classes, Windows;

type
  TImageType = (ITAudioImage, IT9660Image, ITDVDVideoImage, ITISOFileImage, ITBinCueImage);

type
  TCustomImage = class
  private
    FImageType: TImageType;
  published
    property ImageType: TImageType read FImageType write FImageType;
  end;

implementation

end.
