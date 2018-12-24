{-----------------------------------------------------------------------------
 Unit Name: BinCueReader
 Author:    Dancemammal
 Purpose:   Read and extract tracks from BIN / CUE files
 History:   First Release
-----------------------------------------------------------------------------}


unit BinCueReader;

interface

Uses Classes,Windows,sysutils,StrUtils;


Const
      MODE_UNKNOWN = 0;
      MODE_AUDIO = 1;
      MODE_MODE1 = 2;
      MODE_MODE2 = 3;
      MODE_MODE2_FORM1 = 4;
      MODE_MODE2_FORM2 = 5;
      MODE_MODE1_2048 = 6;
      MODE_MODE2_2048 = 7;

      CUE_OK               = 0;
      CUE_CUEMISSING       = 1;
      CUE_BINMISSING       = 2;
      CUE_CUEFILEEXPECTED  = 3;
      CUE_BINFILEEXPECTED  = 4;
      CUE_BINARYEXPECTED   = 5;
      CUE_TRACKEXPECTED    = 6;
      CUE_TRACKNUMEXPECTED = 7;
      CUE_INDEXEXPECTED    = 8;
      CUE_INDEXNUMEXPECTED = 9;
      CUE_INDEXMSFEXPECTED = 10;
      CUE_UNKNOWN_ERROR    = 11;

      PostLeadInGapTime    = 150;


type
  TWaveHeader = record
    { RIFF file header }
    RIFFHeader   : array[1..4] of Char; { Must be "RIFF" }
    FileSize     : Integer; { Must be "RealFileSize - 8" }
    WAVEHeader   : array[1..4] of Char; { Must be "WAVE" }
    { Format information }
    FormatHeader : array[1..4] of Char; { Must be "fmt " }
    FormatSize   : DWord; { Must be 16 (decimal) }
    FormatCode   : Word; { Must be 1 }
    ChannelNumber: Word; { Number of channels }
    SampleRate   : DWord; { Sample rate (hz) }
    BytesPerSecond: DWord; { Bytes per second }
    BytesPerSample: Word; { Bytes per Sample }
    BitsPerSample : Word; { Bits per sample }
    ExtraFormatBytes: Word;
    { Data area }
    DataHeader    : array[1..4] of Char; { Must be "data" }
    DataSize      : DWord; { Data size }
  end;



Type
 TATIPCue = Packed Record
    CTL_ADR   : Byte;   // control field
    TNO       : Byte;   // track number
    Index     : Byte;   // Index number
    DataForm  : Byte;   // data form ??
    SCMS      : Byte;   // Serial Copy Managment system
    Min       : Byte;
    Sec       : Byte;
    Frame     : Byte;
  end;



Type
  TATIPCueList = Packed Record
       Cues : Array[0..98] of TATIPCue;
       Count : Integer;
       BurnMode : Integer;
   end;



Type
   TIndex = Packed Record
      LBA      : Integer;
      ATIP     : Integer;
      IndexNum : Integer;
    end;




Type
 TTrack = Packed Record
     Mode       : Integer;
     ModeDesc   : String[30];
     FileType   : String[20];
     FileName   : String[255];
     FileSize   : LongInt;
     PreGap     : Integer;
     PreATIP    : Integer;
     Index      : Array[0..98] of TIndex;
     FirstIndex : Integer;
     IndexCount : Integer;
     TrackNumber : Integer;
   end;

Type
  TTrackList = Packed Record
     Tracks : Array[0..98] of TTrack;
     Count : Integer;
   end;


TExtractProgress = procedure(PercentDone: Integer; Cancel : Boolean) of object;

