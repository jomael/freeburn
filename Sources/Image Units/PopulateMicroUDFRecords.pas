{-----------------------------------------------------------------------------
 Unit Name: PopulateMicroUDFRecords
 Author:    Dancemammal
 Purpose:   Help Setup default UDf Records
 History:
-----------------------------------------------------------------------------}


unit PopulateMicroUDFRecords;

interface

Uses MicroUDFClassTypes,MicroUDFConsts, Windows, Covertfuncs, Messages, SysUtils, Classes;


Procedure PopulateUDFPrimaryVolumeDescriptor(VAR UDF_PVD : UDF_PrimaryVolumeDescriptor; Sector : Integer ; VolumeName : string);
Procedure PopulateUDFImplementationUseVolumeDescriptor(VAR UDF_IUVD : UDF_ImplementationUseVolumeDescriptor; Sector : Integer ; VolumeName : string);
Procedure PopulateUDFPartitionDescriptor(VAR UDF_PD : UDF_PartitionDescriptor; Sector : Integer ; VolumeName : string);
Procedure PopulateUDFlogicalVolDesc(VAR UDF_LVD : UDF_logicalVolDesc; Sector : Integer ; VolumeName : string);
Procedure PopulateUDFUnallocSpaceDesc(VAR UDF_USD : UDF_UnallocSpaceDesc; Sector : Integer ; VolumeName : string);
Procedure PopulateUDFTerminatingDesc(VAR UDF_TD : UDF_TerminatingDesc; Sector : Integer ; VolumeName : string);
Procedure PopulateUDFAnchorVolumeDescriptorPointer(VAR UDF_ADVP : UDF_AnchorVolumeDescriptorPointer; Sector : Integer ; VolumeName : string);
Procedure PopulateUDFlogicalVolumeIntegrityDesc(VAR UDF_LVID : UDF_logicalVolumeIntegrityDesc; Sector : Integer ; NumOfFiles,NumOfDirs : Integer);
Procedure PopulateUDFFileSetDescriptor(VAR UDF_FSD : UDF_FileSetDescriptor; Sector : Integer ; VolumeName : string);


implementation


Procedure FillRandomChar(VAR MyArray : Array of Char);
var
Index : integer;
begin
  Randomize;
  For Index := 0 to 15 do
     MyArray[Index] := Char(Random(26) + 65);
end;


Procedure BuildVolumeDateTime(var TimeStmp : UDF_TimeStamp);
var
  Timezone, Year : Word;
  Hour, Min, Sec, MSec,Month, Day: word;
begin
  DecodeTime(Now, Hour, Min, Sec, MSec);
  DecodeDate(Now, Year, Month, Day);
  TimeStmp.TypeAndTimezone := $0010;
  TimeStmp.Year := Year;
  TimeStmp.Month := Month;
  TimeStmp.Day := Day;
  TimeStmp.Hour := Hour;
  TimeStmp.Minute := Min;
  TimeStmp.Second := Sec;
  TimeStmp.Centiseconds := MSec div 10;
  TimeStmp.HundredsOfMicroseconds := MSec div 100;
  TimeStmp.Microseconds := MSec;
end;




