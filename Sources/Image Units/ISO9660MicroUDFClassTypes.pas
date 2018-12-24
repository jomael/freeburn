{-----------------------------------------------------------------------------
 Unit Name: ISO9660;
 Author:    Dancemammal , Daniel Mann / Thomas Koos (original class structure)
 Purpose:   Unit for working with ISO Images
 History:   First Code Release
-----------------------------------------------------------------------------}


unit ISO9660MicroUDFClassTypes;

interface

uses windows,Classes,SysUtils,CovertFuncs;

                                                         
Const
     ISO_VD_PRIMARY      = 1;
     ISO_VD_END          = 255;
     ISO_STANDARD_ID     = 'CD001';
     ISO_SYSTEM_ID       = 'WIN32';
     ISO_LIBRARY_ID      = 'WWW.DANCEMAMMAL.COM';
     MAX_DEPTH           = 255;
     DEFAULT_SECTOR_SIZE = 2048;
     HEADER_START_SECTOR = 16;

    VSD_STD_ID_NSR02                     = 'NSR02'; (* (3/9.1) *)
(* Standard Identifier (ECMA 167r3 2/9.1.2) *)
    VSD_STD_ID_BEA01                     = 'BEA01'; (* (2/9.2) *)
    VSD_STD_ID_BOOT2                     = 'BOOT2'; (* (2/9.4) *)
    VSD_STD_ID_CD001                     = 'CD001'; (* (ECMA-119) *)
    VSD_STD_ID_CDW02                     = 'CDW02'; (* (ECMA-168) *)
    VSD_STD_ID_NSR03                     = 'NSR03'; (* (3/9.1) *)
    VSD_STD_ID_TEA01                     = 'TEA01'; (* (2/9.3) *)

    // Volume Descriptor Types
    vdtBR   = $00; // Boot Record
    vdtPVD  = $01; // Primary Volume Descriptor
    vdtSVD  = $02; // Supplementary Volume Descriptor
    vdtVDST = $FF; // Volume Descriptor Set Terminator

    FilesPerBlock = 30;




type
  TCharArr = array of Char;

Type

  PPathTableRecord = ^TPathTableRecord;
  TPathTableRecord = Packed Record
    LengthOfDirectoryIdentifier      : Byte;
    ExtendedAttributeRecordLength    : Byte;
    LocationOfExtent                 : LongWord;
    ParentDirectoryNumber            : Word;
    DirectoryIdentifier              : array [0..36] of Char;

    LocationOfExtentM                : LongWord;
    LengthOfDirectoryIdentifierM     : Byte;
    DirectoryIdentifierM             : array [0..127] of Char;
    JolietLocationOfExtent           : LongWord;
    JolietLocationOfExtentM          : LongWord;
    LengthOfPathRecord               : Byte;
    LengthOfPathRecordM              : Byte;
  End;


  PRootDirectoryRecord = ^TRootDirectoryRecord;
  TRootDirectoryRecord = Packed Record
     LengthOfDirectoryRecord          : Byte;
     ExtendedAttributeRecordLength    : Byte;
     LocationOfExtent                 : TBothEndianDWord;
     DataLength                       : TBothEndianDWord;
     RecordingDateAndTime             : TDirectoryDateTime;
     FileFlags                        : Byte;
     FileUnitSize                     : Byte;
     InterleaveGapSize                : Byte;
     VolumeSequenceNumber             : TBothEndianWord;
     LengthOfFileIdentifier           : Byte; // = 1
     FileIdentifier                   : Byte; // = 0
  End;


  PDirectoryRecord = ^TDirectoryRecord;
  TDirectoryRecord = Packed Record
    LengthOfDirectoryRecord          : Byte;
    ExtendedAttributeRecordLength    : Byte;
    LocationOfExtent                 : TBothEndianDWord;
    DataLength                       : TBothEndianDWord;
    RecordingDateAndTime             : TDirectoryDateTime;
    FileFlags                        : Byte;
    FileUnitSize                     : Byte;
    InterleaveGapSize                : Byte;
    VolumeSequenceNumber             : TBothEndianWord;
    LengthOfFileIdentifier           : Byte;
    // followed by FileIdentifier and padding bytes
  End;


  TPrimaryVolumeDescriptor = Packed Record
     StandardIdentifier               : Array [0..4] Of Char;
     VolumeDescriptorVersion          : Byte;
     unused                           : Byte;
     SystemIdentifier                 : Array [0..31] Of Char;
     VolumeIdentifier                 : Array [0..31] Of Char;
     Unused2                          : Array [0..7] Of Byte;
     VolumeSpaceSize                  : TBothEndianDWord;
     EscapeSequences                  : Array [0..31] of Char;
     VolumeSetSize                    : TBothEndianWord;
     VolumeSequenceNumber             : TBothEndianWord;
     LogicalBlockSize                 : TBothEndianWord;
     PathTableSize                    : TBothEndianDWord;
     LocationOfTypeLPathTable         : LongWord;
     LocationOfOptionalTypeLPathTable : LongWord;
     LocationOfTypeMPathTable         : LongWord;
     LocationOfOptionalTypeMPathTable : LongWord;
     RootDirectory                    : TRootDirectoryRecord;
     VolumeSetIdentifier              : Array [0..127] Of Char;
     PublisherIdentifier              : Array [0..127] Of Char;
     DataPreparerIdentifier           : Array [0..127] Of Char;
     ApplicationIdentifier            : Array [0..127] Of Char;
     CopyrightFileIdentifier          : Array [0..36] Of Char;
     AbstractFileIdentifier           : Array [0..36] Of Char;
     BibliographicFileIdentifier      : Array [0..36] Of Char;
     VolumeCreationDateAndTime        : TVolumeDateTime;
     VolumeModificationDateAndTime    : TVolumeDateTime;
     VolumeExpirationDateAndTime      : TVolumeDateTime;
     VolumeEffectiveDateAndTime       : TVolumeDateTime;
     FileStructureVersion             : Byte;
     ReservedForFutureStandardization : Byte;
     ApplicationUse                   : Array [0..511] Of Byte;
     ReservedForFutureStandardization2: Array [0..652] Of Byte;
  End;


  TSupplementaryVolumeDescriptor = Packed Record
     StandardIdentifier               : Array [0..4] Of Char;
     VolumeDescriptorVersion          : Byte;
     VolumeFlags                      : Byte;
     SystemIdentifier                 : Array [0..31] Of Char;
     VolumeIdentifier                 : Array [0..31] Of Char;
     Unused2                          : Array [0..7] Of Byte;
     VolumeSpaceSize                  : TBothEndianDWord;
     EscapeSequences                  : Array [0..31] of Char;
     VolumeSetSize                    : TBothEndianWord;
     VolumeSequenceNumber             : TBothEndianWord;
     LogicalBlockSize                 : TBothEndianWord;
     PathTableSize                    : TBothEndianDWord;
     LocationOfTypeLPathTable         : LongWord;
     LocationOfOptionalTypeLPathTable : LongWord;
     LocationOfTypeMPathTable         : LongWord;
     LocationOfOptionalTypeMPathTable : LongWord;
     RootDirectory                    : TRootDirectoryRecord;
     VolumeSetIdentifier              : Array [0..127] Of Char;
     PublisherIdentifier              : Array [0..127] Of Char;
     DataPreparerIdentifier           : Array [0..127] Of Char;
     ApplicationIdentifier            : Array [0..127] Of Char;
     CopyrightFileIdentifier          : Array [0..36] Of Char;
     AbstractFileIdentifier           : Array [0..36] Of Char;
     BibliographicFileIdentifier      : Array [0..36] Of Char;
     VolumeCreationDateAndTime        : TVolumeDateTime;
     VolumeModificationDateAndTime    : TVolumeDateTime;
     VolumeExpirationDateAndTime      : TVolumeDateTime;
     VolumeEffectiveDateAndTime       : TVolumeDateTime;
     FileStructureVersion             : Byte;
     ReservedForFutureStandardization : Byte;
     ApplicationUse                   : Array [0..511] Of Byte;
     ReservedForFutureStandardization2: Array [0..652] Of Byte;
  End;




