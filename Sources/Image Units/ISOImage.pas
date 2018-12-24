{-----------------------------------------------------------------------------
 Unit Name: ISOImage
 Author:    Paul Fisher , Andrew Semack
 Purpose:   ISO9660 create and edit class
 History:
-----------------------------------------------------------------------------}

unit ISOImage;

interface

uses
  CustomImage, Math, CovertFuncs, SysUtils, windows, ComCtrls, Classes,
    DeviceTypes,
  ISO9660ClassTypes, ISO9660BootClass, ISO9660PrimaryVolClass,
    ISO9660SupplementVolClass,
  ISO9660streamHandler, ISO9660ImageTree;

type
  TISOImage = class(TCustomImage)
  private
    FOnISOStatus: TCDStatusEvent;
    FFileName: string;
    FVolID: string;
    procedure GetImageData(const ALength: Cardinal);
  protected
    FImage: TImageStreamHandler;
    FISOHeader: TISOHeader;
    FBRClass: TBootRecordVolumeDescriptor;
    FPVDClass: TPrimaryVolumeDescriptor;
    FSVDClass: TSupplementaryVolumeDescriptor;
    FVDSTClass: TVolumeDescriptorSetTerminator;
    FTree: TImageTree;
    procedure SetVolID(VolName: string);
    procedure CreateVolumeDescriptors;
    procedure Log(const AFunction, AMessage: string);
    function ParseDirectory(const AUsePrimaryVD: Boolean = True): Boolean;
    function ParseDirectorySub(AParentDir: TDirectoryEntry; const AFileName:
      string; var ADirectoryEntry: PDirectoryRecord): Boolean;
    procedure WriteStructureTree(Primary: Boolean; ISOStream:
      TImageStreamHandler; ADirEntry: TDirectoryEntry);
    procedure WriteRootStructureTree(Primary: Boolean; ISOStream:
      TImageStreamHandler; ADirEntry: TDirectoryEntry);
    procedure WriteFileData(ISOStream: TImageStreamHandler; ADirEntry:
      TDirectoryEntry);
    procedure WritePathTableData(ISOStream: TImageStreamHandler; CurrentPointer:
      Integer);
    procedure WriteJolietPathTableData(ISOStream: TImageStreamHandler;
      CurrentPointer: Integer);
  public
    constructor Create;
    destructor Destroy; override;
    function OpenImage: Boolean;
    function SaveImageToDisk(Mode: Integer): Boolean;
    function SaveDVDImageToDisk: Boolean;
    function ParsePathTable(ATreeView: TTreeView = nil): Boolean;
    function ExtractFile(const AFileEntry: TFileEntry; const AFileName: string):
      Boolean;
    function CloseImage: Boolean;
  published
    property OnISOStatus: TCDStatusEvent read FOnISOStatus write FOnISOStatus;
    property Filename: string read FFileName write FFileName;
    property Structure: TImageTree read FTree;
    property Volume_ID: string read FVolID write SetVolID;
    property BootRecordVolumeDescriptor: TBootRecordVolumeDescriptor read
      FBRClass write FBRClass;
    property PrimaryVolumeDescriptor: TPrimaryVolumeDescriptor read FPVDClass
      write FPVDClass;
    property SupplementaryVolumeDescriptor: TSupplementaryVolumeDescriptor read
      FSVDClass write FSVDClass;
  end;

implementation

constructor TISOImage.Create;
begin
  inherited Create;
  FFileName := '';
  FImage := nil;
  FPVDClass := nil;
  FSVDClass := nil;
  FBRClass := nil;
  ImageType := IT9660Image;
  FTree := TImageTree.Create;
  CreateVolumeDescriptors; // does this need to be moved ??
end;

destructor TISOImage.Destroy;
begin
  if (Assigned(FTree)) then
    FreeAndNil(FTree);
  if (Assigned(FImage)) then
    FreeAndNil(FImage);
  if (Assigned(FPVDClass)) then
    FreeAndNil(FPVDClass);
  if (Assigned(FSVDClass)) then
    FreeAndNil(FSVDClass);
  if (Assigned(FBRClass)) then
    FreeAndNil(FBRClass);
  inherited;
end;

function TISOImage.CloseImage: Boolean;
begin
  FFileName := '';
  if Assigned(FImage) then
    FreeAndNil(FImage);
  if Assigned(FPVDClass) then
    FreeAndNil(FPVDClass);
  if Assigned(FSVDClass) then
    FreeAndNil(FSVDClass);
  if Assigned(FBRClass) then
    FreeAndNil(FBRClass);
  if Assigned(FTree) then
    FreeAndNil(FTree);
  Result := True;
end;

procedure TISOImage.SetVolID(VolName: string);

begin
  FVolID := VolName;
  if (Assigned(fPVDClass)) then
      fPVDClass.VolumeIdentifier := VolName;
  if (Assigned(fSVDClass)) then
      fSVDClass.VolumeIdentifier := VolName;
end;

procedure TISOImage.GetImageData(const ALength: Cardinal);
var
  OrgPtr,
    Buffer: PByte;
  Row: Cardinal;
  Col: Word;
  CharStr,
    DumpStr: string;
begin
  GetMem(Buffer, ALength);
  OrgPtr := Buffer;
  try
    FImage.Stream.ReadBuffer(Buffer^, ALength);

    for Row := 0 to ((ALength - 1) div 16) do
    begin
      DumpStr := IntToHex(Cardinal(fImage.Stream.Position) - ALength + Row * 16,
        8) + 'h | ';
      CharStr := '';
      for Col := 0 to Min(16, ALength - (Row + 1) * 16) do
      begin
        DumpStr := DumpStr + IntToHex(Buffer^, 2) + ' ';
        if (Buffer^ > 32) then
          CharStr := CharStr + Chr(Buffer^)
        else
          CharStr := CharStr + ' ';
        Inc(Buffer);
      end;
      DumpStr := DumpStr + StringOfChar(' ', 61 - Length(DumpStr)) + '| ' +
        CharStr;
      Log('Dump', DumpStr);
    end;
  finally
    FreeMem(OrgPtr, ALength);
  end;
end;

function TISOImage.ExtractFile(const AFileEntry: TFileEntry; const AFileName:
  string): Boolean;
var
  lFStream: TFileStream;
  lFSize: Int64;
  lBuffer: Pointer;
