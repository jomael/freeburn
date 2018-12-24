{-----------------------------------------------------------------------------
 Unit Name: ISO9660ImageTree
 Author:    Daniel Mann / Thomas Koos (original class) Dancemammal
 Purpose:   Create ISO9660 Image (Structure only)
 History:   Code originally from TISOlib

-----------------------------------------------------------------------------}


unit ISO9660ImageTree;

interface

uses
  SysUtils,
  CovertFuncs,
  Classes,
  Windows,
  Contnrs,
  ISO9660ClassTypes;



Const
       FilesPerBlock = 30; // fix for this problem

type
   TListSortCompare = function (Item1,Item2: Pointer): Integer;


Type
  TImageTree = Class;  // forward declaration
  TFileEntry = Class; // forward declaration

  TDataSourceFlag = (dsfFromImage, dsfFromLocal, dsfOldSession);
  TEntryFlags     = (efNone, efAdded, efDeleted, efModified);



TDirectoryEntry = Class
  Private
    Function GetDirCount: Integer;
    Function GetFileCount: Integer;
    Function GetDirEntry(Index: Integer): TDirectoryEntry;
    Function GetFileEntry(Index: Integer): TFileEntry;
  Protected
    FDirID       : Integer;
    FImageTree   : TImageTree;
    FParent      : TDirectoryEntry;
    FParentID    : Integer;
    FDirectories : TObjectList;
    FFiles       : TObjectList;
    FSource      : TDataSourceFlag;
    FFlags       : TEntryFlags;
    FISOData     : TDirectoryRecord;
    FRootISOData : TRootDirectoryRecord;
    FName        : String;
    FWideName    : PWideChar;
    FBlocks      : Integer;
    FLBAStart    : Integer;
    LastError    : String;
    Function    AddFile(AFileEntry : TFileEntry): Integer;
    Function    DelFile(AFileEntry : TFileEntry): Boolean;
    Function    AddDirectory(ADirEntry : TDirectoryEntry): Integer;
    Function    BlockCount(Primary: Boolean): Integer;
  Public
    Constructor Create(AImageTree : TImageTree; AParentDir : TDirectoryEntry; Const ASource : TDataSourceFlag); Virtual;
    Destructor  Destroy; Override;
    Procedure   CreateLBAStart(Primary: Boolean; var Start : integer);
  //  Procedure   CreateLBAStart(var Start : integer);
    Property    Files[Index: Integer]: TFileEntry             Read GetFileEntry;
    Property    Directories[Index: Integer]: TDirectoryEntry  Read GetDirEntry;
    Function    DelDirectory(ADirEntry : TDirectoryEntry): Boolean;
    Function    DeleteFile(AFileEntry : TFileEntry): Boolean;
    Procedure   MoveDirTo(ANewDirectory : TDirectoryEntry);
    Procedure   FillISOData(Primary : Boolean);
    Procedure   FillRootISOData(Primary : Boolean);
    Procedure   SetupRootDirectoryLocationOfExtent(Extent : Integer);
    Function    GetWideDirName : PWideChar;
  Published
    Property    FileCount      : Integer           Read  GetFileCount;
    Property    DirectoryCount : Integer           Read  GetDirCount;
    Property    Parent         : TDirectoryEntry   Read  FParent;
    Property    Name           : String            Read  FName Write FName;
    Property    ISOData        : TDirectoryRecord  Read  FISOData Write FISOData;
    Property    RootISOData    : TRootDirectoryRecord  Read  FRootISOData Write FRootISOData;
    Property    SourceOfData   : TDataSourceFlag   Read  FSource;
    Property    Flags          : TEntryFlags       Read  FFlags;
    Property    Blocks         : Integer           Read  FBlocks;
    Property    StartLBA       : Integer           Read  FLBAStart;
    Property    ParentID       : Integer           Read  FParentID  Write FParentID;
    Property    DirID          : Integer           Read  FDirID  Write FDirID;
  End;



