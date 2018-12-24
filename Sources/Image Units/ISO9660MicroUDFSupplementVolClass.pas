{-----------------------------------------------------------------------------
 Unit Name: ISO9660MicroUDFSupplementVolClass
 Author:    Dancemammal, Daniel Mann / Thomas Koos (original class structure)
 Purpose:   Supplementary Volume Descriptor Class
 History:   First Code Release
-----------------------------------------------------------------------------}

Unit ISO9660MicroUDFSupplementVolClass;

Interface

Uses
  SysUtils,
  windows,
  Classes,
  CovertFuncs,
  ISO9660MicroUDFClassTypes;



Type
  TSupplementaryVolumeDescriptor = Class
  Private
    Function  GetString(Const AIndex : Integer): String;
    Procedure SetString(const AIndex : Integer; Const Value: String);
    Procedure SetVolumeIdentifier(Const Value: String);
    Function  GetVolumeIdentifier : String;
    Function  Getwide(ID : Array of Char) : String;
  Protected
    FDescriptor : TVolumeDescriptor;
    FRootDirectoryRecord : TRootDirectoryRecord;
    LastErrorString : String;
  Public
    Constructor Create; Overload; Virtual;
    Constructor Create(Const ASupplementaryVolumeDescriptor : TVolumeDescriptor); Overload; Virtual;
    Destructor  Destroy; Override;
    Procedure ResetRootExtent(SUPPRootLBA : Integer);
    Function GetLastError : String;
  Published
    Property  Descriptor : TVolumeDescriptor  Read  fDescriptor;
    Property  SystemIdentifier            : String   Index 0  Read  GetString Write SetString;
    Property  VolumeIdentifier            : String            Read  GetVolumeIdentifier Write SetVolumeIdentifier;
    Property  VolumeSetIdentifier         : String   Index 2  Read  GetString Write SetString;
    Property  PublisherIdentifier         : String   Index 3  Read  GetString Write SetString;
    Property  DataPreparerIdentifier      : String   Index 4  Read  GetString Write SetString;
    Property  ApplicationIdentifier       : String   Index 5  Read  GetString Write SetString;
    Property  CopyrightFileIdentifier     : String   Index 6  Read  GetString Write SetString;
    Property  AbstractFileIdentifier      : String   Index 7  Read  GetString Write SetString;
    Property  BibliographicFileIdentifier : String   Index 8  Read  GetString Write SetString;
    Property  VolumeCreationDateAndTime   : TVolumeDateTime   Read  fDescriptor.Supplementary.VolumeCreationDateAndTime
                                                              Write fDescriptor.Supplementary.VolumeCreationDateAndTime;
    Property  VolumeModificationDateAndTime : TVolumeDateTime
                                                              Read  fDescriptor.Supplementary.VolumeModificationDateAndTime
                                                              Write fDescriptor.Supplementary.VolumeModificationDateAndTime;
    Property  VolumeExpirationDateAndTime : TVolumeDateTime   Read  fDescriptor.Supplementary.VolumeExpirationDateAndTime
                                                              Write fDescriptor.Supplementary.VolumeExpirationDateAndTime;
    Property  VolumeEffectiveDateAndTime  : TVolumeDateTime   Read  fDescriptor.Supplementary.VolumeEffectiveDateAndTime
                                                              Write fDescriptor.Supplementary.VolumeEffectiveDateAndTime;
    Property  VolumeSetSize               : TBothEndianWord   Read  fDescriptor.Supplementary.VolumeSetSize
                                                              Write fDescriptor.Supplementary.VolumeSetSize;
    Property  VolumeSequenceNumber        : TBothEndianWord   Read  fDescriptor.Supplementary.VolumeSequenceNumber
                                                              Write fDescriptor.Supplementary.VolumeSequenceNumber;
    Property  LogicalBlockSize            : TBothEndianWord   Read  fDescriptor.Supplementary.LogicalBlockSize
                                                              Write fDescriptor.Supplementary.LogicalBlockSize;
    Property  PathTableSize               : TBothEndianDWord  Read  fDescriptor.Supplementary.PathTableSize
                                                              Write fDescriptor.Supplementary.PathTableSize;
    Property  VolumeSpaceSize             : TBothEndianDWord  Read  fDescriptor.Supplementary.VolumeSpaceSize
                                                              Write fDescriptor.Supplementary.VolumeSpaceSize;

    Property  RootDirectory               : TRootDirectoryRecord
                                                              Read  fDescriptor.Supplementary.RootDirectory
                                                              Write fDescriptor.Supplementary.RootDirectory;

    Property  LocationOfTypeLPathTable    : LongWord          Read  fDescriptor.Supplementary.LocationOfTypeLPathTable
                                                              Write fDescriptor.Supplementary.LocationOfTypeLPathTable;
    Property  LocationOfOptionalTypeLPathTable : LongWord     Read  fDescriptor.Supplementary.LocationOfOptionalTypeLPathTable
                                                              Write fDescriptor.Supplementary.LocationOfOptionalTypeLPathTable;
    Property  LocationOfTypeMPathTable    : LongWord          Read  fDescriptor.Supplementary.LocationOfTypeMPathTable
                                                              Write fDescriptor.Supplementary.LocationOfTypeMPathTable;
    Property  LocationOfOptionalTypeMPathTable : LongWord     Read  fDescriptor.Supplementary.LocationOfOptionalTypeMPathTable
                                                              Write fDescriptor.Supplementary.LocationOfOptionalTypeMPathTable;
    Property  VolumeFlags                      : Byte         Read  fDescriptor.Supplementary.VolumeFlags
                                                              Write fDescriptor.Supplementary.VolumeFlags;
  End;




