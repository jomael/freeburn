{$WARN SYMBOL_DEPRECATED OFF}
{$WARN SYMBOL_PLATFORM OFF}

{-----------------------------------------------------------------------------
 Unit Name: CovertFuncs
 Author:    Dancemammal
 Purpose:   Standard Functions
 History:
-----------------------------------------------------------------------------}

unit CovertFuncs;

interface

uses Windows, SysUtils, Classes, DeviceTypes, Math, TypInfo, ScsiDefs,
scsitypes;

const
  OS_UNKNOWN = -1;
  OS_WIN95 = 0;
  OS_WIN98 = 1;
  OS_WINNT35 = 2;
  OS_WINNT4 = 3;
  OS_WIN2K = 4;
  OS_WINXP = 5;

  SECURITY_NT_AUTHORITY: TSIDIdentifierAuthority = (Value: (0, 0, 0, 0, 0, 5));
  SECURITY_BUILTIN_DOMAIN_RID = $00000020;
  DOMAIN_ALIAS_RID_ADMINS = $00000220;

type
  TCharArr = array of Char;

type
  TBothEndianWord = packed record
    LittleEndian,
      BigEndian: Word;
  end;

  TBothEndianDWord = packed record
    LittleEndian,
      BigEndian: LongWord;
  end;

type
  TVolumeDateTime = packed record
    Year: array[0..3] of Char;
    Month: array[0..1] of Char;
    Day: array[0..1] of Char;
    Hour: array[0..1] of Char;
    Minute: array[0..1] of Char;
    Second: array[0..1] of Char;
    MSeconds: array[0..1] of Char;
    GMTOffset: Byte;
  end;

type
  TDirectoryDateTime = packed record
    Year: Byte; // since 1900
    Month: Byte;
    Day: Byte;
    Hour: Byte;
    Minute: Byte;
    Second: Byte;
    GMTOffset: Byte; // in 15 minutes steps
  end;

function EnumToStr(ArgType: PTypeInfo; var Arg): string;
function SetToStr(ArgType: PTypeInfo; var Arg): string;
function HexToStrings(Buf: pointer; BufLen: DWORD): TStrings;
function Swap32(value: dword): dword;

function ConvertDataBlock(DataBlock: Integer): Integer;
function GetFileSize(const FileName: string): LongInt;
procedure ZeroMemory(Destination: Pointer; Length: DWORD);
function getOsVersion: integer;
function RoundUp(X: Extended): Integer;
function ArrOfChar(AStr: string): TCharArr;

function IntToMB(const ASize: Int64): string;
function VolumeDateTimeToStr(const VDT: TVolumeDateTime): string;
function SwapWord(const AValue: Word): Word;
function SwapDWord(const AValue: LongWord): LongWord;
function BuildBothEndianWord(const AValue: Word): TBothEndianWord;
function BuildBothEndianDWord(const AValue: LongWord): TBothEndianDWord;
function BuildDirectoryDateTime(const ADateTime: TDateTime; const AGMTOffset:
  Byte): TDirectoryDateTime;
function BuildVolumeDateTime(const ADateTime: TDateTime; const AGMTOffset:
  Byte): TVolumeDateTime;
function RetrieveFileSize(const AFileName: string): LongWord;
function IsAdministrator: Boolean;
function Endian(const Source; var Destination; const Count: Integer): Boolean;
function EndianToIntelBytes(const AValue: array of Byte; Count: Byte): Integer;
function GetLBA(const Byte1, Byte2, Byte3, Byte4: Byte): LongWord;
function HMSFtoLBA(const AHour, AMinute, ASecond, AFrame: Byte): LongWord;
function LBA2HMSF(LBA: Integer): string;
Procedure LBA2MSF(Const LBA: Integer; Var Min, Sec, Frame :Integer);
function LBA2MB(LBA, BlockSize: DWord): DWord;
function LBA2PreCDDB(LBA: Integer): Integer;
function SectorPos2TimePos(SectorPos : longint) : longint;
function TimePos2SectorPos(Min, Sec, Frame : longint) : longint;
function HiWord(Lx: LongWord): Word;
function LoWord(Lx: LongWord): Word;
function HiByte(Lx: Word): Byte;
function LoByte(Lx: Word): Byte;
function IsBitSet(const Value: LongWord; const Bit: Byte): Boolean;
function BitOn(const Value: LongWord; const Bit: Byte): LongWord;
function BitOff(const Value: LongWord; const Bit: Byte): LongWord;
function BitToggle(const Value: LongWord; const Bit: Byte): LongWord;
function ByteToBin(Value: Byte): string;
function ScsiErrToString(Err: TScsiError): string;
function UnicodeToStr(Name: string): String;
function StrToUnicode(Name: string): PWideChar;
function DOSchars_Len(str: string; Sze: integer): string;
function GetISOFilename(const FileName: string): string;