TFileEntry = Class
  Private
    Function    GetFullPath: String;
  Protected
    FDirectory   : TDirectoryEntry;
    FName        : String;
    FWideName    : PWideChar;
    FSource      : TDataSourceFlag;
    FFlags       : TEntryFlags;
    FISOData     : TDirectoryRecord;
    FSourceFile  : String;
    FSourceBlockSize : Integer;
    LastError    : String;
    FLBAStart    : Integer;
    Function    GetCDFSSize(FileSize : Integer) : Integer;
  Public
    Constructor Create(ADirectoryEntry : TDirectoryEntry; Const ASource : TDataSourceFlag); Virtual;
    Destructor  Destroy; Override;
    Procedure   MoveTo(ANewDirectoryEntry: TDirectoryEntry);
    Procedure   FillISOData(Primary : Boolean);
    Procedure   CreateLBAStart( var StartBlock : integer);
    Function    GetWideFileName : PWideChar;
  Published
    Property    Name            : String              Read  FName  Write FName;
    Property    Path            : String              Read  GetFullPath;
      // ISO Data
    Property    ISOData         : TDirectoryRecord    Read  FISOData Write FISOData;
    Property    SourceOfData    : TDataSourceFlag     Read  FSource;
    Property    Flags           : TEntryFlags         Read  FFlags;
    Property    SourceFileName  : String              Read  FSourceFile Write FSourceFile;
    Property    BlockSize       : Integer             Read  FSourceBlockSize;
    Property    StartLBA        : Integer             Read  FLBAStart;
  End;



TImageTree = Class
  Private
  Protected
    FRootDir : TDirectoryEntry;
    FLittleEndianPathTable : TList;
    FPathTableCount : Integer;
    FCurrentPathTableCount : Integer;
    FPathTableStopSector : Integer;
    FFileBlocks : Integer;
    LastError : String;
    FFileStartBlock : Integer;
    FJolietOffsett : Integer;
    FDirectoryStartLBA : Integer;
    Procedure AddDirectory(CurrentDir : TDirectoryEntry ; Parent : Integer);
    Procedure RecurseFiles(CurrentDir : TDirectoryEntry);
    Procedure ScanAllDirectories(CurrentDir : TDirectoryEntry ; Parent : Integer);
    Procedure ClearPathTables;
    Function GetPathTableLength : Integer;
    Function GetJolietPathTableLength : Integer;
    Function GetTableCount : Integer;
  Public
    CurrentLBA : Integer;
    FileLBA    : Integer;
    Constructor Create; Virtual;
    Destructor  Destroy; Override;
    Procedure   RefreshPathTables(StartLBA, FileBlock : Integer);
    procedure   SortDirectories;
    Function    GetLastError : String;
  Published
    Property    RootDirectory : TDirectoryEntry   Read  fRootDir;
    Property    LittleEndianPathTable : TList   Read  FLittleEndianPathTable;
    Property    PathTableCount : Integer Read GetTableCount;
    Property    PathTableStopSector : Integer Read FPathTableStopSector;
    Property    FileBlocks : Integer Read FFileBlocks;
    Property    FileStartBlock : Integer Read FFileStartBlock;
    Property    PathTableLength : Integer Read GetPathTableLength;
    Property    JolietPathTableLength : Integer Read GetJolietPathTableLength;
    Property    JolietOffsett : Integer Read FJolietOffsett write FJolietOffsett;
    Property    DIRStartLBA : Integer Read FDirectoryStartLBA write FDirectoryStartLBA;
  End;


implementation



{ TDirectoryEntry }

Function TDirectoryEntry.AddDirectory(ADirEntry: TDirectoryEntry): Integer;
Begin
  If ( FDirectories.IndexOf(ADirEntry) > -1 ) Then  LastError := ('Directory entry already added');
  If ( Assigned(ADirEntry.FParent) ) And ( ADirEntry.FParent <> Self ) Then
       LastError := ('Directory entry already added - use MoveDirTo() instead!');
  Assert(ADirEntry.FParent = Self, 'Assertion: directory entry on AddDirectory() has different parent directory');
  Result := FDirectories.Add(ADirEntry);
End;



Function TDirectoryEntry.AddFile(AFileEntry: TFileEntry): Integer;
Begin
  If ( fFiles.IndexOf(AFileEntry) > -1 ) Then
    LastError := ('File entry already added');
  If ( Assigned(AFileEntry.FDirectory) ) And
     ( AFileEntry.FDirectory <> Self ) Then
    LastError := ('File entry already listed in different directory');
  Assert(AFileEntry.FDirectory <> Nil, 'Assertion: file entry on AddFile() has no directory assigned');
  Result := FFiles.Add(AFileEntry);