begin
  Result := False;

  if Assigned(AFileEntry) then
  begin
    fImage.SeekSector(AFileEntry.ISOData.LocationOfExtent.LittleEndian);
    lFStream := TFileStream.Create(AFileName, fmCreate);
    lFSize := AFileEntry.ISOData.DataLength.LittleEndian;
    GetMem(lBuffer, fImage.SectorDataSize);
    try
      while (lFSize > 0) do
      begin
        fImage.ReadSector_Data(lBuffer^, fImage.SectorDataSize);
        lFStream.WriteBuffer(lBuffer^, Min(lFSize, fImage.SectorDataSize));
        Dec(lFSize, fImage.SectorDataSize);
      end;
      Result := True;
    finally
      lFStream.Free;
      FreeMem(lBuffer, fImage.SectorDataSize);
    end;
  end;
end;


procedure TISOImage.Log(const AFunction, AMessage: string);
begin
  if Assigned(OnISOStatus) then
    OnISOStatus(AFunction + ' : ' + AMessage);
end;

function TISOImage.OpenImage: Boolean;
var
  VD: TVolumeDescriptor;
  Primary : Boolean;
  TempStr : String;
begin
  Result := False;
  Primary := True;
  if (FileExists(FFileName)) then
  begin
    fImage := TImageStreamHandler.Create(FFileName, ifAuto);
    Log('OpenImage', 'file "' + FFileName + '" opened...');
    fImage.SeekSector(16);
    if (fImage.ImageFormat = ifCompleteSectors) then
      Log('OpenImage', 'image contains RAW data')
    else if (fImage.ImageFormat = ifOnlyData) then
      Log('OpenImage', 'image contains sector data');

    if (fImage.ISOBookFormat = ybfMode1) then
      Log('OpenImage', 'image contains yellow book mode 1 data')
    else if (fImage.ISOBookFormat = ybfMode2) then
      Log('OpenImage', 'image contains yellow book mode 2 data');

    Log('OpenImage', 'user data sector size is ' +
      IntToStr(fImage.SectorDataSize) + ' bytes');
    Log('OpenImage', 'image data offset in image file is ' +
      IntToStr(fImage.ImageOffset) + ' bytes');

    if (fImage.SectorDataSize <> 2048) then
    begin
      Log('OpenImage',
        'sorry, but sector size other than 2048 bytes are not yet supported...');
      Exit;
    end;

    repeat
      FImage.ReadSector_Data(VD, SizeOf(TVolumeDescriptor));

      case Byte(VD.DescriptorType) of
        vdtBR:
          begin
            Log('OpenImage', 'Boot Record Volume Descriptor found');
              // Boot Record VD

            if (Assigned(fBRClass)) then // newer PVD
              fBRClass.Free;
            fBRClass := TBootRecordVolumeDescriptor.Create(VD);
          end;
        vdtPVD:
          begin
            Log('OpenImage', 'Primary Volume Descriptor found');

            if (Assigned(fPVDClass)) then // newer PVD
              fPVDClass.Free;
            fPVDClass := TPrimaryVolumeDescriptor.Create(VD);
            FVolID := fPVDClass.VolumeIdentifier;
          end;
        vdtSVD:
          begin
            Log('OpenImage', 'Supplementary Volume Descriptor found');
              // Supplementary Volume Descriptor

            if (Assigned(fSVDClass)) then // newer SVD
              fSVDClass.Free;
            fSVDClass := TSupplementaryVolumeDescriptor.Create(VD);
            TempStr := fSVDClass.VolumeIdentifier;
            FVolID := UnicodeToStr(TempStr);
            Primary := False;
          end;
      end;
    until (VD.DescriptorType = vdtVDST);

    ParseDirectory(Primary); // use primary Vol Disc
    Result := True;
  end
  else
  begin
    Log('OpenImage', 'file "' + FFileName + '" not found');
  end;
end;


procedure TISOImage.CreateVolumeDescriptors;
begin
  Log('CreateImage', 'ISO Header Created'); // ISO Header 32k of 0
  FillChar(FISOHeader, SizeOf(FISOHeader), Char(0));

  Log('CreateImage', 'Boot Record Volume Descriptor Created'); // Boot Record VD
  if (Assigned(fBRClass)) then
    fBRClass.Free;
  FBRClass := TBootRecordVolumeDescriptor.Create;

  Log('CreateImage', 'Primary Volume Descriptor Created');
    // Primary Volume Descriptor
  if (Assigned(fPVDClass)) then
    fPVDClass.Free;
  FPVDClass := TPrimaryVolumeDescriptor.Create;

  Log('CreateImage', 'Supplementary Volume Descriptor Created');
    // Supplementary Volume Descriptor
  if (Assigned(FSVDClass)) then
    FSVDClass.Free;
  FSVDClass := TSupplementaryVolumeDescriptor.Create;

  Log('CreateImage', 'Volume Descriptor Set Terminator Created');
    // Volume Descriptor Set Terminator
  FillChar(FVDSTClass, SizeOf(FVDSTClass), Char(0));

  FVDSTClass.VolumeDescriptorType := vdtVDST;
  FVDSTClass.StandardIdentifier := ISO_STANDARD_ID;
  FVDSTClass.VolumeDescriptorVersion := 1;
end;

procedure TISOImage.WriteRootStructureTree(Primary: Boolean; ISOStream:
  TImageStreamHandler; ADirEntry: TDirectoryEntry);
var
  DirIndex, FileIndex, Padd: Integer;
  Dir: TDirectoryEntry;
  RootDir: TRootDirectoryrecord;
  Fil: TFileEntry;
  TempPchar: PChar;
  TempPWideChr: PWideChar;
  PadByte, FileID: Byte;
  FillBlock: array[0..2047] of Byte;
  WideArray: array[0..127] of byte;
  CurrentLBA, StreamPos, PadIndex: Integer;
  DIRRecSize: Integer;
  Sector: Integer;