Type
    TBinCueReader = Class
    Private
       CurrentTrack : Integer;
       CurrentFileType : String;
       CurrentIndexCount : Integer;
       CueBuilderIndex : Integer;
       FCueFileName : String;
       FBinFileName : String;
       FExtractProcess : TExtractProgress;
       FBinTracks : TTrackList;
       FCUEList : Tstringlist;
       FTitle : String;
       FPerformer : String;
       FSongWriter : String;
       FCatalog : String;
       FATIPCounter : Integer;
       FATIPCueList : TATIPCueList;
       FCuePath     : String;
       Function GetATIPCueList : TATIPCueList;
       Function TrackModeToString(TrackMode : Integer): String;
       Function StrToMode(TrackVal : String): Integer;
       Function Parse(CueLine : String) : Integer;
       Procedure AddPostLeadInGap;
       Procedure SetupLeadIn;
       Procedure SetupLeadOut;
       Procedure CheckPreGap(Track : TTrack);
       Procedure AddTrackToCUE(Track : TTrack);
       Function BinLength(FileName : String):Integer;
       Function WavLength(FileName : String):Integer;
    Public
      Function ExtractTrack(TrackNo : Integer; ToFileName : String ) : Boolean;
      Function TrackMode(TrackNo : Integer): Integer;
      Function OpenCueFile(FileName : String) : Integer;
      Procedure SaveATIPCueToFile(FileName : String);
      Constructor Create;
      Destructor Destroy; override;
    Published
      property OnExtractProcess: TExtractProgress read FExtractProcess write FExtractProcess;
      property CueFileName: String read FCueFileName write FCueFileName;
      property BinFileName: String read FBinFileName write FBinFileName;
      Property BinTrackList : TTrackList Read FBinTracks;
      Property ATIPCueList : TATIPCueList Read GetATIPCueList;
      property Title : String read FTitle write FTitle;
      property Performer : String read FPerformer write FPerformer;
      property SongWriter : String read FSongWriter write FSongWriter;
      property Catalog : String read FCatalog write FCatalog;
   end;


implementation

uses covertfuncs,ReadWave;


function HMSFtoLBA(const  AMinute, ASecond, AFrame: Byte): LongWord;
begin
   Result := (AMinute * 60 * 75) + (ASecond * 75) + AFrame;
end;


Function StrToLBA(HSF : String) : LongWord;
var
    AMinute, ASecond, AFrame :Byte;
   TempStr,Coded : String;
begin
   Coded := HSF;
   TempStr := copy(Coded,0,pos(':',Coded)-1);
   AMinute := strtoint(TempStr);
   delete(Coded,1,pos(':',Coded));

   TempStr := copy(Coded,0,pos(':',Coded)-1);
   ASecond := strtoint(TempStr);
   delete(Coded,1,pos(':',Coded));

   TempStr := copy(Coded,0,99);
   AFrame := strtoint(TempStr);

   Result := HMSFtoLBA(AMinute,ASecond,AFrame);
end;



Constructor TBinCueReader.Create;
begin
    FCUEList := Tstringlist.create;
    FATIPCounter := 0;
end;


Destructor TBinCueReader.Destroy;
begin
   FCUEList.Clear;
   FCUEList.Free;
end;


Function TBinCueReader.StrToMode(TrackVal : String): Integer;
begin
      Result := MODE_UNKNOWN;
      If TrackVal = 'AUDIO' then Result := MODE_AUDIO;
      If TrackVal = 'MODE1/2352' then Result := MODE_MODE1;
      If TrackVal = 'MODE2/2352' then Result := MODE_MODE2;
      If TrackVal = 'MODE2FORM1/2352' then Result := MODE_MODE2_FORM1;
      If TrackVal = 'MODE2FORM2/2352' then Result := MODE_MODE2_FORM2;
      If TrackVal = 'MODE1/2048' then Result := MODE_MODE1_2048;
      If TrackVal = 'MODE2/2048' then Result := MODE_MODE2_2048;
End;


Function TBinCueReader.TrackModeToString(TrackMode : Integer): String;
begin
     Result := 'MODE UNKNOWN';
     Case TrackMode of
        1 : Result := 'AUDIO';
        2 : Result := 'MODE1 / 2352';
        3 : Result := 'MODE2 / 2352';
        4 : Result := 'MODE2 FORM1 / 2352';
        5 : Result := 'MODE2 FORM2 / 2352';
        6 : Result := 'MODE1 / 2048';
        7 : Result := 'MODE2 / 2048';
     end;
end;


