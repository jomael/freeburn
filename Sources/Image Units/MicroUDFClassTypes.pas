{-----------------------------------------------------------------------------
 Unit Name: MicroUDFClassTypes
 Author:    Dancemammal
 Purpose:   Volume discriptors for MicroUDF File system
 History:   First Release
-----------------------------------------------------------------------------}


Unit MicroUDFClassTypes;

interface

Uses
     Windows, Messages, SysUtils, Classes, Graphics, Controls,
     MicroUDFConsts;


Type
 Dstring = Char;

Type
(* Character set specification (ECMA 167r3 1/7.2.1) *)
     UDF_CharSpec = packed record
          CharSetType : Byte;                    //OSTA_CS0_CHARACTER_SET_TYPE
          CharSetInfo : array [0..62] of Char;   //OSTA_CS0_CHARACTER_SET_INFO
     end;

  PUDF_CharSpec = ^UDF_CharSpec;


(* Timestamp (ECMA 167r3 1/7.3) *)
     UDF_Timestamp = packed record
          TypeAndTimezone        : Word;
          Year                   : Word;
          Month                  : Byte;
          Day                    : Byte;
          Hour                   : Byte;
          Minute                 : Byte;
          Second                 : Byte;
          Centiseconds           : Byte;
          HundredsOfMicroseconds : Byte;
          Microseconds           : Byte;
     end;
    PUDF_TimeStamp = ^UDF_TimeStamp;


(* Recorded Address (ECMA 167r3 4/7.1) *)

Type
  UDF_RecordedAddress = packed record
    LogicalBlockNum       : DWord;
    PartitionReferenceNum : Word;
  end;

  PUDF_RecordedAddress = ^UDF_RecordedAddress;

(* Short Allocation Descriptor (ECMA 167r3 4/14.14.1) *)
  UDF_ShortAllocationDescriptor = packed record
    ExtentLength     : DWord;
    ExtentPosition   : DWord;
  end;

  PUDF_ShortAllocationDescriptor = ^UDF_ShortAllocationDescriptor;


(* Long Allocation Descriptor (ECMA 167r3 4/14.14.2) *)
  UDF_LongAllocationDescriptor = packed record
    ExtentLength        : DWord;
    ExtentLocation      : UDF_RecordedAddress;
    ImplementationUse   : packed array [0..5] of Byte;
  end;

  PUDF_LongAllocationDescriptor = ^UDF_LongAllocationDescriptor;



(* Extended Allocation Descriptor (ECMA 167r3 4/14.14.3) *)
  UDF_ExtendedAllocationDescriptor = packed record
    ExtentLength         : DWord;
    RecordedLength       : DWord;
    InformationLength    : DWord;
    ExtentLocation       : UDF_RecordedAddress;
    ImplementationUse    : packed array [0..1] of Byte;
  end;
  PUDF_ExtendedAllocationDescriptor = ^UDF_ExtendedAllocationDescriptor;


(* Entity identifier (ECMA 167r3 1/7.4) *)
Type
  UDF_EntityIdentifier = packed record
    Flags             : Byte;
    Identifier        : packed array [0..22] of Char;
    IdentifierSuffix  : packed array [0..7] of Char;
  end;

    PUDF_EntityIdentifier = ^UDF_EntityIdentifier;



Type
(* Volume Structure Descriptor (ECMA 167r3 2/9.1) *)
  UDF_VolumeStructureDescriptor = packed record
    StructureType       : Byte;
    StandardIdentifier  : packed array [0..VSD_STD_ID_LEN-1] of Char;
    StructureVersion    : Byte;
    StructureData       : packed array [0..2040] of Byte;
  end;

  PUDF_VolumeStructureDescriptor = ^UDF_VolumeStructureDescriptor;




(* Beginning Extended Area Descriptor (ECMA 167r3 2/9.2) *)