End;



Constructor TDirectoryEntry.Create(AImageTree: TImageTree; AParentDir : TDirectoryEntry; Const ASource : TDataSourceFlag);
Begin
  Inherited Create;
  FImageTree   := AImageTree;
  FParent      := AParentDir;
  FFiles       := TObjectList.Create(True);
  FDirectories := TObjectList.Create(True);
  If Assigned(FParent) Then FParent.AddDirectory(Self);
  FSource      := ASource;
  FFlags       := efNone;
  FBlocks      := 0;
End;


Procedure TDirectoryEntry.SetupRootDirectoryLocationOfExtent(Extent : Integer);
begin
  FRootISOData.LocationOfExtent := BuildBothEndianDWord(Extent);
end;


Function TDirectoryEntry.GetWideDirName : PWideChar;
begin
   Result := FWideName;
end;


Procedure TDirectoryEntry.FillISOData(Primary : Boolean);
var
        RecordSize : Integer;
Begin
   FWideName := StrToUnicode(fName);
if Primary = True then
  With FISOData Do
  Begin
    RecordSize                    := sizeof(FISOData) + Length(fName);  // make record size even
    if (RecordSize mod 2) > 0 then inc(RecordSize);
    LengthOfDirectoryRecord       := RecordSize;
    DataLength.LittleEndian       := 2048;
    DataLength.BigEndian          := SwapDWord(DataLength.LittleEndian);
    RecordingDateAndTime          := BuildDirectoryDateTime(NOW,0);
    VolumeSequenceNumber.LittleEndian  := 1;
    VolumeSequenceNumber.BigEndian  := SwapWord(VolumeSequenceNumber.LittleEndian);
    FileFlags                     := $02;      // directory
    LengthOfFileIdentifier        := Length(fName);
    FileUnitSize                  := 0;
    InterleaveGapSize             := 0;
    LocationOfExtent              := BuildBothEndianDWord(FLBAStart);
  End
  else
  With FISOData Do
  Begin
    RecordSize                    := sizeof(FISOData) + (Length(fName)* 2);  // make record size even
    if (RecordSize mod 2) > 0 then inc(RecordSize);
    LengthOfDirectoryRecord       := RecordSize;
    DataLength.LittleEndian       := 2048;
    DataLength.BigEndian          := SwapDWord(DataLength.LittleEndian);
    RecordingDateAndTime          := BuildDirectoryDateTime(NOW,0);
    VolumeSequenceNumber.LittleEndian  := 1;
    VolumeSequenceNumber.BigEndian  := SwapWord(VolumeSequenceNumber.LittleEndian);
    FileFlags                     := $02;      // directory
    LengthOfFileIdentifier        := Length(fName)* 2;
    FileUnitSize                  := 0;
    InterleaveGapSize             := 0;
    LocationOfExtent              := BuildBothEndianDWord(FLBAStart);
  End
End;



Procedure TDirectoryEntry.FillRootISOData(Primary : Boolean);
var
        RecordSize : Integer;
Begin
   FWideName := StrToUnicode(fName);
if Primary = True then
  With FRootISOData Do
  Begin
    RecordSize                    := sizeof(FRootISOData);  // make record size even
    if (RecordSize mod 2) > 0 then inc(RecordSize);
    LengthOfDirectoryRecord       := RecordSize;
    DataLength.LittleEndian       := 2048;
    DataLength.BigEndian          := SwapDWord(DataLength.LittleEndian);
    RecordingDateAndTime          := BuildDirectoryDateTime(NOW,0);
    VolumeSequenceNumber.LittleEndian  := 1;
    VolumeSequenceNumber.BigEndian  := SwapWord(VolumeSequenceNumber.LittleEndian);
    FileFlags                     := $02;      // directory
    LengthOfFileIdentifier        := 1;
    FileUnitSize                  := 0;
    InterleaveGapSize             := 0;
    LocationOfExtent.LittleEndian := FLBAStart;
    LocationOfExtent.BigEndian    := SwapDWord(LocationOfExtent.LittleEndian);
    FileIdentifier                := 0;
  End
  else
  With FRootISOData Do
  Begin
    RecordSize                    := sizeof(FRootISOData);  // make record size even
    if (RecordSize mod 2) > 0 then inc(RecordSize);
    LengthOfDirectoryRecord       := RecordSize;
    DataLength.LittleEndian       := 2048;
    DataLength.BigEndian          := SwapDWord(DataLength.LittleEndian);
    RecordingDateAndTime          := BuildDirectoryDateTime(NOW,0);
    VolumeSequenceNumber.LittleEndian  := 1;
    VolumeSequenceNumber.BigEndian  := SwapDWord(VolumeSequenceNumber.LittleEndian);
    FileFlags                     := $02;      // directory
    LengthOfFileIdentifier        := 1;
    FileUnitSize                  := 0;
    InterleaveGapSize             := 0;
    LocationOfExtent.LittleEndian := FLBAStart;
    LocationOfExtent.BigEndian    := SwapDWord(LocationOfExtent.LittleEndian);
    FileIdentifier                := 0;
  End
