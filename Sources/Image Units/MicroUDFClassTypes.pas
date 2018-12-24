{-----------------------------------------------------------------------------

 Author:    Dancemammal
 Purpose:   Volume discriptors for MicroUDF File system
 History:   First Release
-----------------------------------------------------------------------------}


Unit MicroUDFClassTypes;










































    PartitionReferenceNum : Word;
  end;






    ExtentPosition   : DWord;
  end;







    ExtentLocation      : UDF_RecordedAddress;
    ImplementationUse   : packed array [0..5] of Byte;
  end;








    RecordedLength       : DWord;
    InformationLength    : DWord;
    ExtentLocation       : UDF_RecordedAddress;
    ImplementationUse    : packed array [0..1] of Byte;
  end;







    Identifier        : packed array [0..22] of Char;
    IdentifierSuffix  : packed array [0..7] of Char;
  end;








    StructureType       : Byte;
    StandardIdentifier  : packed array [0..VSD_STD_ID_LEN-1] of Char;
    StructureVersion    : Byte;
    StructureData       : packed array [0..2040] of Byte;
  end;





















































    ExtentLocation   : DWord;
  end;


















    DescriptorVersion    : Word;
    TagChecksum          : Byte;
    Reserved             : Byte;
    TagSerialNumber      : Word;
    DescriptorCRC        : Word;
    DescriptorCRCLength  : Word;
    TagLocation          : DWord;
  end;



































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







    MainVolumeDescriptorSequenceExtent    : UDF_ExtentDescriptor;
    ReserveVolumeDescriptorSequenceExtent : UDF_ExtentDescriptor;
    Reserved                              : packed array [0..479] of Byte;
  end;





    VolumeDescriptorSequenceNumber     : DWord;
    NextVolumeDescriptorSequenceExtent : UDF_ExtentDescriptor;
    Reserved                           : packed array [0..483] of Byte;
  end;






    LogicalVolumeIdentifier  : packed array [0..127] of dstring;
    LVInfo1                  : packed array [0..35] of dstring;
    LVInfo2                  : packed array [0..35] of dstring;
    LVInfo3                  : packed array [0..35] of dstring;
    ImplementionID           : UDF_EntityIdentifier;
    ImplementationUse        : packed array [0..127] of Byte;
  end;






    VolumeDescriptorSequenceNumber  : DWord;
    ImplementationIdentifier        : UDF_EntityIdentifier;
    LVInformation                   : UDF_LVInformation;
  end;







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









































































































          MinimumUDFReadRevision   : Word;
          MinimumUDFWriteRevision  : Word;
          MaximumUDFWriteRevision  : Word;









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





    UnallocatedSpaceTable     : UDF_ShortAllocationDescriptor;
    UnallocatedSpaceBitmap    : UDF_ShortAllocationDescriptor;
    PartitionIntegrityTable   : UDF_ShortAllocationDescriptor;
    FreedSpaceTable           : UDF_ShortAllocationDescriptor;
    FreedSpaceBitmap          : UDF_ShortAllocationDescriptor;
    Reserved                  : packed array [0..87] of Byte;
  end;






    FileVersionNumber          : Word;
    FileCharacteristics        : Byte;
    LengthOfFileIdentifier     : Byte;
    ICB                        : UDF_LongAllocationDescriptor;
    LengthOfImplementationUse  : Word;
    UDF_EntityIdentifierFlags  : Byte;
  end;
   PUDF_FileIdentifierDescriptor = ^UDF_FileIdentifierDescriptor;
















    StrategyType                        : Word;
    StrategyParameter                   : packed array [0..1] of Byte;
    MaximumNumberOfEntries              : Word;
    Reserved                            : Byte;
    FileType                            : Byte;
    ParentICBLocation                   : UDF_RecordedAddress;
    Flags                               : Word;
  end;






    ICBTag                : UDF_ICBTag;
    IndirectICB           : UDF_LongAllocationDescriptor;
  end;






    UDF_ICBTag      : UDF_ICBTag;
  end;






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






    ImplementationAttributesLocation  : DWord;
    ApplicationAttributesLocation     : DWord;
  end;






    AttributeSubtype          : Byte;
    Reserved                  : packed array [0..2] of Byte;
    AttributeLength           : DWord;
    AttrData1stByte           : Byte;
  end;
   PUDF_GenericExtendedAttribute = ^UDF_GenericExtendedAttribute;












    AttributeSubtype         : Byte;
    Reserved                 : packed array [0..2] of Byte;
    AttributeLength          : DWord;
    EscapeSequencesLength    : DWord;
    CharacterSetType         : Byte;
    EscapeSeq1stByte         : Byte;
  end;






























    AttributeSubtype         : Byte;
    Reserved                 : packed array [0..2] of Byte;
    AttributeLength          : DWord;
    DataLength               : DWord;
    InformationTimeExistence : DWord;
    InfoTimes1stByte         : Byte;
  end;






    AttributeSubtype             : Byte;
    Reserved                     : packed array [0..2] of Byte;
    AttributeLength              : DWord;
    ImplementationUseLength      : DWord;
    MajorDeviceIdentification    : DWord;
    MinorDeviceIdentification    : DWord;
    ImpUse1stByte                : Byte;
  end;






    AttributeSubtype           : Byte;
    Reserved                   : packed array [0..2] of Byte;
    AttributeLength            : DWord;
    ImplementationUseLength    : DWord;
    ImplementationIdentifier   : UDF_EntityIdentifier;
    ImpUse1stByte              : Byte;
  end;






    AttributeSubtype           : Byte;
    Reserved                   : packed array [0..2] of Byte;
    AttributeLength            : DWord;
    ApplicationUseLength       : DWord;
    ApplicationIdentifier      : UDF_EntityIdentifier;
    ApplicationUse1stByte      : Byte;
  end;










    UDF_ICBTag                       : UDF_ICBTag;
    LengthOfAllocationDescriptors    : DWord;
    AllocDescs1stByte                : Byte;
  end;






    NumberOfBits        : DWord;
    NumberOfBytes       : DWord;
    Bitmap1stByte       : Byte;
  end;




































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







