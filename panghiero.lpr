program panghiero;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}
  cthreads,
  {$ENDIF}
  {$IFDEF HASAMIGA}
  athreads,
  {$ENDIF}
  Interfaces, // this includes the LCL widgetset
  { you can add units after this }
  Classes,
  uglyphdata, utools, ucharacterinfo;

{$R *.res}


var
  files:TStringList;
  i,f:integer;
  glyphs:TList;
  glyph:TGlyphData;


begin
initdata;
files:=listfiles;
for f:=0 to files.count-1 do begin
  processhierofile(files[f]);
  end;
//RequireDerivedFormResource:=True;
//  Application.Scaled:=True;
//  Application.Initialize;
//  Application.CreateForm(TForm1, Form1);
//  Application.Run;
end.

