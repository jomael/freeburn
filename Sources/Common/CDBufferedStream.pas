{-----------------------------------------------------------------------------
 Unit Name: CDBufferedStream
 Author:    Dancemammal
 Purpose:   create a buffer for the file stream, Buffered Read No buffer for write
 History:   First code release
-----------------------------------------------------------------------------}


unit CDBufferedStream;

interface

uses Classes, Types, sysutils, windows, Messages;


const
   BufferMax = 1000; // 1000 * sectorsize = about 2 meg buffer

   DefSectorSize = 2048;

   HFILE_ERROR = -1;
   FILE_BEGIN = 0;
   FILE_CURRENT = 1;
   FILE_END = 2;


type
   TCDBufferedStream = class
   private
      FBuffer: PChar;
      FBufferSize: Integer;
      FBufEnd: longint;
      FBufPos: longint;
      FBytesRead: Longint;
      //BytesInMem   : LongInt;
      FSize: longint;
      FFileHandle: file;
      FSectorSize: Integer;
      FSectorCount: Integer;
      ISOSizeOK: Boolean;
      FBytesLeft: Integer;
      FSectorsLeft: Integer;
      FFileName: string;
      FPosition: Int64;
      FileMode: Word;
      function GetSize: Int64;
      function GetFilePosition: Int64;
   protected
      function ReadBufferFromFile: boolean;
      procedure SetSectorSize(Sector: Integer);
      procedure ResetBufferSize(SectorSize: integer);
      function GetSectorsleft: Integer;
      function SeekFile(Offset: LongInt; Origin: Word): LongInt;
   public
      constructor Create(const FileName: string; Mode: Word);
      destructor Destroy; override;
      procedure FlushBuffer;
      function ReadBuffer(var Buffer; Count: longint): longint;
      function Read(var Buffer; Count: longint): longint;
      function WriteBuffer(const Buffer; Count: LongInt): LongInt;
      function Write(const Buffer; Count: longint): longint;
      function CopyFrom(Source: TStream; Count: Int64): Int64;
      function Seek(Offset: longint; Origin: word): longint;
      function BufferPercentFull: Integer;
      property Position: int64 read GetFilePosition;
      property Size: int64 read GetSize;
      property SectorCount: integer read FSectorCount;
      property SectorSize: integer write SetSectorSize;
      property SectorsLeft: integer read GetSectorsleft;
      property BytesLeft: integer read FBytesLeft;
      property ISOSectorSizeOK: Boolean read ISOSizeOK;
   end;


implementation


function GetFileSize(const FileName: string): LongInt;
var
  SearchRec: TSearchRec;
begin
  try
    if FindFirst(ExpandFileName(FileName), faAnyFile, SearchRec) = 0 then
    begin
      Result := SearchRec.Size;
    end
    else
      Result := -1;
  finally
    SysUtils.FindClose(SearchRec);
  end;
end;




function TCDBufferedStream.GetSize: Int64;
begin
   if (FSize = 0) and FileExists(FFileName) then
      FSize := GetFileSize(FFilename);
   result := FSize;
end;



function TCDBufferedStream.GetFilePosition: Int64;
begin
   FPosition := (FilePos(FFileHandle) - FBufEnd) + FBufPos; //Result := PositionOfFile - End of Buffer + PositionOfBuffer
   Result := FPosition;
end;



procedure TCDBufferedStream.ResetBufferSize(SectorSize: integer);
begin
   if (FBuffer <> nil) then FreeMem(FBuffer, FBufferSize);
   FBufferSize := (BufferMax * SectorSize) - 1;
   GetMem(FBuffer, FBufferSize);
   FillChar(FBuffer^, FBufferSize, 0);
end;

{
fmCreate	Create a file with the given name. If a file with the given name exists, open the file in write mode.
fmOpenRead	Open the file for reading only.
fmOpenWrite	Open the file for writing only. Writing to the file completely replaces the current contents.
fmOpenReadWrite	Open the file to modify the current contents rather than replace them.
}

constructor TCDBufferedStream.Create(const FileName: string; Mode: Word);
begin
   AssignFile(FFileHandle, Filename);
   if ((Mode = fmOpenRead) or (Mode = fmOpenReadWrite)) and FileExists(Filename) then
      Reset(FFileHandle, 1)
   else
      if ((Mode = fmOpenWrite) or (Mode = fmCreate)) and (not FileExists(Filename)) then
         ReWrite(FFileHandle, 1)
      else //error --> readonly and not fileexists
         raise Exception.Create('Could not open file.');
   FileMode := Mode;
   ResetBufferSize(DefSectorSize); // align buffer to sector size
   FFileName := FileName;
   ISOSizeOK := False;
   FPosition := 0;
   FSize := 0;
   FBytesLeft := Size;
end;


destructor TCDBufferedStream.Destroy;
begin
   if (FileMode <> fmOpenRead) then FlushBuffer;
   CloseFile(FFileHandle);
   if (FBuffer <> nil) then FreeMem(FBuffer, FBufferSize);
end;



procedure TCDBufferedStream.SetSectorSize(Sector: Integer);
begin
   FSectorSize := Sector;
   ResetBufferSize(FSectorSize); // reset buff to align to new sector size
   FSectorCount := (Size div FSectorSize);
  {work out if ISO image is the right size}
   ISOSizeOK := (Size mod FSectorSize) = 0;
   FSectorsLeft := FSectorCount;
end;