function BigEndianW(Arg: WORD): WORD;
function BigEndianD(Arg: DWORD): DWORD;
procedure BigEndian(const Source; var Dest; Count: integer);
function GatherWORD(b1, b0: byte): WORD;
function GatherDWORD(b3, b2, b1, b0: byte): DWORD;
procedure ScatterDWORD(Arg: DWORD; var b3, b2, b1, b0: byte);
procedure ASPIstrCopy(Src: PChar; var Dst: ShortString; Leng: Integer);

function CDDB_Sum(N: Integer): Integer;



implementation

function getOsVersion: integer;
var
  os: OSVERSIONINFO;
begin
  ZeroMemory(@os, sizeof(os));
  os.dwOSVersionInfoSize := sizeof(os);
  GetVersionEx(os);

  if os.dwPlatformId = VER_PLATFORM_WIN32_NT then
  begin
    if (os.dwMajorVersion = 3) and (os.dwMinorVersion >= 51) then
    begin
      Result := OS_WINNT35;
      Exit;
    end
    else if os.dwMajorVersion = 4 then
    begin
      Result := OS_WINNT4;
      Exit;
    end
    else if (os.dwMajorVersion = 5) and (os.dwMinorVersion = 0) then
    begin
      Result := OS_WIN2K;
      Exit;
    end
    else
    begin
      Result := OS_WINXP;
      Exit;
    end;
  end
  else if os.dwPlatformId = VER_PLATFORM_WIN32_WINDOWS then
  begin
    if os.dwMinorVersion = 0 then
    begin
      Result := OS_WIN95;
      Exit;
    end
    else
    begin
      Result := OS_WIN98;
      Exit;
    end;
  end;

  Result := OS_UNKNOWN;
end;

function BigEndianW(Arg: WORD): WORD;
begin
  result := ((Arg shl 8) and $FF00) or
    ((Arg shr 8) and $00FF);
end;

function BigEndianD(Arg: DWORD): DWORD;
begin
  result := ((Arg shl 24) and $FF000000) or
    ((Arg shl 8) and $00FF0000) or
    ((Arg shr 8) and $0000FF00) or
    ((Arg shr 24) and $000000FF);
end;

procedure BigEndian(const Source; var Dest; Count: integer);
var
  pSrc, pDst: PChar;
  i: integer;
begin
  pSrc := @Source;
  pDst := PChar(@Dest) + Count;
  for i := 0 to Count - 1 do
  begin
    Dec(pDst);
    pDst^ := pSrc^;
    Inc(pSrc);
  end;
end;

function GatherWORD(b1, b0: byte): WORD;
begin
  result := ((WORD(b1) shl 8) and $FF00) or
    ((WORD(b0)) and $00FF);
end;

{$WARNINGS OFF}

function GatherDWORD(b3, b2, b1, b0: byte): DWORD;
begin
  result := ((LongInt(b3) shl 24) and $FF000000) or
    ((LongInt(b2) shl 16) and $00FF0000) or
    ((LongInt(b1) shl 8) and $0000FF00) or
    ((LongInt(b0)) and $000000FF);
end;
{$WARNINGS ON}