Implementation




Constructor TSupplementaryVolumeDescriptor.Create; // New Widestring Functions
var
     Temp : String;
     WideChr : PWideChar;
Begin
  Inherited Create;
  FillChar(fDescriptor, SizeOf(fDescriptor), 0);
  fDescriptor.DescriptorType := vdtSVD;
  WideChr := 'WIN32';
  FillChar(FDescriptor.Supplementary.SystemIdentifier,32,0);
  CopyMemory(@FDescriptor.Supplementary.SystemIdentifier[1],@WideChr[0],(length('WIN32')*2)-1);//makes it big endian wide char
  FDescriptor.Supplementary.StandardIdentifier      := ISO_STANDARD_ID;
  FDescriptor.Supplementary.VolumeDescriptorVersion := 1;
  FDescriptor.Supplementary.VolumeSetSize           := BuildBothEndianWord(1);
  FDescriptor.Supplementary.FileStructureVersion    := $01;
  FillChar(FDescriptor.Supplementary.PublisherIdentifier,length(FDescriptor.Supplementary.PublisherIdentifier),$20);
  FillChar(FDescriptor.Supplementary.DataPreparerIdentifier,length(FDescriptor.Supplementary.DataPreparerIdentifier),$20);
  FillChar(FDescriptor.Supplementary.PublisherIdentifier,length(FDescriptor.Supplementary.PublisherIdentifier),$20);
  FillChar(FDescriptor.Supplementary.VolumeSetIdentifier,length(FDescriptor.Supplementary.VolumeSetIdentifier),$20);
  FDescriptor.Supplementary.VolumeCreationDateAndTime := BuildVolumeDateTime(NOW,0);
  FDescriptor.Supplementary.VolumeModificationDateAndTime := BuildVolumeDateTime(NOW,0);
  FDescriptor.Supplementary.LogicalBlockSize              := BuildBothEndianWord(2048);
  FDescriptor.Supplementary.VolumeSequenceNumber          := BuildBothEndianWord(1);
  FDescriptor.Supplementary.LocationOfTypeLPathTable      := 21;
  FDescriptor.Supplementary.LocationOfOptionalTypeLPathTable := 0;
  FDescriptor.Supplementary.LocationOfTypeMPathTable      := SwapDWord(22);
  FDescriptor.Supplementary.LocationOfOptionalTypeMPathTable := 0;
  FillChar(FDescriptor.Supplementary.EscapeSequences,32,0);

  FDescriptor.Supplementary.EscapeSequences[0] := '%';
  FDescriptor.Supplementary.EscapeSequences[1] := '/';
  FDescriptor.Supplementary.EscapeSequences[2] := 'E';

  Temp := FormatDateTime('yyyymmddhhnnsszz',Now);
  WideChr := pwidechar(Temp);
  FillChar(FDescriptor.Supplementary.VolumeIdentifier,32,0);
  CopyMemory(@FDescriptor.Supplementary.VolumeIdentifier[1],@WideChr[0],(length(Temp)*2)-1);//makes it big endian wide char

  WideChr := StrToUnicode(ISO_LIBRARY_ID);
  FillChar(FDescriptor.Supplementary.ApplicationIdentifier,128,0);
  CopyMemory(@FDescriptor.Supplementary.ApplicationIdentifier[1],@WideChr[0],(length(ISO_LIBRARY_ID)*2)-1);//makes it big endian wide char
