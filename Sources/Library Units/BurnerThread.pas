{-----------------------------------------------------------------------------
 Unit Name: BurnerThread
 Author:    Paul Fisher / Andrew Semack
 Purpose:   main thread to burn TCustomimages (audio / file / iso9660 / DVD /BinCUE)
 History:
-----------------------------------------------------------------------------}

unit BurnerThread;

interface

uses
  Windows, Classes, SCSIDefs, DeviceTypes, CustomImage, FileImage,
  AudioImage, DVDImage, ISOImage, BinCueImage, HandledThread,Resources,
  SysUtils, SCSIUnit, SCSITypes, CDBufferedStream;

type
  TBurnerThread = class(THandledThread)
  private
    FInfoRecord: PCDBurnerInfo;
    FBurnSettings: TBurnSettings;
    FOnCDStatus: TCDStatusEvent;
    FOnCopyStatus: TCopyStatusEvent;
    FOnBufferProgress: TCDBufferProgressEvent;
    FOnFileBufferProgress: TCDFileBufferProgressEvent;
    FOnBufferStatus: TCDBufferStatusEvent;
    FOnWriteStatusEvent: TCDWriteStatusEvent;
    FFileName: string;
    FImage: TCustomImage;
    FLastError: TScsiError;
    FDefaults: TScsiDefaults;
    ISOFilestream: TCDBufferedStream;
    BufferSize: Integer;
    BufferFreeSpace: Integer;
    FCDSpeedType: Integer;
    function SetWriteMode(BurnSettings: TBurnSettings): boolean;
    function WriteData(GLBA: DWORD; SectorCount: WORD;
      Buf: pointer; BufLen: DWORD): boolean;
    function WriteAudio(GLBA, SectorCount: DWORD;
      Buf: pointer; BufLen: DWORD): boolean;
    function SendCueSheet(ATIPBuffer: pointer; ATIPBufferSize : longint): boolean;
    function GetBufferFreeSpace: Integer;
    function GetBufferCapacity: Integer;
    function CloseTrack(TrackNo: Byte): boolean;
    function CloseSession: boolean;
    function SyncCache: boolean;
    function GetBurnerInfo: TCDBurnerInfo;
    procedure WriteImage;
  protected
    function WriteISOToCD(Filename: string): boolean;
    function WriteAudioCD(TrackCount: Integer): boolean;
    function WriteDAOImage: boolean;
    procedure Execute; override;
    property BurnerInfo: TCDBurnerInfo read GetBurnerInfo;
  public
    procedure Burn;
    constructor Create(InfoRecord: PCDBurnerInfo; ISOImage: TCustomImage);
    destructor Destroy; override;
  published
    property BurnSettings: TBurnSettings read FBurnSettings write FBurnSettings;
    property CDSpeed: Integer read FCDSpeedType write FCDSpeedType default
      SCDS_MAXSPEED;
    property OnCDStatus: TCDStatusEvent read FOnCDStatus write FOnCDStatus;
    property OnCopyStatus: TCopyStatusEvent read FOnCopyStatus write
      FOnCopyStatus;
    property OnBufferProgress: TCDBufferProgressEvent read FOnBufferProgress
      write FOnBufferProgress;
    property OnFileBufferProgress: TCDFileBufferProgressEvent read
      FOnFileBufferProgress write FOnFileBufferProgress;
    property OnBufferStatus: TCDBufferStatusEvent read FOnBufferStatus write
      FOnBufferStatus;
    property OnWriteStatusEvent: TCDWriteStatusEvent read FOnWriteStatusEvent
      write FOnWriteStatusEvent;
  end;

implementation

uses CovertFuncs;

{ TBurnerThread }

procedure TBurnerThread.Burn;
begin
  Resume;
end;

constructor TBurnerThread.Create(InfoRecord: PCDBurnerInfo; ISOImage: TCustomImage);
begin
  inherited Create(True); // Create thread suspended
  Priority := TThreadPriority(tpTimeCritical); // Set Priority Level
  FreeOnTerminate := True; // Thread Free Itself when terminated
  FFileName := '';
  FImage := ISOImage;        // assign tcustomimage
  FInfoRecord := InfoRecord; // CD/DVD Burner
end;

function TBurnerThread.GetBurnerInfo: TCDBurnerInfo;
begin
  Result := FInfoRecord^;
end;

destructor TBurnerThread.Destroy;
begin
  if ISOFilestream <> nil then ISOFilestream.Free;
  inherited;