{Sector 32 plus repeated at sector 48}
Procedure PopulateUDFPrimaryVolumeDescriptor(VAR UDF_PVD : UDF_PrimaryVolumeDescriptor; Sector : Integer ; VolumeName : string);
begin
  FillChar(UDF_PVD, SizeOf(UDF_PVD), Char(0)); // empty record
  UDF_PVD.DescriptorTag.TagIdentifier       := TAG_IDENT_PVD;
  UDF_PVD.DescriptorTag.DescriptorVersion   := TAG_DESCRIPTOR_VERSION;
  UDF_PVD.DescriptorTag.TagChecksum         := $00;
  UDF_PVD.DescriptorTag.TagSerialNumber     := $00;
  UDF_PVD.DescriptorTag.DescriptorCRC       := $00;
  UDF_PVD.DescriptorTag.DescriptorCRCLength := $00;
  UDF_PVD.DescriptorTag.TagLocation         := Sector; //20 00 00 00
  UDF_PVD.VolumeDescriptorSequenceNumber    := $00000000;
  UDF_PVD.PrimaryVolumeDescriptorNumber     := $00000000;

  StrPCopy(UDF_PVD.VolumeIdentifier,Copy(VolumeName, 1, Length(UDF_PVD.VolumeIdentifier)));
  UDF_PVD.VolumeSequenceNumber              := $0001; //0100
  UDF_PVD.MaximumVolumeSequenceNumber       := $0001; //0100
  UDF_PVD.InterchangeLevel                  := $0002;
  UDF_PVD.MaximumInterchangeLevel           := $0002;
  UDF_PVD.CharacterSetList                  := CHARSPEC_TYPE_CS1;
  UDF_PVD.MaximumCharacterSetList           := CHARSPEC_TYPE_CS1;
  FillRandomChar(UDF_PVD.VolumeSetIdentifier);// 08 33 33 39 45 42 44 36 44
  UDF_PVD.DescriptorCharacterSet.CharSetType := OSTA_CS0_CHARACTER_SET_TYPE;
  UDF_PVD.DescriptorCharacterSet.CharSetInfo := OSTA_CS0_CHARACTER_SET_INFO;

  UDF_PVD.ExplanatoryCharacterSet.CharSetType := OSTA_CS0_CHARACTER_SET_TYPE;
  UDF_PVD.ExplanatoryCharacterSet.CharSetInfo := OSTA_CS0_CHARACTER_SET_INFO;

  UDF_PVD.VolumeAbstract.ExtentLength          := $0000;
  UDF_PVD.VolumeAbstract.ExtentLocation        := $0000;
  UDF_PVD.VolumeCopyrightNotice.ExtentLength          := $0000;
  UDF_PVD.VolumeCopyrightNotice.ExtentLocation        := $0000;
  BuildVolumeDateTime(UDF_PVD.RecordingDateAndTime);

  UDF_PVD.ImplementationIdentifier.Flags         := $00;
  UDF_PVD.ImplementationIdentifier.Identifier    := OSTA_DEVELOPER_ID;

end;


{Sector 33}
Procedure PopulateUDFImplementationUseVolumeDescriptor(VAR UDF_IUVD : UDF_ImplementationUseVolumeDescriptor; Sector : Integer ; VolumeName : string);
begin
  UDF_IUVD.DescriptorTag.TagIdentifier       := TAG_IDENT_IUVD;
  UDF_IUVD.DescriptorTag.DescriptorVersion   := TAG_DESCRIPTOR_VERSION;
  UDF_IUVD.DescriptorTag.TagChecksum         := $00;
  UDF_IUVD.DescriptorTag.TagSerialNumber     := $00;
  UDF_IUVD.DescriptorTag.DescriptorCRC       := $00;
  UDF_IUVD.DescriptorTag.DescriptorCRCLength := $00;
  UDF_IUVD.DescriptorTag.TagLocation         := Sector; //21 00 00 00
  
  UDF_IUVD.VolumeDescriptorSequenceNumber    := $0001; //0100
  UDF_IUVD.ImplementationIdentifier.Flags         := $00;
  UDF_IUVD.ImplementationIdentifier.Identifier    := REGID_ID_LV_INFO;

  UDF_IUVD.LVInformation.LVICharset.CharSetType := OSTA_CS0_CHARACTER_SET_TYPE;
  UDF_IUVD.LVInformation.LVICharset.CharSetInfo := OSTA_CS0_CHARACTER_SET_INFO;
  StrPCopy(UDF_IUVD.LVInformation.LogicalVolumeIdentifier,Copy(VolumeName, 1, Length(UDF_IUVD.LVInformation.LogicalVolumeIdentifier)));
  UDF_IUVD.LVInformation.ImplementionID.Flags := $00;
  UDF_IUVD.LVInformation.ImplementionID.Identifier := OSTA_DEVELOPER_ID;
