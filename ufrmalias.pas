unit ufrmalias;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics,
  Dialogs, Grids, ExtCtrls, LCLType,
  StdCtrls, Buttons;

type

  { TfrmAliases }

  TfrmAliases = class(TForm)
    Button1: TButton;
    btnCancel: TButton;
    btnSaveNew: TButton;
    btnSaveEdit: TButton;
    Label1: TLabel;
    txtIdentifier: TEdit;
    txtSubst: TEdit;
    gbAliasEditor: TGroupBox;
    GroupBox1: TGroupBox;
    GroupBox2: TGroupBox;
    Panel1: TPanel;
    Panel2: TPanel;
    sgAliases: TStringGrid;
    btnNewAlias: TSpeedButton;
    btnEditAlias: TSpeedButton;
    btnRemoveAlias: TSpeedButton;
    Splitter1: TSplitter;
    procedure btnCancelClick(Sender: TObject);
    procedure btnEditAliasClick(Sender: TObject);
    procedure btnRemoveAliasClick(Sender: TObject);
    procedure btnSaveEditClick(Sender: TObject);
    procedure btnSaveNewClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure btnNewAliasClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure loadaliases;
    procedure savealiases;
    procedure sgAliasesDblClick(Sender: TObject);
  private

  public

  end;

var
  frmAliases: TfrmAliases;
  selectedrow:integer;

implementation

{$R *.lfm}

{ TfrmAliases }

procedure TfrmAliases.Button1Click(Sender: TObject);
begin
close;
end;

procedure TfrmAliases.btnCancelClick(Sender: TObject);
begin
selectedrow:=-1;
btnNewAlias.enabled:=true;
btneditAlias.enabled:=true;
btnRemoveAlias.enabled:=true;

gbAliasEditor.Visible:=false;

end;

procedure TfrmAliases.btnEditAliasClick(Sender: TObject);
begin
if (sgAliases.Row>-1) then begin
   selectedrow:=sgAliases.Row;
   btnNewAlias.enabled:=false;
   btneditAlias.enabled:=false;
   btnRemoveAlias.enabled:=false;
   btnSaveEdit.Visible:=true;
   btnSaveNew.Visible:=false;
   txtIdentifier.text:=sgAliases.Cells[0, sgAliases.row];
   txtSubst.text:=sgAliases.Cells[1, sgAliases.row];


   gbAliasEditor.caption:='Edit Existing Alias';
   gbAliasEditor.Visible:=true;
   end;

end;

procedure TfrmAliases.btnRemoveAliasClick(Sender: TObject);
begin
if (sgAliases.Row>-1) then begin
   selectedrow:=sgAliases.Row;
   if (application.MessageBox(PChar('Are you sure you want to remove the following alias?'#13#10 + sgAliases.Cells[0, selectedrow] + '->' + txtIdentifier.Text), 'Remove Alias', MB_YESNOCANCEL)=IDYES) then begin
      sgAliases.DeleteRow(selectedrow);
      savealiases;
      end;
   end;
selectedrow:=-1;
end;

procedure TfrmAliases.btnSaveEditClick(Sender: TObject);
begin
//showmessage(inttostr(selectedrow));
if (selectedrow>-1) then begin
   if (trim(txtIdentifier.Text)<>'') then begin
    sgAliases.Cells[0, selectedrow]:=trim(txtIdentifier.Text);
    sgAliases.Cells[1, selectedrow]:=trim(txtSubst.text);
    savealiases;
   end;
  end;
btnNewAlias.enabled:=true;
btneditAlias.enabled:=true;
btnRemoveAlias.enabled:=true;
txtIdentifier.Clear;
txtSubst.Clear;
gbAliasEditor.Visible:=false;
selectedrow:=-1;
end;

procedure TfrmAliases.btnSaveNewClick(Sender: TObject);
begin
if (trim(txtIdentifier.Text)<>'') then begin
  sgAliases.RowCount:=sgAliases.RowCount + 1;
  sgAliases.Cells[0, sgAliases.RowCount-1]:=trim(txtIdentifier.Text);
  sgAliases.Cells[1, sgAliases.RowCount-1]:=trim(txtSubst.text);
  savealiases;
  end;

btnNewAlias.enabled:=true;
btneditAlias.enabled:=true;
btnRemoveAlias.enabled:=true;
txtIdentifier.Clear;
txtSubst.Clear;
gbAliasEditor.Visible:=false;
selectedrow:=-1;
end;

procedure TfrmAliases.btnNewAliasClick(Sender: TObject);
begin
selectedrow:=-1;
btnNewAlias.enabled:=false;
btneditAlias.enabled:=false;
btnRemoveAlias.enabled:=false;
btnSaveEdit.Visible:=false;
btnSaveNew.Visible:=true;
txtIdentifier.Clear;
txtSubst.Clear;

gbAliasEditor.caption:='Create New Alias';
gbAliasEditor.Visible:=true;
end;

procedure TfrmAliases.FormCreate(Sender: TObject);
begin
selectedrow:=-1;
sgAliases.SaveOptions:=soAll;
sgAliases.RowCount:=0;
gbAliasEditor.Visible:=false;
btnSaveNew.Left:=btnSaveEdit.left;
if (fileexists('aliases.dat')) then begin
   loadaliases;
   end;
end;

procedure TfrmAliases.loadaliases;
var
  s:TStringList;
  i:integer;
  parts:TStringArray;

begin
s:=TStringList.create;
sgAliases.RowCount:=0;
if (fileexists('aliases.dat')) then begin
   s.LoadFromFile('aliases.dat');
   for i:=0 to s.Count-1 do begin
     sgAliases.RowCount := sgAliases.RowCount + 1;
     parts:=s[i].Split('|');
     sgAliases.Cells[0, sgAliases.RowCount-1]:=parts[0];
     sgAliases.Cells[1, sgAliases.RowCount-1]:=parts[1];
     end;
   end;
sgAliases.Refresh;
end;

procedure TfrmAliases.savealiases;
var
  s:TStringList;
  i:integer;

begin
s:=TStringList.create;
for i:=0 to sgAliases.RowCount-1 do begin
   s.add(sgAliases.Cells[0, i] + '|' + sgAliases.Cells[1, i]);
   end;
s.savetofile('aliases.dat');
end;

procedure TfrmAliases.sgAliasesDblClick(Sender: TObject);
begin
btnEditAliasClick(self);
end;


end.