Function TBinCueReader.TrackMode(TrackNo : Integer):Integer;
begin
    Result := FBinTracks.Tracks[TrackNo -1].Mode;
end;



Function TBinCueReader.WavLength(FileName : String):Integer;
var
  Header: PWaveInformation;
  Count : LongInt;
  Secs, Mins, Frames : Integer;
begin
  Result := 0;
  Header := GetWaveInformationFromFile(FileName);
  Count := round(Header^.Length);
  Dispose(Header);
  Result := Count;
end;


Function TBinCueReader.BinLength(FileName : String):Integer;
begin
  Result := 0;
  with TFileStream.Create(FileName, fmOpenRead) do
    try
     Result := Size;
    finally
      Free;
    end;
end;



{
FILE "VIDEOC~1.BIN" BINARY
TRACK 01 MODE2/2352
INDEX 01 00:00:00
TRACK 02 MODE2/2352
INDEX 00 00:04:00
INDEX 01 00:06:00
TRACK 03 MODE2/2352
INDEX 00 00:37:52
INDEX 01 00:39:52


TITLE "Enter title (disc or track)"
PERFORMER "Enter Performer (disc or track)"
SONGWRITER "Enter Songwriter (disc or track)"
CATALOG 1234567890123

FILE "C:\TRACK1.WAV" WAVE
  TRACK 01 AUDIO
    PREGAP 00:02:00
    INDEX 01 00:00:00
FILE "C:\TRACK2.WAV" WAVE
  TRACK 02 AUDIO
    PREGAP 00:02:00
    INDEX 01 00:00:00
}


Function TBinCueReader.Parse(CueLine : String) : Integer;
var
   Filename,Filetype : String;
   TrackNo, TrackType, IndexNo, TrackSecs : String;
   TempCopy,Line : String;
   IndexInt, TrackLength : Integer;
