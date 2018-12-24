{-----------------------------------------------------------------------------
 Unit Name: MicroUDFConsts
 Author:    Dancemammal
 Purpose:   Constants for Micro UDF Records
 History:   First Version
-----------------------------------------------------------------------------}


unit MicroUDFConsts;

interface



Const
    OSTA_DEVELOPER_ID           = '*Dancemammal.Com';

    OSTA_CS0_CHARACTER_SET_TYPE = 0;
    OSTA_CS0_CHARACTER_SET_INFO = 'OSTA Compressed Unicode';

    REGID_ID_COMPLIANT =          '*OSTA UDF Compliant';
    REGID_ID_SPARABLE_PARTITION = '*UDF Sparable Partition';
    REGID_ID_LV_INFO =            '*UDF LV Info';
    REGID_ID_SPARING_TABLE =      '*UDF Sparing Table';

(* Character Set Type (ECMA 167r3 1/7.2.1.1) *)
    CHARSPEC_TYPE_CS0                    = $00; (* (1/7.2.2) *)
    CHARSPEC_TYPE_CS1                    = $01; (* (1/7.2.3) *)
    CHARSPEC_TYPE_CS2                    = $02; (* (1/7.2.4) *)
    CHARSPEC_TYPE_CS3                    = $03; (* (1/7.2.5) *)
    CHARSPEC_TYPE_CS4                    = $04; (* (1/7.2.6) *)
    CHARSPEC_TYPE_CS5                    = $05; (* (1/7.2.7) *)
    CHARSPEC_TYPE_CS6                    = $06; (* (1/7.2.8) *)
    CHARSPEC_TYPE_CS7                    = $07; (* (1/7.2.9) *)
    CHARSPEC_TYPE_CS8                    = $08; (* (1/7.2.10) *)

(* Type and Time Zone (ECMA 167r3 1/7.3.1) *)
    TIMESTAMP_TYPE_MASK                  = $F000;
    TIMESTAMP_TYPE_CUT                   = $0000;
    TIMESTAMP_TYPE_LOCAL                 = $1000;
    TIMESTAMP_TYPE_AGREEMENT             = $2000;
    TIMESTAMP_TIMEZONE_MASK              = $0FFF;

(* Flags (ECMA 167r3 1/7.4.1) *)
    ENTITYID_FLAGS_DIRTY                 = $00;
    ENTITYID_FLAGS_PROTECTED             = $01;

(* Volume Structure Descriptor (ECMA 167r3 2/9.1) *)
    VSD_STD_ID_LEN                       = 5;

(* Standard Identifier (EMCA 167r2 2/9.1.2) *)
    VSD_STD_ID_NSR02                     = 'NSR02'; (* (3/9.1) *)
(* Standard Identifier (ECMA 167r3 2/9.1.2) *)
    VSD_STD_ID_BEA01                     = 'BEA01'; (* (2/9.2) *)
    VSD_STD_ID_BOOT2                     = 'BOOT2'; (* (2/9.4) *)
    VSD_STD_ID_CD001                     = 'CD001'; (* (ECMA-119) *)
    VSD_STD_ID_CDW02                     = 'CDW02'; (* (ECMA-168) *)
    VSD_STD_ID_NSR03                     = 'NSR03'; (* (3/9.1) *)
    VSD_STD_ID_TEA01                     = 'TEA01'; (* (2/9.3) *)

(* Flags (ECMA 167r3 2/9.4.12) *)
    BOOT_FLAGS_ERASE                     = $01;

(* Tag Identifier (ECMA 167r3 3/7.2.1) *)
    TAG_IDENT_PVD                        = $0001;
    TAG_IDENT_AVDP                       = $0002;
    TAG_IDENT_VDP                        = $0003;
    TAG_IDENT_IUVD                       = $0004;
    TAG_IDENT_PD                         = $0005;
    TAG_IDENT_LVD                        = $0006;
    TAG_IDENT_USD                        = $0007;
    TAG_IDENT_TD                         = $0008;
    TAG_IDENT_LVID                       = $0009;
    TAG_IDENT_FSD                        = $0100;
    TAG_IDENT_FID                        = $0101;
    TAG_IDENT_AED                        = $0102;
    TAG_IDENT_IE                         = $0103;
    TAG_IDENT_TE                         = $0104;
    TAG_IDENT_FE                         = $0105;
    TAG_IDENT_EAHD                       = $0106;
    TAG_IDENT_USE                        = $0107;
    TAG_IDENT_SBD                        = $0108;
    TAG_IDENT_PIE                        = $0109;
    TAG_IDENT_EFE                        = $010A;

    TAG_DESCRIPTOR_VERSION               = $0002;

