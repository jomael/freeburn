{-----------------------------------------------------------------------------
 Unit Name: DiscInfo
 Author:    Paul Fisher / Andrew Semack
 Purpose:   Class for CD / DVD disk information
 History:
-----------------------------------------------------------------------------}

unit DiscInfo;

interface

uses
  Windows, Classes, SysUtils, SCSIDefs, DeviceTypes, CDDAText, DiskCDDBInfo,
    SCSIUnit, SCSITypes, CovertFuncs, Resources;

type
  TDiscInfo = class
  private
    FLastError: TScsiError;
    FDefaults: TScsiDefaults;
    FInfoRecord: PCDBurnerInfo;
    FDiscLayout: TDiscLayout;
    FCDText: TCDDAText;
    FCDDBQuery: TCDDBQuery;
    FDeviceDiscType: TScsiProfileDeviceDiscTypes;
    FEmptyDisk: Boolean;
    FISAudioDisk : Boolean;
    function GetBurnerInfo: TCDBurnerInfo;
    function GetCDText: TCDDAText;
    function GetDiscType: TScsiProfileDeviceDiscTypes;
    function GetIsErasable: boolean;
    function GetLastTrack: integer;
    function GetTOC: TScsiTOC;
    function GetCDDBInfo: TCDDBQuery;
    function GetLayout: TDiscLayout;
    function GetSessions: TScsiSessionInfo;
    function GetCapacity: integer;
    function GetFormatCapacity: TFormatCapacity;
    function GetISRC(TrackNumber: integer): TScsiISRC;
    function GetSectorType(aLBA: integer): TScsiReadCdSectorType;
    function GetTrackInfo(ATrack: Byte): TTrackInformation;
    function GetDVDescriptor: TScsiDVDLayerDescriptorInfo;
    procedure RefreshDiskLayout;
  protected
    property BurnerInfo: TCDBurnerInfo read GetBurnerInfo;
  public
    constructor Create(InfoRecord: PCDBurnerInfo);
    destructor Destroy; override;
    Procedure RefreshInfo;
    function CDDB_ID: string;
    procedure CreateCUEFile(ISOFileName, CUEFileName: string);
    property IsAudioDisk: boolean read FISAudioDisk;
    property IsErasable: boolean read GetIsErasable;
    property DiscType: TScsiProfileDeviceDiscTypes read GetDiscType;
    property LastTrack: integer read GetLastTrack;
    property TOC: TScsiTOC read GetTOC;
    property DiscLayout: TDiscLayout read GetLayout;
    property Sessions: TScsiSessionInfo read GetSessions;
    property Capacity: integer read GetCapacity;
    property CDText: TCDDAText read GetCDText;
    property CDDBInformation: TCDDBQuery read GetCDDBInfo;
    property FormatCapacity: TFormatCapacity read GetFormatCapacity;
    property SectorType[aLBA: integer]: TScsiReadCdSectorType read
      GetSectorType;
    property ISRC[TrackNumber: integer]: TScsiISRC read GetISRC;
    property TrackInformation[ATrack: Byte]: TTrackInformation read
      GetTrackInfo;
    property DVDescriptor: TScsiDVDLayerDescriptorInfo read GetDVDescriptor;
  end;

implementation

{ TDiscInfo }

{ TODO : There should be implemenation to detect current inseted disk propertiies }
{ TODO : Need to implement cd door close then check for disk : getdisktype}

constructor TDiscInfo.Create(InfoRecord: PCDBurnerInfo);
begin
  FinfoRecord := InfoRecord;
  FDefaults := SCSI_DEF;
  FCDDBQuery := TCDDBQuery.Create;
  FCDText := TCDDAText.Create;
  RefreshInfo;
end;

destructor TDiscInfo.Destroy;
begin
  FCDDBQuery.Free;
  FCDText.Free;
end;

function TDiscInfo.GetBurnerInfo: TCDBurnerInfo;
begin
  Result := FInfoRecord^;
end;


Procedure TDiscInfo.RefreshInfo;
begin
   FDeviceDiscType := GetDiscType;
   FISAudioDisk := False;
   FEmptyDisk := False;
   if (TOC.TrackCount < 1) then FEmptyDisk := True;
   if (ssqfAudioTrack in TOC.Tracks[0].Flags) then FISAudioDisk := True;