procedure ScatterDWORD(Arg: DWORD; var b3, b2, b1, b0: byte);
begin
  b3 := (Arg shr 24) and $FF;
  b2 := (Arg shr 16) and $FF;
  b1 := (Arg shr 8) and $FF;
  b0 := Arg and $FF;
end;

procedure ASPIstrCopy(Src: PChar; var Dst: ShortString; Leng: Integer);
var
  i: integer;
begin
  i := 0;
  while (i < Leng) and (Src[i] >= ' ') do
  begin
    Dst[i + 1] := Src[i];
    inc(i);
  end;
  while (i > 0) and (Dst[i] = ' ') do
    Dec(i); // Trim it Right
  Dst[0] := CHR(i);
end;

function Swap32(value: dword): dword;
  assembler;
asm
   bswap eax
end;


function UnicodeToStr(Name: string): String;
var
  i: integer;
  ResString : String;
begin
  i := 0;
  ResString := '';
  For I := 0 to length(Name) do
     if Name[i] <> #0 then ResString := ResString + Name[i];
  Result := ResString;
end;


function StrToUnicode(Name: string): PWideChar;
var
  WideChr: PWideChar;
  Size: Integer;
begin
  Size := (length(Name) + 1) * 2;
  WideChr := PWideChar(StrAlloc(Size)); //important
  StringToWideChar(Name, WideChr, Size + 1);
  Result := WideChr;
end;

function DOSchars_Len(str: string; Sze: integer): string;
//filters out non DOS chars, max length = Sze, including extension
var
  temp: string;
  i: integer;
begin
  result := ''; //important
  temp := UpperCase(str);
  if Pos('.', temp) > 0 then
  begin
    result := DOSchars_Len(Copy(temp, 1, Pos('.', temp) - 1), Sze - 4) +
      Copy(temp, Pos('.', temp), 4);
    exit;
  end;
  for i := 1 to length(temp) do
    if temp[i] in ['0'..'9', 'A'..'Z', '_'] then
      result := result + temp[i];
  result := Copy(result, 1, Sze);
end;

procedure ZeroMemory(Destination: Pointer; Length: DWORD);
begin
  FillChar(Destination^, Length, 0);
end;

function EnumToStr(ArgType: PTypeInfo; var Arg): string;
begin
  case (GetTypeData(ArgType))^.OrdType of
    otSByte, otUByte: Result := GetEnumName(ArgType, BYTE(Arg));
    otSWord, otUWord: Result := GetEnumName(ArgType, WORD(Arg));
    otSLong: Result := GetEnumName(ArgType, LongInt(Arg));
  end;
end;

function ScsiErrToString(Err: TScsiError): string;
begin
  Result := EnumToStr(TypeInfo(TScsiError), Err);
end;

type
  TIntegerSet = set of 0..SizeOf(Integer) * 8 - 1;
  PIntegerSet = ^TIntegerSet;

function SetToStr(ArgType: PTypeInfo; var Arg): string;
var
  Info: PTypeInfo;
  Data: PTypeData;
  I: Integer;
begin
  Result := '[';
  Info := (GetTypeData(ArgType))^.CompType^;
  Data := GetTypeData(Info);
  for I := Data^.MinValue to Data^.MaxValue do
    if I in PIntegerSet(@Arg)^ then
    begin
      if Length(Result) <> 1 then
        Result := Result + ', ';
      Result := Result + GetEnumName(Info, I);
    end;
  Result := Result + ']';
end;

{$WARNINGS OFF}

function HexToStrings(Buf: pointer; BufLen: DWORD): TStrings;
const
  BytesPerLine = 16;
  BytesPerTab = 4;
  CharsInAddress = 4;
var
  CurLine, CurByte, CurOffset: integer;
  s: string;
  b: char;
