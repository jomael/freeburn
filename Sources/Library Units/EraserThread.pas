{-----------------------------------------------------------------------------
 Unit Name: EraserThread
 Author:    Paul Fisher / Andrew Semack
 Purpose:   Thread class for disk formatting and erasing
 History:
-----------------------------------------------------------------------------}

unit EraserThread;

interface

uses
  Windows, Classes, HandledThread, Device, DeviceTypes, SCSIUnit,
  SCSIDefs, SCSITypes, Resources;

type
  TEraserThread = class(THandledThread)
  private
    FInfoRecord: PCDBurnerInfo;
    FBurnSettings: TBurnSettings;
    FGLBA: Integer;
    FOnCDStatus: TCDStatusEvent;
    FOnCopyStatus: TCopyStatusEvent;
    FOnBufferProgress: TCDBufferProgressEvent;
    FOnFileBufferProgress: TCDFileBufferProgressEvent;
    FOnBufferStatus: TCDBufferStatusEvent;
    FOnWriteStatusEvent: TCDWriteStatusEvent;
    FDefaults: TScsiDefaults;
    function GetBurnerInfo: TCDBurnerInfo;
  protected
    procedure Execute; override;
    procedure FormatDisk;
    property BurnerInfo: TCDBurnerInfo read GetBurnerInfo;
  public
    procedure Erase;
    constructor Create(InfoRecord: PCDBurnerInfo);
    destructor Destroy; override;
    property BurnSettings: TBurnSettings read FBurnSettings write FBurnSettings;
    property GLBA: Integer read FGLBA write FGLBA default 0;
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

{ TBurnerThread }

procedure TEraserThread.Erase;
begin
  Resume;
end;

constructor TEraserThread.Create(InfoRecord: PCDBurnerInfo);
begin
  inherited Create(True); // already created suspended
  Priority := TThreadPriority(tpTimeCritical); // Set Priority Level
  FreeOnTerminate := True; // Thread Free Itself when terminated
  FInfoRecord := InfoRecord;
end;

destructor TEraserThread.Destroy;
begin
  inherited;
end;

function TEraserThread.GetBurnerInfo: TCDBurnerInfo;
begin
  Result := FInfoRecord^;
end;

procedure TEraserThread.FormatDisk;
begin
  if Assigned(FOnCDStatus) then
    FOnCDStatus(resErasingData);
  SCSIBlankCD(BurnerInfo, FBurnSettings.EraseType, FGLBA, fDefaults);
  if Assigned(FOnCDStatus) then
    FOnCDStatus(resEraseFinish);
end;

procedure TEraserThread.Execute;
begin
  try
    FormatDisk;
  except
    HandleException;
  end;
end;

end.
