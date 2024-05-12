unit ucharacterinfo;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;
type

{ TGlyphData }

 { TCharacterInfo }

 TCharacterInfo = class(TObject)
  public
  name: string;
  code: string;
  width: integer;
  height: integer;
  position: string;
  constructor create;
  end;

implementation

{ TCharacterInfo }

constructor TCharacterInfo.create;
begin
name:='blank';
code:='';
width:=1;
height:=38;
position:='regular';
end;

end.