begin
  Result := TStringList.Create;
  if (BufLen <= 0) or not Assigned(Buf) then
    exit;
  try
    for CurLine := 0 to (BufLen - 1) div BytesPerLine do
    begin
      CurOffset := CurLine * BytesPerLine;
      s := IntToHex(CurOffset, CharsInAddress);
      for CurByte := 0 to BytesPerLine - 1 do
      begin
        if (CurByte mod BytesPerTab) = 0 then
          s := s + ' ';
        if CurOffset < BufLen then
          s := s + IntToHex(BYTE((PChar(Buf) + CurOffset)^), 2) + ' '
        else
          s := s + '   ';
        Inc(CurOffset);
      end;
      s := s + '|';
      CurOffset := CurLine * BytesPerLine;
      for CurByte := 0 to BytesPerLine - 1 do
      begin
        if CurOffset < BufLen then
        begin
          b := (PChar(Buf) + CurOffset)^;
          if b < ' ' then
            b := ' ';
          s := s + b;
        end
        else
          s := s + ' ';
        Inc(CurOffset);
      end;
      Result.Add(s);
    end;
  except
    Result.Clear;
  end;
end;
{$WARNINGS ON}

function LBA2MB(LBA, BlockSize: DWord): DWord;
begin
  Result := ((LBA div 1024) * BlockSize) div 1024;
end;

function ConvertDataBlock(DataBlock: Integer): Integer;
var
  DataSize: Integer;
begin
  DataSize := 2048;
  case DataBlock of
    $00: DataSize := 2352;
    $01: DataSize := 2368;
    $02: DataSize := 2448;
    $03: DataSize := 2448;
    $08: DataSize := 2048;
    $09: DataSize := 2336;
    $0A: DataSize := 2048;
    $0B: DataSize := 2056;
    $0C: DataSize := 2324;
    $0D: DataSize := 2324;
  end;
  result := DataSize;
end;

{   btRAW_DATA_BLOCK = $00,
    btRAW_DATA_P_Q_SUB = $01,
    btRAW_DATA_P_W_SUB = $02,
    btRAW_DATA_P_W_SUB2 = $03,
    btMODE_1 = $08,
    btMODE_2 = $09,
    btMODE_2_XA_FORM_1 = $0A,
    btMODE_2_XA_FORM_1_SUB = $0B,
    btMODE_2_XA_FORM_2 = $0C,
    btMODE_2_XA_FORM_2_SUB = $0D }

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




function IntToMB(const ASize: Int64): string;
begin
  Result := IntToStr(ASize div 1024 div 1024);
end;

function VolumeDateTimeToStr(const VDT: TVolumeDateTime): string;
begin
  Result := string(VDT.Day) + '.' + string(VDT.Month) + '.' +
    string(VDT.Year) + ' ' + string(VDT.Hour) + ':' +
    string(VDT.Minute) + ':' + string(VDT.Second) + '.' +
    string(VDT.MSeconds) + ' ' + IntToStr(VDT.GMTOffset * 15) + ' min from GMT';
end;

function ArrOfChar(AStr: string): TCharArr;
var
  j: integer;
begin
  SetLength(Result, Length(AStr));
  for j := 0 to Length(AStr) - 1 do
    Result[j] := AStr[j + 1];
end;

function SwapWord(const AValue: Word): Word;
begin
  Result := ((AValue shl 8) and $FF00) or ((AValue shr 8) and $00FF);
end;

function SwapDWord(const AValue: LongWord): LongWord;
begin
  Result := ((AValue shl 24) and $FF000000) or
    ((AValue shl 8) and $00FF0000) or
    ((AValue shr 8) and $0000FF00) or
    ((AValue shr 24) and $000000FF);
end;

function BuildBothEndianWord(const AValue: Word): TBothEndianWord;
begin
  Result.LittleEndian := AValue;
  Result.BigEndian := SwapWord(AValue);
end;

function BuildBothEndianDWord(const AValue: LongWord): TBothEndianDWord;
begin
  Result.LittleEndian := AValue;
  Result.BigEndian := SwapDWord(AValue);
end;

function BuildVolumeDateTime(const ADateTime: TDateTime; const AGMTOffset:
  Byte): TVolumeDateTime;
var
  Hour, Min, Sec, MSec,
    Year, Month, Day: Word;
  s: string;