end;

function TBurnerThread.SetWriteMode(BurnSettings: TBurnSettings): boolean;
begin
  FLastError := SCSISetWriteParameters(BurnerInfo, 0,
    BurnSettings.WriteType, BurnSettings.DataBlockType, BurnSettings.TrackMode,
      BurnSettings.SessionType,
    BurnSettings.PacketSize, BurnSettings.AudioPause, BurnSettings.TestWrite,
      BurnSettings.BurnProof, fDefaults);
  Result := fLastError = Err_None;
end;


function TBurnerThread.SendCueSheet(ATIPBuffer: pointer; ATIPBufferSize : longint): boolean;
begin
  FLastError := SCSISendCUESheet(BurnerInfo, ATIPBuffer, ATIPBufferSize, fDefaults);
  Result := fLastError = Err_None;
end;



function TBurnerThread.WriteData(GLBA: DWORD; SectorCount: WORD;
  Buf: pointer; BufLen: DWORD): boolean;
begin
  FLastError := SCSIWrite10(BurnerInfo, GLBA, SectorCount, Buf, BufLen,
    fDefaults);
  Result := fLastError = Err_None;
end;

function TBurnerThread.WriteAudio(GLBA, SectorCount: DWORD;
  Buf: pointer; BufLen: DWORD): boolean;
begin
  fLastError := SCSIWriteCDDA(BurnerInfo, GLBA, SectorCount, csfAudio,
    [cffUserData], Buf, BufLen, fDefaults);
  Result := fLastError = Err_None;
end;

function TBurnerThread.GetBufferFreeSpace: Integer;
var
  BufferInfo: TScsiCDBufferInfo;
  FreeSpace: DWord;
begin
  FillChar(BufferInfo, sizeof(TScsiCDBufferInfo), 0);
  SCSIgetBufferCapacity(BurnerInfo, BufferInfo, fDefaults);
  FreeSpace := BufferInfo.BlankLength;
  FreeSpace := Swap32(FreeSpace);
  Result := FreeSpace;
end;

function TBurnerThread.GetBufferCapacity: Integer;
var
  BufferInfo: TScsiCDBufferInfo;
  BufSpace: DWord;
  FreeSpace: DWord;
  Percent, Divisor: Integer;

begin
  FillChar(BufferInfo, sizeof(TScsiCDBufferInfo), 0);
  SCSIgetBufferCapacity(BurnerInfo, BufferInfo, fDefaults);
  BufSpace := BufferInfo.SizeOfBuffer;
  FreeSpace := BufferInfo.BlankLength;
  BufferSize := Swap32(BufSpace);
  BufferFreeSpace := Swap32(FreeSpace);
  Divisor := (BufferSize div 100);
  Percent := ((BufferSize - BufferFreeSpace) div Divisor);
  if (Percent < 0) then
    Percent := 0;
  if (Percent > 100) then
    Percent := 100;
  Result := Percent;
end;

function TBurnerThread.CloseSession: boolean;
begin
  FLastError := SCSICloseSession(BurnerInfo, fDefaults);
  Result := FLastError = Err_None;
end;

function TBurnerThread.CloseTrack(TrackNo: Byte): boolean;
begin
  FLastError := SCSICloseTrack(BurnerInfo, TrackNo, fDefaults);
  Result := FLastError = Err_None;
end;

function TBurnerThread.SyncCache: boolean;
begin
  FLastError := SCSISYNCCACHE(BurnerInfo, fDefaults);
  Result := FLastError = Err_None;
end;

function TBurnerThread.WriteISOToCD(Filename: string): boolean;
var
  ISOFilestream: TCDBufferedStream;
  Buf: Pointer;
  BufLen, SectorSize, SectorsToWrite: integer;
  BytesWritten: integer;
  IndexBlock: integer;
  LastBlock: integer;