End;



{Fix provided by Esteban : Thanks}
Function TDirectoryEntry.BlockCount(Primary: Boolean): Integer;
 var  Index : Integer;
      iBytes : Integer;
      Bytes : Extended;
      MyFName : String;
      MyFilename : String;
      MyFileNameSize : Integer;
Begin
  Bytes := 0;
  for Index := 0 to (FileCount - 1) do
   begin
   MyFName := ExtractFileName(GetFileEntry(Index).SourceFileName);
   MyFilename := MyFName + ';1';
   MyFileNameSize := Length(MyFilename);
   MyFName := GetISOFilename(MyFName);

  if (Primary = True) then
   iBytes := sizeof(TDirectoryrecord) + Length(MyFName)
  else
   iBytes := sizeof(TDirectoryrecord) + (MyFileNameSize*2);

  if (iBytes mod 2) > 0 then iBytes := iBytes + 1;
  Bytes := Bytes + iBytes;
  end;

  for Index := 0 to (DirectoryCount - 1) do
  begin
     iBytes := sizeof(TDirectoryrecord) + Length(GetDirEntry(Index).Name);
     if (Primary = False) then iBytes := iBytes + Length(GetDirEntry(Index).Name);
     if (iBytes mod 2) > 0 then iBytes := iBytes + 1;
     Bytes := Bytes + iBytes;
  end;

  Bytes := Bytes + 68; // Por los . y ..
  Result := RoundUp(Bytes / 2048);
End;



{Procedure TDirectoryEntry.CreateLBAStart( var Start : integer);
begin
    FBlocks := RoundUp(GetFileCount / FilesPerBlock);
    if FBlocks < 1 then FBlocks := 1;
    Start := Start + FBlocks;
    FLBAStart := Start;
end;}


{Fix provided by Esteban : Thanks}
Procedure TDirectoryEntry.CreateLBAStart(Primary : Boolean ; var Start : integer);
begin
  FBlocks := BlockCount(Primary);
  if FBlocks < 1 then FBlocks := 1;
  Start := Start + FBlocks;
  FLBAStart := Start;
end;


Function TDirectoryEntry.DelDirectory(ADirEntry: TDirectoryEntry): Boolean;
Begin
  Result := False;
  If ( FDirectories.IndexOf(ADirEntry) = -1 ) Then Exit;
  FDirectories.Extract(ADirEntry);
  ADirEntry.FParent := Nil;
  Result := True;
End;


Function TDirectoryEntry.DelFile(AFileEntry: TFileEntry): Boolean;
Begin
  Result := False;
  If ( FFiles.IndexOf(AFileEntry) = -1 ) Then Exit;
  FFiles.Extract(AFileEntry);
  AFileEntry.fDirectory := Nil;
  Result := True;
End;

Function TDirectoryEntry.DeleteFile(AFileEntry: TFileEntry): Boolean;
Begin
  Result := False;
  If ( FFiles.IndexOf(AFileEntry) = -1 ) Then Exit;
  FFiles.Extract(AFileEntry);
  AFileEntry.fDirectory := Nil;
  Result := True;
End;


Destructor TDirectoryEntry.Destroy;
Begin
  If ( Assigned(FFiles) ) Then FreeAndNil(FFiles);
  If ( Assigned(FDirectories) ) Then FreeAndNil(FDirectories);
  Inherited;
