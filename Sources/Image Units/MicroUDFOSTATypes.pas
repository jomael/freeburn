{-----------------------------------------------------------------------------

 Author:    Dancemammal
 Purpose:   OSTA UDF Records
 History:   First release
-----------------------------------------------------------------------------}


Unit MicroUDFOSTATypes;






















































































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








    PreviousVATICBLocation    : DWord;
  end;































          MappedLocation    : DWord;
      end;






    SparingIdentifier         : UDF_EntityIdentifier;
    ReallocationTableLength   : Word;
    Reserved                  : Word;
    SequenceNumber            : DWord;
  end;














