End;


function TDiscInfo.GetCapacity: integer;
var
  temp: cardinal;
begin
  FLastError := SCSIreadCapacity(BurnerInfo, temp, fDefaults);
  Result := Temp;
end;

function TDiscInfo.GetDiscType: TScsiProfileDeviceDiscTypes;
begin
  FLastError := SCSIGetDevConfigProfileMedia(BurnerInfo, Result, fDefaults);
end;

function TDiscInfo.GetFormatCapacity: TFormatCapacity;
begin
  FLastError := SCSIReadFormatCapacity(BurnerInfo, Result, fDefaults);
end;

function TDiscInfo.GetIsErasable: boolean;
begin
  Result := False;
end;

function TDiscInfo.GetISRC(TrackNumber: integer): TScsiISRC;
begin
  FLastError := SCSIgetISRC(BurnerInfo, TrackNumber, Result, fDefaults);
end;

function TDiscInfo.GetLastTrack: integer;
begin
  Result := 0;
end;

procedure TDiscInfo.RefreshDiskLayout;
begin
  FLastError := SCSIgetLayoutInfo(BurnerInfo, FDiscLayout, fDefaults);
end;

function TDiscInfo.GetLayout: TDiscLayout;
begin
  Result := FDiscLayout;
end;

function TDiscInfo.GetSectorType(aLBA: integer): TScsiReadCdSectorType;
begin
  FLastError := SCSIreadHeader(BurnerInfo, aLBA, Result, fDefaults);
end;

function TDiscInfo.GetSessions: TScsiSessionInfo;
begin
  FLastError := SCSIgetSessionInfo(BurnerInfo, Result, fDefaults);
end;

function TDiscInfo.GetTOC: TScsiTOC;
begin
  FLastError := SCSIgetTOC(BurnerInfo, Result, fDefaults);
end;

function TDiscInfo.GetTrackInfo(ATrack: Byte): TTrackInformation;
begin
  FLastError := SCSIReadTrackInformation(BurnerInfo, ATrack, Result, fDefaults);
end;

function TDiscInfo.GetDVDescriptor: TScsiDVDLayerDescriptorInfo;
begin
  FLastError := SCSIReadDVDStructure(BurnerInfo, Result, fDefaults);
end;

function TDiscInfo.CDDB_ID: string;
var
  Index, DiskID, TrackID: integer;
  PreTrack1, PreTrack2: Integer;
  PreHex: DWord;

begin
  Result := 'ffffffff';
  TrackID := 0;
  // add up all track sizes
  for Index := 0 to TOC.LastTrack - 1 do
    TrackID := TrackID + CDDB_Sum(LBA2PreCDDB(TOC.Tracks[Index].AbsAddress));
  //size of the disc
  PreTrack1 := LBA2PreCDDB(TOC.Tracks[TOC.LastTrack].AbsAddress);
  PreTrack2 := LBA2PreCDDB(TOC.Tracks[0].AbsAddress);
  DiskID := (PreTrack1 - PreTrack2);
  // Create CDDB ID
  TrackID := (TrackID mod $FF);
  TrackID := TrackID shl 24;
  DiskID := DiskID shl 8;
  PreHex := TrackID or DiskID or (TOC.LastTrack);
  Result := LowerCase(IntToHex(PreHex, 8)); //a70ce90d
end;

function TDiscInfo.GetCDDBInfo: TCDDBQuery;
var
  DBID: string;
begin
  DBID := CDDB_ID;
  FCDDBQuery.ClearCDDB;
  FCDDBQuery.ApplicationName := 'FreeBurner.exe';
  FCDDBQuery.CDDBID := DBID;
  FCDDBQuery.GetCDDBInfo;
  Result := FCDDBQuery;
end;

function TDiscInfo.GetCDText: TCDDAText;
var
  CDTEXT: TCDText;
  Packets, Index: integer;
  Trackname, HoldStr: string;