End;


Function TDirectoryEntry.GetDirCount: Integer;
Begin
  If ( Assigned(FDirectories) ) Then
    Result := FDirectories.Count
  Else
    Result := 0;
End;


Function TDirectoryEntry.GetDirEntry(Index: Integer): TDirectoryEntry;
Begin
  Result := FDirectories[Index] As TDirectoryEntry;
End;

Function TDirectoryEntry.GetFileCount: Integer;
Begin
  If ( Assigned(FFiles) ) Then
    Result := FFiles.Count
  Else
    Result := 0;
End;


Function TDirectoryEntry.GetFileEntry(Index: Integer): TFileEntry;
Begin
  Result := FFiles[Index] As TFileEntry;
End;


Procedure TDirectoryEntry.MoveDirTo(ANewDirectory: TDirectoryEntry);
Begin
  If ( Self = ANewDirectory ) Then
    LastError := ('can not move directory to itself');
  If ( fParent = ANewDirectory ) Then
  Begin
    Assert(False, 'senseless move of directory');
    Exit;
  End;
  FParent.DelDirectory(Self);
  FParent := ANewDirectory;
  ANewDirectory.AddDirectory(Self);
End;



{ TFileEntry }

Constructor TFileEntry.Create(ADirectoryEntry: TDirectoryEntry; Const ASource : TDataSourceFlag);
Begin
  Inherited Create;
  FSource     := ASource;
  FSourceFile := '';
  FDirectory  := ADirectoryEntry;
  FDirectory.AddFile(Self);
  FFlags      := efNone;
  FSourceBlockSize := GetCDFSSize(RetrieveFileSize(fSourceFile));
End;



Destructor TFileEntry.Destroy;
Begin
  Inherited;
End;



Function TFileEntry.GetCDFSSize(FileSize : Integer):Integer;
var
     ResLength : Integer;
begin
    ResLength := 1;
    if FileSize > 2048 then
    begin
      ResLength := FileSize div 2048;
      if FileSize mod 2048 > 0 then ResLength := ResLength + 1;
    end;
    result := ResLength;
end;



Procedure TFileEntry.CreateLBAStart( var StartBlock : integer);
begin
    FLBAStart := StartBlock;
    StartBlock := StartBlock + GetCDFSSize(RetrieveFileSize(fSourceFile));
end;


Function TFileEntry.GetWideFileName : PWideChar;
begin
   Result := FWideName;
end;


Procedure TFileEntry.FillISOData(Primary : Boolean);
var
        RecordSize : Integer;
        FileNameSize : Integer;
        Filename : String;
Begin
  If ( FSource <> dsfFromLocal ) Then
     LastError := ('Can not fill ISO structure, Not a local file entry');
  FName := ExtractFileName(FSourceFile);
  Filename := FName + ';1';
  FileNameSize := Length(Filename);
  FWideName := StrToUnicode(Filename);
  fName := GetISOFilename(fname);
if Primary = True then
  With FISOData Do
  Begin
    RecordSize                          := sizeof(FISOData) + Length(fName);
    if (RecordSize mod 2) >0 then inc(RecordSize);
    LengthOfDirectoryRecord             := RecordSize;
    DataLength.LittleEndian             := RetrieveFileSize(fSourceFile);
    DataLength.BigEndian                := SwapDWord(DataLength.LittleEndian);
    RecordingDateAndTime                := BuildDirectoryDateTime(NOW,0);
    VolumeSequenceNumber.LittleEndian   := 1;
    VolumeSequenceNumber.BigEndian      := SwapWord(VolumeSequenceNumber.LittleEndian);
    FileFlags                           := $00; //File
    LengthOfFileIdentifier              := Length(fName);
    FileUnitSize                        := 0;
    InterleaveGapSize                   := 0;
    LocationOfExtent.LittleEndian       := FLBAStart;
    LocationOfExtent.BigEndian          := SwapDWord(LocationOfExtent.LittleEndian);
  End
   else
  With FISOData Do
  Begin
    RecordSize                          := sizeof(FISOData) + (FileNameSize * 2);
    if (RecordSize mod 2) >0 then inc(RecordSize);
    LengthOfDirectoryRecord             := RecordSize;
    DataLength.LittleEndian             := RetrieveFileSize(fSourceFile);
    DataLength.BigEndian                := SwapDWord(DataLength.LittleEndian);
    RecordingDateAndTime                := BuildDirectoryDateTime(NOW,0);
    VolumeSequenceNumber.LittleEndian   := 1;
    VolumeSequenceNumber.BigEndian      := SwapWord(VolumeSequenceNumber.LittleEndian);
    FileFlags                           := $00; //File
    LengthOfFileIdentifier              := (FileNameSize * 2);
    FileUnitSize                        := 0;
    InterleaveGapSize                   := 0;
    LocationOfExtent.LittleEndian       := FLBAStart;
    LocationOfExtent.BigEndian          := SwapDWord(LocationOfExtent.LittleEndian);
  End;