end;


{Sector 34}
Procedure PopulateUDFPartitionDescriptor(VAR UDF_PD : UDF_PartitionDescriptor; Sector : Integer ; VolumeName : string);
begin
  UDF_PD.DescriptorTag.TagIdentifier       := TAG_IDENT_PD;
  UDF_PD.DescriptorTag.DescriptorVersion   := TAG_DESCRIPTOR_VERSION;
  UDF_PD.DescriptorTag.TagChecksum         := $00;
  UDF_PD.DescriptorTag.TagSerialNumber     := $00;
  UDF_PD.DescriptorTag.DescriptorCRC       := $00;
  UDF_PD.DescriptorTag.DescriptorCRCLength := $00;
  UDF_PD.DescriptorTag.TagLocation         := Sector; //22 00 00 00
  UDF_PD.VolumeDescriptorSequenceNumber    := $0002;
  UDF_PD.PartitionFlags                    := $0001;
  UDF_PD.PartitionNumber                   := $0000;
  UDF_PD.PartitionContents.Flags           := $02;
  UDF_PD.PartitionContents.Identifier      := PD_PARTITION_CONTENTS_NSR02;
  UDF_PD.AccessType                        := PD_ACCESS_TYPE_READ_ONLY;
  UDF_PD.PartitionStartingLocation         := 262; //06 01 00 00
  UDF_PD.PartitionLength                   := 1364814; //4E D3 14 00
  UDF_PD.ImplementationIdentifier.Flags    := $00;
  UDF_PD.ImplementationIdentifier.Identifier := OSTA_DEVELOPER_ID;
end;


{Sector 35}
Procedure PopulateUDFlogicalVolDesc(VAR UDF_LVD : UDF_logicalVolDesc; Sector : Integer ; VolumeName : string);
begin
  UDF_LVD.DescriptorTag.TagIdentifier       := TAG_IDENT_LVD;
  UDF_LVD.DescriptorTag.DescriptorVersion   := TAG_DESCRIPTOR_VERSION;
  UDF_LVD.DescriptorTag.TagChecksum         := $00;
  UDF_LVD.DescriptorTag.TagSerialNumber     := $00;
  UDF_LVD.DescriptorTag.DescriptorCRC       := $00;
  UDF_LVD.DescriptorTag.DescriptorCRCLength := $00;
  UDF_LVD.DescriptorTag.TagLocation         := Sector; //22 00 00 00
  UDF_LVD.VolumeDescSeqNum                  := $0003;
  UDF_LVD.DescriptorCharacterSet.CharSetType := OSTA_CS0_CHARACTER_SET_TYPE;
  UDF_LVD.DescriptorCharacterSet.CharSetInfo := OSTA_CS0_CHARACTER_SET_INFO;
  StrPCopy(UDF_LVD.LogicalVolumeIdentifier,Copy(VolumeName, 1, Length(UDF_LVD.LogicalVolumeIdentifier)));
  UDF_LVD.LogicalBlockSize                   := 2048;
  UDF_LVD.DomainIdentifier.Flags             := $00;
  UDF_LVD.DomainIdentifier.Identifier        := REGID_ID_COMPLIANT;
  UDF_LVD.ImplementationIdentifier.Flags     := $00;
  UDF_LVD.ImplementationIdentifier.Identifier := OSTA_DEVELOPER_ID;
  UDF_LVD.IntegritySequenceExtent.ExtentLength := 4096;
  UDF_LVD.IntegritySequenceExtent.ExtentLocation:= 64;
  UDF_LVD.partitionMap1.PartitionMapType        :=$01;
  UDF_LVD.partitionMap1.PartitionMapLength      :=$06;
  UDF_LVD.partitionMap1.VolumeSeqNumber         :=$01;
  UDF_LVD.partitionMap1.partitionNumber         :=$00;
end;


