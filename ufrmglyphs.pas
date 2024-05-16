unit ufrmglyphs;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls;

type

  { TfrmGlyphs }

  TfrmGlyphs = class(TForm)
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    GroupBox3: TGroupBox;
    GroupBox4: TGroupBox;
    GroupBox5: TGroupBox;
    Image1: TImage;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    ListBox1: TListBox;
    ListBox2: TListBox;
    ListBox3: TListBox;
    ListBox4: TListBox;
    ListBox5: TListBox;
    Panel1: TPanel;
    Panel2: TPanel;
    Splitter1: TSplitter;
    procedure FormCreate(Sender: TObject);
    procedure ListBox1Click(Sender: TObject);
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
var
  parts:TStringArray;
  i:integer;

begin
Panel1.Align:=alClient;
s:=TStringList.create;
s.LoadFromFile('fullhieroglyphs.csv');
ListBox1.Clear;
ListBox2.Clear;
ListBox3.Clear;
ListBox4.Clear;
ListBox5.Clear;
for i:=0 to s.Count-1 do begin
  parts:=s[i].Split('|');
  if (Length(parts)>1) then begin
     ListBox1.items.add(parts[1] + ' ' + parts[0]);
     listbox2.items.add(parts[1]);
     listbox5.items.add(parts[0]);
     if (length(parts)>2) then begin
        listbox3.items.add(parts[2]);
        if (length(parts)>3) then begin
           listbox4.items.add(parts[3]);
           end else begin
           listbox4.items.add('');
           end;
        end else begin
        listbox3.items.add('');
        listbox4.items.add('');
        end;
     end;
  end;
end;

procedure TfrmGlyphs.ListBox1Click(Sender: TObject);
var
  parts:TStringArray;
  i:integer;
  f:string;

begin
if ((listbox1.items.count>0)and(listbox1.ItemIndex>-1)) then begin
   Image1.Picture.Clear;
   label1.Caption:=listbox2.items[listbox1.itemindex];
   label2.Caption:=listbox3.items[listbox1.itemindex];
   label3.Caption:=listbox4.items[listbox1.itemindex];
   f:=IncludeTrailingBackslash('./img') + 'hiero_' + listbox5.Items[listbox1.itemindex] + '.png';

   if (fileexists(f)) then begin
      Image1.Picture.LoadFromFile(f);
      end;
   Image1.Width:=label1.width;
   end;
end;

end.