begin
   Line := Trim(CueLine);
   TempCopy := Copy(Line,0,Pos(' ',Line)-1);  // get KeyWord (FILE, TRACK, INDEX etc)
   Delete(Line,1,Pos(' ',Line));

   if (TempCopy = 'FILE') then //FILE "VIDEOC~1.BIN" BINARY
    begin
        Delete(Line,1,Pos('"',Line));
        Filename := Copy(Line,0,pos('"',Line)-1); // filename
        FileName := AnsiReplaceStr(FileName,'"','');
        Delete(Line,1,Pos('"',Line));
        Filetype := Copy(Line,0,100);
        FBinFileName := trim(FileName);
        CurrentFileType := trim(Filetype);
        exit;
    end;

   if (TempCopy = 'TITLE') then //TITLE "Enter title (disc or track)"
    begin
        Filename := Copy(Line,0,99); // title
        FileName := AnsiReplaceStr(FileName,'"','');
        FTitle := trim(FileName);
        exit;
    end;

   if (TempCopy = 'PERFORMER') then //PERFORMER "Enter Performer (disc or track)"
    begin
        Filename := Copy(Line,0,99); // title
        FileName := AnsiReplaceStr(FileName,'"','');
        FPerformer := trim(FileName);
        exit;
    end;

   if (TempCopy = 'SONGWRITER') then //SONGWRITER "Enter Songwriter (disc or track)"
    begin
        Filename := Copy(Line,0,99); // title
        FileName := AnsiReplaceStr(FileName,'"','');
        FSongWriter := trim(FileName);
        exit;
    end;

   if (TempCopy = 'CATALOG') then //CATALOG 1234567890123
    begin
        Filename := Copy(Line,0,99); // title
        FCatalog := trim(FileName);
        exit;
    end;


   if (TempCopy = 'TRACK') then //TRACK 01 MODE2/2352
    begin
        TrackNo := Copy(Line,0,pos(' ',Line)-1); // Track no
        Delete(Line,1,Pos(' ',Line));
        TrackType := Copy(Line,0,100);
        
        if (CurrentTrack > 0) then
            inc(FATIPCounter,FBinTracks.Tracks[CurrentTrack -1].FileSize); // add on length of last file ?

        CurrentTrack := strtoint(TrackNo);
        FBinTracks.Tracks[CurrentTrack -1].FileName := FBinFileName;
        FBinTracks.Tracks[CurrentTrack -1].Mode := StrToMode(trim(TrackType));
        FBinTracks.Tracks[CurrentTrack -1].ModeDesc := TrackModeToString(StrToMode(trim(TrackType)));
        FBinTracks.Tracks[CurrentTrack -1].FirstIndex := -1;
        FBinTracks.Tracks[CurrentTrack -1].PreGap := 0;
        FBinTracks.Tracks[CurrentTrack -1].TrackNumber := CurrentTrack;
        if CurrentFileType = 'WAVE' then
        begin
          TrackLength := WavLength(FBinFileName);
          FBinTracks.Tracks[CurrentTrack -1].FileSize := TrackLength;
        end
          else
           if CurrentFileType = 'BINARY' then
           begin
             TrackLength := BinLength(FBinFileName);
             FBinTracks.Tracks[CurrentTrack -1].FileSize := TrackLength;
           end;
        CurrentIndexCount := 0;
        Exit;
    end;

   if (TempCopy = 'PREGAP') then //PREGAP 00:02:00
    begin
        TrackSecs := Copy(Line,0,100); //00:02:00
        FBinTracks.Tracks[CurrentTrack -1].PreGap := StrToLBA(TrackSecs);
        inc(FATIPCounter,FBinTracks.Tracks[CurrentTrack -1].PreGap);
        FBinTracks.Tracks[CurrentTrack -1].PreATIP := FATIPCounter;
        Exit;
    end;

   if (TempCopy = 'INDEX') then //INDEX 00 00:00:00  INDEX 01 03:28:42
    begin
        IndexNo := Copy(Line,0,pos(' ',Line)-1); // Index no
        IndexInt := strtoint(IndexNo);
        Delete(Line,1,Pos(' ',Line));
        TrackSecs := Copy(Line,0,100);
        if (FBinTracks.Tracks[CurrentTrack -1].FirstIndex = -1) then
                    FBinTracks.Tracks[CurrentTrack -1].FirstIndex := IndexInt;

        FBinTracks.Tracks[CurrentTrack -1].Index[IndexInt].LBA := StrToLBA(TrackSecs);
        inc(FATIPCounter,FBinTracks.Tracks[CurrentTrack -1].Index[IndexInt].LBA);
        FBinTracks.Tracks[CurrentTrack -1].Index[IndexInt].ATIP := FATIPCounter;

        FBinTracks.Tracks[CurrentTrack -1].Index[IndexInt].IndexNum := IndexInt;
        FBinTracks.Tracks[CurrentTrack -1].IndexCount := (CurrentIndexCount + 1);
        inc(CurrentIndexCount);
        FBinTracks.Tracks[CurrentTrack -1].FileType := CurrentFileType;
        Exit;
    end;

end;





Function TBinCueReader.OpenCueFile(FileName : String) : Integer;
var
     Count : Integer;
     BufString : String;

begin
    Result := CUE_OK;
    if not fileexists(Filename) then
    begin
        Result := CUE_CUEMISSING;
        exit;
    end;
    CurrentTrack := 0;
    CurrentIndexCount := 0;
    FATIPCounter := 150;
    FCUEList.LoadFromFile(Filename);
    FCuePath := ExtractFilePath(FileName);
    for Count := 0 to FCUEList.Count -1 do
    begin
      BufString := FCUEList.Strings[Count];
      Result := Parse(Trim(BufString));
    end;
    inc(FATIPCounter,FBinTracks.Tracks[CurrentTrack -1].FileSize); // add on length of last file for lead out
    FBinTracks.Count := CurrentTrack;
end;






Function TBinCueReader.ExtractTrack(TrackNo : Integer; ToFileName : String ) : Boolean;
Const
    ChunkSize = 65535;
var
    lngStart, lngEnd, Counter : Integer; //start and end offset
    BinFileStream, OUTFileStream : TFileStream;      //  file Streams
    StreamBuf : PChar;          //read buffer
    blnCancel : Boolean;
    BytesWritten : Integer;

