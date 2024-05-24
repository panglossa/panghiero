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
  Forms, ufrmmain, ufrmabout, ufrmglyphs, ufrmoptions, ufrmalias
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Scaled:=True;
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.CreateForm(TfrmAbout, frmAbout);
  Application.CreateForm(TfrmGlyphs, frmGlyphs);
  Application.CreateForm(TfrmOptions, frmOptions);
  Application.CreateForm(TfrmAliases, frmAliases);
  Application.Run;
end.