Type
    TISOImage_Volume_Descriptors = packed Record
          Image_Fileformat            : String[30];
          Image_Version               : String[30];
          PrimaryVolumeDescriptor     : TPrimaryVolumeDescriptor;
          SecondaryVolumeDescriptor   : TSupplementaryVolumeDescriptor;
          PathTable                   : array of Pointer;
          PathTable_Number            : integer;
          Directories                 : array of Pointer;
          Directories_Number          : integer;
        end;





Type
  TBootVolumeDescriptor = packed record
    StandardIdentifier               : Array [0..4] of Char;
    VersionOfDescriptor              : Byte;
    BootSystemIdentifier             : Array [0..31] of Char;
    BootIdentifier                   : Array [0..31] of Char;
    BootCatalogPointer               : LongWord;
    Unused                           : Array [0..1972] of Byte;
  end;




  TBootCatalog = packed record
    Header: Byte;
    PlatformID: Byte;
    Reserved1: Word;
    Developer: packed array [4..27] of Char;
    Checksum: Word;
    KeyByte1: Byte;
    KeyByte2: Byte;
    BootIndicator: Byte;
    BootMediaType: Byte;
    LoadSegment: Word;
    SystemType: Byte;
    Unused1: Byte;
    SectorCount: Word;
    LoadRBA: DWORD;
    Unused2: packed array [12..31] of Byte;
    Unused3: packed array [48..2031] of Byte;
  end;



Type
  TISOHeader = Packed Record
       Header_Space     : Array [0..32767] of Char;
  end;



Type
  TVolumeDescriptorSetTerminator = Packed Record
    VolumeDescriptorType             : Byte;
    StandardIdentifier               : Array [1..5] of Char;
    VolumeDescriptorVersion          : Byte; // 7 so far
    Unused                           : Array [1..2041] of Byte; //pad to 2048 
  End;


Type
  TVolumeDescriptor = Packed Record
    Case DescriptorType : Byte Of
      vdtBR   : (BootRecord    : TBootVolumeDescriptor);
      vdtPVD  : (Primary       : TPrimaryVolumeDescriptor);
      vdtSVD  : (Supplementary : TSupplementaryVolumeDescriptor);
  End;


implementation



end.