Begin
    BytesWritten := 0;
    blnCancel := False;
    BinFileStream := TFileStream.Create(FBinFileName, fmOpenRead);

     //Get Start LBA
    with FBinTracks.Tracks[TrackNo -1] do
       if FirstIndex = 0 then
            lngStart := Index[1].LBA * 2352
           else
             lngStart := index[0].LBA * 2352;

     //get the LBA of the next track
    If TrackNo = FBinTracks.Count Then
        lngEnd := (BinFileStream.Size - lngStart)
    Else
        lngEnd := FBinTracks.Tracks[TrackNo].index[0].LBA * 2352;

    // Setup seek pos and output file
    BinFileStream.Seek((lngStart + 1), soFromBeginning);
    OUTFileStream := TFileStream.Create(ToFileName, fmOpenRead);

    // extract data
   While (BytesWritten < (lngEnd - lngStart)) do
   begin
        If (ChunkSize + BinFileStream.Position > lngEnd) Then
            Counter := (lngEnd - BinFileStream.Position)
            else
              Counter := ChunkSize;
       BytesWritten := BytesWritten + BinFileStream.Read(StreamBuf^,Counter);
       OUTFileStream.Write(StreamBuf^,Counter);
       if Assigned(FExtractProcess) then FExtractProcess(BytesWritten div ((lngEnd - lngStart) div 100), blnCancel);
       If blnCancel Then Exit;
   end;
    OUTFileStream.free;
    BinFileStream.free;
End;


// add cue line for 2 second gap (150 lba) after lead in
Procedure TBinCueReader.AddPostLeadInGap;
begin
   FATIPCueList.Cues[CueBuilderIndex].CTL_ADR := $01;
   FATIPCueList.Cues[CueBuilderIndex].TNO := $01;
   FATIPCueList.Cues[CueBuilderIndex].Index := $00;
   FATIPCueList.Cues[CueBuilderIndex].DataForm := $01;
   FATIPCueList.Cues[CueBuilderIndex].SCMS := $00;
   FATIPCueList.Cues[CueBuilderIndex].Min := $00;
   FATIPCueList.Cues[CueBuilderIndex].Sec := $00;
   FATIPCueList.Cues[CueBuilderIndex].Frame := $00;
   inc(CueBuilderIndex);
end;


// set up first CUE as disk lead in
Procedure TBinCueReader.SetupLeadIn;
begin
   FATIPCueList.Cues[0].CTL_ADR := $01;
   FATIPCueList.Cues[0].TNO := $00;
   FATIPCueList.Cues[0].Index := $00;
   FATIPCueList.Cues[0].DataForm := $01;
   FATIPCueList.Cues[0].SCMS := $00;
   FATIPCueList.Cues[0].Min := $00;
   FATIPCueList.Cues[0].Sec := $00;
   FATIPCueList.Cues[0].Frame := $00;
   CueBuilderIndex := 1;
   AddPostLeadInGap;
end;


// set up Last CUE as disk lead out
Procedure TBinCueReader.SetupLeadOut;
var
  Min, Sec, Frm : Integer;
begin
   LBA2MSF(FATIPCounter,  Min, Sec, Frm);
   FATIPCueList.Cues[CueBuilderIndex].CTL_ADR := $01;
   FATIPCueList.Cues[CueBuilderIndex].TNO := $AA;
   FATIPCueList.Cues[CueBuilderIndex].Index := $01;
   FATIPCueList.Cues[CueBuilderIndex].DataForm := $01;
   FATIPCueList.Cues[CueBuilderIndex].SCMS := $00;
   FATIPCueList.Cues[CueBuilderIndex].Min := Min; 
   FATIPCueList.Cues[CueBuilderIndex].Sec := Sec;
   FATIPCueList.Cues[CueBuilderIndex].Frame := Frm;
   FATIPCueList.Count := CueBuilderIndex;
end;



Procedure TBinCueReader.CheckPreGap(Track : TTrack);
var
  Min, Sec, Frm : Integer;