End;




Function TFileEntry.GetFullPath: String;
Var
  ADir : TDirectoryEntry;
Begin
  ADir := fDirectory;
  Result := '';
  While ( Assigned(ADir) ) Do
  Begin
    Result := ADir.Name + '/' + Result;
    ADir   := ADir.Parent;
  End;
End;



Procedure TFileEntry.MoveTo(ANewDirectoryEntry: TDirectoryEntry);
Begin
  fDirectory.DelFile(Self);
  fDirectory := ANewDirectoryEntry;
  ANewDirectoryEntry.AddFile(Self);
End;


{ TImageTree }

Constructor TImageTree.Create;
Begin
  Inherited Create;
  FFileBlocks := 0;
  FLittleEndianPathTable := TList.create;
  FRootDir := TDirectoryEntry.Create(Self, Nil, dsfFromImage);
  FRootDir.FName := char(0);
End;


Destructor TImageTree.Destroy;
Begin
  ClearPathTables;
  If ( Assigned(FLittleEndianPathTable) ) Then FLittleEndianPathTable.Free;
  If ( Assigned(fRootDir) ) Then FreeAndNil(fRootDir);
  Inherited;
End;



Procedure TImageTree.ClearPathTables;
Var
   Index : Integer;
   PathRec : PPathTableRecord;
begin
   FFileBlocks := 0;
   if FLittleEndianPathTable.Count = 0 then exit;
//   for Index := 0 to (FLittleEndianPathTable.Count - 1) do   //changed to fix AV error 
   For Index := (FLittleEndianPathTable.Count - 1) downto 0 do
   begin
       PathRec := FLittleEndianPathTable.Items[Index];
     try
       if PathRec <> nil then
            Dispose(PathRec);
     except
     end;
      FLittleEndianPathTable.Delete(Index);
   end;
  FLittleEndianPathTable.Pack;
end;




Function TImageTree.GetPathTableLength : Integer;
var
     TableSize : Integer;
     Index,SubSize : Integer;
     PathRec : PPathTableRecord;
begin
   TableSize := 0;
   for Index := 0 to FLittleEndianPathTable.Count - 1 do
   begin
     PathRec := FLittleEndianPathTable.Items[Index];
     SubSize := PathRec^.LengthOfPathRecord;
     TableSize := TableSize + SubSize;
   end;
   Result := TableSize;
end;



Function TImageTree.GetJolietPathTableLength : Integer;
var
     TableSize : Integer;
     Index,SubSize : Integer;
     PathRec : PPathTableRecord;
begin
   TableSize := 0;
   for Index := 0 to FLittleEndianPathTable.Count - 1 do
   begin
     PathRec := FLittleEndianPathTable.Items[Index];
     SubSize := PathRec^.LengthOfPathRecordM;
     TableSize := TableSize + SubSize;
   end;
   Result := TableSize;
end;




Procedure TImageTree.RecurseFiles(CurrentDir : TDirectoryEntry);
var
     Index : Integer;
begin
    for Index := 0 to CurrentDir.FileCount -1 do
    begin
       CurrentDir.GetFileEntry(Index).CreateLBAStart(FileLBA);
       FFileBlocks := FFileBlocks + CurrentDir.GetFileEntry(Index).BlockSize;
    end;
end;




procedure TImageTree.SortDirectories;
var
   NoExchanges : boolean;
   Index : Integer;
   PathRec1,PathRec2 : PPathTableRecord;