begin
  PadByte := $00;
  FillChar(FillBlock, 2048, 0);
  Log('Write Root Structure', 'Name : ' + ADirEntry.Name);
  // fill in "." and ".." directory sections (i previosly missed)

  RootDir := ADirEntry.RootISOData;
  RootDir.LengthOfDirectoryRecord := $22;
  RootDir.LengthOfFileIdentifier := 1;
  RootDir.FileFlags := $02;
  RootDir.VolumeSequenceNumber := BuildBothEndianWord(1);
  RootDir.LocationOfExtent := ADirEntry.RootISOData.LocationOfExtent;
  FileID := 0;
  ISOStream.Stream.Write(RootDir, sizeof(TDirectoryrecord));
  ISOStream.Stream.Write(FileID, sizeof(FileID)); // write file identifier

  RootDir := ADirEntry.RootISOData;
  RootDir.LengthOfDirectoryRecord := $22;
  RootDir.LengthOfFileIdentifier := 1;
  RootDir.FileFlags := $02;
  RootDir.VolumeSequenceNumber := BuildBothEndianWord(1);
  RootDir.LocationOfExtent := ADirEntry.RootISOData.LocationOfExtent;
  FileID := 1;
  ISOStream.Stream.Write(RootDir, sizeof(TDirectoryrecord));
  ISOStream.Stream.Write(FileID, sizeof(FileID)); // write file identifier
  // done with "." ".."

  for DirIndex := 0 to ADirEntry.DirectoryCount - 1 do // write directories
  begin
    Dir := ADirEntry.Directories[DirIndex];
    Dir.FillISOData(Primary);
    ISOStream.Stream.Write(Dir.ISOData, sizeof(TDirectoryrecord));
    if Primary = True then
    begin
      TempPchar := pchar(Dir.Name);
      ISOStream.Stream.Write(TempPchar^, Dir.ISOData.LengthOfFileIdentifier);
    end
    else
    begin
      TempPWideChr := Dir.GetWideDirName;
      FillChar(WideArray, 128, 0);
      CopyMemory(@WideArray[1], @TempPWideChr[0],
        (Dir.ISOData.LengthOfFileIdentifier) - 1); //makes it big endian wide char
      ISOStream.Stream.Write(WideArray, Dir.ISOData.LengthOfFileIdentifier);
    end;

    DIRRecSize := sizeof(TDirectoryrecord) + Dir.ISOData.LengthOfFileIdentifier;
      // get padding size
    if (DIRRecSize mod 2) > 0 then
      FImage.Stream.Write(PadByte, 1);
  end;

  for FileIndex := 0 to ADirEntry.FileCount - 1 do // write files
  begin
    Fil := ADirEntry.Files[FileIndex];
    Fil.FillISOData(Primary);
    ISOStream.Stream.Write(Fil.ISOData, sizeof(TDirectoryrecord));
    if Primary = True then
    begin
      TempPchar := pchar(Fil.Name);
      ISOStream.Stream.Write(TempPchar^, Fil.ISOData.LengthOfFileIdentifier);
    end
    else
    begin
      TempPWideChr := Fil.GetWideFileName;
      FillChar(WideArray, 128, 0);
      CopyMemory(@WideArray[1], @TempPWideChr[0],
        (Fil.ISOData.LengthOfFileIdentifier) - 1); //makes it big endian wide char
      ISOStream.Stream.Write(WideArray, Fil.ISOData.LengthOfFileIdentifier);
    end;

    DIRRecSize := sizeof(TDirectoryrecord) + Fil.ISOData.LengthOfFileIdentifier;
      // get padding size
    if (DIRRecSize mod 2) > 0 then
      FImage.Stream.Write(PadByte, 1);
  end;

  //pad the remainder of the block
  Padd := 2048 - (ISOstream.Stream.Position mod 2048);
  if Padd < 2048 then
    ISOStream.Stream.Write(FillBlock, Padd);

  for DirIndex := 0 to ADirEntry.DirectoryCount - 1 do // Rescan directories
  begin
    Dir := ADirEntry.Directories[DirIndex];
    Dir.FillISOData(Primary);
    WriteStructureTree(Primary, ISOStream, Dir);
  end;

  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('Write Root Structure', 'Current Pos After Structure: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));

  Log('SaveImage',
    '|----------------------------------------------------------|');

end;

procedure TISOImage.WriteStructureTree(Primary: Boolean; ISOStream:
  TImageStreamHandler; ADirEntry: TDirectoryEntry);
var
  DirIndex, FileIndex, Padd: Integer;
  Dir: TDirectoryEntry;
  RootDir: TDirectoryrecord;
  Fil: TFileEntry;
  TempPchar: PChar;
  TempPWideChr: PWideChar;
  PadByte, FileID: Byte;
  FillBlock: array[0..2047] of Byte;
  WideArray: array[0..127] of byte;
  CurrentLBA, StreamPos, PadIndex: Integer;
  DIRRecSize: Integer;
  Sector: Integer;

begin
  PadByte := $00;
  FillChar(FillBlock, 2048, 0);
  Log('Write Structure', 'Name : ' + ADirEntry.Name);
  // fill in "." and ".." directory sections (i previosly missed)
  RootDir := ADirEntry.ISOData;
  RootDir.LengthOfDirectoryRecord := $22;
  RootDir.LengthOfFileIdentifier := 1;
  RootDir.FileFlags := $02;
  RootDir.VolumeSequenceNumber := BuildBothEndianWord(1);
  RootDir.LocationOfExtent := ADirEntry.ISOData.LocationOfExtent;
  FileID := $00;
  ISOStream.Stream.Write(RootDir, sizeof(TDirectoryrecord));
  ISOStream.Stream.Write(FileID, sizeof(FileID)); // write file identifier

  if (ADirEntry.Parent = nil) then
    RootDir.LocationOfExtent := ADirEntry.RootISOData.LocationOfExtent
  else
  begin
    ADirEntry.Parent.FillISOData(Primary);
    RootDir.LocationOfExtent := ADirEntry.Parent.ISOData.LocationOfExtent;
  end;
  FileID := $01;
  ISOStream.Stream.Write(RootDir, sizeof(TDirectoryrecord));
  ISOStream.Stream.Write(FileID, sizeof(FileID)); // write file identifier
  // done with "." ".."

  for DirIndex := 0 to ADirEntry.DirectoryCount - 1 do // write directories
  begin
    Dir := ADirEntry.Directories[DirIndex];
    Dir.FillISOData(Primary);
    ISOStream.Stream.Write(Dir.ISOData, sizeof(TDirectoryrecord));
    if Primary = True then
    begin
      TempPchar := pchar(Dir.Name);
      ISOStream.Stream.Write(TempPchar^, Dir.ISOData.LengthOfFileIdentifier);
    end
    else
    begin
      TempPWideChr := Dir.GetWideDirName;
      FillChar(WideArray, 128, 0);
      CopyMemory(@WideArray[1], @TempPWideChr[0],
        (Dir.ISOData.LengthOfFileIdentifier) - 1); //makes it big endian wide char
      ISOStream.Stream.Write(WideArray, Dir.ISOData.LengthOfFileIdentifier);
    end;

    DIRRecSize := sizeof(TDirectoryrecord) + Dir.ISOData.LengthOfFileIdentifier;
      // get padding size
    if (DIRRecSize mod 2) > 0 then
      FImage.Stream.Write(PadByte, 1);
  end;

  for FileIndex := 0 to ADirEntry.FileCount - 1 do // write files
  begin
    Fil := ADirEntry.Files[FileIndex];
    Fil.FillISOData(Primary);
    ISOStream.Stream.Write(Fil.ISOData, sizeof(TDirectoryrecord));
    if Primary = True then
    begin
      TempPchar := pchar(Fil.Name);
      ISOStream.Stream.Write(TempPchar^, Fil.ISOData.LengthOfFileIdentifier);
    end
    else
    begin
      TempPWideChr := Fil.GetWideFileName;
      FillChar(WideArray, 128, 0);
      CopyMemory(@WideArray[1], @TempPWideChr[0],
        (Fil.ISOData.LengthOfFileIdentifier) - 1); //makes it big endian wide char
      ISOStream.Stream.Write(WideArray, Fil.ISOData.LengthOfFileIdentifier);
    end;

    DIRRecSize := sizeof(TDirectoryrecord) + Fil.ISOData.LengthOfFileIdentifier;
      // get padding size
    if (DIRRecSize mod 2) > 0 then
      FImage.Stream.Write(PadByte, 1);
  end;

  //pad the remainder of the block
  Padd := 2048 - (ISOstream.Stream.Position mod 2048);
  if Padd < 2048 then
    ISOStream.Stream.Write(FillBlock, Padd);

  for DirIndex := 0 to ADirEntry.DirectoryCount - 1 do // Rescan directories
  begin
    Dir := ADirEntry.Directories[DirIndex];
    WriteStructureTree(Primary, ISOStream, Dir);
  end;

  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('Write Structure', 'Current Pos After Structure: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));

  Log('SaveImage',
    '|----------------------------------------------------------|');
end;

procedure TISOImage.WriteFileData(ISOStream: TImageStreamHandler; ADirEntry:
  TDirectoryEntry);
var
  DirIndex, FileIndex, Padd: Integer;
  Dir: TDirectoryEntry;
  Fil: TFileEntry;
  TempPchar: PChar;
  PadByte: Byte;
  FillBlock: array[0..2047] of Byte;
  CDFile: TfileStream;

begin
  PadByte := 0;
  FillChar(FillBlock, 2048, 0);

  for FileIndex := 0 to ADirEntry.FileCount - 1 do // write files
  begin
    Fil := ADirEntry.Files[FileIndex];
    CDFile := TfileStream.Create(Fil.SourceFileName, fmOpenRead);
    CDFile.Seek(0, soFromBeginning);
    ISOStream.Stream.CopyFrom(CDFile, CDFile.Size);
    CDFile.Free;
  end;

  //pad the remainder of the block
  Padd := 2048 - (ISOstream.Stream.Position mod 2048);
  if Padd < 2048 then
    ISOStream.Stream.Write(FillBlock, Padd);

  for DirIndex := 0 to ADirEntry.DirectoryCount - 1 do // Rescan directories
  begin
    Dir := ADirEntry.Directories[DirIndex];
    WriteFileData(ISOStream, Dir);
  end;
end;

procedure TISOImage.WritePathTableData(ISOStream: TImageStreamHandler;
  CurrentPointer: Integer);
var
  Index: Integer;
  TempPchar, TempPadChar: Pchar;
  PathRec: PPathTableRecord;
  StreamPos: Integer;
  ReverseByte: Cardinal;
  CurrentStreamPointer, PadBytes, Sector: Integer;
begin
  TempPadChar := $00;
  CurrentStreamPointer := CurrentPointer;
  // write out little endian path table sector 19
  for Index := 0 to FTree.PathTableCount - 1 do
  begin
    PathRec := FTree.LittleEndianPathTable.Items[Index];
    Log('SaveImage', 'Write Dir LPath Name: ' + PathRec^.DirectoryIdentifier);
    FImage.Stream.Write(PathRec^.LengthOfDirectoryIdentifier, 1);
      //ISO Path Table L
    FImage.Stream.Write(PathRec^.ExtendedAttributeRecordLength, 1);
    FImage.Stream.Write(PathRec^.LocationOfExtent, 4);
    FImage.Stream.Write(PathRec^.ParentDirectoryNumber, 2);
    TempPchar := PathRec^.DirectoryIdentifier;
    FImage.Stream.Write(TempPchar^, PathRec^.LengthOfDirectoryIdentifier);
    if (PathRec^.LengthOfDirectoryIdentifier mod 2) > 0 then
      FImage.Stream.Write(TempPadChar, 1);
  end;
  StreamPos := FImage.Stream.Position;
  PadBytes := 2048 - (StreamPos - CurrentStreamPointer); // pad out to 2048
  for Index := 1 to PadBytes do
    FImage.Stream.Write(TempPadChar, 1);
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After LPath Tables: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));

  CurrentStreamPointer := FImage.Stream.Position;
  Log('SaveImage',
    '|----------------------------------------------------------|');
  // write out big endian path table sector 20
  for Index := 0 to FTree.PathTableCount - 1 do
  begin
    PathRec := FTree.LittleEndianPathTable.Items[Index];
    Log('SaveImage', 'Write Dir MPath Name: ' + PathRec^.DirectoryIdentifier);
    FImage.Stream.Write(PathRec^.LengthOfDirectoryIdentifier, 1);
      //ISO Path Table L
    FImage.Stream.Write(PathRec^.ExtendedAttributeRecordLength, 1);
    FImage.Stream.Write(PathRec^.LocationOfExtentM, 4);
    ReverseByte := SwapWord(PathRec^.ParentDirectoryNumber);
      // reverse to big endian
    FImage.Stream.Write(ReverseByte, 2);
    TempPchar := PathRec^.DirectoryIdentifier;
    FImage.Stream.Write(TempPchar^, PathRec^.LengthOfDirectoryIdentifier);
    if (PathRec^.LengthOfDirectoryIdentifier mod 2) > 0 then
      FImage.Stream.Write(TempPadChar, 1); // padding byte
  end;

  StreamPos := FImage.Stream.Position;
  PadBytes := 2048 - (StreamPos - CurrentStreamPointer); // pad out to 2048
  for Index := 1 to PadBytes do
    FImage.Stream.Write(TempPadChar, 1);
  Log('SaveImage',
    '|----------------------------------------------------------|');
  // end of path table
