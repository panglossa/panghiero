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
    GroupBox11: TGroupBox;
    Label1: TLabel;
    lblGardinerCode: TLabel;
    lstPhono: TListBox;
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
   Label1.caption:=lstPhono.items[lstMain.itemindex];
   if (trim(Label1.caption)='') then begin
      GroupBox11.Visible:=false;
      end else begin
      GroupBox11.Visible:=true;
      end;
   f:=IncludeTrailingBackslash('./img') + 'hiero_' + lstCodes.Items[lstMain.itemindex] + '.png';

   if (fileexists(f)) then begin
      GroupBox3.caption:='Image';
      imgGlyphImage.Picture.LoadFromFile(f);
      end else begin
      GroupBox3.caption:='Image not available';
      end;
   imgGlyphImage.Width:=lblGlyphUnicode.width;
   end;
end;

procedure TfrmGlyphs.loaddata;
var
  parts, readings:TStringArray;
  i, p:integer;
  ok:boolean;
  specialsigns:string;

begin
Panel1.Align:=alClient;
s:=TStringList.create;
s.LoadFromFile('fullhieroglyphs.dat');
lstMain.Clear;
lstCodes.Clear;
lstGlyphs.Clear;
lstDesc.Clear;
lstDetails.Clear;
lstPhono.Clear;
groupbox11.Visible:=false;
label1.caption:='-';

{ code|glyph|description|detail }
for i:=0 to s.Count-1 do begin
  parts:=s[i].Split('|');
  if (Length(parts)>1) then begin
     //we have at least a code and a glyph
     ok:=true;
     if (cboFilterCode.itemindex>0) then begin
        //something was selected, let's filter
        ok:=false;
        if (cboFilterCode.itemindex>=cboFilterCode.items.Count-4) then begin
           //phonetic groups
           //continue only if the entry has at least one phonetic value
           if (length(parts)>4) then begin
              if (trim(parts[4])<>'') then begin
              readings:=parts[4].Split(',');
              if (cboFilterCode.itemindex=cboFilterCode.items.Count-4) then begin
                 //any type of phonetic value
                 //if we got to this point...
                 if (length(readings)>0) then begin
                    //ShowMessage(inttostr(length(readings)));
                    ok:=true;
                    end;
                 end else if (cboFilterCode.itemindex=cboFilterCode.items.Count-3) then begin
                 //phonetic values with length 1
                 for p:=0 to length(readings)-1 do begin
                   if (length(readings[p])=1) then begin
                      ok:=true;
                      end;
                   end;
                 end else if (cboFilterCode.itemindex=cboFilterCode.items.Count-2) then begin
                 //phonetic values with length 2
                 for p:=0 to length(readings)-1 do begin
                   if (length(readings[p])=2) then begin
                      ok:=true;
                      end;
                   end;
                 end else if (cboFilterCode.itemindex=cboFilterCode.items.Count-1) then begin
                 //phonetic values with length 3
                 for p:=0 to length(readings)-1 do begin
                   if (length(readings[p])=3) then begin
                      ok:=true;
                      end;
                   end;
                 end;
                 end;
              end;
          {if (cboFilterCode.itemindex=cboFilterCode.items.Count-3) then begin
            specialsigns:=',G1,M17,M17A,Z4,D36,G43,Z7,D58,Q3,I9,G17,N35,D21,O4,V28,Aa1,F32,O34,S29,N37,N29,V31,W11,X1,V13,D46,I10,';
            end else if (cboFilterCode.itemindex=cboFilterCode.items.Count-2) then begin
            specialsigns:=',F40,U23,G25,M15,Q1,F51C,D54,E9,E8,F34,Aa13,Z11,A27,K1,W24,W25,A48,D4,T24,M40,A19,I3,V15,O29,F16,T24,G35,'
         + 'K3,V26,V27,V4,T21,F13,E34,M42,G36,F51C,Q1,Q2,M13,V24,V25,G29,W10,W10A,F18,G40,G41,O1,F22,D56,T9,U1,D36,D38,N36,W19,N35A,'
         + 'G18,T1,Y5,N36,O5,U6,U23,V22,D35,D41,U19,W24,V30,O5,T34,T35,M22A,H4,G21,F20,Aa27,E23,T13,U13,M16,F18,Aa5,N42,U36,M2,U8,V36'
         + ',D2,N31,W14,T3,T4,L6,M12,N28,D43,R22,M3,K4,D33,F26,T28,G39,V16,V17,O50,Aa17,Aa18,M23,T22,V29,F29,Q1,S22,Z9,H7,M8,H6,N40'
         + ',V1,V7,V6,F30,Aa8,T19,Aa28,D28,R5,I6,G38,G28,Aa13,Aa16,N16,N17,U30,U33,D1,T8,U15,M6,G47,S24,D37,X8,U28,U29,X8,N26,G22,M36,R11,I11,';
            end else if (cboFilterCode.itemindex=cboFilterCode.items.Count-1) then begin
            specialsigns:=',E26,O28,F44,S39,Aa20,S34,P6,I1,V29,S40,M13,D60,F25,F12,Aa11,S12,F35,R8,T12,S38,R4,L1,W17,S42,P8,U34,W9,N14,F42,F36,S29,G54,T31,U21,F21,A50,M26,T18,U17,G4,T25,';
            end;
          if (pos(',' + parts[0] + ',', specialsigns)<>0) then begin
            ok:=true;
            end;
          }
          end else begin
          //gardiner groups
          if (Pos(cboFilterCode.items[cboFilterCode.itemindex], parts[0])<>0) then begin
           ok:=true;
           end;
          {
            if (Pos(cboFilterCode.items[cboFilterCode.itemindex], parts[0])<>0) then begin
             ok:=true;
             end;
            }
           end;
        end;
     if (trim(txtFilterDescription.text)<>'') then begin
        //something was requested, let's filter
        ok:=false;
        if (length(parts)>2) then begin
          if (Pos(LowerCase(txtFilterDescription.Text), lowercase(parts[2]))<>0) then begin
             ok:=true;
             end;
           end;
        end;
     if (trim(txtFilterDetails.text)<>'') then begin
        //something was requested, let's filter
        ok:=false;
        if (length(parts)>3) then begin
          if (Pos(LowerCase(txtFilterDetails.Text), lowercase(parts[3]))<>0) then begin
             ok:=true;
             end;
           end;
        end;
     if ok then begin
       //either no parameters were specified, or the current entry satisfies the
       //given parameters
       lstMain.items.add(parts[1] + ' ' + parts[0]);
       lstCodes.items.add(parts[0]);
       lstGlyphs.items.add(parts[1]);
       if (length(parts)>2) then begin
          lstDesc.items.add(parts[2]);
          if (length(parts)>3) then begin
             lstDetails.items.add(parts[3]);
             if (length(parts)>4) then begin
                lstphono.items.add(parts[4]);
                end else begin
                lstphono.items.add('');
                end;
             end else begin
             lstDetails.items.add('');
             lstphono.items.add('');
             end;
          end else begin
          lstDesc.items.add('');
          lstDetails.items.add('');
          lstphono.items.add('');
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