Type
     UDF_BeginningExtendedAreaDesc = packed record
          StructureType       : Byte;
          StandardIdentifier  : array [0..VSD_STD_ID_LEN-1] of Char;
          StructureVersion    : Byte;
          StructureData       : array [0..2040] of Byte;
     end;
      PUDF_BeginningExtendedAreaDesc = ^UDF_BeginningExtendedAreaDesc;


(* Terminating Extended Area Descriptor (ECMA 167r3 2/9.3) *)
     UDF_TerminatingExtendedAreaDesc = packed record
          StructureType       : Byte;
          StandardIdentifier  : array [0..VSD_STD_ID_LEN-1] of Char;
          StructureVersion    : Byte;
          StructureData       : array [0..2040] of Byte;
     end;
       PUDF_TerminatingExtendedAreaDesc = ^UDF_TerminatingExtendedAreaDesc;


(* Boot Descriptor (ECMA 167r3 2/9.4) *)
     UDF_BootDesc = packed record
          StructureType                       : Byte;
          StandardIdentifier                  : array [0..VSD_STD_ID_LEN-1] of Char;
          StructureVersion                    : Byte;
          Reserved1                           : Byte;
          ArchitectureType                    : UDF_EntityIdentifier;
          BootIdentifier                      : UDF_EntityIdentifier;
          BootExtentLocation                  : DWord;
          BootExtentLength                    : DWord;
          loadAddress                         : Int64;
          StartAddress                        : Int64;
          DescriptorCreationDateAndTime       : UDF_Timestamp;
          Flags                               : Word;
          Reserved2                           : array [0..31] of Byte;
          BootUse                             : array [0..1905] of Byte;
     end;
       PUDF_BootDesc = ^UDF_BootDesc;



(* Extent Descriptor (ECMA 167r3 3/7.1) *)
Type
  UDF_ExtentDescriptor = packed record
    ExtentLength     : DWord;
    ExtentLocation   : DWord;
  end;
    PUDF_ExtentDescriptor = ^UDF_ExtentDescriptor;



(* Tag Identifier (ECMA 167r3 3/7.2.1) *
    TAG_IDENT_PVD                        = $0001;
    TAG_IDENT_AVDP                       = $0002;
    TAG_IDENT_VDP                        = $0003;
    TAG_IDENT_IUVD                       = $0004;
    TAG_IDENT_PD                         = $0005;
    TAG_IDENT_LVD                        = $0006;
    TAG_IDENT_USD                        = $0007;
    TAG_IDENT_TD                         = $0008;
    TAG_IDENT_LVID                       = $0009; }

(* Descriptor Tag (ECMA 167r3 3/7.2) *)
  UDF_DescriptorTag = packed record
    TagIdentifier        : Word;
    DescriptorVersion    : Word;
    TagChecksum          : Byte;
    Reserved             : Byte;
    TagSerialNumber      : Word;
    DescriptorCRC        : Word;
    DescriptorCRCLength  : Word;
    TagLocation          : DWord;
  end;
   PUDF_DescriptorTag = ^UDF_DescriptorTag;



Type
     UDF_TDB = packed record
          T               : Byte;
          D               : Byte;
          I               : Byte;
          Length          : Word;
          Res             : Byte;
          LowestTrack     : Byte;
          HighestTrack    : Byte;
          TrackNumber     : Byte;
          RecordingMethod : Byte;
          PacketSize      : packed array [0..2] of Byte;
          Res1            : packed array [0..10] of Byte;
     end;
      PUDF_TDB = ^UDF_TDB;


(* NSR Descriptor (ECMA 167r3 3/9.1) *)
     UDF_NSRDescriptor = record
          StructureType      : Byte;
          StandardIdentifier : array [0..VSD_STD_ID_LEN-1] of Char;
          StructureVersion   : Byte;
          Reserved           : Byte;
          StructureData      : array [0..2039] of Byte;
     end;
      PUDF_NSRDescriptor = ^UDF_NSRDescriptor;