begin
  DecodeTime(ADateTime, Hour, Min, Sec, MSec);
  DecodeDate(ADateTime, Year, Month, Day);
  Result.GMTOffset := AGMTOffset;
  s := IntToStr(Hour);
  StrPCopy(Result.Hour, s);
  s := IntToStr(Min);
  StrPCopy(Result.Minute, s);
  s := IntToStr(Sec);
  StrPCopy(Result.Second, s);
  s := IntToStr(MSec);
  StrPCopy(Result.MSeconds, s);
  s := IntToStr(Year);
  StrPCopy(Result.Year, s);
  s := IntToStr(Month);
  StrPCopy(Result.Month, s);
  s := IntToStr(Day);
  StrPCopy(Result.Day, s);
end;

function BuildDirectoryDateTime(const ADateTime: TDateTime; const AGMTOffset:
  Byte): TDirectoryDateTime;
var
  Hour, Min, Sec, MSec,
    Year, Month, Day: Word;
begin
  DecodeTime(ADateTime, Hour, Min, Sec, MSec);
  DecodeDate(ADateTime, Year, Month, Day);
  Result.GMTOffset := AGMTOffset;
  Result.Hour := Hour;
  Result.Minute := Min;
  Result.Second := Sec;
  Result.Year := Year;
  Result.Month := Month;
  Result.Day := Day;
end;

function RetrieveFileSize(const AFileName: string): LongWord;
var
  SR: TSearchRec;
begin
  Result := 0;
  if (FileExists(AFileName)) and
    (FindFirst(AFileName, faAnyFile, SR) = 0) then
  begin
    if ((SR.Attr and faDirectory) = 0) and
      ((SR.Attr and faVolumeID) = 0) then
      Result := SR.Size;
      FindClose(sr);
  end;
end;

function Sgn(X: Extended): Integer;
begin
  if X < 0 then
    Result := -1
  else if X = 0 then
    Result := 0
  else
    Result := 1;
end;

function RoundUp(X: Extended): Integer;
var
  Temp: Extended;
begin
  Temp := Int(X) + Sgn(Frac(X));
  Result := round(Temp);
end;

function IsAdministrator: Boolean;
var
  hAccessToken: THandle;
  ptgGroups: PTokenGroups;
  dwInfoBufferSize: DWORD;
  psidAdministrators: PSID;
  x: Integer;
  bSuccess: BOOL;
begin
  Result := False;
  bSuccess := OpenThreadToken(GetCurrentThread, TOKEN_QUERY, True,
    hAccessToken);
  if not bSuccess then
  begin
    if GetLastError = ERROR_NO_TOKEN then
      bSuccess := OpenProcessToken(GetCurrentProcess, TOKEN_QUERY,
        hAccessToken);
  end;
  if bSuccess then
  begin
    GetMem(ptgGroups, 1024);
    bSuccess := GetTokenInformation(hAccessToken, TokenGroups,
      ptgGroups, 1024, dwInfoBufferSize);
    CloseHandle(hAccessToken);
    if bSuccess then
    begin
      AllocateAndInitializeSid(SECURITY_NT_AUTHORITY, 2,
        SECURITY_BUILTIN_DOMAIN_RID, DOMAIN_ALIAS_RID_ADMINS,
        0, 0, 0, 0, 0, 0, psidAdministrators);
{$R-}
      for x := 0 to ptgGroups.GroupCount - 1 do
        if EqualSid(psidAdministrators, ptgGroups.Groups[x].Sid) then
        begin
          Result := True;
          Break;
        end;
{$R+}
      FreeSid(psidAdministrators);
    end;
    FreeMem(ptgGroups);
  end;
end;

function Endian(const Source; var Destination; const Count: Integer): Boolean;
var
  PSource, PDestination: PChar;
  I: Integer;
begin
  Result := False;
  PSource := @Source;
  PDestination := PChar(@Destination) + Count;
  for i := 0 to Count - 1 do
  begin
    Dec(PDestination);
    pDestination^ := PSource^;
    Inc(PSource);
    Result := True;
  end;
end;

function EndianToIntelBytes(const AValue: array of Byte; Count: Byte): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to Count - 1 do
  begin
    Result := (AValue[I] shl ((Count - (I + 1)) * 8) or Result);
  end;