end;

procedure TISOImage.WriteJolietPathTableData(ISOStream: TImageStreamHandler;
  CurrentPointer: Integer);
var
  Index: Integer;
  TempPchar, TempPadChar: Pchar;
  PathRec: PPathTableRecord;
  StreamPos: Integer;
  ReverseByte: Cardinal;
  SectorOffsett: Integer;
  ReverseOffsett: LongWord;
  CurrentStreamPointer, PadBytes, Sector: Integer;
begin
  TempPadChar := $00;
  SectorOffsett := (FTree.JolietOffsett - FTree.DIRStartLBA);

  CurrentStreamPointer := CurrentPointer;
  // write out little endian path table sector 21
  for Index := 0 to FTree.PathTableCount - 1 do
  begin
    PathRec := FTree.LittleEndianPathTable.Items[Index];
    Log('SaveImage', 'Write Dir Joliet LPath Name: ' +
      PathRec^.DirectoryIdentifierM);
    FImage.Stream.Write(PathRec^.LengthOfDirectoryIdentifierM, 1);
      //ISO Path Table L
    FImage.Stream.Write(PathRec^.ExtendedAttributeRecordLength, 1);
    PathRec^.JolietLocationOfExtent := (PathRec^.LocationOfExtent +
      SectorOffsett);
    FImage.Stream.Write(PathRec^.JolietLocationOfExtent, 4);
    FImage.Stream.Write(PathRec^.ParentDirectoryNumber, 2);
    TempPchar := PathRec^.DirectoryIdentifierM;
    FImage.Stream.Write(TempPchar^, PathRec^.LengthOfDirectoryIdentifierM);
    if (PathRec^.LengthOfDirectoryIdentifierM mod 2) > 0 then
      FImage.Stream.Write(TempPadChar, 1);
  end;
  StreamPos := FImage.Stream.Position;
  PadBytes := 2048 - (StreamPos - CurrentStreamPointer); // pad out to 2048
  for Index := 1 to PadBytes do
    FImage.Stream.Write(TempPadChar, 1);
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After LPath Tables: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));

  CurrentStreamPointer := FImage.Stream.Position;
  Log('SaveImage',
    '|----------------------------------------------------------|');
  // write out big endian path table sector 22
  for Index := 0 to FTree.PathTableCount - 1 do
  begin
    PathRec := FTree.LittleEndianPathTable.Items[Index];
    Log('SaveImage', 'Write Dir Joliet MPath Name: ' +
      PathRec^.DirectoryIdentifierM[0]);
    FImage.Stream.Write(PathRec^.LengthOfDirectoryIdentifierM, 1);
      //ISO Path Table L
    FImage.Stream.Write(PathRec^.ExtendedAttributeRecordLength, 1);
    PathRec^.JolietLocationOfExtentM :=
      SwapDWord(PathRec^.JolietLocationOfExtent);
    FImage.Stream.Write(PathRec^.JolietLocationOfExtentM, 4);
    ReverseByte := SwapWord(PathRec^.ParentDirectoryNumber);
      // reverse to big endian
    FImage.Stream.Write(ReverseByte, 2);
    TempPchar := PathRec^.DirectoryIdentifierM;
    FImage.Stream.Write(TempPchar^, PathRec^.LengthOfDirectoryIdentifierM);
    if (PathRec^.LengthOfDirectoryIdentifierM mod 2) > 0 then
      FImage.Stream.Write(TempPadChar, 1); // padding byte
  end;
  StreamPos := FImage.Stream.Position;
  PadBytes := 2048 - (StreamPos - CurrentStreamPointer); // pad out to 2048
  for Index := 1 to PadBytes do
    FImage.Stream.Write(TempPadChar, 1);
  Log('SaveImage',
    '|----------------------------------------------------------|');
  // end of path table