begin
  Result := nil;
  FLastError := SCSIgetTOCCDText(BurnerInfo, CDTEXT, fDefaults);
  if fLastError = Err_None then
  begin
    for Packets := 0 to 255 do
    begin
      Result := FCDText;
      if CDTEXT.CDText[Packets].idSeq <> Packets then exit;
      if ((CDTEXT.CDText[Packets].idFlg and $30) = 0) then //dont want unicode
      begin
        case CDTEXT.CDText[Packets].idType of
          CD_TEXT_PACK_ALBUM_NAME: if (CDTEXT.CDText[Packets].idTrk = 0) then
            begin
              for Index := 0 to 11 do
                begin
                  HoldStr := HoldStr + Chr(CDTEXT.CDText[Packets].txt[Index]);
                  if Chr(CDTEXT.CDText[Packets].txt[Index]) = #0 then
                  begin
                     FCDText.Album := HoldStr;
                     HoldStr := '';
                  end;
                end;
            end
            else
            begin
              for Index := 0 to 11 do
               begin
                  Trackname := Trackname + Chr(CDTEXT.CDText[Packets].txt[Index]);
                  if Chr(CDTEXT.CDText[Packets].txt[Index]) = #0 then
                  begin
                     FCDText.MusicTracks.Add(TrackName);
                     Trackname := '';
                  end;
               end;
            end;
          CD_TEXT_PACK_PERFORMER:
            begin
               for Index := 0 to 11 do
                begin
                  HoldStr := HoldStr + Chr(CDTEXT.CDText[Packets].txt[Index]);
                  if Chr(CDTEXT.CDText[Packets].txt[Index]) = #0 then
                  begin
                     if (CDTEXT.CDText[Packets].idTrk <> 0) then
                     begin
                        HoldStr := FCDText.MusicTracks[CDTEXT.CDText[Packets].idTrk -1 ] + ' : ' + HoldStr;
                        FCDText.MusicTracks[CDTEXT.CDText[Packets].idTrk -1 ] := HoldStr;
                        HoldStr := '';
                     end
                      else
                       FCDText.Artist := HoldStr;
                  end;
                end;
            end;
          CD_TEXT_PACK_GENRE: if (CDTEXT.CDText[Packets].idTrk = 0) then
            begin
               for Index := 0 to 11 do
                begin
                  HoldStr := HoldStr + Chr(CDTEXT.CDText[Packets].txt[Index]);
                  if Chr(CDTEXT.CDText[Packets].txt[Index]) = #0 then
                  begin
                     FCDText.Genre := HoldStr;
                     HoldStr := '';
                  end;
                end;
            end;
        end; //case
      end;
    end; // end packet loop
  end;
end;




procedure TDiscInfo.CreateCUEFile(ISOFileName, CUEFileName: string);
var
  CueFile: TStringList;
  SectorType: string;
  i, j: integer;
  k, s: string;
begin
  CueFile := TStringList.Create;
  CueFile.Add('FILE "' + ExtractFileName(ISOFileName) + '" BINARY');
  CueFile.Add('');
  RefreshDiskLayout;
  for I := Disclayout.FirstSession to Disclayout.LastSession do
  begin
    k := Format('%02.02d', [I]);
    CueFile.Add(' REM SESSION ' + k +
      '        ; Not supported by all applications');
    for j := Disclayout.Sessions[i].FirstTrack to
      Disclayout.Sessions[i].LastTrack do
    begin
      k := Format('%02.02d', [j]);
      SectorType := Disclayout.Sessions[i].Tracks[j].fTypeStr;
      if SectorType = 'Audio' then
        s := '  TRACK ' + k + ' AUDIO';
      if SectorType = 'Data (Mode 1)' then
        s := '  TRACK ' + k + ' MODE1/2352';
      if SectorType = 'Data (Mode 2)' then
        s := '  TRACK ' + k + ' MODE2/2352';
      CueFile.Add(s);
      CueFile.Add('    INDEX 01 ' + Disclayout.Sessions[i].Tracks[j].StartAddressStr);
      CueFile.Add('    REM MSF: ' + Disclayout.Sessions[i].Tracks[j].StartAddressStr + ' = LBA: ' +
        inttostr(Disclayout.Sessions[i].Tracks[j].StartAddress));
    end;
  end;
  CueFile.Add('');
  CueFile.Add('');
  CueFile.Add(resCueInfo);
  CueFile.Add(resCueWebInfo);
  CueFile.SaveToFile(CUEFileName);
  CueFile.Free;
end;


{
TITLE "How Precious"
PERFORMER "Dino"
SONGWRITER "Enya"
}


end.