{Sector 36}
Procedure PopulateUDFUnallocSpaceDesc(VAR UDF_USD : UDF_UnallocSpaceDesc; Sector : Integer ; VolumeName : string);
begin
  UDF_USD.DescriptorTag.TagIdentifier       := TAG_IDENT_USD;
  UDF_USD.DescriptorTag.DescriptorVersion   := TAG_DESCRIPTOR_VERSION;
  UDF_USD.DescriptorTag.TagChecksum         := $00;
  UDF_USD.DescriptorTag.TagSerialNumber     := $00;
  UDF_USD.DescriptorTag.DescriptorCRC       := $00;
  UDF_USD.DescriptorTag.DescriptorCRCLength := $00;
  UDF_USD.DescriptorTag.TagLocation         := Sector; //22 00 00 00
  UDF_USD.VolumeDescSeqNum                  := $0004;
end;



{Sector 36 - 65}
Procedure PopulateUDFTerminatingDesc(VAR UDF_TD : UDF_TerminatingDesc; Sector : Integer ; VolumeName : string);
begin
  UDF_TD.DescriptorTag.TagIdentifier       := TAG_IDENT_TD;
  UDF_TD.DescriptorTag.DescriptorVersion   := TAG_DESCRIPTOR_VERSION;
  UDF_TD.DescriptorTag.TagChecksum         := $00;
  UDF_TD.DescriptorTag.TagSerialNumber     := $00;
  UDF_TD.DescriptorTag.DescriptorCRC       := $0000;
  UDF_TD.DescriptorTag.DescriptorCRCLength := $0000;
  UDF_TD.DescriptorTag.TagLocation         := Sector; //263  Dword
end;



{Sector 64}
Procedure PopulateUDFlogicalVolumeIntegrityDesc(VAR UDF_LVID : UDF_logicalVolumeIntegrityDesc; Sector : Integer ; NumOfFiles,NumOfDirs : Integer);
begin
  UDF_LVID.DescriptorTag.TagIdentifier       := TAG_IDENT_LVID;
  UDF_LVID.DescriptorTag.DescriptorVersion   := TAG_DESCRIPTOR_VERSION;
  UDF_LVID.DescriptorTag.TagChecksum         := $00;
  UDF_LVID.DescriptorTag.TagSerialNumber     := $00;
  UDF_LVID.DescriptorTag.DescriptorCRC       := $00;
  UDF_LVID.DescriptorTag.DescriptorCRCLength := $00;
  UDF_LVID.DescriptorTag.TagLocation         := Sector; //22 00 00 00
  BuildVolumeDateTime(UDF_LVID.RecordingDateAndTime);
  UDF_LVID.IntegrityType                     := LVID_INTEGRITY_TYPE_CLOSE;
  UDF_LVID.NextIntegrityExt.ExtentLength     := $00000000;
  UDF_LVID.NextIntegrityExt.ExtentLocation   := $00000000;
  UDF_LVID.NumOfPartitions                   := $00000001;
  UDF_LVID.LengthOfImpUse                    := $0000002E;
  UDF_LVID.FreeSpaceTable                    := $00000000;
  UDF_LVID.SizeTable                         := $0019F4F3;//      F3F41900;
  UDF_LVID.ImpUse.Flags                      := $00;
  UDF_LVID.ImpUse.Identifier                 := OSTA_DEVELOPER_ID;
  //UDF_LVID.ImpUse.IdentifierSuffix           := $0000000000010005;
  UDF_LVID.NumberOfFiles                     := NumOfFiles;
  UDF_LVID.NumberOfDirectories               := NumOfDirs;
  UDF_LVID.MinimumUDFReadRevision            := $0102;
  UDF_LVID.MinimumUDFWriteRevision           := $0102;
  UDF_LVID.MaximumUDFWriteRevision           := $0105;
end;