end;

function TISOImage.SaveImageToDisk(Mode: Integer): Boolean;

var
  StreamPos: Integer;
  StartLBA, FileStartBlock: Integer;
  TempPchar, TempPadChar: Pchar;
  TempString: string;
  ReverseByte: Cardinal;
  Index: Integer;
  PathRec: PPathTableRecord;
  CurrentStreamPointer, PadBytes, Sector: Integer;

begin
  Result := False;
  TempPadChar := $00;
  Sector := 0;
  StartLBA := 22;
  FileStartBlock := 150;
  if FFileName = '' then
  begin
    Log('SaveImage', 'No Filename Entered!');
    exit;
  end;

  case Mode of
    1: FImage := TImageStreamHandler.Create(FFileName, ybfMode1,
      ifCompleteSectors);
    2: FImage := TImageStreamHandler.Create(FFileName, ybfMode2,
      ifCompleteSectors);
  end;

  if (FImage.ISOBookFormat = ybfMode1) then
    Log('SaveImage', 'Yellow book mode 1')
  else if (FImage.ISOBookFormat = ybfMode2) then
    Log('SaveImage', 'Yellow book mode 2');

  Log('SaveImage', 'User data sector size is ' + IntToStr(FImage.SectorDataSize)
    + ' bytes');
  Log('SaveImage', 'Image data offset in image file is ' +
    IntToStr(FImage.ImageOffset) + ' bytes');

  if (FImage.SectorDataSize <> 2048) then
  begin
    Log('SaveImage',
      'sorry, but sector size other than 2048 bytes are not yet supported...');
    Exit;
  end;

  // Setup Directory tree and path tables
  FTree.RefreshPathTables(StartLBA, FileStartBlock);
  FTree.SortDirectories;
  Log('SaveImage', 'Refresh Path Tables');

  // Setup Root Directory tree and Fill Data
  FTree.RootDirectory.FillRootISOData(True);
  FTree.RootDirectory.SetupRootDirectoryLocationOfExtent(FTree.RootDirectory.StartLBA);
  Log('SaveImage', 'Fill Root Directory Data');

  // Start writing image data to file
  Log('SaveImage',
    '|----------------------------------------------------------|');
  FImage.Stream.Write(FISOHeader, sizeof(FISOHeader)); //ISO Header 32k
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Write ISO Header : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //setup primary volume descriptor
  FPVDClass.VolumeIdentifier := FVolID;
  FPVDClass.VolumeSpaceSize := BuildBothEndianDWord(FTree.FileLBA +
    FTree.FileBlocks);
  FPVDClass.PathTableSize := BuildBothEndianDWord(FTree.PathTableLength);
  copymemory(@FPVDClass.Descriptor.Primary.RootDirectory,
    @FTree.RootDirectory.RootISOData, sizeof(TRootDirectoryRecord));
  FImage.Stream.Write(FPVDClass.Descriptor, sizeof(FPVDClass.Descriptor));
    //ISO Primary Volume Descriptor
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Write ISO Primary Volume Descriptor : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //setup secondary volume descriptor
  FSVDClass.VolumeIdentifier := FVolID;
  FSVDClass.VolumeSpaceSize := BuildBothEndianDWord(FTree.FileLBA +
    FTree.FileBlocks);
  FSVDClass.PathTableSize := BuildBothEndianDWord(FTree.JolietPathTableLength);
  copymemory(@FSVDClass.Descriptor.Supplementary.RootDirectory,
    @FTree.RootDirectory.RootISOData, sizeof(TRootDirectoryRecord));
  FSVDClass.ResetRootExtent(FTree.JolietOffsett + 1);
    // make sure it starts in the right place
  FImage.Stream.Write(FSVDClass.Descriptor, sizeof(FSVDClass.Descriptor));
    //ISO Secondary Volume Descriptor
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Write ISO Secondary Volume Descriptor :' +
    inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  // write out boot record descriptor
    // Image.Stream.Write(FBRClass.Descriptor,sizeof(FBRClass.Descriptor));  //ISO Boot Record
    // Log('SaveImage', 'Write ISO Boot Record');

  // write volume set terminator
  FImage.Stream.Write(FVDSTClass, sizeof(FVDSTClass));
    //ISO Volume Set Terminator
  Log('SaveImage', 'Write Volume Set Terminator');

  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Volume Descriptors: ' +
    inttostr(CurrentStreamPointer) + ' : ' + inttohex(CurrentStreamPointer, 6) +
    ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //write out Primary path table
  WritePathTableData(FImage, CurrentStreamPointer);
  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Pri Path Tables: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //write out Supplemental path table
  WriteJolietPathTableData(FImage, CurrentStreamPointer);
  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Sup Path Tables: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  // write directory and file tables start with root sector 23 start
  WriteRootStructureTree(True, FImage, FTree.RootDirectory);
  Log('SaveImage', 'Joliet Offsett: ' + inttostr(FTree.JolietOffsett));

  // write Joliet directory and file tables start with FTree.JolietOffsett
  FTree.RefreshPathTables(FTree.JolietOffsett, FileStartBlock);
  FTree.RootDirectory.FillRootISOData(False);
  WriteRootStructureTree(False, FImage, FTree.RootDirectory);

  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Write Structure: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //Fill Up Gap to 150 sectors
  PadBytes := (FTree.FileStartBlock * 2048); // get size
  CurrentStreamPointer := FImage.Stream.Position; // get current position
  PadBytes := (PadBytes - CurrentStreamPointer); // pad number
  for Index := 1 to PadBytes do
    FImage.Stream.Write(TempPadChar, 1); // pad out sectors
  Log('SaveImage',
    '|----------------------------------------------------------|');

  // load up and write out files data
  WriteFileData(FImage, FTree.RootDirectory);
  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Write File Data: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  FImage.Free;
  FImage := nil;
  Result := True;