begin
  if (FBurnSettings.DataBlockType = btRAW_DATA_P_Q_SUB) then
    FBurnSettings.TrackMode := tmCDR_MODE_DAO_96
  else
    FBurnSettings.TrackMode := tmCDR_MODE_DATA;
  if not
    SetWriteMode(FBurnSettings) then
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resSetDataHardwareFail);
    Result := False;
    exit;
  end
  else if Assigned(FOnCDStatus) then
    FOnCDStatus(resSetDataHardwareOK);

  ISOFilestream := TCDBufferedStream.Create(Filename, fmOpenRead);

  SectorSize := ConvertDataBlock(FBurnSettings.DataBlockType);
  ISOFilestream.SectorSize := SectorSize;

  if not ISOFilestream.ISOSectorSizeOK then
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resImageSizeError);
    ISOFilestream.free;
    Result := False;
    exit;
  end;

  LastBlock := ISOFilestream.SectorCount;
  IndexBlock := 0;
  BytesWritten := 0;
  SectorsToWrite := 20; // increase to make faster writing ????
  Buf := nil;
  BufLen := (SectorSize * SectorsToWrite); //10 * 4096 40kb at a time
  ReallocMem(Buf, BufLen); // alloc max buf size

  while (BytesWritten < ISOFilestream.Size - 1) do
    //  for IndexBlock := 0 to LastBlock - 1 do
  begin
    try
      if (SectorsToWrite > ISOFilestream.SectorsLeft) then
        SectorsToWrite := (ISOFilestream.SectorsLeft);
      buflen := (SectorSize * SectorsToWrite);

      BytesWritten := BytesWritten + ISOFilestream.Read(pchar(Buf)^, BufLen);
        // read data from iso

      if not WriteData(IndexBlock, SectorsToWrite, buf, BufLen) then
        // write data to cd
      begin
        if Assigned(FOnCDStatus) then
          FOnCDStatus(resDiskWriteError);
        ISOFilestream.free;
        Result := False;
        exit;
      end;

      inc(IndexBlock, SectorsToWrite);
    finally
      if Assigned(FOnCopyStatus) then
        FOnCopyStatus(IndexBlock, (IndexBlock div ((LastBlock - 1) div 100)));
      if Assigned(FOnWriteStatusEvent) then
        FOnWriteStatusEvent(BytesWritten);
      if Assigned(FOnBufferProgress) then
        FOnBufferProgress(GetBufferCapacity);
      if Assigned(FOnBufferStatus) then
        FOnBufferStatus(BufferSize, BufferFreeSpace);
      if Assigned(FOnFileBufferProgress) then
        FOnFileBufferProgress(ISOFilestream.BufferPercentFull);
    end;
    while (GetBufferFreeSpace < 2448) do
    begin
      if Assigned(FOnBufferProgress) then
        FOnBufferProgress(GetBufferCapacity);
        sleep(500);
    end;
  end; {writing for loop}

  ReallocMem(Buf, 0);
  if Assigned(FOnBufferProgress) then
    FOnBufferProgress(GetBufferCapacity);
  if Assigned(FOnCDStatus) then
    FOnCDStatus(resSyncCache);
  if not SyncCache then // Sync the cache buffer
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resSyncCacheError);
    ISOFilestream.free;
    Result := False;
    exit;
  end;

  if Assigned(FOnCDStatus) then
    FOnCDStatus(resCloseTrack);
  self.CloseTrack(1);
  self.SyncCache;

  if CloseSession = true then
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resCloseSession);
    self.CloseSession;
    self.SyncCache;
  end;

  if Assigned(FOnBufferProgress) then
    FOnBufferProgress(GetBufferCapacity);
  if Assigned(FOnFileBufferProgress) then
    FOnFileBufferProgress(0);
  ISOFilestream.Free;
  Result := True;
  BufLen := (SectorSize * 20);
  Freemem(Buf, BufLen);
  if Assigned(FOnCDStatus) then
    FOnCDStatus(resFinishISOBurn);
  Self.Terminate;
end;



function TBurnerThread.WriteAudioCD(TrackCount: Integer): boolean;
var
  Buf: Pointer;
  BufLen, SectorSize, TempDataSize: integer;
  SectorsToWrite: Integer;
  BytesWritten: integer;
  TrackID: Integer;
  LastTrackLBA: Integer;
  IndexBlock: integer;
  LastBlock: integer;
  CDTracks : TAudioImage;