End;



Procedure TSupplementaryVolumeDescriptor.ResetRootExtent(SUPPRootLBA : Integer);
begin
    FDescriptor.Supplementary.RootDirectory.LocationOfExtent := BuildBothEndianDWord(SUPPRootLBA);
end;



Constructor TSupplementaryVolumeDescriptor.Create(Const ASupplementaryVolumeDescriptor: TVolumeDescriptor);
Begin
  Inherited Create;
  If ( ASupplementaryVolumeDescriptor.DescriptorType <> vdtSVD ) Then
    LastErrorString :=('MisMatched Primary Volume Descriptor');
  fDescriptor := ASupplementaryVolumeDescriptor;
End;



Destructor TSupplementaryVolumeDescriptor.Destroy;
Begin
  Inherited;
End;


Function TSupplementaryVolumeDescriptor.GetLastError : String;
begin
    Result := LastErrorString;
end;


Function TSupplementaryVolumeDescriptor.Getwide(ID : Array of Char) : String;
var
  TempStr : String;
  Index : Integer;
begin
   For Index := 0 to length(id) do
   TempStr := TempStr + id[index];
   Result := TempStr;
end;



Function TSupplementaryVolumeDescriptor.GetString(Const AIndex: Integer): String;
Begin
  Case AIndex Of
    0 : Result := Getwide(fDescriptor.Supplementary.SystemIdentifier);
    1 : Result := Getwide(fDescriptor.Supplementary.VolumeIdentifier);
    2 : Result := Getwide(fDescriptor.Supplementary.VolumeSetIdentifier);
    3 : Result := Getwide(fDescriptor.Supplementary.PublisherIdentifier);
    4 : Result := Getwide(fDescriptor.Supplementary.DataPreparerIdentifier);
    5 : Result := Getwide(fDescriptor.Supplementary.ApplicationIdentifier);
    6 : Result := Getwide(fDescriptor.Supplementary.CopyrightFileIdentifier);
    7 : Result := Getwide(fDescriptor.Supplementary.AbstractFileIdentifier);
    8 : Result := Getwide(fDescriptor.Supplementary.BibliographicFileIdentifier);
    9 : Result := Getwide(fDescriptor.Supplementary.StandardIdentifier);
  End;
End;



Procedure TSupplementaryVolumeDescriptor.SetVolumeIdentifier(Const Value: String);
var
     WideChr : PWideChar;
     Temp : String;
     Size : Integer;
begin
   Temp := Value;
   Size := (length(temp)+1)*2;
   WideChr := PWideChar(StrAlloc(Size));//important
   StringToWideChar(temp,WideChr,Size + 1);
   FillChar(fDescriptor.Supplementary.VolumeIdentifier,32,0);
   CopyMemory(@fDescriptor.Supplementary.VolumeIdentifier[1],@WideChr[0],(length(Temp)*2)-1);//makes it big endian wide char
end;



Function TSupplementaryVolumeDescriptor.GetVolumeIdentifier : String;
var
  TempStr : String;
begin
   TempStr := Getwide(fDescriptor.Supplementary.VolumeIdentifier);
   Result := TempStr;
end;



Procedure TSupplementaryVolumeDescriptor.SetString(Const AIndex: Integer; Const Value: String);
Begin
  Case AIndex Of
    0 : StrPCopy(fDescriptor.Supplementary.SystemIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.SystemIdentifier)));
    1 : StrPCopy(fDescriptor.Supplementary.VolumeIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.VolumeIdentifier)));
    2 : StrPCopy(fDescriptor.Supplementary.VolumeSetIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.VolumeSetIdentifier)));
    3 : StrPCopy(fDescriptor.Supplementary.PublisherIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.PublisherIdentifier)));
    4 : StrPCopy(fDescriptor.Supplementary.DataPreparerIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.DataPreparerIdentifier)));
    5 : StrPCopy(fDescriptor.Supplementary.ApplicationIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.ApplicationIdentifier)));
    6 : StrPCopy(fDescriptor.Supplementary.CopyrightFileIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.CopyrightFileIdentifier)));
    7 : StrPCopy(fDescriptor.Supplementary.AbstractFileIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.AbstractFileIdentifier)));
    8 : StrPCopy(fDescriptor.Supplementary.BibliographicFileIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.BibliographicFileIdentifier)));
    9 : StrPCopy(fDescriptor.Supplementary.StandardIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Supplementary.StandardIdentifier)));
  End;
End;

End.