(* Flags (ECMA 167r3 3/10.1.21) *)
    PVD_FLAGS_VSID_COMMON                = $0001;

(* Partition Flags (ECMA 167r3 3/10.5.3) *)
    PD_PARTITION_FLAGS_ALLOC             = $0001;

(* Partition Contents (ECMA 167r2 3/10.5.3) *)
    PD_PARTITION_CONTENTS_NSR02          = '+NSR02';
(* Partition Contents (ECMA 167r3 3/10.5.5) *)
    PD_PARTITION_CONTENTS_FDC01          = '+FDC01';
    PD_PARTITION_CONTENTS_CD001          = '+CD001';
    PD_PARTITION_CONTENTS_CDW02          = '+CDW02';
    PD_PARTITION_CONTENTS_NSR03          = '+NSR03';

(* Access Type (ECMA 167r3 3/10.5.7) *)
    PD_ACCESS_TYPE_NONE                  = $00000000;
    PD_ACCESS_TYPE_READ_ONLY             = $00000001;
    PD_ACCESS_TYPE_WRITE_ONCE            = $00000002;
    PD_ACCESS_TYPE_REWRITABLE            = $00000003;
    PD_ACCESS_TYPE_OVERWRITABLE          = $00000004;

(* Partition Map Type (ECMA 167r3 3/10.7.1.1) *)
    GP_PARTITION_MAP_TYPE_UNDEF          = $00;
    GP_PARTIITON_MAP_TYPE_1              = $01;
    GP_PARTITION_MAP_TYPE_2              = $02;

(* Integrity Type (ECMA 167r3 3/10.10.3) *)
    LVID_INTEGRITY_TYPE_OPEN             = $00000000;
    LVID_INTEGRITY_TYPE_CLOSE            = $00000001;


(* File Characteristics (ECMA 167r3 4/14.4.3) *)
    FID_FILE_CHAR_HIDDEN                 = $01;
    FID_FILE_CHAR_DIRECTORY              = $02;
    FID_FILE_CHAR_DELETED                = $04;
    FID_FILE_CHAR_PARENT                 = $08;
    FID_FILE_CHAR_METADATA               = $10;

(* Strategy Type (ECMA 167r3 4/14.6.2) *)
    ICBTAG_STRATEGY_TYPE_UNDEF           = $0000;
    ICBTAG_STRATEGY_TYPE_1               = $0001;
    ICBTAG_STRATEGY_TYPE_2               = $0002;
    ICBTAG_STRATEGY_TYPE_3               = $0003;
    ICBTAG_STRATEGY_TYPE_4               = $0004;

(* File Type (ECMA 167r3 4/14.6.6) *)
    ICBTAG_FILE_TYPE_UNDEF               = $00;
    ICBTAG_FILE_TYPE_USE                 = $01;
    ICBTAG_FILE_TYPE_PIE                 = $02;
    ICBTAG_FILE_TYPE_IE                  = $03;
    ICBTAG_FILE_TYPE_DIRECTORY           = $04;
    ICBTAG_FILE_TYPE_REGULAR             = $05;
    ICBTAG_FILE_TYPE_BLOCK               = $06;
    ICBTAG_FILE_TYPE_CHAR                = $07;
    ICBTAG_FILE_TYPE_EA                  = $08;
    ICBTAG_FILE_TYPE_FIFO                = $09;
    ICBTAG_FILE_TYPE_SOCKET              = $0A;
    ICBTAG_FILE_TYPE_TE                  = $0B;
    ICBTAG_FILE_TYPE_SYMLINK             = $0C;
    ICBTAG_FILE_TYPE_STREAMDIR           = $0D;

