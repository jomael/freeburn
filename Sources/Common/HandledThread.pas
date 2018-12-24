{-----------------------------------------------------------------------------
 Unit Name: HandledThread
 Author:    Paul Fisher / Andrew Semack
 Purpose:   Base class for the Burn and erase threads
 History:
-----------------------------------------------------------------------------}

unit HandledThread;

interface

uses
  Windows, Classes, SysUtils, Forms, Messages;

type
  THandledThread = class(TThread)
  private
    FException: Exception;
    procedure DoHandleException;
  protected
    procedure HandleException; virtual;
  public
  end;

implementation

{ THandledThread }

procedure THandledThread.DoHandleException;
begin
  if GetCapture <> 0 then
    SendMessage(GetCapture, WM_CANCELMODE, 0, 0);
  if FException is Exception then
    Application.ShowException(FException)
  else
    SysUtils.ShowException(FException, nil);
end;

procedure THandledThread.HandleException;
begin
  FException := Exception(ExceptObject);
  try
    if not (FException is EAbort) then
      Synchronize(DoHandleException);
  finally
    FException := nil;
  end;
end;

end.