end;



function TISOImage.SaveDVDImageToDisk: Boolean;

var
  StreamPos: Integer;
  StartLBA, FileStartBlock: Integer;
  TempPchar, TempPadChar: Pchar;
  TempString: string;
  ReverseByte: Cardinal;
  Index: Integer;
  PathRec: PPathTableRecord;
  CurrentStreamPointer, PadBytes, Sector: Integer;

begin
  Result := False;
  TempPadChar := $00;
  Sector := 0;
  StartLBA := 256;
  FileStartBlock := 300;
  if FFileName = '' then
  begin
    Log('SaveImage', 'No Filename Entered!');
    exit;
  end;

  FImage := TImageStreamHandler.Create(FFileName, ybfMode1, ifCompleteSectors);

  if (FImage.ISOBookFormat = ybfMode1) then
    Log('SaveImage', 'Yellow book mode 1')
  else if (FImage.ISOBookFormat = ybfMode2) then
    Log('SaveImage', 'Yellow book mode 2');

  Log('SaveImage', 'User data sector size is ' + IntToStr(FImage.SectorDataSize)
    + ' bytes');
  Log('SaveImage', 'Image data offset in image file is ' +
    IntToStr(FImage.ImageOffset) + ' bytes');

  if (FImage.SectorDataSize <> 2048) then
  begin
    Log('SaveImage',
      'sorry, but sector size other than 2048 bytes are not yet supported...');
    Exit;
  end;

  // Setup Directory tree and path tables (move to 256 for dvd video)
  FTree.RefreshPathTables(StartLBA, FileStartBlock);
  FTree.SortDirectories;
  Log('SaveImage', 'Refresh Path Tables');

  // Setup Root Directory tree and Fill Data
  FTree.RootDirectory.FillRootISOData(True);
  FTree.RootDirectory.SetupRootDirectoryLocationOfExtent(FTree.RootDirectory.StartLBA);
  Log('SaveImage', 'Fill Root Directory Data');

  // Start writing image data to file
  Log('SaveImage',
    '|----------------------------------------------------------|');
  FImage.Stream.Write(FISOHeader, sizeof(FISOHeader)); //ISO Header 32k
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Write ISO Header : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //setup primary volume descriptor
  FPVDClass.VolumeIdentifier := FVolID;
  FPVDClass.VolumeSpaceSize := BuildBothEndianDWord(FTree.FileLBA +
    FTree.FileBlocks);
  FPVDClass.PathTableSize := BuildBothEndianDWord(FTree.PathTableLength);
  copymemory(@FPVDClass.Descriptor.Primary.RootDirectory,
    @FTree.RootDirectory.RootISOData, sizeof(TRootDirectoryRecord));
  FImage.Stream.Write(FPVDClass.Descriptor, sizeof(FPVDClass.Descriptor));
    //ISO Primary Volume Descriptor
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Write ISO Primary Volume Descriptor : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //setup secondary volume descriptor
  FSVDClass.VolumeIdentifier := FVolID;
  FSVDClass.VolumeSpaceSize := BuildBothEndianDWord(FTree.FileLBA +
    FTree.FileBlocks);
  FSVDClass.PathTableSize := BuildBothEndianDWord(FTree.JolietPathTableLength);
  copymemory(@FSVDClass.Descriptor.Supplementary.RootDirectory,
    @FTree.RootDirectory.RootISOData, sizeof(TRootDirectoryRecord));
  FSVDClass.ResetRootExtent(FTree.JolietOffsett + 1);
    // make sure it starts in the right place
  FImage.Stream.Write(FSVDClass.Descriptor, sizeof(FSVDClass.Descriptor));
    //ISO Secondary Volume Descriptor
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Write ISO Secondary Volume Descriptor :' +
    inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  // write out boot record descriptor
    // Image.Stream.Write(FBRClass.Descriptor,sizeof(FBRClass.Descriptor));  //ISO Boot Record
    // Log('SaveImage', 'Write ISO Boot Record');

  // write volume set terminator
  FImage.Stream.Write(FVDSTClass, sizeof(FVDSTClass));
    //ISO Volume Set Terminator
  Log('SaveImage', 'Write Volume Set Terminator');

  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Volume Descriptors: ' +
    inttostr(CurrentStreamPointer) + ' : ' + inttohex(CurrentStreamPointer, 6) +
    ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //write out Primary path table
  WritePathTableData(FImage, CurrentStreamPointer);
  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Pri Path Tables: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //write out Supplemental path table
  WriteJolietPathTableData(FImage, CurrentStreamPointer);
  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Sup Path Tables: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  // write directory and file tables start with root sector 23 start
  WriteRootStructureTree(True, FImage, FTree.RootDirectory);
  Log('SaveImage', 'Joliet Offsett: ' + inttostr(FTree.JolietOffsett));

  // write Joliet directory and file tables start with FTree.JolietOffsett
  FTree.RefreshPathTables(FTree.JolietOffsett, FileStartBlock);
  FTree.RootDirectory.FillRootISOData(False);
  WriteRootStructureTree(False, FImage, FTree.RootDirectory);

  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Write Structure: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  //Fill Up Gap to DVD size sectors
  PadBytes := (FTree.FileStartBlock * 2048); // get size
  CurrentStreamPointer := FImage.Stream.Position; // get current position
  PadBytes := (PadBytes - CurrentStreamPointer); // pad number
  for Index := 1 to PadBytes do
    FImage.Stream.Write(TempPadChar, 1); // pad out sectors
  Log('SaveImage',
    '|----------------------------------------------------------|');

  // load up and write out files data
  WriteFileData(FImage, FTree.RootDirectory);
  CurrentStreamPointer := FImage.Stream.Position;
  Sector := (FImage.Stream.Position div FImage.SectorDataSize);
  Log('SaveImage', 'Current Pos After Write File Data: ' +
    inttostr(FImage.Stream.Position) + ' : ' + inttohex(FImage.Stream.Position, 6)
    + ' : ' + inttostr(Sector));
  Log('SaveImage',
    '|----------------------------------------------------------|');

  FImage.Free;
  Result := True;