(* Flags (ECMA 167r3 4/14.6.8) *)
    ICBTAG_FLAG_AD_MASK                  = $0007;
    ICBTAG_FLAG_AD_SHORT                 = $0000;
    ICBTAG_FLAG_AD_LONG                  = $0001;
    ICBTAG_FLAG_AD_EXTENDED              = $0002;
    ICBTAG_FLAG_AD_IN_ICB                = $0003;
    ICBTAG_FLAG_SORTED                   = $0008;
    ICBTAG_FLAG_NONRELOCATABLE           = $0010;
    ICBTAG_FLAG_ARCHIVE                  = $0020;
    ICBTAG_FLAG_SETUID                   = $0040;
    ICBTAG_FLAG_SETGID                   = $0080;
    ICBTAG_FLAG_STICKY                   = $0100;
    ICBTAG_FLAG_CONTIGUOUS               = $0200;
    ICBTAG_FLAG_SYSTEM                   = $0400;
    ICBTAG_FLAG_TRANSFORMED              = $0800;
    ICBTAG_FLAG_MULTIVERSIONS            = $1000;
    ICBTAG_FLAG_STREAM                   = $2000;

(* Permissions (ECMA 167r3 4/14.9.5) *)
    FE_PERM_O_EXEC                       = $00000001;
    FE_PERM_O_WRITE                      = $00000002;
    FE_PERM_O_READ                       = $00000004;
    FE_PERM_O_CHATTR                     = $00000008;
    FE_PERM_O_DELETE                     = $00000010;
    FE_PERM_G_EXEC                       = $00000020;
    FE_PERM_G_WRITE                      = $00000040;
    FE_PERM_G_READ                       = $00000080;
    FE_PERM_G_CHATTR                     = $00000100;
    FE_PERM_G_DELETE                     = $00000200;
    FE_PERM_U_EXEC                       = $00000400;
    FE_PERM_U_WRITE                      = $00000800;
    FE_PERM_U_READ                       = $00001000;
    FE_PERM_U_CHATTR                     = $00002000;
    FE_PERM_U_DELETE                     = $00004000;

(* Record Format (ECMA 167r3 4/14.9.7) *)
    FE_RECORD_FMT_UNDEF                  = $00;
    FE_RECORD_FMT_FIXED_PAD              = $01;
    FE_RECORD_FMT_FIXED                  = $02;
    FE_RECORD_FMT_VARIABLE8              = $03;
    FE_RECORD_FMT_VARIABLE16             = $04;
    FE_RECORD_FMT_VARIABLE16_MSB         = $05;
    FE_RECORD_FMT_VARIABLE32             = $06;
    FE_RECORD_FMT_PRINT                  = $07;
    FE_RECORD_FMT_LF                     = $08;
    FE_RECORD_FMT_CR                     = $09;
    FE_RECORD_FMT_CRLF                   = $0A;
    FE_RECORD_FMT_LFCR                   = $0B;

   // Records                              = Display;
    FE_RECORD_DISPLAY_ATTR_UNDEF         = $00;
    FE_RECORD_DISPLAY_ATTR_1             = $01;
    FE_RECORD_DISPLAY_ATTR_2             = $02;
    FE_RECORD_DISPLAY_ATTR_3             = $03;

(* FileTimeExistence (ECMA 167r3 4/14.10.5.6) *)
    FTE_CREATION                         = $00000001;
    FTE_DELETION                         = $00000004;
    FTE_EFFECTIVE                        = $00000008;
    FTE_BACKUP                           = $00000002;

(* FExtended Attributes(ECMA 167r3 4/14.10.5.6) *)
    EXTATTR_CHAR_SET                     = 1;
    EXTATTR_ALT_PERMS                    = 3;
    EXTATTR_FILE_TIMES                   = 5;
    EXTATTR_INFO_TIMES                   = 6;
    EXTATTR_DEV_SPEC                     = 12;
    EXTATTR_IMP_USE                      = 2048;
    EXTATTR_APP_USE                      = 65536;

(* Extent Length (ECMA 167r3 4/14.14.1.1) *)
    EXT_RECORDED_ALLOCATED               = $00000000;
    EXT_NOT_RECORDED_ALLOCATED           = $40000000;
    EXT_NOT_RECORDED_NOT_ALLOCATED       = $80000000;
    EXT_NEXT_EXTENT_ALLOCDECS            = $C0000000;


// OSTA Constants