begin
   if (Track.PreGap <> 0) then
   begin
        LBA2MSF(Track.PreATIP,  Min, Sec, Frm);
        FATIPCueList.Cues[CueBuilderIndex].CTL_ADR := $41;
        FATIPCueList.Cues[CueBuilderIndex].TNO := Track.TrackNumber;
        FATIPCueList.Cues[CueBuilderIndex].Index := $00;
        FATIPCueList.Cues[CueBuilderIndex].DataForm := $10;
        FATIPCueList.Cues[CueBuilderIndex].SCMS := $00;
        FATIPCueList.Cues[CueBuilderIndex].Min := Min; 
        FATIPCueList.Cues[CueBuilderIndex].Sec := Sec;
        FATIPCueList.Cues[CueBuilderIndex].Frame := Frm;
        inc(CueBuilderIndex);
   end;
end;




Procedure TBinCueReader.AddTrackToCUE(Track : TTrack);
Var
    IndexCnt : Integer;
    Min, Sec, Frm : Integer;
    Count : Integer;

begin
   CheckPreGap(Track);
   FATIPCueList.BurnMode := Track.Mode;
   for IndexCnt := Track.FirstIndex to Track.IndexCount do
   begin
      LBA2MSF(Track.Index[IndexCnt].ATIP,  Min, Sec, Frm);
      FATIPCueList.Cues[CueBuilderIndex].CTL_ADR := $41;     // can copy and is trc index
      FATIPCueList.Cues[CueBuilderIndex].TNO := Track.TrackNumber;
      FATIPCueList.Cues[CueBuilderIndex].Index := Track.Index[IndexCnt].IndexNum;
      FATIPCueList.Cues[CueBuilderIndex].DataForm := $C0;
      FATIPCueList.Cues[CueBuilderIndex].SCMS := $00;
      FATIPCueList.Cues[CueBuilderIndex].Min := Min;
      FATIPCueList.Cues[CueBuilderIndex].Sec := Sec;
      FATIPCueList.Cues[CueBuilderIndex].Frame := Frm;
      inc(CueBuilderIndex);
   end;
end;


Procedure TBinCueReader.SaveATIPCueToFile(FileName : String);
var
  Index : Integer;
  CueFile : TStringlist;
  Temp : String;
begin
   CueFile := TStringlist.create;
   GetATIPCueList;
   CueFile.Add('|  Count  |  CTL/ADR  |  TRK No  |  Index  | Data Form |  SCMS  |  MIN  |  SEC  |  Frame  |');
   CueFile.add('-------------------------------------------------------------------------------------------');
   for Index := 0 to 98 do
   begin

     Temp :=     '|   '+Inttostr(Index)+'    ';
     Temp :=Temp+'|    '+InttoHex(FATIPCueList.Cues[index].CTL_ADR,2)+'     ';
     Temp :=Temp+'|   '+InttoHex(FATIPCueList.Cues[index].TNO,2)+'   ';
     Temp :=Temp+'|   '+InttoHex(FATIPCueList.Cues[index].Index,2)+'   ';
     Temp :=Temp+'|    '+InttoHex(FATIPCueList.Cues[index].DataForm,2)+'     ';
     Temp :=Temp+'|   '+InttoHex(FATIPCueList.Cues[index].SCMS,2)+'   ';
     Temp :=Temp+'|   '+Inttostr(FATIPCueList.Cues[index].Min)+'   ';
     Temp :=Temp+'|   '+Inttostr(FATIPCueList.Cues[index].Sec)+'   ';
     Temp :=Temp+'|   '+Inttostr(FATIPCueList.Cues[index].Frame)+'   ';
     CueFile.add(Temp);
   end;
   CueFile.SaveToFile(Filename);
end;






Function TBinCueReader.GetATIPCueList : TATIPCueList;
var
   Index : Integer;
begin
    CueBuilderIndex := 0;
    SetupLeadIn;
    for Index := 0 to BinTrackList.Count -1 do
          AddTrackToCUE(BinTrackList.Tracks[Index]);
   SetupLeadOut;
   result := FATIPCueList;
end;




end.
 