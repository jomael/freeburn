{-----------------------------------------------------------------------------
 Unit Name: ISO9660StreamHandler
 Author:    Daniel Mann / Thomas Koos (original class) Dancemammal
 Purpose:   Image File Handler
 History:   Code originally from Daniel Mann / Thomas Koos


-----------------------------------------------------------------------------}


Unit ISO9660StreamHandler;

Interface

Uses
  Classes,CDBufferedStream;

Type
  TISOBookFormat = (ybfAuto, ybfMode1, ybfMode2);
  TISOImageFormat = (ifAuto, ifCompleteSectors, ifOnlyData);

  TImageStreamHandler = Class
  Private
    fISOBookFormat    : TISOBookFormat;
    fImageFormat      : TISOImageFormat;
    fImageOffset      : Cardinal; // e.g. used by Nero Images
    fFileStream       : TCDBufferedStream;
    fCurrentSector    : Cardinal;
    FLastErrorString  : String;
  Protected
    Procedure    DetectImageType; Virtual;
    Function     CalcSectorOffset(Const ASector : Cardinal): Integer; Virtual;
    Function     CalcUserDataOffset: Integer; Virtual;
    Function     GetSectorDataSize: Cardinal; Virtual;
  Public
    Constructor  Create(Const AFileName : String; Const AImageFormat : TISOImageFormat); Overload; Virtual;
    Constructor  Create(Const ANewFileName : String; Const ABookFormat : TISOBookFormat; Const AImageFormat : TISOImageFormat); Overload; Virtual;
    Destructor   Destroy; Override;
    Function     SeekSector(Const ASector : Cardinal; Const AGrow : Boolean = True): Boolean; Virtual;
    Function     ReadSector_Data(Var ABuffer; Const ABufferSize : Integer = -1): Boolean; Virtual;
    Function     ReadSector_Raw (Var ABuffer; Const ABufferSize : Integer = -1): Boolean; Virtual;
    Function     GetLastError : String;
  Published
    Property     ISOBookFormat    : TISOBookFormat         Read  fISOBookFormat;
    Property     ImageFormat      : TISOImageFormat        Read  fImageFormat;
    Property     ImageOffset      : Cardinal               Read  fImageOffset;
    Property     SectorDataSize   : Cardinal               Read  GetSectorDataSize;
    Property     CurrentSector    : Cardinal               Read  fCurrentSector;
    Property     Stream           : TCDBufferedStream      Read  fFileStream;
  End;


Implementation

Uses
  SysUtils; // for FileExists()


Function TImageStreamHandler.GetLastError : String;
begin
   Result := FLastErrorString;
end;


Constructor TImageStreamHandler.Create(Const AFileName: String; Const AImageFormat: TISOImageFormat);
Begin
  Inherited Create;
  If ( Not FileExists(AFileName) ) Then
  begin
     FLastErrorString := 'ISO Image file not found, Creating';
     exit;
  end
  else
  fFileStream := TCDBufferedStream.Create(AFileName,fmOpenRead);
  DetectImageType;
  SeekSector(fCurrentSector);
End;



Constructor TImageStreamHandler.Create(Const ANewFileName : String; Const ABookFormat: TISOBookFormat; Const AImageFormat: TISOImageFormat);
Begin
  Inherited Create;
  If ( ABookFormat = ybfAuto ) Then FLastErrorString := 'ISO Image book format has to be defined!';
  If ( AImageFormat = ifAuto ) Then FLastErrorString := 'Image format has to be defined!';
  fISOBookFormat     := ABookFormat;
  FImageFormat       := AImageFormat;
  FImageOffset       := 0;
  fFileStream := TCDBufferedStream.Create(ANewFileName,fmCreate);
  SeekSector(fCurrentSector);
End;


Destructor TImageStreamHandler.Destroy;
Begin
  If ( Assigned(fFileStream) ) Then FreeAndNil(fFileStream);
  Inherited;
End;

Function TImageStreamHandler.CalcUserDataOffset: Integer;
Begin
  Result := 0;
  Case fImageFormat Of
    ifCompleteSectors  : Result := 16; // 12 bytes SYNC, 4 byte Header
    ifOnlyData         : Result := 0;
    ifAuto             : FLastErrorString := 'can not calculate sector offset with auto values!';
  Else
    FLastErrorString := 'TImageStreamHandler.CalcUserDataOffset(): Implementation error!';
  End;
End;



Function TImageStreamHandler.CalcSectorOffset(Const ASector: Cardinal): Integer;
Begin
  Result := 0;
  Case fImageFormat Of
    ifCompleteSectors : Result := fImageOffset + ASector * 2352;
    ifOnlyData        :
      Begin
        Case fISOBookFormat Of
          ybfMode1 : Result := fImageOffset + ASector * 2048;
          ybfMode2 : Result := fImageOffset + ASector * 2336;
          ybfAuto  : FLastErrorString := ('can not calculate sector with auto settings');
        Else
          FLastErrorString := ('TImageStreamHandler.CalcSectorOffset(): Implementation error!');
        End;
      End;
    ifAuto : FLastErrorString := ('can not calculate sector with auto settings');
  Else
    FLastErrorString := ('TImageStreamHandler.CalcSectorOffset(): Implementation error!');
  End;
