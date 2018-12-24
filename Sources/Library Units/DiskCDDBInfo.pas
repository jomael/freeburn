unit DiskCDDBInfo;

interface

Uses WinInet, Windows, Sysutils, Classes;


Const
     CDDBServer   = 'Freedb.Freedb.org';
     CDDBCmdStr   = '/~cddb/cddb.cgi?cmd=';
     CDDBCmdHello = '&hello=AudioUser+hostname+FreeBurner+1.0&proto=4';

Type
   TCDDBQuery = Class
   private
    FCDDBID : String;
    FAlbum  : String;
    FArtist : String;
    FCategory  : String;
    FYear   : String;
    FErrorCode : Integer;
    FTracks : TStringList;
    FEXTData : TStringList;
    FWEBText : String;
    FApplicationName : String;
    function GetAlbum: string;
    function GetArtist: string;
    function GetCategory: string;
    function GetYear: string;
    function GetCDDBRead: String;
    function GetInetFile(FileURL: String): boolean;
    procedure ReadCDInfoFromData;

   Public
    constructor Create;
    destructor Destroy; override;
    procedure ClearCDDB;
    Procedure GetCDDBInfo;
   Published
    property ApplicationName : String read FApplicationName write FApplicationName;
    property CDDBID  : String read FCDDBID write FCDDBID;
    property Artist  : string read GetArtist;
    property Album   : string read GetAlbum;
    property Tracks  : TStringlist read FTracks;
    property Category: string read GetCategory;
    property Year    : string read GetYear;
  end;





implementation


constructor TCDDBQuery.Create;
begin
  FTracks := TStringList.create;
  FEXTData := TStringList.create;
end;

destructor TCDDBQuery.Destroy;
begin
    FTracks.free;
    FEXTData.free;
    Inherited Destroy;
end;

function TCDDBQuery.GetCDDBRead: String;
begin
  if FCDDBID <>'' then
    Result := 'http://'+CDDBServer + CDDBCmdStr + 'cddb+read+' + FCategory + '+' + FCDDBID
  else
    Result := 'http://'+CDDBServer + CDDBCmdStr + 'cddb+read+' + FCategory;
  Result := LowerCase(Result) + CDDBCmdHello;
  //http://Freedb.Freedb.org/~cddb/cddb.cgi?cmd=cddb+read+rock+c611cd0e&hello=AudioUser+hostname+FreeBurner+1.0&proto=4
end;

function TCDDBQuery.GetAlbum: string;
begin
  Result := FAlbum;
end;

function TCDDBQuery.GetArtist: string;
begin
  Result := FArtist;
end;

function TCDDBQuery.GetCategory: string;
begin
  Result := FCategory;
end;

function TCDDBQuery.GetYear: string;
begin
  Result := FYear;
end;

procedure TCDDBQuery.ClearCDDB;
begin
    FCategory:='';
    FArtist:='';
    FAlbum:='';
    FYear:='';
    FTracks.clear;
    FEXTData.Clear;
end;



function TCDDBQuery.GetInetFile(FileURL: String): boolean;
const BufferSize = 16384;
var
  hSession, hURL: HInternet;
  Buffer   : PChar;
  BuffStr : String;
  sAppName: string;
  FBytesRead : dword;
  RC : boolean;

begin
 Result := False;
 FWEBText := '';
 sAppName := ExtractFileName(FApplicationName);
 hSession := InternetOpen(PChar(sAppName),INTERNET_OPEN_TYPE_PRECONFIG,nil, nil, 0);
 try
  hURL := InternetOpenURL(hSession,PChar(FileURL),nil,0,0,0);
  try
    GetMem(Buffer,BufferSize);
   repeat
    rc := InternetReadFile(hURL,Buffer,BufferSize,FBytesRead);
    BuffStr := Buffer;
    FWEBText := FWEBText + Copy(BuffStr,1,FBytesRead);
    Sleep(0);
   until not RC or (FBytesRead = 0);
   Result := True;
  finally
   InternetCloseHandle(hURL)
  end
 finally
  InternetCloseHandle(hSession)
 end
end;



procedure TCDDBQuery.ReadCDInfoFromData;
var
  i,si,p,j :integer;
  CDBString, StatusID : string;
  sl : TStringList;
  Position : integer;

begin
  ClearCDDB;
  si := 0;
  sl := TStringList.Create;
  sl.text := FWEBText;
  CDBString :='';
  CDBString := sl.Strings[0];    // 210 rock c611cd0e
  // get status
  Position := pos(' ',CDBString);
  if Position >0 then
  begin
     StatusID := trim(Copy(CDBString,1,Position));
     delete(CDBString,1,Position);
  end;
  // get category
  if StatusID = '210' then
   begin
      Position := pos(' ',CDBString);
    if Position >0 then
     begin
       FCategory := trim(Copy(CDBString,1,Position));
     end;
  CDBString := '';
  for i := 0 to sl.Count -1 do
    if pos('DTITLE=',sl[i]) = 1 then begin
      CDBString := CDBString + copy(sl[i],system.Length('DTITLE=')+1,1024);
      si := i;
    end else
      if CDBString<>'' then
        Break;
  p := pos(' / ',CDBString);
  if p > 0 then
   begin
    FArtist := copy(CDBString,1,p-1);
    FAlbum := copy(CDBString,p+3,1024);
    FTracks.Add(Artist);
    FTracks.Add(Album);
  end;
  j := 0;
  FTracks.Clear;
  for i := si + 1 to sl.count-1 do
   begin
    if pos('TTITLE',sl[i]) = 1 then begin
      FTracks.Add(copy(sl[i],system.Length('TTITLE'+inttostr(j)+'=')+1,1024));
      inc(j);
    end
     else
      break;
  end;
  end;
  sl.free;
end;




Procedure TCDDBQuery.GetCDDBInfo;
var
    CDDBQuery : String;
begin
  FCategory := 'rock';
  CDDBQuery := GetCDDBRead;
  If GetInetFile(CDDBQuery) = true then
  begin
    ReadCDInfoFromData;
  end;
end;



end.
