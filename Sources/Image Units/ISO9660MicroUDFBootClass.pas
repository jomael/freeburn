{-----------------------------------------------------------------------------
 Unit Name: ISO9660MicroUDFBootClass
 Author:    Paul Fisher , Daniel Mann / Thomas Koos (original class structure)
 Purpose:   Class for Bootrecord volume descriptor
 History:   First Code Release
-----------------------------------------------------------------------------}


Unit ISO9660MicroUDFBootClass;

Interface

Uses
  SysUtils,
  Classes,
  ISO9660MicroUDFClassTypes;




   


Type
  TBootRecordVolumeDescriptor = Class
  Private
  Protected
    FDescriptor : TVolumeDescriptor;
    LastErrorString : String;
    Function  GetString(Const AIndex : Integer): String;
    Procedure SetString(const AIndex : Integer; Const Value: String);
  Public
    Constructor Create; Overload; Virtual;
    Constructor Create(Const ABootRecordVolumeDescriptor : TVolumeDescriptor); Overload; Virtual;
    Destructor  Destroy; Override;
    Function GetLastError : String;
  Published
    Property  Descriptor : TVolumeDescriptor  Read  FDescriptor;
    Property  BootSystemIdentifier        : String   Index 0  Read  GetString
                                                              Write SetString;
    Property  BootIdentifier              : String   Index 1  Read  GetString
                                                              Write SetString;
    Property  BootCatalogPointer      : LongWord    Read  FDescriptor.BootRecord.BootCatalogPointer
                                                    Write FDescriptor.BootRecord.BootCatalogPointer;
  End;




Implementation

Uses
    CovertFuncs;



Constructor TBootRecordVolumeDescriptor.Create;
Begin
  Inherited Create;
  FillChar(fDescriptor, SizeOf(fDescriptor), 0);
  fDescriptor.DescriptorType := vdtBR;
  fDescriptor.BootRecord.StandardIdentifier := ISO_STANDARD_ID;
  fDescriptor.BootRecord.VersionOfDescriptor := 1;
End;


Constructor TBootRecordVolumeDescriptor.Create(Const ABootRecordVolumeDescriptor: TVolumeDescriptor);
Begin
  Inherited Create;
  If ( ABootRecordVolumeDescriptor.DescriptorType <> vdtBR ) Then
    LastErrorString := ('MisMatched Boot record Descriptor');
  fDescriptor := ABootRecordVolumeDescriptor;
End;


Destructor TBootRecordVolumeDescriptor.Destroy;
Begin
  Inherited;
End;


Function TBootRecordVolumeDescriptor.GetLastError : String;
begin
    Result := LastErrorString;
end;


Function TBootRecordVolumeDescriptor.GetString(Const AIndex: Integer): String;
Begin
  Case AIndex Of
    0 : Result := fDescriptor.BootRecord.BootSystemIdentifier;
    1 : Result := fDescriptor.BootRecord.BootIdentifier;
  End;
End;

Procedure TBootRecordVolumeDescriptor.SetString(Const AIndex: Integer; Const Value: String);
Begin
  Case AIndex Of
    0 : StrPCopy(fDescriptor.BootRecord.BootSystemIdentifier,
                  Copy(Value, 1, Length(fDescriptor.BootRecord.BootSystemIdentifier)));
    1 : StrPCopy(fDescriptor.BootRecord.BootIdentifier,
                  Copy(Value, 1, Length(fDescriptor.BootRecord.BootIdentifier)));
  End;
End;


End.


