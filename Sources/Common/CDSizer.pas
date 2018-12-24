{-----------------------------------------------------------------------------
 Unit Name: CDSizer
 Author:    Dancemammal
 Purpose:   Visual guide to CD / DVD Usage
 History:   First Code Release
-----------------------------------------------------------------------------}

unit CDSizer;

interface

uses Classes, Controls, Forms, Graphics, Messages, SysUtils, 
     WinProcs, WinTypes;

     { Unit-wide declarations }
     { type }
     { . . . }
     { var }
     { . . . }

type
  TCDSize = class(TGraphicControl)
    private
      { Private fields of TCDSize }
        { Storage for property BarColour }
        FBarColour : TColor;
        { Storage for property IsHorizontal }
        FIsHorizontal : Boolean;
        { Storage for property MaxCDSize }
        FMaxCDSize : Integer;
        { Storage for property MaxMemory }
        FMaxMemory : Integer;
        { Storage for property OverBurnColour }
        FOverBurnColour : TColor;
        { Storage for property PercentShaded }
        FMEMShaded : Integer;
        { Storage for property TickColour }
        FTickColour : TColor;
        { Pointer to application's OnOverBurn handler, if any }
        FOnOverBurn : TNotifyEvent;
        { Storage for property BarColour }
        FMEMBarColour : TColor;
        FGap : Integer;

      { Private methods of TCDSize }
        { Method to set variable and property values and create objects }
        procedure AutoInitialize;
        { Method to free any objects created by AutoInitialize }
        procedure AutoDestroy;
        { Read method for property BarColour }
        function GetBarColour : TColor;
        { Write method for property BarColour }
        procedure SetBarColour(Value : TColor);
        { Read method for property BarColour }
        function GetMemBarColour : TColor;
        { Write method for property BarColour }
        procedure SetMemBarColour(Value : TColor);
        { Read method for property MaxCDSize }
        function GetMaxCDSize : Integer;
        { Write method for property MaxCDSize }
        procedure SetMaxCDSize(Value : Integer);
        { Read method for property MaxMemory }
        function GetMaxMemory : Integer;
        { Write method for property MaxMemory }
        procedure SetMaxMemory(Value : Integer);
        { Read method for property OverBurnColour }
        function GetOverBurnColour : TColor;
        { Write method for property OverBurnColour }
        procedure SetOverBurnColour(Value : TColor);
        { Write method for property PercentShaded }
        procedure SetPercentShaded(Value : Integer);
        { Read method for property TickColour }
        function GetTickColour : TColor;
        { Write method for property TickColour }
        procedure SetTickColour(Value : TColor);

    protected
      { Protected fields of TCDSize }
        TickCount : double;

      { Protected methods of TCDSize }
        { Method to generate OnOverBurn event }
        procedure OverBurn(Sender : TObject); virtual;
        procedure Paint; override;

    public
      { Public fields and properties of TCDSize }
        { Orientation of the progress bar (read-only) }
        property IsHorizontal : Boolean read FIsHorizontal;

      { Public methods of TCDSize }
        constructor Create(AOwner: TComponent); override;
        destructor Destroy; override;

    published
      { Published properties of TCDSize }
        property OnOverBurn : TNotifyEvent read FOnOverBurn write FOnOverBurn;
        property BarColour : TColor
             read GetBarColour write SetBarColour
             default clSilver;
        property MemBarColour : TColor
             read GetMemBarColour write SetMemBarColour
             default clSilver;
        Property ProgressGap : Integer read FGap write FGap default 2;
        property Height default 20;
        { CD Max Size }
        property MaxCDSize : Integer
             read GetMaxCDSize write SetMaxCDSize
             default 650;
        property MaxMemory : Integer
             read GetMaxMemory write SetMaxMemory
             default 750;
        { Colour After Size }
        property OverBurnColour : TColor
             read GetOverBurnColour write SetOverBurnColour
             default clRed;
        { Percentage of the progress bar shaded }
        property MemShaded : Integer
             read FMEMShaded write SetPercentShaded
             default 0;
        property TickColour : TColor
             read GetTickColour write SetTickColour
             default clBlack;
        property Width default 90;

  end;

procedure Register;

implementation

procedure Register;
begin
     RegisterComponents('Additional', [TCDSize]);
end;

{ Method to set variable and property values and create objects }
procedure TCDSize.AutoInitialize;
begin
     TickCount := 5.0;
     FBarColour := clSilver;
     Height := 20;
     FMaxCDSize := 650;
     FMaxMemory := 750;
     FOverBurnColour := clRed;
     FMEMShaded := 0;
     FTickColour := clBlack;
     Width := 90;
end; { of AutoInitialize }

{ Method to free any objects created by AutoInitialize }
procedure TCDSize.AutoDestroy;
begin
     { No objects from AutoInitialize to free }
end; { of AutoDestroy }

{ Read method for property BarColour }
function TCDSize.GetBarColour : TColor;
begin
     Result := FBarColour;
end;

{ Write method for property BarColour }
procedure TCDSize.SetBarColour(Value : TColor);
begin
     FBarColour := Value;

     { If changing this property affects the appearance of
       the component, call Invalidate here so the image will be
       updated. }
      Invalidate;
end;


function TCDSize.GetMemBarColour : TColor;
begin
     Result := FMEMBarColour;
end;

{ Write method for property BarColour }
procedure TCDSize.SetMemBarColour(Value : TColor);
begin
     FMEMBarColour := Value;

     { If changing this property affects the appearance of
       the component, call Invalidate here so the image will be
       updated. }
      Invalidate;
end;



{ Read method for property MaxCDSize }
function TCDSize.GetMaxCDSize : Integer;
begin
     Result := FMaxCDSize;
end;

{ Write method for property MaxCDSize }
procedure TCDSize.SetMaxCDSize(Value : Integer);
begin
     FMaxCDSize := Value;

     { If changing this property affects the appearance of
       the component, call Invalidate here so the image will be
       updated. }
     { Invalidate; }
end;

{ Read method for property MaxMemory }
function TCDSize.GetMaxMemory : Integer;
begin
     Result := FMaxMemory;
end;

{ Write method for property MaxMemory }
procedure TCDSize.SetMaxMemory(Value : Integer);
begin
     FMaxMemory := Value;

     { If changing this property affects the appearance of
       the component, call Invalidate here so the image will be
       updated. }
     { Invalidate; }
end;

{ Read method for property OverBurnColour }
function TCDSize.GetOverBurnColour : TColor;
begin
     Result := FOverBurnColour;
end;

{ Write method for property OverBurnColour }
procedure TCDSize.SetOverBurnColour(Value : TColor);
begin
     FOverBurnColour := Value;

     { If changing this property affects the appearance of
       the component, call Invalidate here so the image will be
       updated. }
     { Invalidate; }
end;

{ Write method for property PercentShaded }
procedure TCDSize.SetPercentShaded(Value : Integer);
begin
     FMEMShaded := Value;
     if FMEMShaded < 0 then
          FMEMShaded := 0
     else
          if FMEMShaded > FMaxMemory then
               FMEMShaded := FMaxMemory;
     { Update the display of the component }
     Invalidate
end;

{ Read method for property TickColour }
function TCDSize.GetTickColour : TColor;
begin
     Result := FTickColour;
end;

{ Write method for property TickColour }
procedure TCDSize.SetTickColour(Value : TColor);
begin
     FTickColour := Value;

     { If changing this property affects the appearance of
       the component, call Invalidate here so the image will be
       updated. }
     { Invalidate; }
end;

{ Method to generate OnOverBurn event }
procedure TCDSize.OverBurn(Sender : TObject);
begin
     { Has the application assigned a method to the event, whether
       via the Object Inspector or a run-time assignment?  If so,
       execute that method }
     if Assigned(FOnOverBurn) then
        FOnOverBurn(Sender);
end;

constructor TCDSize.Create(AOwner: TComponent);
begin
     { Call the Create method of the parent class }
     inherited Create(AOwner);

     { Set the initial values of variables and properties using }
     { AutoInitialize procedure, generated by Component Create  }
     AutoInitialize;

     { Code to perform other tasks when the component is created }

end;

destructor TCDSize.Destroy;
begin
     { AutoDestroy, which is generated by Component Create, frees any   }
     { objects created by AutoInitialize.                               }
     AutoDestroy;

     { Here, free any other dynamic objects that the component methods  }
     { created but have not yet freed.  Also perform any other clean-up }
     { operations needed before the component is destroyed.             }

     { Last, free the component by calling the Destroy method of the    }
     { parent class.                                                    }
     inherited Destroy;
end;


procedure TCDSize.Paint;
var
   TickNumber :integer;
   TickIndex :Integer;
   Divisor :Integer;

begin
     { Determine orientation; store it so it will
       be available in the IsHorizontal property }
     FIsHorizontal := (Width >= Height);
     Divisor := 10;
     if FMaxMemory > 1000 then Divisor := 100;

     TickNumber := round(FMaxMemory / Divisor);

     TickCount := (width / (FMaxMemory / Divisor));

     { Draw the framing rectangle }
     Canvas.Brush.Color := clWhite;
     Canvas.Pen.Width := 0;
     Canvas.Rectangle(0, 0, Width, Height);

    { Draw the Main cd mem bar within }
    Canvas.Brush.Color := FBarColour;
    Canvas.Rectangle(0, 0, Round(Width * (FMaxCDSize/FMaxMemory))+1,(Height div 2));


     { Draw the progress bar within }
     if (FMEMShaded > FMaxCDSize) then
     Canvas.Brush.Color := FOverBurnColour
     else
      Canvas.Brush.Color := FMEMBarColour;

     Canvas.Pen.Width := 0;
     if FIsHorizontal then
          Canvas.Rectangle(2, FGap, Round(Width * (FMEMShaded/FMaxMemory))+1, (Height div 2)- FGap)
     else
          Canvas.Rectangle(FGap, FGap, Width, Round(Height * (FMEMShaded/FMaxMemory))-FGap);




    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := TickColour;
    Canvas.Font.Color := TickColour;
    Canvas.Brush.Style := bsClear;
    for TickIndex := 1 to TickNumber do
    begin
    Canvas.MoveTo(round(TickIndex * TickCount),0);
    If (TickIndex mod 5) = 0 then   // every 5
    begin
    If (TickIndex mod 10) = 0 then
    begin
    Canvas.LineTo(round(TickIndex * TickCount),Height);  //every 10
    canvas.TextOut(round(TickIndex * TickCount)-20,(Height div 2)+2,inttostr(TickIndex*Divisor)+' mb');
    end
    else
    Canvas.LineTo(round(TickIndex * TickCount),(Height div 2)+3);

    end
    else
    Canvas.LineTo(round(TickIndex * TickCount),(Height div 2));
    end;
     if (FMEMShaded > FMaxCDSize) then
        if assigned(FOnOverBurn) then FOnOverBurn(nil);

end;


end.
