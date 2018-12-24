{-----------------------------------------------------------------------------
 Unit Name: ISO9660PrimaryVolClass
 Author:    Dancemammal, Daniel Mann / Thomas Koos (original class structure)
 Purpose:  Primary Volume Descriptor Class
 History:  First Code Release
-----------------------------------------------------------------------------}


Unit ISO9660PrimaryVolClass;

Interface

Uses
  SysUtils,
  Classes,
  CovertFuncs,
  ISO9660ClassTypes;


Type
  TPrimaryVolumeDescriptor = Class
  Private
    Function  GetString(Const AIndex : Integer): String;
    Procedure SetString(const AIndex : Integer; Const Value: String);
  Protected
    FDescriptor : TVolumeDescriptor;
    LastErrorString : String;
  Public
    Constructor Create; Overload; Virtual;
    Constructor Create(Const APrimaryVolumeDescriptor : TVolumeDescriptor); Overload; Virtual;
    Destructor  Destroy; Override;
    Function GetLastError : String;
  Published
    Property  Descriptor : TVolumeDescriptor  Read  fDescriptor;
    Property  SystemIdentifier            : String   Index 0  Read  GetString Write SetString;
    Property  VolumeIdentifier            : String   Index 1  Read  GetString Write SetString;
    Property  VolumeSetIdentifier         : String   Index 2  Read  GetString Write SetString;
    Property  PublisherIdentifier         : String   Index 3  Read  GetString Write SetString;
    Property  DataPreparerIdentifier      : String   Index 4  Read  GetString Write SetString;
    Property  ApplicationIdentifier       : String   Index 5  Read  GetString Write SetString;
    Property  CopyrightFileIdentifier     : String   Index 6  Read  GetString Write SetString;
    Property  AbstractFileIdentifier      : String   Index 7  Read  GetString Write SetString;
    Property  BibliographicFileIdentifier : String   Index 8  Read  GetString Write SetString;
    Property  VolumeCreationDateAndTime   : TVolumeDateTime   Read  fDescriptor.Primary.VolumeCreationDateAndTime
                                                              Write fDescriptor.Primary.VolumeCreationDateAndTime;
    Property  VolumeModificationDateAndTime : TVolumeDateTime
                                                              Read  fDescriptor.Primary.VolumeModificationDateAndTime
                                                              Write fDescriptor.Primary.VolumeModificationDateAndTime;
    Property  VolumeExpirationDateAndTime : TVolumeDateTime   Read  fDescriptor.Primary.VolumeExpirationDateAndTime
                                                              Write fDescriptor.Primary.VolumeExpirationDateAndTime;
    Property  VolumeEffectiveDateAndTime  : TVolumeDateTime   Read  fDescriptor.Primary.VolumeEffectiveDateAndTime
                                                              Write fDescriptor.Primary.VolumeEffectiveDateAndTime;
    Property  VolumeSetSize               : TBothEndianWord   Read  fDescriptor.Primary.VolumeSetSize
                                                              Write fDescriptor.Primary.VolumeSetSize;
    Property  VolumeSequenceNumber        : TBothEndianWord   Read  fDescriptor.Primary.VolumeSequenceNumber
                                                              Write fDescriptor.Primary.VolumeSequenceNumber;
    Property  LogicalBlockSize            : TBothEndianWord   Read  fDescriptor.Primary.LogicalBlockSize
                                                              Write fDescriptor.Primary.LogicalBlockSize;
    Property  PathTableSize               : TBothEndianDWord  Read  fDescriptor.Primary.PathTableSize
                                                              Write fDescriptor.Primary.PathTableSize;
    Property  VolumeSpaceSize             : TBothEndianDWord  Read  fDescriptor.Primary.VolumeSpaceSize
                                                              Write fDescriptor.Primary.VolumeSpaceSize;
                                                              
    Property  RootDirectory               : TRootDirectoryRecord
                                                              Read  fDescriptor.Primary.RootDirectory
                                                              Write fDescriptor.Primary.RootDirectory;

    Property  LocationOfTypeLPathTable    : LongWord          Read  fDescriptor.Primary.LocationOfTypeLPathTable
                                                              Write fDescriptor.Primary.LocationOfTypeLPathTable;
    Property  LocationOfOptionalTypeLPathTable : LongWord     Read  fDescriptor.Primary.LocationOfOptionalTypeLPathTable
                                                              Write fDescriptor.Primary.LocationOfOptionalTypeLPathTable;
    Property  LocationOfTypeMPathTable    : LongWord          Read  fDescriptor.Primary.LocationOfTypeMPathTable
                                                              Write fDescriptor.Primary.LocationOfTypeMPathTable;
    Property  LocationOfOptionalTypeMPathTable : LongWord     Read  fDescriptor.Primary.LocationOfOptionalTypeMPathTable
                                                              Write fDescriptor.Primary.LocationOfOptionalTypeMPathTable;
  End;



Implementation