(* Primary Volume Descriptor (ECMA 167r3 3/10.1) *)
  UDF_PrimaryVolumeDescriptor = packed record
    DescriptorTag                        : UDF_DescriptorTag;
    VolumeDescriptorSequenceNumber       : DWord;
    PrimaryVolumeDescriptorNumber        : DWord;
    VolumeIdentifier                     : packed array [0..31] of dstring;
    VolumeSequenceNumber                 : Word;
    MaximumVolumeSequenceNumber          : Word;
    InterchangeLevel                     : Word;
    MaximumInterchangeLevel              : Word;
    CharacterSetList                     : DWord;
    MaximumCharacterSetList              : DWord;
    VolumeSetIdentifier                  : packed array [0..127] of dstring;
    DescriptorCharacterSet               : UDF_CharSpec;
    ExplanatoryCharacterSet              : UDF_CharSpec;
    VolumeAbstract                       : UDF_ExtentDescriptor;
    VolumeCopyrightNotice                : UDF_ExtentDescriptor;
    ApplicationIdentifier                : UDF_EntityIdentifier;
    RecordingDateAndTime                 : UDF_TimeStamp;
    ImplementationIdentifier             : UDF_EntityIdentifier;
    ImplementationUse                    : packed array [0..63] of Byte;
    PredecessorVolumeDescriptorSequenceLocation : Byte;
    Flags                                : Word;
    Reserved                             : packed array [0..21] of Byte;
  end;
   PUDF_PrimaryVolumeDescriptor = ^UDF_PrimaryVolumeDescriptor;


Type
(* Anchor Volume Descriptor Pointer (ECMA 167r3 3/10.2) *)
  UDF_AnchorVolumeDescriptorPointer = packed record
    DescriptorTag                         : UDF_DescriptorTag;
    MainVolumeDescriptorSequenceExtent    : UDF_ExtentDescriptor;
    ReserveVolumeDescriptorSequenceExtent : UDF_ExtentDescriptor;
    Reserved                              : packed array [0..479] of Byte;
  end;
   PUDF_AnchorVolumeDescriptorPointer = ^UDF_AnchorVolumeDescriptorPointer;

(* Volume Descriptor Pointer (ECMA 167r3 3/10.3) *)
  UDF_VolumeDescriptorPointer = packed record
    DescriptorTag                      : UDF_DescriptorTag;
    VolumeDescriptorSequenceNumber     : DWord;
    NextVolumeDescriptorSequenceExtent : UDF_ExtentDescriptor;
    Reserved                           : packed array [0..483] of Byte;
  end;
   PUDF_VolumeDescriptorPointer = ^UDF_VolumeDescriptorPointer;


