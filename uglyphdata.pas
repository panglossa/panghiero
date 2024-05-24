unit uglyphdata;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils;

type

{ TGlyphData }
//represents data from the database relating to glyphs in general
 TGlyphData = class(TObject)
  public
  name: string;
  code: TStringList;
  width: integer;
  height: integer;
  procedure parse(src:string);
  constructor create(src:string);
  function matchcode(candidate:string):boolean;
  end;

implementation
{ TGlyphData }

procedure TGlyphData.parse(src: string);
var
  tmp:TStringArray;
  tmpcode:string;
  i:integer;

begin
tmp:= src.Split('|');
name:=tmp[0];
tmpcode:=tmp[1];
width:=StrToInt(tmp[2]);
height:=StrToInt(tmp[3]);
tmp:= tmpcode.Split(',');
code:=TStringList.create;
for i:=0 to length(tmp)-1 do begin
  code.add(trim(tmp[i]));
  end;
end;

constructor TGlyphData.create(src: string);
begin
parse(src);
end;

function TGlyphData.matchcode(candidate: string): boolean;
var
  x:integer;

begin
result:=false;
//candidate:=trim(candidate);
for x:=0 to code.Count-1 do begin
  if ((code[x]<>'')and(candidate<>'')and(code[x]=candidate)) then begin
    //writeln('***CODE: ' + code[x] + '*** --- CANDIDATE: ' + candidate + '***');
    result:=true;
    //Break;
    end;
  end;
end;

end.