function TCDBufferedStream.GetSectorsleft: Integer;
var
   BytesToGo: Integer;
begin
   BytesToGo := (size - Position);
   FSectorsLeft := (BytesToGo div FSectorSize);
   FBytesLeft := BytesToGo;
   Result := FSectorsLeft;
end;



function TCDBufferedStream.BufferPercentFull: Integer;
var
   Percent, Divisor: Integer;
begin
   Divisor := (FBufferSize div 100);
   Percent := ((FBufferSize - FBufPos) div Divisor);
   if (Percent < 0) then Percent := 0;
   if (Percent > 100) then Percent := 100;
   Result := Percent;
end;



procedure TCDBufferedStream.FlushBuffer;
begin
   if FBufPos > 0 then //if there's anyting in the buffer lets clean it
      BlockWrite(FFileHandle, FBuffer^, FBufPos);
   FBufPos := 0;
   FBytesRead := 0;
end;



function TCDBufferedStream.ReadBufferFromFile: boolean;
begin
  {read the next bufferful from the stream}
   BlockRead(FFileHandle, FBuffer^, FBufferSize, FBufEnd);
   FBufPos := 0;
  {return true if at least one byte read, false otherwise}
   Result := FBufEnd <> FBufPos;
end;



function TCDBufferedStream.ReadBuffer(var Buffer; Count: longint): longint;
var
   UserBuf: PChar;
   BytesToGo: longint;
   BytesToRead: longint;
begin

   UserBuf := @Buffer; {reference the buffer as a PChar}
   Result := 0; {start the counter for the number of bytes read}

   if (FBufPos = FBufEnd) then {if needed, fill internal buffer from underlying stream}
      if not ReadBufferFromFile then Exit;

   BytesToGo := Count; {calculate number of bytes to copy from internal buffer}
   BytesToRead := FBufEnd - FBufPos;
   if (BytesToRead > BytesToGo) then BytesToRead := BytesToGo;

   Move(FBuffer[FBufPos], UserBuf^, BytesToRead); {copy bytes from internal buffer to user buffer}

   inc(FBufPos, BytesToRead); {adjust the counters}
   dec(BytesToGo, BytesToRead);
   inc(Result, BytesToRead);

   while (BytesToGo <> 0) do
   begin {while there are more bytes to copy, do so}
      inc(UserBuf, BytesToRead);
      if not ReadBufferFromFile then Exit; {fill the internal buffer from the underlying stream}
      BytesToRead := FBufEnd - FBufPos; {calculate number of bytes to copy from internal buffer}
      if (BytesToRead > BytesToGo) then BytesToRead := BytesToGo;
      Move(FBuffer^, UserBuf^, BytesToRead); {copy bytes from internal buffer to user buffer}
      inc(FBufPos, BytesToRead);
      dec(BytesToGo, BytesToRead);
      inc(Result, BytesToRead);
   end;
end;



function TCDBufferedStream.Read(var Buffer; Count: longint): longint;
begin
   Result := ReadBuffer(Buffer, Count);
end;


function TCDBufferedStream.SeekFile(Offset: LongInt; Origin: Word): LongInt;
var
   StartPosition, FinishPosition: Longint;
begin
   StartPosition := Position;
   case Origin of
      soFromCurrent: StartPosition := Position;
      soFromEnd: StartPosition := FileSize(FFileHandle); { get file size }
      soFromBeginning: StartPosition := 0;
   end;

   Result := Position; //just in case the user wants a offset that doesnt exist we stay where we are
     //FlushBuffer;
   FinishPosition := StartPosition + Offset;
   if FinishPosition > FileSize(FFileHandle) then exit; //if the user wants to go to a aofsset that doesn't exist get out
   System.Seek(FFileHandle, FinishPosition);
   ReadBufferFromFile;
   Result := FinishPosition;
end;


function TCDBufferedStream.WriteBuffer(const Buffer; Count: LongInt): LongInt;
var
   BytesWritten: longint;
   UserBuf: PChar;
begin
   UserBuf := @Buffer; {reference the buffer as a PChar}
   BlockWrite(FFileHandle, UserBuf^, Count, BytesWritten);
   Result := BytesWritten;
end;


function TCDBufferedStream.Write(const Buffer; Count: LongInt): LongInt;
begin
   Result := WriteBuffer(Buffer, Count);
end;


function TCDBufferedStream.Seek(Offset: longint; Origin: word): longint;
begin
   Result := SeekFile(Offset, Origin);
end;


function TCDBufferedStream.CopyFrom(Source: TStream; Count: Int64): Int64;

const
   MaxBufferSize = 1024; // 1 meg buffer
var
   BytesWritten,BufWrite: longint;
   UserBuf: PChar;
   BufferCount: Integer;

begin
   try
      GetMem(Userbuf, MaxBufferSize);
      FillChar(Userbuf^, MaxBufferSize, 0);
      BufferCount := MaxBufferSize;
      BytesWritten := 0;
      BufWrite := 0;
      if BufferCount > Count then BufferCount := Count;
      repeat
         if ((BytesWritten + BufferCount) > Count) then
                  BufferCount := (Count - (BytesWritten - 1));

         Source.Read(UserBuf^, BufferCount);
         BlockWrite(FFileHandle, UserBuf^, BufferCount, BufWrite);
         inc(BytesWritten,BufWrite);
      until (BytesWritten >= Count);
   finally
      FreeMem(Userbuf);
   end;
   Result := BytesWritten;
end;


end.