{Sector 256}
Procedure PopulateUDFAnchorVolumeDescriptorPointer(VAR UDF_ADVP : UDF_AnchorVolumeDescriptorPointer; Sector : Integer ; VolumeName : string);
begin
  UDF_ADVP.DescriptorTag.TagIdentifier       := TAG_IDENT_AVDP;
  UDF_ADVP.DescriptorTag.DescriptorVersion   := TAG_DESCRIPTOR_VERSION;
  UDF_ADVP.DescriptorTag.TagChecksum         := $00;
  UDF_ADVP.DescriptorTag.TagSerialNumber     := $00;
  UDF_ADVP.DescriptorTag.DescriptorCRC       := $00;
  UDF_ADVP.DescriptorTag.DescriptorCRCLength := $00;
  UDF_ADVP.DescriptorTag.TagLocation         := Sector; //22 00 00 00
  UDF_ADVP.MainVolumeDescriptorSequenceExtent.ExtentLength := 32768; //00 80 00 00
  UDF_ADVP.MainVolumeDescriptorSequenceExtent.ExtentLocation := 32; //20 00 00 00
  UDF_ADVP.ReserveVolumeDescriptorSequenceExtent.ExtentLength :=  32768; //00 80 00 00
  UDF_ADVP.ReserveVolumeDescriptorSequenceExtent.ExtentLocation := 48; //20 00 00 00
end;


{Sector 262}
Procedure PopulateUDFFileSetDescriptor(VAR UDF_FSD : UDF_FileSetDescriptor; Sector : Integer ; VolumeName : string);
begin
  UDF_FSD.DescriptorTag.TagIdentifier       := TAG_IDENT_FSD;
  UDF_FSD.DescriptorTag.DescriptorVersion   := TAG_DESCRIPTOR_VERSION;
  UDF_FSD.DescriptorTag.TagChecksum         := $00;
  UDF_FSD.DescriptorTag.TagSerialNumber     := $00;
  UDF_FSD.DescriptorTag.DescriptorCRC       := $00;
  UDF_FSD.DescriptorTag.DescriptorCRCLength := $00;
  UDF_FSD.DescriptorTag.TagLocation         := Sector; //22 00 00 00
  BuildVolumeDateTime(UDF_FSD.RecordingDateAndTime);
  UDF_FSD.InterchangeLevel                  := $0003;
  UDF_FSD.MaximumInterchangeLevel           := $0003;
  UDF_FSD.CharacterSetList                  := CHARSPEC_TYPE_CS1;
  UDF_FSD.MaximumCharacterSetList           := CHARSPEC_TYPE_CS1;
  UDF_FSD.FileSetNumber                     := $00;
  UDF_FSD.FileSetDescriptorNumber           := $00;
  UDF_FSD.LogicalVolumeIdentifierCharSet.CharSetType := OSTA_CS0_CHARACTER_SET_TYPE;
  UDF_FSD.LogicalVolumeIdentifierCharSet.CharSetInfo := OSTA_CS0_CHARACTER_SET_INFO;
  StrPCopy(UDF_FSD.LogicalVolumeIdentifier,Copy(VolumeName, 1, Length(UDF_FSD.LogicalVolumeIdentifier)));
  UDF_FSD.FileSetCharacterSet.CharSetType   := OSTA_CS0_CHARACTER_SET_TYPE;
  UDF_FSD.FileSetCharacterSet.CharSetInfo   := OSTA_CS0_CHARACTER_SET_INFO;
  StrPCopy(UDF_FSD.FileSetIdentifier,Copy(VolumeName, 1, Length(UDF_FSD.FileSetIdentifier)));
  UDF_FSD.RootDirectoryICB.ExtentLength      := $00000800;
  UDF_FSD.RootDirectoryICB.ExtentLocation.LogicalBlockNum := $0002;
  UDF_FSD.RootDirectoryICB.ExtentLocation.PartitionReferenceNum := $0000;
  UDF_FSD.DomainIdentifier.Flags             := $00;
  UDF_FSD.DomainIdentifier.Identifier        := REGID_ID_COMPLIANT;
end;







end.
