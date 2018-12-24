{-----------------------------------------------------------------------------
 Unit Name: MicroUDFOSTATypes
 Author:    Dancemammal
 Purpose:   OSTA UDF Records
 History:   First release
-----------------------------------------------------------------------------}


Unit MicroUDFOSTATypes;


interface

Uses 
     Windows, Messages, SysUtils, Classes, Graphics, Controls, MicroUDFClassTypes,
     MicroUDFConsts;


Type
     OSTA_IdentSuffix = packed record
          UDFRevision     : Word;
          OSClass         : Byte;
          OSIdentifier    : Byte;
          reserved        : packed array [0..3] of Byte;
     end;
       POSTA_IdentSuffix = ^OSTA_IdentSuffix;



     OSTA_ImpIdentSuffix = packed record
          OSClass        : Byte;
          OSIdentifier   : Byte;
          reserved       : packed array [0..5] of Byte;
     end;
      POSTA_ImpIdentSuffix = ^OSTA_ImpIdentSuffix;


     OSTA_AppIdentSuffix = packed record
          ImpUse : packed array [0..7] of Byte;
     end;
      POSTA_AppIdentSuffix = ^OSTA_AppIdentSuffix;


(* Logical Volume Integrity Descriptor (UDF 2.01 2.2.6) *)
(* Implementation Use (UDF 2.01 2.2.6.4) *)
     OSTA_LogicalVolumeIntegrityDescriptorImpUse = packed record
          ImpIdent        : UDF_EntityIdentifier;
          NumFiles        : Word;
          NumDirs         : Word;
          MinUDFReadRev   : Word;
          MinUDFWriteRev  : Word;
          MaxUDFWriteRev  : Word;
     end;
       POSTA_LogicalVolumeIntegrityDescriptorImpUse = ^OSTA_LogicalVolumeIntegrityDescriptorImpUse;


(* Implementation Use Volume Descriptor (UDF 2.01 2.2.7) *)
(* Implementation Use (UDF 2.01 2.2.7.2) *)
     OSTA_ImplementationUseVolumeDescriptorImpUse = packed record
          LVICharset : UDF_CharSpec;
          logicalVolIdent   : packed array [0..127] of Char;
          LVInfo1           : packed array [0..35] of Char;
          LVInfo2           : packed array [0..35] of Char;
          LVInfo3           : packed array [0..35] of Char;
          ImpIdent          : UDF_EntityIdentifier;
          ImpUse            : packed array [0..127] of Byte;
     end;


     OSTA_UDFPartitionMap2 = packed record
          partitionMapType      : Byte;
          partitionMapLength    : Byte;
          Reserved1             : packed array [0..1] of Byte;
          PartIdent             : UDF_EntityIdentifier;
          VolumeSeqNumber       : Word;
          PartitionNumber       : Word;
     end;
      POSTA_UDFPartitionMap2 = ^OSTA_UDFPartitionMap2;


(* Virtual Partition Map (UDF 2.01 2.2.8) *)
     OSTA_VirtualPartitionMap = packed record
          partitionMapType   : Byte;
          partitionMapLength : Byte;
          Reserved1          : packed array [0..1] of Byte;
          PartIdent          : UDF_EntityIdentifier;
          VolumeSeqNumber    : Word;
          PartitionNumber    : Word;
          Reserved2          : packed array [0..23] of Byte;
     end;


(* Sparable Partition Map (UDF 2.01 2.2.9) *)
  OSTA_SparablePartitionMap = packed record
    PartitionMapType              : Byte;
    PartitionMapLength            : Byte;
    Reserved1                     : packed array [0..1] of Byte;
    PartitionTypeIdentifier       : UDF_EntityIdentifier;
    VolumeSequenceNumber          : Word;
    PartitionNumber               : Word;
    PacketLength                  : Word;
    NumberOfSparingTables         : Byte;
    Reserved2                     : Byte;
    SizeOfEachSparingTable        : DWord;
    LocationsOfSparingTables      : array [0..1] of DWord;
    Pad                           : packed array [0..7] of Byte;
  end;
   POSTA_SparablePartitionMap = ^OSTA_SparablePartitionMap;




(* Virtual Allocation Table (UDF 1.5 2.2.10) *)
  OSTA_VirtualAllocationTableTail = packed record
    EntityIdentifier          : UDF_EntityIdentifier;
    PreviousVATICBLocation    : DWord;
  end;
   POSTA_VirtualAllocationTableTail = ^OSTA_VirtualAllocationTableTail;




(* Virtual Allocation Table (UDF 2.01 2.2.10) *)

Type
     VirtualAllocationTable20 = record
          lengthHeader : Uint16;
          lengthImpUse : Uint16;
          logicalVolIdent : array [0..127] of dstring;
          previousVatICBLoc : Uint32;
          numFIDSFiles : Uint32;
          numFIDSDirectories : Uint32;
          minReadRevision : Uint16;
          minWriteRevision : Uint16;
          maxWriteRevision : Uint16;
          reserved : Uint16;
          impUse1stByte : Byte;
     end;





(* Sparing Table (UDF 2.01 2.2.11) *)

Type
     OSTA_SparingEntry = packed record
          OriginalLocation  : DWord;
          MappedLocation    : DWord;
      end;

    POSTA_SparingEntry = ^OSTA_SparingEntry;


  OSTA_SparingTable = packed record
    DescriptorTag             : UDF_DescriptorTag;
    SparingIdentifier         : UDF_EntityIdentifier;
    ReallocationTableLength   : Word;
    Reserved                  : Word;
    SequenceNumber            : DWord;
  end;
   POSTA_SparingTable = ^OSTA_SparingTable;


(* struct long_ad ICB - ADImpUse (UDF 2.01 2.2.4.3) *)
     OSTA_AllocDescImpUse = packed record
          FRlags : Word;
          ImpUse : packed array [0..3] of Byte;
     end;
      POSTA_AllocDescImpUse = ^OSTA_AllocDescImpUse;




(* Implementation Use Extended Attribute (UDF 2.01 3.3.4.5) *)
(* FreeEASpace (UDF 2.01 3.3.4.5.1.1) *)
     OSTA_FreeEaSpace = packed record
          HeaderChecksum     : Word;
          FreeEASpace1stByte : Byte;
     end;
      POSTA_FreeEaSpace = ^OSTA_FreeEaSpace;

(* DVD Copyright Management Information (UDF 2.01 3.3.4.5.1.2) *)
     OSTA_DVDCopyrightImpUse = packed record
          HeaderChecksum   : Word;
          CGMSInfo         : Byte;
          DataType         : Byte;
          ProtectionSystemInfo : packed array [0..3] of Byte;
     end;
      POSTA_DVDCopyrightImpUse = ^OSTA_DVDCopyrightImpUse;

(* Application Use Extended Attribute (UDF 2.01 3.3.4.6) *)
(* FreeAppEASpace (UDF 2.01 3.3.4.6.1) *)

     OSTA_FreeAppEaSpace = packed record
          HeaderChecksum     : Word;
          FreeEASpace1stByte : Byte;
     end;
      POSTA_FreeAppEaSpace = ^OSTA_FreeAppEaSpace;




implementation



end.