Constructor TPrimaryVolumeDescriptor.Create;
Begin
  Inherited Create;
  FillChar(FDescriptor, SizeOf(FDescriptor), 0);
  FDescriptor.DescriptorType := vdtPVD;
  FDescriptor.Primary.SystemIdentifier        := ISO_SYSTEM_ID;
  FDescriptor.Primary.StandardIdentifier      := ISO_STANDARD_ID;
  FDescriptor.Primary.VolumeDescriptorVersion := 1;
  FDescriptor.Primary.VolumeSetSize           := BuildBothEndianWord(1);
  FDescriptor.Primary.ApplicationIdentifier   := ISO_LIBRARY_ID;
  FillChar(FDescriptor.Primary.PublisherIdentifier,length(FDescriptor.Primary.PublisherIdentifier),$20);
  FillChar(FDescriptor.Primary.DataPreparerIdentifier,length(FDescriptor.Primary.DataPreparerIdentifier),$20);
  FillChar(FDescriptor.Primary.PublisherIdentifier,length(FDescriptor.Primary.PublisherIdentifier),$20);
  FillChar(FDescriptor.Primary.VolumeSetIdentifier,length(FDescriptor.Primary.VolumeSetIdentifier),$20);
  FDescriptor.Primary.FileStructureVersion    := $01;
  FDescriptor.Primary.VolumeCreationDateAndTime := BuildVolumeDateTime(NOW,0);
  FDescriptor.Primary.VolumeModificationDateAndTime := BuildVolumeDateTime(NOW,0);
  FDescriptor.Primary.LogicalBlockSize              := BuildBothEndianWord(2048);
  FDescriptor.Primary.VolumeSequenceNumber          := BuildBothEndianWord(1);
  FDescriptor.Primary.VolumeSetSize                 := BuildBothEndianWord(1);
  FDescriptor.Primary.LocationOfTypeLPathTable      := 19;
  FDescriptor.Primary.LocationOfOptionalTypeLPathTable := 0;
  FDescriptor.Primary.LocationOfTypeMPathTable      := SwapDWord(20);
  FDescriptor.Primary.LocationOfOptionalTypeMPathTable := 0;
  FillChar(FDescriptor.Primary.EscapeSequences,32,0);

  FDescriptor.Primary.EscapeSequences[0] := '%';
  FDescriptor.Primary.EscapeSequences[1] := '/';
  FDescriptor.Primary.EscapeSequences[2] := 'E';
End;




Constructor TPrimaryVolumeDescriptor.Create(Const APrimaryVolumeDescriptor: TVolumeDescriptor);
Begin
  Inherited Create;
  If ( APrimaryVolumeDescriptor.DescriptorType <> vdtPVD ) Then
    LastErrorString := ('MisMatched Primary Volume Descriptor');
  fDescriptor := APrimaryVolumeDescriptor;
End;


Destructor TPrimaryVolumeDescriptor.Destroy;
Begin
  Inherited Destroy;
End;


Function TPrimaryVolumeDescriptor.GetLastError : String;
begin
    Result := LastErrorString;
end;


Function TPrimaryVolumeDescriptor.GetString(Const AIndex : Integer): String;
Begin
  Case AIndex Of
    0 : Result := fDescriptor.Primary.SystemIdentifier;
    1 : Result := fDescriptor.Primary.VolumeIdentifier;
    2 : Result := fDescriptor.Primary.VolumeSetIdentifier;
    3 : Result := fDescriptor.Primary.PublisherIdentifier;
    4 : Result := fDescriptor.Primary.DataPreparerIdentifier;
    5 : Result := fDescriptor.Primary.ApplicationIdentifier;
    6 : Result := fDescriptor.Primary.CopyrightFileIdentifier;
    7 : Result := fDescriptor.Primary.AbstractFileIdentifier;
    8 : Result := fDescriptor.Primary.BibliographicFileIdentifier;
  End;
End;



Procedure TPrimaryVolumeDescriptor.SetString(Const AIndex: Integer; Const Value: String);
Begin

  Case AIndex Of
    0 : StrPCopy(fDescriptor.Primary.SystemIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Primary.SystemIdentifier)));
    1 : StrPCopy(fDescriptor.Primary.VolumeIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Primary.VolumeIdentifier)));
    2 : StrPCopy(fDescriptor.Primary.VolumeSetIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Primary.VolumeSetIdentifier)));
    3 : StrPCopy(fDescriptor.Primary.PublisherIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Primary.PublisherIdentifier)));
    4 : StrPCopy(fDescriptor.Primary.DataPreparerIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Primary.DataPreparerIdentifier)));
    5 : StrPCopy(fDescriptor.Primary.ApplicationIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Primary.ApplicationIdentifier)));
    6 : StrPCopy(fDescriptor.Primary.CopyrightFileIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Primary.CopyrightFileIdentifier)));
    7 : StrPCopy(fDescriptor.Primary.AbstractFileIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Primary.AbstractFileIdentifier)));
    8 : StrPCopy(fDescriptor.Primary.BibliographicFileIdentifier,
                  Copy(Value, 1, Length(fDescriptor.Primary.BibliographicFileIdentifier)));
  End;
End;


End.