End;



Procedure TImageStreamHandler.DetectImageType;
Type
  TCheckBuf = Packed Record
    DeskID : Byte;
    StdID  : Array[0..4] Of Char;
  End;

  TRawCheckBuf = Packed Record
    SYNC   : Array[0..11] of Byte;
    Header_SectMin,
    Header_SectSec,
    Header_SectNo,
    Header_Mode    : Byte;
    Deskriptor : TCheckBuf;
  End;

Var
  Buff    : TCheckBuf;
  RawBuff : TRawCheckBuf;
  Tries   : Boolean;
Begin
  fISOBookFormat := ybfAuto;
  fImageFormat      := ifAuto;
  fImageOffset      := 0;

  If ( Assigned(fFileStream) ) And ( fFileStream.Size > 16*2048 ) Then
  Begin
    For Tries := False To True Do
    Begin
      If ( Tries ) Then // ok, 2nd run, last try: nero .nrg image file
        fImageOffset := 307200;


    // fFileStream.Position := fImageOffset + 16 * 2048;
    // fFileStream.ReadBuffer(Buff, SizeOf(Buff));
    fFileStream.Seek(fImageOffset + 16 * 2048,soFromBeginning);
      fFileStream.ReadBuffer(Buff, SizeOf(Buff));
      If ( String(Buff.StdID) = 'CD001' ) Then
      Begin
        fImageFormat      := ifOnlyData;
        fISOBookFormat    := ybfMode1;
        Break;
      End;

     // fFileStream.Position := fImageOffset + 16 * 2336;
      fFileStream.Seek(fImageOffset + 16 * 2336,soFromBeginning);
      fFileStream.ReadBuffer(Buff, SizeOf(Buff));

      If ( String(Buff.StdID) = 'CD001' ) Then
      Begin
        fImageFormat      := ifOnlyData;
        fISOBookFormat    := ybfMode2;
        Break;
      End;

      //fFileStream.Position := fImageOffset + 16 * 2352;
      fFileStream.Seek(fImageOffset + 16 * 2352,soFromBeginning);
      fFileStream.ReadBuffer(RawBuff, SizeOf(RawBuff));

      If ( String(RawBuff.Deskriptor.StdID) = 'CD001' ) Then
      Begin
        fImageFormat := ifCompleteSectors;
        If ( RawBuff.Header_Mode = 1 ) Then
             fISOBookFormat    := ybfMode1
        Else If ( RawBuff.Header_Mode = 2 ) Then
             fISOBookFormat    := ybfMode2
        Else
          FLastErrorString := ('Unknown ISO Book mode!');
        Break;
      End;
    End;
  End;

  If ( fImageFormat = ifAuto ) Or ( fISOBookFormat = ybfAuto ) Then
    FLastErrorString := ('Unkown Image Format!');
End;



Function TImageStreamHandler.SeekSector(Const ASector: Cardinal; Const AGrow: Boolean): Boolean;
Var
  lFPos : Integer;
Begin
  Result := False;
  If ( Assigned(fFileStream) ) Then
  Begin
    lFPos := CalcSectorOffset(ASector);
    If ( (lFPos + 2048) > fFileStream.Size ) And ( Not AGrow ) Then
      Exit;

    //fFileStream.Position := lFPos;
    fFileStream.Seek(lFPos,soFromBeginning);
    fCurrentSector := ASector;
  End;
End;



Function TImageStreamHandler.ReadSector_Data(Var ABuffer; Const ABufferSize : Integer = -1): Boolean;
Var
  lDataOffset : Integer;
Begin
  Result := False;
  If ( Assigned(FFileStream) ) Then
  Begin
    lDataOffset := CalcUserDataOffset;
    fFileStream.Seek(lDataOffset, soFromCurrent);
    If ( ABufferSize > -1 ) And ( Cardinal(ABufferSize) < GetSectorDataSize ) Then
         FLastErrorString := ('ReadSector_Data(): buffer overflow protection');
    fFileStream.ReadBuffer(ABuffer, GetSectorDataSize);
    SeekSector(fCurrentSector+1);
    Result := True;
  End;
End;




Function TImageStreamHandler.ReadSector_Raw(Var ABuffer; Const ABufferSize : Integer = -1): Boolean;
Begin
  Result := False;

  If ( Assigned(FFileStream) ) Then
  Begin
    If ( ABufferSize > -1 ) And ( ABufferSize < 2352 ) Then
      FLastErrorString := ('ReadSector_Raw(): buffer overflow protection');
    FFileStream.ReadBuffer(ABuffer, 2352);
    Result := True;
  End;
End;



Function TImageStreamHandler.GetSectorDataSize: Cardinal;
Begin
  Result := 0;
  Case fISOBookFormat Of
    ybfMode1 : Result := 2048;
    ybfMode2 : Result := 2336;
  Else
    FLastErrorString := ('can not figure out sector data size on auto type');
  End;
End;


End.

