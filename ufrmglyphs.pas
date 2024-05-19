unit ufrmglyphs;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Buttons, lcltype, Clipbrd;

type

  { TfrmGlyphs }

  TfrmGlyphs = class(TForm)
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
    BitBtn3: TBitBtn;
    BitBtn4: TBitBtn;
    btnSearch: TButton;
    Button2: TButton;
    cboFilterCode: TComboBox;
    GroupBox10: TGroupBox;
    lblGardinerCode: TLabel;
    lstDetails: TListBox;
    SpeedButton1: TSpeedButton;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    SpeedButton6: TSpeedButton;
    txtFilterDetails: TEdit;
    txtFilterDescription: TEdit;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    GroupBox6: TGroupBox;
    GroupBox7: TGroupBox;
    GroupBox8: TGroupBox;
    GroupBox9: TGroupBox;
    imgGlyphImage: TImage;
    lblGlyphUnicode: TLabel;
    lblDesc: TLabel;
    lblDetails: TLabel;
    lstMain: TListBox;
    lstDesc: TListBox;
    lstGlyphs: TListBox;
    lstCodes: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Panel3: TPanel;
    Splitter1: TSplitter;
    procedure BitBtn1Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure btnSearchClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure lstMainClick(Sender: TObject);
    procedure loaddata;
    procedure SpeedButton1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton6Click(Sender: TObject);
    procedure txtFilterDescriptionKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure txtFilterDescriptionKeyPress(Sender: TObject; var Key: char);
    procedure txtFilterDetailsKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  private

  public

  end;

var
  frmGlyphs: TfrmGlyphs;
  s:Tstringlist;

implementation

{$R *.lfm}

{ TfrmGlyphs }

procedure TfrmGlyphs.FormCreate(Sender: TObject);
begin
loaddata;
end;

procedure TfrmGlyphs.btnSearchClick(Sender: TObject);
begin
txtFilterDescription.text:=trim(txtFilterDescription.text);
txtFilterDetails.text:=trim(txtFilterDetails.text);
loaddata;
end;

procedure TfrmGlyphs.BitBtn1Click(Sender: TObject);
begin
Clipboard.AsText:=lblGardinerCode.Caption;
end;

procedure TfrmGlyphs.BitBtn2Click(Sender: TObject);
begin
Clipboard.AsText:=lblDesc.Caption;
end;

procedure TfrmGlyphs.BitBtn3Click(Sender: TObject);
begin
Clipboard.AsText:=lblDetails.Caption;
end;

procedure TfrmGlyphs.BitBtn4Click(Sender: TObject);
begin
clipboard.AsText:=lblGlyphUnicode.caption;
end;

procedure TfrmGlyphs.Button2Click(Sender: TObject);
begin
btnSearch.Enabled:=false;
cboFilterCode.ItemIndex:=-1;
txtFilterDescription.text:='';
txtFilterDetails.text:='';
loaddata;
btnSearch.Enabled:=true;
end;

procedure TfrmGlyphs.lstMainClick(Sender: TObject);
var
  parts:TStringArray;
  i:integer;
  f:string;

begin
if ((lstMain.items.count>0)and(lstMain.ItemIndex>-1)) then begin
   imgGlyphImage.Picture.Clear;
   lblGlyphUnicode.Caption:=lstGlyphs.items[lstMain.itemindex];
   lblDesc.Caption:=lstDesc.items[lstMain.itemindex];
   lblDetails.Caption:=lstDetails.items[lstMain.itemindex];
   lblGardinerCode.caption:=lstCodes.items[lstMain.itemindex];
   f:=IncludeTrailingBackslash('./img') + 'hiero_' + lstCodes.Items[lstMain.itemindex] + '.png';

   if (fileexists(f)) then begin
      imgGlyphImage.Picture.LoadFromFile(f);
      end;
   imgGlyphImage.Width:=lblGlyphUnicode.width;
   end;
end;

procedure TfrmGlyphs.loaddata;
var
  parts:TStringArray;
  i:integer;
  ok:boolean;

begin
Panel1.Align:=alClient;
s:=TStringList.create;
s.LoadFromFile('fullhieroglyphs.csv');
lstMain.Clear;
lstCodes.Clear;
lstGlyphs.Clear;
lstDesc.Clear;
lstDetails.Clear;
{ code|glyph|description|detail }
for i:=0 to s.Count-1 do begin
  parts:=s[i].Split('|');
  if (Length(parts)>1) then begin
     ok:=true;
     if (cboFilterCode.itemindex>0) then begin
        ok:=false;
        if (Pos(cboFilterCode.items[cboFilterCode.itemindex], parts[0])<>0) then begin
           ok:=true;
           end;
        end;
     if (trim(txtFilterDescription.text)<>'') then begin
        ok:=false;
        if (length(parts)>2) then begin
          if (Pos(LowerCase(txtFilterDescription.Text), lowercase(parts[2]))<>0) then begin
             ok:=true;
             end;
           end;
        end;
     if (trim(txtFilterDetails.text)<>'') then begin
        ok:=false;
        if (length(parts)>3) then begin
          if (Pos(LowerCase(txtFilterDetails.Text), lowercase(parts[3]))<>0) then begin
             ok:=true;
             end;
           end;
        end;
     if ok then begin
       lstMain.items.add(parts[1] + ' ' + parts[0]);
       lstCodes.items.add(parts[0]);
       lstGlyphs.items.add(parts[1]);
       if (length(parts)>2) then begin
          lstDesc.items.add(parts[2]);
          if (length(parts)>3) then begin
             lstDetails.items.add(parts[3]);
             end else begin
             lstDetails.items.add('');
             end;
          end else begin
          lstDesc.items.add('');
          lstDetails.items.add('');
          end;
        end;
     end;
  end;
end;

procedure TfrmGlyphs.SpeedButton1Click(Sender: TObject);
begin
cboFilterCode.ItemIndex:=0;
end;

procedure TfrmGlyphs.SpeedButton2Click(Sender: TObject);
begin
txtFilterDescription.text:='';
end;

procedure TfrmGlyphs.SpeedButton6Click(Sender: TObject);
begin
txtFilterDetails.text:='';
end;

procedure TfrmGlyphs.txtFilterDescriptionKeyDown(Sender: TObject;
  var Key: Word; Shift: TShiftState);
begin
if key=VK_RETURN  then begin
   btnSearch.Enabled:=false;
   loaddata;
   btnSearch.Enabled:=true;
   end;
end;

procedure TfrmGlyphs.txtFilterDescriptionKeyPress(Sender: TObject; var Key: char
  );
begin

end;

procedure TfrmGlyphs.txtFilterDetailsKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
if key=VK_RETURN  then begin
   btnSearch.Enabled:=false;
   loaddata;
   btnSearch.Enabled:=true;
   end;

end;

end.