Const
(* OSTA CS0 Charspec (UDF 2.01 2.1.2) *)
    UDF_CHAR_SET_TYPE                    = 0;
    UDF_CHAR_SET_INFO                    = 'OSTA Compressed Unicode';

(* Entity Identifier (UDF 2.01 2.1.5) *)
(* Identifiers (UDF 2.01 2.1.5.2) *)
    UDF_ID_DEVELOPER                     = '*Dancemammal.Com';
    UDF_ID_COMPLIANT                     = '*OSTA UDF Compliant';
    UDF_ID_LV_INFO                       = '*UDF LV Info';
    UDF_ID_FREE_EA                       = '*UDF FreeEASpace';
    UDF_ID_FREE_APP_EA                   = '*UDF FreeAppEASpace';
    UDF_ID_DVD_CGMS                      = '*UDF DVD CGMS Info';
    UDF_ID_OS2_EA                        = '*UDF OS/2 E';
    UDF_ID_OS2_EA_LENGTH                 = '*UDF OS/2 EALength';
    UDF_ID_MAC_VOLUME                    = '*UDF Mac VolumeInfo';
    UDF_ID_MAC_FINDER                    = '*UDF Mac FinderInfo';
    UDF_ID_MAC_UNIQUE                    = '*UDF Mac UniqueIDTable';
    UDF_ID_MAC_RESOURCE                  = '*UDF Mac ResourceForm';
    UDF_ID_VIRTUAL                       = '*UDF Virtual Partition';
    UDF_ID_SPARABLE                      = '*UDF Sparable Partition';
    UDF_ID_ALLOC                         = '*UDF Virtual Alloc Tbl';
    UDF_ID_SPARING                       = '*UDF Sparing Table';

(* Identifier Suffix (UDF 2.01 2.1.5.3) *)
    IS_DF_HARD_WRITE_PROTECT             = $01;
    IS_DF_SOFT_WRITE_PROTECT             = $02;

(* UDF Defined System Stream (UDF 2.01 3.3.7) *)
    UDF_ID_UNIQUE_ID                     = '*UDF Unique ID Mapping Dat';
    UDF_ID_NON_ALLOC                     = '*UDF Non-Allocatable Spac';
    UDF_ID_POWER_CAL                     = '*UDF Power Cal Tabl';
    UDF_ID_BACKUP                        = '*UDF Backu';

(* Operating System Identifiers (UDF 2.01 6.3) *)
    UDF_OS_CLASS_UNDEF                   = $00;
    UDF_OS_CLASS_DOS                     = $01;
    UDF_OS_CLASS_OS2                     = $02;
    UDF_OS_CLASS_MAC                     = $03;
    UDF_OS_CLASS_UNIX                    = $04;
    UDF_OS_CLASS_WIN9X                   = $05;
    UDF_OS_CLASS_WINNT                   = $06;
    UDF_OS_CLASS_OS400                   = $07;
    UDF_OS_CLASS_BEOS                    = $08;
    UDF_OS_CLASS_WINCE                   = $09;

    UDF_OS_ID_UNDEF                      = $00;
    UDF_OS_ID_DOS                        = $00;
    UDF_OS_ID_OS2                        = $00;
    UDF_OS_ID_MAC                        = $00;
    UDF_OS_ID_UNIX                       = $00;
    UDF_OS_ID_AIX                        = $01;
    UDF_OS_ID_SOLARIS                    = $02;
    UDF_OS_ID_HPUX                       = $03;
    UDF_OS_ID_IRIX                       = $04;
    UDF_OS_ID_LINUX                      = $05;
    UDF_OS_ID_MKLINUX                    = $06;
    UDF_OS_ID_FREEBSD                    = $07;
    UDF_OS_ID_WIN9X                      = $00;
    UDF_OS_ID_WINNT                      = $00;
    UDF_OS_ID_OS400                      = $00;
    UDF_OS_ID_BEOS                       = $00;
    UDF_OS_ID_WINCE                      = $00;

    ICBTAG_FILE_TYPE_VAT20               = $F8;
    ICBTAG_FILE_TYPE_VAT15               = $00;

    AD_IU_EXT_ERASED                     = $0001;
    
(* Real-Time Files (UDF 2.01 6.11) *)
    ICBTAG_FILE_TYPE_REALTIME            = $F9;



implementation

end.
 