(* LV information (UDF2.01,2.2.7.2*)
  UDF_LVInformation = packed record
    LVICharset               : UDF_CharSpec;
    LogicalVolumeIdentifier  : packed array [0..127] of dstring;
    LVInfo1                  : packed array [0..35] of dstring;
    LVInfo2                  : packed array [0..35] of dstring;
    LVInfo3                  : packed array [0..35] of dstring;
    ImplementionID           : UDF_EntityIdentifier;
    ImplementationUse        : packed array [0..127] of Byte;
  end;
   PUDF_LVInformation = ^UDF_LVInformation;


(* Implementation Use Volume Descriptor (ECMA 167r3 3/10.4) *)
  UDF_ImplementationUseVolumeDescriptor = packed record
    DescriptorTag                   : UDF_DescriptorTag;
    VolumeDescriptorSequenceNumber  : DWord;
    ImplementationIdentifier        : UDF_EntityIdentifier;
    LVInformation                   : UDF_LVInformation;
  end;
   PUDF_ImplementationUseVolumeDescriptor = ^UDF_ImplementationUseVolumeDescriptor;



(* Partition Descriptor (ECMA 167r3 3/10.5) *)
  UDF_PartitionDescriptor = packed record
    DescriptorTag                       : UDF_DescriptorTag;
    VolumeDescriptorSequenceNumber      : DWord;
    PartitionFlags                      : Word;
    PartitionNumber                     : Word;
    PartitionContents                   : UDF_EntityIdentifier;
    PartitionContentsUse                : packed array [0..127] of Byte;
    AccessType                          : DWord;
    PartitionStartingLocation           : DWord;
    PartitionLength                     : DWord;
    ImplementationIdentifier            : UDF_EntityIdentifier;
    ImplementationUse                   : packed array [0..127] of Byte;
    Reserved                            : packed array [0..155] of Byte;
  end;
   PUDF_PartitionDescriptor = ^UDF_PartitionDescriptor;





Type
     UDF_PartitionMapType1 = packed record
          PartitionMapType     : Byte;
          PartitionMapLength   : Byte;
          VolumeSeqNumber      : Word;
          partitionNumber      : Word;
     end;
       PUDF_PartitionMapType1 = ^UDF_PartitionMapType1;


     UDF_partitionMapType2 = packed record
          PartitionMapType     : Byte;
          PartitionMapLength   : Byte;
          Res                  : packed array [0..1] of Byte;
          Ident                : UDF_EntityIdentifier;
          VolumeSeqNumber      : Word;
          PartitionNumber      : Word;
          reserved             : packed array [0..23] of Byte;
     end;
      PUDF_partitionMapType2 = ^UDF_partitionMapType2;


(* Logical Volume Descriptor (ECMA 167r3 3/10.6) *)
     UDF_logicalVolDesc = packed record
          DescriptorTag            : UDF_DescriptorTag;
          VolumeDescSeqNum         : DWord;
          DescriptorCharacterSet   : UDF_CharSpec;
          LogicalVolumeIdentifier  : packed array [0..127] of dstring;
          LogicalBlockSize         : DWord;
          DomainIdentifier         : UDF_EntityIdentifier;
          LogicalVolumeContentsUse : UDF_LongAllocationDescriptor;
          MapTableLength           : DWord;
          NumPartitionMaps         : DWord;
          ImplementationIdentifier : UDF_EntityIdentifier;
          ImplementationUse        : array [0..127] of Byte;
          IntegritySequenceExtent  : UDF_ExtentDescriptor;
          partitionMap1            : UDF_PartitionMapType1;
          partitionMap2            : UDF_partitionMapType2;
     end;
       PUDF_logicalVolDesc = ^UDF_logicalVolDesc;


(* Generic Partition Map (ECMA 167r3 3/10.7.1) *)
     UDF_GenericPartitionMap = packed record
          PartitionMapType        : Byte;
          PartitionMapLength      : Byte;
          PartitionMapping1stByte : Byte;
     end;
      PUDF_GenericPartitionMap = ^UDF_GenericPartitionMap;


(* Type 1 Partition Map (ECMA 167r3 3/10.7.2) *)
     UDF_GenericPartitionMap1 = packed record
          PartitionMapType       : Byte;
          PartitionMapLength     : Byte;
          VolumeSeqNum           : Word;
          PartitionNum           : Word;
     end;
      PUDF_GenericPartitionMap1 = ^UDF_GenericPartitionMap1;

(* Type 2 Partition Map (ECMA 167r3 3/10.7.3) *)
     UDF_GenericPartitionMap2 = packed record
          PartitionMapType      : Byte;
          PartitionMapLength    : Byte;
          PartitionIdent        : packed array [0..61] of Byte;
     end;
      pUDF_GenericPartitionMap2 = ^UDF_GenericPartitionMap2;

(* Unallocated Space Descriptor (ECMA 167r3 3/10.8) *)
     UDF_UnallocSpaceDesc = packed record
          DescriptorTag    : UDF_DescriptorTag;
          VolumeDescSeqNum : DWord;
          AumAllocDescs    : DWord;
          AllocDescs       : UDF_ExtentDescriptor;
     end;
      PUDF_UnallocSpaceDesc = ^UDF_UnallocSpaceDesc;

(* Terminating Descriptor (ECMA 167r3 3/10.9) *)
     UDF_TerminatingDesc = packed record
          DescriptorTag     : UDF_DescriptorTag;
          reserved          : packed array [0..495] of Byte;
     end;
      PUDF_TerminatingDesc = ^UDF_TerminatingDesc;


(* Logical Volume Integrity Descriptor (ECMA 167r3 3/10.10) *)
     UDF_logicalVolumeIntegrityDesc = packed record
          DescriptorTag            : UDF_DescriptorTag;
          RecordingDateAndTime     : UDF_Timestamp;
          IntegrityType            : DWord;
          NextIntegrityExt         : UDF_ExtentDescriptor;
          LogicalVolContentsUse    : packed array [0..31] of char;
          NumOfPartitions          : DWord;
          LengthOfImpUse           : DWord;
          FreeSpaceTable           : DWord;
          SizeTable                : DWord;
          ImpUse                   : UDF_EntityIdentifier;
          NumberOfFiles            : DWord;
          NumberOfDirectories      : DWord;
          MinimumUDFReadRevision   : Word;
          MinimumUDFWriteRevision  : Word;
          MaximumUDFWriteRevision  : Word;
     end;
       PUDF_logicalVolumeIntegrityDesc = ^UDF_logicalVolumeIntegrityDesc;



(* File Set Descriptor (ECMA 167r3 4/14.1) *)
Type
  UDF_FileSetDescriptor = packed record
    DescriptorTag                    : UDF_DescriptorTag;
    RecordingDateAndTime             : UDF_TimeStamp;
    InterchangeLevel                 : Word;
    MaximumInterchangeLevel          : Word;
    CharacterSetList                 : DWord;
    MaximumCharacterSetList          : DWord;
    FileSetNumber                    : DWord;
    FileSetDescriptorNumber          : DWord;
    LogicalVolumeIdentifierCharSet   : UDF_CharSpec;
    LogicalVolumeIdentifier          : packed array [0..127] of dstring;
    FileSetCharacterSet              : UDF_CharSpec;
    FileSetIdentifier                : packed array [0..31] of dstring;
    CopyrightFileIdentifier          : packed array [0..31] of dstring;
    AbstractFileIdentifier           : packed array [0..31] of dstring;
    RootDirectoryICB                 : UDF_LongAllocationDescriptor;
    DomainIdentifier                 : UDF_EntityIdentifier;
    NextExtent                       : UDF_LongAllocationDescriptor;
    StreamDirectoryICB               : UDF_LongAllocationDescriptor;
    Reserved                         : packed array [0..31] of Byte;
  end;
   PUDF_FileSetDescriptor = ^UDF_FileSetDescriptor;


(* Partition Header Descriptor (ECMA 167r3 4/14.3) *)
  UDF_PartitionHeaderDescriptor = packed record
    UnallocatedSpaceTable     : UDF_ShortAllocationDescriptor;
    UnallocatedSpaceBitmap    : UDF_ShortAllocationDescriptor;
    PartitionIntegrityTable   : UDF_ShortAllocationDescriptor;
    FreedSpaceTable           : UDF_ShortAllocationDescriptor;
    FreedSpaceBitmap          : UDF_ShortAllocationDescriptor;
    Reserved                  : packed array [0..87] of Byte;
  end;
   PUDF_PartitionHeaderDescriptor = ^UDF_PartitionHeaderDescriptor;


(* File Identifier Descriptor (ECMA 167r3 4/14.4) *)
  UDF_FileIdentifierDescriptor = packed record
    DescriptorTag              : UDF_DescriptorTag;
    FileVersionNumber          : Word;
    FileCharacteristics        : Byte;
    LengthOfFileIdentifier     : Byte;
    ICB                        : UDF_LongAllocationDescriptor;
    LengthOfImplementationUse  : Word;
    UDF_EntityIdentifierFlags  : Byte;
  end;
   PUDF_FileIdentifierDescriptor = ^UDF_FileIdentifierDescriptor;



(* Allocation Ext Descriptor (ECMA 167r3 4/14.5) *)
Type
     UDF_AllocExtDesc = Packed record
          DescriptorTag                  : UDF_DescriptorTag;
          PreviousAllocExtLocation       : Dword;
          LengthOfAllocationDescriptors  : Dword;
     end;
      PUDF_AllocExtDesc = ^UDF_AllocExtDesc;


(* ICB Tag (ECMA 167r3 4/14.6) *)
  UDF_ICBTag = packed record
    PriorRecordedNumberOfDirectEntries  : Dword;
    StrategyType                        : Word;
    StrategyParameter                   : packed array [0..1] of Byte;
    MaximumNumberOfEntries              : Word;
    Reserved                            : Byte;
    FileType                            : Byte;
    ParentICBLocation                   : UDF_RecordedAddress;
    Flags                               : Word;
  end;
    PUDF_ICBTag = ^UDF_ICBTag;


(* Indirect Entry (ECMA 167r3 4/14.7) *)
  UDF_IndirectEntry = packed record
    DescriptorTag         : UDF_DescriptorTag;
    ICBTag                : UDF_ICBTag;
    IndirectICB           : UDF_LongAllocationDescriptor;
  end;
   PUDF_IndirectEntry = ^UDF_IndirectEntry;


(* Terminal Entry (ECMA 167r3 4/14.8) *)
  UDF_TerminalEntry = packed record
    DescriptorTag   : UDF_DescriptorTag;
    UDF_ICBTag      : UDF_ICBTag;
  end;
   PUDF_TerminalEntry = ^UDF_TerminalEntry;


(* File Entry (ECMA 167r3 4/14.9) *)
  UDF_FileEntry = packed record
    DescriptorTag                : UDF_DescriptorTag;
    ICBTag                       : UDF_ICBTag;
    Uid                          : DWord;
    Gid                          : DWord;
    Permissions                  : DWord;
    FileLinkCount                : Word;
    RecordFormat                 : Byte;
    RecordDisplayAttributes      : Byte;
    RecordLength                 : DWord;
    InformationLength            : int64;
    LogicalBlocksRecorded        : int64;
    AccessDateAndTime            : UDF_TimeStamp;
    ModificationDateAndTime      : UDF_TimeStamp;
    AttributeDateAndTime         : UDF_TimeStamp;
    Checkpoint                   : DWord;
    ExtendedAttributeICB         : UDF_LongAllocationDescriptor;
    ImplementationIdentifier     : UDF_EntityIdentifier;
    UniqueID                     : int64;
    LengthOfExtendedAttributes   : DWord;
    LengthOfAllocationDescriptors: DWord;
    AllocationDescriptors        : packed array [0..1871] of Byte;
  end;
   PUDF_FileEntry = ^UDF_FileEntry;


Type
  UDF_ExtendedAttributeHeaderDescriptor = packed record
    DescriptorTag                     : UDF_DescriptorTag;
    ImplementationAttributesLocation  : DWord;
    ApplicationAttributesLocation     : DWord;
  end;
   PUDF_ExtendedAttributeHeaderDescriptor = ^UDF_ExtendedAttributeHeaderDescriptor;


(* Generic Format (ECMA 167r3 4/14.10.2) *)
  UDF_GenericExtendedAttribute = packed record
    AttributeType             : DWord;
    AttributeSubtype          : Byte;
    Reserved                  : packed array [0..2] of Byte;
    AttributeLength           : DWord;
    AttrData1stByte           : Byte;
  end;
   PUDF_GenericExtendedAttribute = ^UDF_GenericExtendedAttribute;


     UDF_ExtendedAttributes = packed record
          Header  : UDF_ExtendedAttributeHeaderDescriptor;
          Content : UDF_GenericExtendedAttribute;
     end;
      PUDF_ExtendedAttributes = ^UDF_ExtendedAttributes;


(* Character Set Information (ECMA 167r3 4/14.10.3) *)
  UDF_CharacterSetInformationExtendedAttribute = packed record
    AttributeType            : DWord;
    AttributeSubtype         : Byte;
    Reserved                 : packed array [0..2] of Byte;
    AttributeLength          : DWord;
    EscapeSequencesLength    : DWord;
    CharacterSetType         : Byte;
    EscapeSeq1stByte         : Byte;
  end;
   PUDF_CharacterSetInformationExtendedAttribute = ^UDF_CharacterSetInformationExtendedAttribute;

(* Alternate Permissions (ECMA 167r3 4/14.10.4) *)
     UDF_AlternatePermissions = Packed record
          AttributeType      : Dword;
          AttributeSubtype   : Byte;
          Reserved           : Packed array [0..2] of Byte;
          AttributeLength    : DWord;
          OwnerIdent         : Word;
          GroupIdent         : Word;
          Permission         : Word;
     end;
      PUDF_AlternatePermissions = ^UDF_AlternatePermissions;

(* File Times Extended Attribute (ECMA 167r3 4/14.10.5) *)
     UDF_FileTimesExtendedAttribute = Packed record
          AttributeType          : DWord;
          AttributeSubtype       : Byte;
          Reserved               : Packed array [0..2] of Byte;
          AttributeLength        : DWord;
          DataLength             : DWord;
          FileTimeExistence      : DWord;
          FileTimes              : UDF_Timestamp;
     end;
       PUDF_FileTimesExtendedAttribute = ^UDF_FileTimesExtendedAttribute;


(* Information Times Extended Attribute (ECMA 167r3 4/14.10.6) *)
  UDF_InformationTimesExtendedAttribute = packed record
    AttributeType            : DWord;
    AttributeSubtype         : Byte;
    Reserved                 : packed array [0..2] of Byte;
    AttributeLength          : DWord;
    DataLength               : DWord;
    InformationTimeExistence : DWord;
    InfoTimes1stByte         : Byte;
  end;
   PUDF_InformationTimesExtendedAttribute = ^UDF_InformationTimesExtendedAttribute;


(* Device Specification (ECMA 167r3 4/14.10.7) *)
  UDF_DeviceSpecificationExtendedAttribute = packed record
    AttributeType                : DWord;
    AttributeSubtype             : Byte;
    Reserved                     : packed array [0..2] of Byte;
    AttributeLength              : DWord;
    ImplementationUseLength      : DWord;
    MajorDeviceIdentification    : DWord;
    MinorDeviceIdentification    : DWord;
    ImpUse1stByte                : Byte;
  end;
   PUDF_DeviceSpecificationExtendedAttribute = ^UDF_DeviceSpecificationExtendedAttribute;


(* Implementation Use Extended Attr (ECMA 167r3 4/14.10.8) *)
  UDF_ImplementationUseExtendedAttribute = packed record
    AttributeType              : DWord;
    AttributeSubtype           : Byte;
    Reserved                   : packed array [0..2] of Byte;
    AttributeLength            : DWord;
    ImplementationUseLength    : DWord;
    ImplementationIdentifier   : UDF_EntityIdentifier;
    ImpUse1stByte              : Byte;
  end;
   PUDF_ImplementationUseExtendedAttribute = ^UDF_ImplementationUseExtendedAttribute;


(* Application Use Extended Attribute (ECMA 167r3 4/14.10.9) *)
  UDF_ApplicationUseExtendedAttribute = packed record
    AttributeType              : DWord;
    AttributeSubtype           : Byte;
    Reserved                   : packed array [0..2] of Byte;
    AttributeLength            : DWord;
    ApplicationUseLength       : DWord;
    ApplicationIdentifier      : UDF_EntityIdentifier;
    ApplicationUse1stByte      : Byte;
  end;
   PUDF_ApplicationUseExtendedAttribute = ^UDF_ApplicationUseExtendedAttribute;





(* Unallocated Space Entry (ECMA 167r3 4/14.11) *)
Type
  UDF_UnallocatedSpaceEntry = packed record
    DescriptorTag                    : UDF_DescriptorTag;
    UDF_ICBTag                       : UDF_ICBTag;
    LengthOfAllocationDescriptors    : DWord;
    AllocDescs1stByte                : Byte;
  end;
   PUDF_UnallocatedSpaceEntry = ^UDF_UnallocatedSpaceEntry;


(* Space Bitmap Descriptor (ECMA 167r3 4/14.12) *)
  UDF_SpaceBitmapDescriptor = packed record
    DescriptorTag       : UDF_DescriptorTag;
    NumberOfBits        : DWord;
    NumberOfBytes       : DWord;
    Bitmap1stByte       : Byte;
  end;
   PUDF_SpaceBitmapDescriptor = ^UDF_SpaceBitmapDescriptor;


(* Partition Integrity Entry (ECMA 167r3 4/14.13) *)
     UDF_PartitionIntegrityEntry = packed record
          DescriptorTag            : UDF_DescriptorTag;
          UDF_ICBTag               : UDF_ICBTag;
          RecordingDateAndTime     : UDF_Timestamp;
          IntegrityType            : Byte;
          reserved                 : array [0..174] of Byte;
          ImplimentationIdentifier : UDF_EntityIdentifier;
          ImplimentationUse        : packed array [0..255] of Byte;
     end;


(* Logical Volume Header Descriptor (ECMA 167r3 4/14.15) *)
    UDF_LogicalVolHeaderDesc = Packed record
          UniqueID : int64;
          Reserved : packed array [0..23] of Byte;
     end;
       PUDF_LogicalVolHeaderDesc = ^UDF_LogicalVolHeaderDesc;


(* Path Component (ECMA 167r3 4/14.16.1) *)
     UDF_PathComponent = packed record
          ComponentType              : Byte;
          LengthComponentIdent       : Byte;
          ComponentFileVersionNum    : Word;
          ComponentIdent1stByte      : dstring;
     end;
      PUDF_PathComponent = ^UDF_PathComponent;


(* File Entry (ECMA 167r3 4/14.17) *)
  UDF_ExtendedFileEntry = packed record
    DescriptorTag                  : UDF_DescriptorTag;
    ICBTag                         : UDF_ICBTag;
    Uid                            : DWord;
    Gid                            : DWord;
    Permissions                    : DWord;
    FileLinkCount                  : Word;
    RecordFormat                   : Byte;
    RecordDisplayAttributes        : Byte;
    RecordLength                   : DWord;
    InformationLength              : int64;
    ObjectSize                     : int64;
    LogicalBlocksRecorded          : int64;
    AccessDateAndTime              : UDF_TimeStamp;
    ModificationDateAndTime        : UDF_TimeStamp;
    CreationDateAndTime            : UDF_TimeStamp;
    AttributeDateAndTime           : UDF_TimeStamp;
    Checkpoint                     : DWord;
    reserved                       : DWord;
    ExtendedAttributeICB           : UDF_LongAllocationDescriptor;
    StreamDirectoryICB             : UDF_LongAllocationDescriptor;
    ImplementationIdentifier       : UDF_EntityIdentifier;
    UniqueID                       : int64;
    LengthOfExtendedAttributes     : DWord;
    LengthOfAllocationDescriptors  : DWord;
    ExtendedAttr1stByte            : Byte;
  end;
   PUDF_ExtendedFileEntry = ^UDF_ExtendedFileEntry;



implementation



end.