begin
	Repeat
		NoExchanges := true;
		For Index := 0 to FLittleEndianPathTable.Count -2 do
		begin
                     PathRec1 := FLittleEndianPathTable.Items[index];
                     PathRec2 := FLittleEndianPathTable.Items[index+1];
			if (PathRec1^.ParentDirectoryNumber > PathRec2^.ParentDirectoryNumber) then
			begin //we have to switch.
                            NoExchanges := False; //We have to tell the sort we aren't done.
                            FLittleEndianPathTable.Exchange(Index,Index+1);
			end;
		end;
	Until NoExchanges;
end;






Procedure TImageTree.AddDirectory(CurrentDir : TDirectoryEntry ; Parent : Integer);
var
     PathRecL,PathRecM : PPathTableRecord;
     Temp : String;
     wTemp : WideString;
     WideChr : PWideChar;
     Size : Integer;
begin
   CurrentDir.CreateLBAStart(False,CurrentLBA);
   RecurseFiles(CurrentDir);
   // do little endian list first
   New(PathRecL);
   FillChar(PathRecL^,sizeof(PathRecL^),$00);
   PathRecL^.ParentDirectoryNumber := Parent;
   PathRecL^.LengthOfDirectoryIdentifier := Length(CurrentDir.Name);
   if (PathRecL^.LengthOfDirectoryIdentifier mod 2) > 0 then inc(PathRecL^.LengthOfDirectoryIdentifier);
   StrPCopy(PathRecL^.DirectoryIdentifier,Copy(CurrentDir.Name, 1, Length(CurrentDir.Name)));
   PathRecL^.LocationOfExtent := CurrentDir.StartLBA;
   PathRecL^.LengthOfPathRecord := (8 + PathRecL^.LengthOfDirectoryIdentifier);


   //do big endian list
   Temp := CurrentDir.Name;
   Size := (length(temp)+1)*2;
   WideChr:= PWideChar(StrAlloc(Size));//important
   StringToWideChar(temp,WideChr,Size + 1);
   FillChar(PathRecL^.DirectoryIdentifierM,128,0);
   CopyMemory(@PathRecL^.DirectoryIdentifierM[1],@WideChr[0],(length(Temp)*2)-1);//makes it big endian wide char

   if Length(CurrentDir.Name) = 1 then
        PathRecL^.LengthOfDirectoryIdentifierM := 1
         else
             PathRecL^.LengthOfDirectoryIdentifierM := Length(CurrentDir.Name)*2;

   if (PathRecL^.LengthOfDirectoryIdentifierM mod 2) > 0 then inc(PathRecL^.LengthOfDirectoryIdentifierM);
   PathRecL^.LocationOfExtentM := SwapDWord(CurrentDir.StartLBA);
   PathRecL^.LengthOfPathRecordM := (8 + PathRecL^.LengthOfDirectoryIdentifierM);
 // add to list
   FLittleEndianPathTable.Add(PathRecL);
end;








Procedure TImageTree.ScanAllDirectories(CurrentDir : TDirectoryEntry ; Parent : Integer);
var
     Index : Integer;
begin
   For Index := 0 to CurrentDir.GetDirCount -1 do
   begin
       AddDirectory(CurrentDir.GetDirEntry(Index),Parent);   // add to list under parent
       if CurrentDir.GetDirEntry(Index).GetDirCount > 0 then
          ScanAllDirectories(CurrentDir.GetDirEntry(Index),Parent +1);
   end; 
end;





Procedure TImageTree.RefreshPathTables(StartLBA, FileBlock : Integer);
var
     PathRec : PPathTableRecord;
begin
   if not Assigned(fRootDir) then Exit;
   ClearPathTables;           // Clear all remaining path tables
   CurrentLBA := StartLBA;          // setup start Logical Block Address
   FDirectoryStartLBA := StartLBA;
   FileLBA := FileBlock;
   FFileStartBlock := FileLBA;
   AddDirectory(FRootDir,1);   // Start With Root Directory
   ScanAllDirectories(FRootDir,1);
   FPathTableStopSector := CurrentLBA;
   FJolietOffsett := CurrentLBA;
end;




Function TImageTree.GetTableCount : Integer;
begin
    Result := FLittleEndianPathTable.Count;
end;


Function TImageTree.GetLastError : String;
begin
    Result := LastError;
end;



end.