begin
  LastTrackLBA := 0; // set start point
  BufLen := 0;
  CDTracks := TAudioImage(FImage);

  if not SetWriteMode(FBurnSettings) then
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resSetAudioHardwareFail);
    Result := False;
    exit;
  end
  else if Assigned(FOnCDStatus) then
    FOnCDStatus(resSetAudioHardwareOK);

  for TrackID := 0 to TrackCount - 1 do //burn all tracks to cd
  begin
    FOnCDStatus('Burning :' + CDTracks.Tracks[TrackID].CDTrack.TrackName);
    SectorSize := ConvertDataBlock(FBurnSettings.DataBlockType);
    CDTracks.Tracks[TrackID].CDTrack.SectorSize := SectorSize;

    LastBlock := (LastTrackLBA + CDTracks.Tracks[TrackID].CDTrack.SectorCount);
    //set data offsett past header
    CDTracks.Tracks[TrackID].CDTrack.Seek(soFromBeginning,
      CDTracks.Tracks[TrackID].CDTrack.DataOffset);

    SectorsToWrite := 20; //copy 20 sectors at a time
    BytesWritten := 0; // No of bytes written to disk
    BufLen := (SectorSize * SectorsToWrite); // big enough for 20 sectors
    Buf := nil;
    ReallocMem(Buf, BufLen);
    IndexBlock := LastTrackLBA;

    while (IndexBlock < LastBlock) do
      //for IndexBlock := LastTrackLBA to LastBlock - 1 do
    begin
      try
        TempDataSize := CDTracks.Tracks[TrackID].CDTrack.DataSize;
        if BufLen > (TempDataSize - BytesWritten) then
        begin
          BufLen := (TempDataSize - BytesWritten);
          SectorsToWrite := (LastBlock - IndexBlock); // find last sector count
        end;

        BytesWritten := BytesWritten +
          CDTracks.Tracks[TrackID].CDTrack.Read(pchar(Buf)^, BufLen);
          //read buffer full
        WriteAudio(IndexBlock, SectorsToWrite, buf, BufLen);
          // write the buffer to cd
        inc(IndexBlock, SectorsToWrite);
      finally
        if Assigned(FOnBufferProgress) then
          FOnBufferProgress(GetBufferCapacity);
        if Assigned(FOnCopyStatus) then
          FOnCopyStatus(IndexBlock, (IndexBlock div ((LastBlock - 1) div 100)));
        if Assigned(FOnWriteStatusEvent) then
          FOnWriteStatusEvent(BytesWritten);
        if Assigned(FOnBufferStatus) then
          FOnBufferStatus(BufferSize, BufferFreeSpace);
      end;
      while (GetBufferFreeSpace < 2448) do
        if Assigned(FOnBufferProgress) then
          FOnBufferProgress(GetBufferCapacity);
    end; //all track data for loop

    if Assigned(FOnCDStatus) then
      FOnCDStatus(resSyncCache);
    SyncCache;
    if Assigned(FOnBufferProgress) then
      FOnBufferProgress(GetBufferCapacity);
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resCloseTrack +
        inttostr(TrackID));
    CloseTrack(TrackID);
    LastTrackLBA := (LastBlock + FBurnSettings.AudioPause + 2);
      // reset LastTrackLBA to Next block to write (Leo-Soft)
  end; // for all tracks loop

  if FBurnSettings.CloseSession = True then
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resCloseSession);
    CloseSession;
  end;
  if Assigned(FOnBufferProgress) then
    FOnBufferProgress(GetBufferCapacity);
  Freemem(Buf, BufLen);
  if Assigned(FOnCDStatus) then
    FOnCDStatus(resFinishAudioBurn);
  Result := True;
  Self.Terminate;
end;



function TBurnerThread.WriteDAOImage: boolean;
var
  ISOFilestream: TCDBufferedStream;
  Buf: Pointer;
  BufLen, SectorSize, SectorsToWrite: integer;
  BytesWritten: integer;
  IndexBlock: integer;
  LastBlock: integer;
  BINFileName : String;
  ATIPBuffer : Pointer;
  ATIPBufferSize : Longint;
  BINCue : TBinCueImage;