end;





function TISOImage.ParseDirectory(const AUsePrimaryVD: Boolean): Boolean;
var
  DirRootSourceRec: TRootDirectoryRecord;
  EndSector: Cardinal;
  DR: PDirectoryRecord;
  SecFileName: string;
  RecordSize: Integer;
  lWorkPtr,
    lBuffer: PByte;
begin
  Result := False;
  //RecordSize := SizeOf(TRootDirectoryRecord);
  RecordSize := SizeOf(TDirectoryRecord);
  if (AUsePrimaryVD) then
  begin
    Log('ParseDirectory', 'Parsing Directory Using Primary Volume Descriptor');
    DirRootSourceRec := fPVDClass.Descriptor.Primary.RootDirectory;
  end
  else
  begin
    Log('ParseDirectory',
      'Parsing Directory Using Supplementary Volume Descriptor...');
    if Assigned(fSVDClass) then
      DirRootSourceRec := fSVDClass.Descriptor.Primary.RootDirectory
    else
    begin
      Log('ParseDirectory', 'No Supplementary Volume Descriptor Found!');
      Log('ParseDirectory', 'Using Primary Volume Descriptor.');
      DirRootSourceRec := fPVDClass.Descriptor.Primary.RootDirectory;
    end;
  end;

  Log('ParseDirectory', 'directory sector ' +
    IntToStr(DirRootSourceRec.LocationOfExtent.LittleEndian));

  EndSector := DirRootSourceRec.LocationOfExtent.LittleEndian +
    (DirRootSourceRec.DataLength.LittleEndian + fImage.SectorDataSize - 1) div
      fImage.SectorDataSize;

  fImage.SeekSector(DirRootSourceRec.LocationOfExtent.LittleEndian);

  GetMem(lBuffer, fImage.SectorDataSize);
  try
    lWorkPtr := lBuffer;
    fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);

    while (fImage.CurrentSector <= EndSector) do
    begin
      if (fImage.SectorDataSize - (Cardinal(lWorkPtr) - Cardinal(lBuffer))) <
        RecordSize then
      begin
        lWorkPtr := lBuffer;
        fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);
      end;

      New(DR);
      Move(lWorkPtr^, DR^, RecordSize);
      Inc(lWorkPtr, RecordSize); // move pointer across

      SetLength(SecFileName, DR.LengthOfFileIdentifier);
      Move(lWorkPtr^, SecFileName[1], DR.LengthOfFileIdentifier);
      Inc(lWorkPtr, DR.LengthOfFileIdentifier);

      // padding bytes
      if ((RecordSize + DR.LengthOfFileIdentifier) < DR.LengthOfDirectoryRecord)
        then
        Inc(lWorkPtr, DR.LengthOfDirectoryRecord - RecordSize -
          DR.LengthOfFileIdentifier);

      ParseDirectorySub(FTree.RootDirectory, SecFileName, DR);
    end;
  finally
    FreeMem(lBuffer, fImage.SectorDataSize);
  end;
end;


function TISOImage.ParseDirectorySub(AParentDir: TDirectoryEntry; const
  AFileName: string; var ADirectoryEntry: PDirectoryRecord): Boolean;
var
  EndSector: Cardinal;
  OldPosition: Integer;
  ActDir: TDirectoryEntry;
  FileEntry: TFileEntry;
  DRFileName: string;
  DR: PDirectoryRecord;
  RecordSize: Integer;
  lWorkPtr,
    lBuffer: PByte;