end;

function GetLBA(const Byte1, Byte2, Byte3, Byte4: Byte): LongWord;
begin
  Result := (Byte1 shl 24) or (Byte2 shl 16) or (Byte3 shl 8) or Byte4;
end;

function HMSFtoLBA(const AHour, AMinute, ASecond, AFrame: Byte): LongWord;
begin
  Result := (AHour * 60 * 60 * 75) + (AMinute * 60 * 75) + (ASecond * 75) + AFrame;
end;


function LBA2HMSF(LBA: Integer): string;
var
  M, S, F: Integer;
begin
  F := (LBA mod 75);
  S := (LBA div 75) mod 60;
  M := (LBA div 75) div 60;
  Result := Format('%02.02d:%02.02d:%02.02d', [m, s, f])
end;


Procedure LBA2MSF(Const LBA: Integer; Var Min, Sec, Frame :Integer);
begin
  Frame := (LBA mod 75);
  Sec := (LBA div 75) mod 60;
  Min := (LBA div 75) div 60;
end;


function LBA2PreCDDB(LBA: Integer): Integer;
var
  M, S, Start: Integer;
begin
  Start := 150 + LBA;
  S := (Start div 75) mod 60;
  M := (Start div 75) div 60;
  Result := ((M * 60) + S);
end;


function TimePos2SectorPos(Min, Sec, Frame : longint) : longint;
begin
    Result := longint(Min) * 4500 + Longint(Sec) * 75 + Frame - 150;
end;


function SectorPos2TimePos(SectorPos : longint) : longint;
var
    Min, Sec, Frame : longint;
begin
    Frame := SectorPos mod 75;
    Sec   := ((SectorPos + 150) div 75) mod 60;
    Min   := (SectorPos + 150) div 4500;
    Result := (Min shl 16) + (Sec shl 8) + Frame;
end;

function HiWord(Lx: LongWord): Word;
begin
  Result := (Lx shr 16) and $FFFF;
end;

function LoWord(Lx: LongWord): Word;
begin
  Result := Lx;
end;

function HiByte(Lx: Word): Byte;
begin
  Result := (Lx shr 8) and $FF;
end;

function LoByte(Lx: Word): Byte;
begin
  Result := Lx and $FF;
end;

function IsBitSet(const Value: LongWord; const Bit: Byte): Boolean;
begin
  Result := (Value and (1 shl Bit)) <> 0;
end;

function BitOn(const Value: LongWord; const Bit: Byte): LongWord;
begin
  Result := Value or (1 shl Bit);
end;

function BitOff(const Value: LongWord; const Bit: Byte): LongWord;
begin
  Result := Value and ((1 shl Bit) xor $FFFFFFFF);
end;

function BitToggle(const Value: LongWord; const Bit: Byte): LongWord;
begin
  Result := Value xor (1 shl Bit);
end;

function ByteToBin(Value: Byte): string;
var
  I: Integer;
begin
  Result := StringOfChar('0', 8);

  for I := 0 to 7 do
  begin
    if (Value mod 2) = 1 then
      Result[8 - i] := '1';

    Value := Value div 2;
  end;
end;

function GetShortFilename(const FileName: TFileName): TFileName;
var
  buffer: array[0..MAX_PATH - 1] of char;
begin
  SetString(Result, buffer, GetShortPathName(pchar(FileName), buffer, MAX_PATH -
    1));
end;

function GetISOFilename(const FileName: string): string;
var
  TempRes: string;
  Ext: string;
begin
  if length(Filename) > 12 then
  begin
    Ext := extractfileext(Filename);
    TempRes := copy(Filename, 1, 6);
    TempRes := TempRes + '~1' + Ext + ';1';
  end
  else
    TempRes := Filename;
  Result := UpperCase(TempRes);
end;

function CDDB_Sum(N: Integer): Integer;
var
  Ret: Integer;
begin
  Ret := 0;
  while (N > 0) do
  begin
    Ret := Ret + (N mod 10);
    N := N div 10;
  end;
  Result := Ret;
end;

end.
