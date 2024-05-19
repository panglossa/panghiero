unit ufrmoptions;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Spin, IniFiles;

type

  { TfrmOptions }

  TfrmOptions = class(TForm)
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    FontDialog1: TFontDialog;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Panel4: TPanel;
    Panel5: TPanel;
    Panel6: TPanel;
    Panel7: TPanel;
    spnTextSpace: TSpinEdit;
    spnTextMaxHeight: TSpinEdit;
    spnTextMaxWidth: TSpinEdit;
    spnTextLineHeight: TSpinEdit;
    spnTextBorder: TSpinEdit;
    spnTextLineSpace: TSpinEdit;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  frmOptions: TfrmOptions;
  ini:TIniFile;

implementation

{$R *.lfm}

{ TfrmOptions }

procedure TfrmOptions.Button1Click(Sender: TObject);
begin
if FontDialog1.execute then begin
  Label1.Font:=FontDialog1.Font;
  Label1.caption:=FontDialog1.Font.Name + ' - ' + inttostr(FontDialog1.Font.Size) + 'pt';
  end;
end;

procedure TfrmOptions.Button2Click(Sender: TObject);
begin
close;
end;

procedure TfrmOptions.FormCreate(Sender: TObject);
begin
ini:=TIniFile.Create(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'panghiero.ini');
end;

procedure TfrmOptions.FormShow(Sender: TObject);
begin
FontDialog1.font.Name:=ini.ReadString('Editor Font', 'Name', 'Aegyptus');
FontDialog1.font.Size:=ini.ReadInteger('Editor Font', 'Size', 20);
Label1.Font:=FontDialog1.Font;
Label1.caption:=FontDialog1.Font.Name + ' - ' + inttostr(FontDialog1.Font.Size) + 'pt';
spnTextBorder.Value:=ini.ReadInteger('Graphic Options', 'Image Border', 0);
spnTextLineHeight.Value:=ini.ReadInteger('Graphic Options', 'Line Height', 0);
spnTextMaxWidth.Value:=ini.ReadInteger('Graphic Options', 'Maximum Text Width', 1000);
spnTextMaxHeight.Value:=ini.ReadInteger('Graphic Options', 'Maximum Text Height', 5000);
spnTextSpace.Value:=ini.ReadInteger('Graphic Options', 'Character Spacing', 0);
spnTextLineSpace.Value:=ini.ReadInteger('Graphic Options', 'Interlinear Space', 0);

end;

end.