begin
  if (ADirectoryEntry.FileFlags and $2) = $2 then // directory
  begin
    OldPosition := fImage.CurrentSector;
    RecordSize := SizeOf(TDirectoryRecord);
    if (AFileName <> #0) and (AFileName <> #1) then
    begin
      ActDir := TDirectoryEntry.Create(fTree, AParentDir, dsfFromImage);
      ActDir.Name := UnicodeToStr(AFileName);
      ActDir.ISOData := ADirectoryEntry^;
      fImage.SeekSector(ADirectoryEntry.LocationOfExtent.LittleEndian);
      EndSector := ADirectoryEntry.LocationOfExtent.LittleEndian +
        (ADirectoryEntry.DataLength.LittleEndian + fImage.SectorDataSize - 1) div
          fImage.SectorDataSize;

      Dispose(ADirectoryEntry);
      ADirectoryEntry := nil;

      GetMem(lBuffer, fImage.SectorDataSize);
      try
        lWorkPtr := lBuffer;
        fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);

        while (fImage.CurrentSector <= EndSector) do
        begin
          if (fImage.SectorDataSize - (Cardinal(lWorkPtr) - Cardinal(lBuffer)))
            < RecordSize then
          begin
            lWorkPtr := lBuffer;
            fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);
          end;

          New(DR);
          Move(lWorkPtr^, DR^, RecordSize);
          Inc(lWorkPtr, RecordSize);

          SetLength(DRFileName, DR.LengthOfFileIdentifier);
          Move(lWorkPtr^, DRFileName[1], DR.LengthOfFileIdentifier);
          Inc(lWorkPtr, DR.LengthOfFileIdentifier);

          // padding bytes
          if ((RecordSize + DR.LengthOfFileIdentifier) <
            DR.LengthOfDirectoryRecord) then
            Inc(lWorkPtr, DR.LengthOfDirectoryRecord - RecordSize -
              DR.LengthOfFileIdentifier);

          ParseDirectorySub(ActDir, DRFileName, DR);
        end;
      finally
        FreeMem(lBuffer, fImage.SectorDataSize);
      end;
    end;

    fImage.SeekSector(OldPosition);
  end
  else
  begin
    if (AFileName <> '') and (ADirectoryEntry.DataLength.LittleEndian > 0) then
    begin
      FileEntry := TFileEntry.Create(AParentDir, dsfFromImage);
      FileEntry.Name := UnicodeToStr(AFileName);
      FileEntry.ISOData := ADirectoryEntry^;
    end;
  end;
  Result := True;
end;

function TISOImage.ParsePathTable(ATreeView: TTreeView): Boolean;
var
  PathTableEntry: TPathTableRecord;
  FileName: string;
  SectorCount: Cardinal;
  Node: TTreeNode;
  PathTabelEntryNumber: Integer;
  lWorkPtr,
    lBuffer: PByte;
  i: Integer;
  IDLength: Integer;

  function FindParent(const AParentPathNumber: Integer): TTreeNode;
  begin
    Result := ATreeView.Items.GetFirstNode;
    while (Integer(Result.Data) <> AParentPathNumber) do
      Result := Result.GetNext;
  end;

begin
  Result := False;

  Log('ParsePathTable', 'path table first sector ' +
    IntToStr(fPVDClass.Descriptor.Primary.LocationOfTypeLPathTable));
  Log('ParsePathTable', 'path table length ' +
    IntToStr(fPVDClass.Descriptor.Primary.PathTableSize.LittleEndian) + ' bytes');

  if (Assigned(ATreeView)) then
    ATreeView.Items.Clear;

  SectorCount := (fPVDClass.Descriptor.Primary.PathTableSize.LittleEndian +
    fImage.SectorDataSize - 1) div fImage.SectorDataSize;

  fImage.SeekSector(fPVDClass.Descriptor.Primary.LocationOfTypeLPathTable);

  GetMem(lBuffer, SectorCount * fImage.SectorDataSize);
  lWorkPtr := lBuffer;
  try
    PathTabelEntryNumber := 0;

    for i := 1 to SectorCount do
    begin
      fImage.ReadSector_Data(lWorkPtr^, fImage.SectorDataSize);
      Inc(lWorkPtr, fImage.SectorDataSize);
    end;

    lWorkPtr := lBuffer;

    repeat
      FillChar(PathTableEntry, sizeof(PathTableEntry), 0);
      Move(lWorkPtr^, PathTableEntry.LengthOfDirectoryIdentifier, 1);
      Inc(lWorkPtr, 1);
      Move(lWorkPtr^, PathTableEntry.ExtendedAttributeRecordLength, 1);
      Inc(lWorkPtr, 1);
      Move(lWorkPtr^, PathTableEntry.LocationOfExtent, 4);
      Inc(lWorkPtr, 4);
      Move(lWorkPtr^, PathTableEntry.ParentDirectoryNumber, 2);
      Inc(lWorkPtr, 2);
      Move(lWorkPtr^, PathTableEntry.DirectoryIdentifier,
        PathTableEntry.LengthOfDirectoryIdentifier);
      Inc(lWorkPtr, PathTableEntry.LengthOfDirectoryIdentifier);

      FileName := PathTableEntry.DirectoryIdentifier;

      if (Odd(PathTableEntry.LengthOfDirectoryIdentifier)) then
        Inc(lWorkPtr, 1);

      Inc(PathTabelEntryNumber);

      if (PathTableEntry.LengthOfDirectoryIdentifier = 1) then
      begin
        if (Assigned(ATreeView)) and (PathTabelEntryNumber = 1) then
        begin
          Node := ATreeView.Items.AddChild(nil, '/');
          Node.Data := Pointer(PathTabelEntryNumber);
        end;
      end
      else
      begin
        if (Assigned(ATreeView)) then
        begin
          Node := ATreeView.Items.AddChild(FindParent(PathTableEntry.ParentDirectoryNumber), FileName);
          Node.Data := Pointer(PathTabelEntryNumber);
        end;
      end;
    until ((Cardinal(lWorkPtr) - Cardinal(lBuffer)) >=
      (fPVDClass.Descriptor.Primary.PathTableSize.LittleEndian - 2));
  finally
    FreeMem(lBuffer, SectorCount * fImage.SectorDataSize);
  end;
end;

end.