begin
  BINFileName := TBinCueImage(FImage).BINFileName;
  FBurnSettings.TrackMode := TBinCueImage(FImage).TrackMode;
  SectorSize := TBinCueImage(FImage).SectorSize;

  //FImage seems to go out of scope after setwritemode, so set cue sheet first ?????
  ATIPBufferSize := (TBinCueImage(FImage).ATIPCueList.Count + 1) * 8; // no of bytes needed for ATIP CueSheet
  try
    ATIPBuffer := nil;
    ReallocMem(ATIPBuffer, ATIPBufferSize); // alloc max buf size
    Move(TBinCueImage(FImage).ATIPCueList.Cues, ATIPBuffer^, ATIPBufferSize); // move bytes from cue list to buffer

  if not SetWriteMode(FBurnSettings) then
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resSetDataHardwareFail);
    Result := False;
    exit;
  end
  else if Assigned(FOnCDStatus) then
    FOnCDStatus(resSetDataHardwareOK);

  if not SendCueSheet(ATIPBuffer, ATIPBufferSize) then
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resCUESheetFailed);
    Result := False;
    exit;
  end
  else if Assigned(FOnCDStatus) then
    FOnCDStatus(resCUESheetSent);

  finally
     freemem(ATIPBuffer,ATIPBufferSize);  // free cue sheet buffer
  end;

  ISOFilestream := TCDBufferedStream.Create(BINFileName, fmOpenRead);

  ISOFilestream.SectorSize := SectorSize;

  if not ISOFilestream.ISOSectorSizeOK then
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resImageSizeError);
    ISOFilestream.free;
    Result := False;
    exit;
  end;

  LastBlock := ISOFilestream.SectorCount;
  IndexBlock := 0;
  BytesWritten := 0;
  SectorsToWrite := 20; // increase to make faster writing ????
  Buf := nil;
  BufLen := (SectorSize * SectorsToWrite); //20 *  at a time
  ReallocMem(Buf, BufLen); // alloc max buf size

  while (BytesWritten < ISOFilestream.Size - 1) do
    //  for IndexBlock := 0 to LastBlock - 1 do
  begin
    try
      if (SectorsToWrite > ISOFilestream.SectorsLeft) then
        SectorsToWrite := (ISOFilestream.SectorsLeft);
      buflen := (SectorSize * SectorsToWrite);

      BytesWritten := BytesWritten + ISOFilestream.Read(pchar(Buf)^, BufLen);
        // read data from iso

      if not WriteData(IndexBlock, SectorsToWrite, buf, BufLen) then
        // write data to cd
      begin
        if Assigned(FOnCDStatus) then
          FOnCDStatus(resDiskWriteError);
        ISOFilestream.free;
        Result := False;
        exit;
      end;

      inc(IndexBlock, SectorsToWrite);
    finally
      if Assigned(FOnCopyStatus) then
        FOnCopyStatus(IndexBlock, (IndexBlock div ((LastBlock - 1) div 100)));
      if Assigned(FOnWriteStatusEvent) then
        FOnWriteStatusEvent(BytesWritten);
      if Assigned(FOnBufferProgress) then
        FOnBufferProgress(GetBufferCapacity);
      if Assigned(FOnBufferStatus) then
        FOnBufferStatus(BufferSize, BufferFreeSpace);
      if Assigned(FOnFileBufferProgress) then
        FOnFileBufferProgress(ISOFilestream.BufferPercentFull);
    end;
    while (GetBufferFreeSpace < 2448) do
      if Assigned(FOnBufferProgress) then
        FOnBufferProgress(GetBufferCapacity);
  end; {writing for loop}

  ReallocMem(Buf, 0);
  if Assigned(FOnBufferProgress) then
    FOnBufferProgress(GetBufferCapacity);
  if Assigned(FOnCDStatus) then
    FOnCDStatus(resSyncCache);
  if not SyncCache then // Sync the cache buffer
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resSyncCacheError);
    ISOFilestream.free;
    Result := False;
    exit;
  end;

  if Assigned(FOnCDStatus) then
    FOnCDStatus(resCloseTrack);
  self.CloseTrack(1);
  self.SyncCache;

  if CloseSession = true then
  begin
    if Assigned(FOnCDStatus) then
      FOnCDStatus(resCloseSession);
    self.CloseSession;
    self.SyncCache;
  end;

  if Assigned(FOnBufferProgress) then
    FOnBufferProgress(GetBufferCapacity);
  if Assigned(FOnFileBufferProgress) then
    FOnFileBufferProgress(0);
  ISOFilestream.Free;
  Result := True;
  BufLen := (SectorSize * 20);
  Freemem(Buf, BufLen);
  if Assigned(FOnCDStatus) then
    FOnCDStatus(resFinishISOBurn);
  Self.Terminate;
end;





procedure TBurnerThread.WriteImage;
begin
  if FImage is TFileImage then
  begin
    FFileName := TFileImage(FImage).ISOFileName;
    WriteISOToCD(FFileName);
  end
  else if FImage is TAudioImage then
  begin
    WriteAudioCD(TAudioImage(FImage).TrackCount);
  end
  else if FImage is TBinCueImage then
  begin
    WriteDAOImage;
  end;
end;


procedure TBurnerThread.Execute;
begin
  try
    WriteImage;
  except
    HandleException;
  end;
end;

end.
