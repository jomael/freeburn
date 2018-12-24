{-----------------------------------------------------------------------------
 Unit Name: CDDAText
 Author:    Paul Fisher
 Purpose:   Class to store CDDA Text information
 History:
-----------------------------------------------------------------------------}

unit CDDAText;

interface

uses SysUtils, Classes, Resources;

type
  TCDDAText = class
  private
    { Storage for property Album }
    FAlbum: string;
    { Storage for property Artist }
    FArtist: string;
    { Storage for property Genre }
    FGenre: string;
    { Storage for property MusicTracks }
    FTracks: TStringList;
    { Method to set variable and property values and create objects }
    procedure AutoInitialize;
    { Method to free any objects created by AutoInitialize }
    procedure AutoDestroy;
    { Read method for property Album }
    function GetAlbum: string;
    { Write method for property Album }
    procedure SetAlbum(Value: string);
    { Read method for property Artist }
    function GetArtist: string;
    { Write method for property Artist }
    procedure SetArtist(Value: string);
    { Read method for property Genre }
    function GetGenre: string;
    { Write method for property Genre }
    procedure SetGenre(Value: string);
    { Read method for property MusicTrack }
    function GetMusicTrack: TStringList;
  public
    constructor Create;
    destructor Destroy; override;
    function Execute: Boolean;
  published
    { Published properties of TCDDAText }
    property Album: string read GetAlbum write SetAlbum;
    property Artist: string read GetArtist write SetArtist;
    property Genre: string read GetGenre write SetGenre;
    property MusicTracks: TStringList read GetMusicTrack;
  end;

implementation

{ Method to set variable and property values and create objects }

procedure TCDDAText.AutoInitialize;
begin
  FTracks := TStringList.Create;
  FArtist := resUnknownArtist;
  FAlbum := resUnknownAlbum;
end; { of AutoInitialize }

{ Method to free any objects created by AutoInitialize }

procedure TCDDAText.AutoDestroy;
begin
  FTracks.Free;
end; { of AutoDestroy }

{ Read method for property Album }

function TCDDAText.GetAlbum: string;
begin
  Result := FAlbum;
end;

{ Write method for property Album }

procedure TCDDAText.SetAlbum(Value: string);
begin
  FAlbum := Value;
end;

{ Read method for property Artist }

function TCDDAText.GetArtist: string;
begin
  Result := FArtist;
end;

{ Write method for property Artist }

procedure TCDDAText.SetArtist(Value: string);
begin
  FArtist := Value;
end;

{ Read method for property Genre }

function TCDDAText.GetGenre: string;
begin
  Result := FGenre;
end;

{ Write method for property Genre }

procedure TCDDAText.SetGenre(Value: string);
begin
  FGenre := Value;
end;

{ Read method for property MusicTrack }

function TCDDAText.GetMusicTrack: TStringList;
begin
  Result := FTracks;
end;

constructor TCDDAText.Create;
begin
  AutoInitialize;
end;

destructor TCDDAText.Destroy;
begin
  AutoDestroy;
end;

function TCDDAText.Execute: Boolean;
begin
  Result := True
end;

end.
