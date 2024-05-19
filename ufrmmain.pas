unit ufrmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls, lcltype, Clipbrd,
  ExtCtrls, Buttons, FileCtrl, ExtDlgs, IniFiles,
  ActnList,
  uglyphdata, ucharacterinfo,
  utools;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    actCopy: TAction;
    actCut: TAction;
    actPaste: TAction;
    ActionList1: TActionList;
    cboGardiner: TComboBox;
    FileListBox1: TFileListBox;
    pnlGlyphs: TFlowPanel;
    GroupBox1: TGroupBox;
    imgMainDisplay: TImage;
    Image2: TImage;
    mnuMain: TMainMenu;
    txtMainEditor: TMemo;
    mnuFile: TMenuItem;
    mnuTools: TMenuItem;
    mnuToolsOptions: TMenuItem;
    mnuEdit: TMenuItem;
    mnuEditCopy: TMenuItem;
    mnuEditCut: TMenuItem;
    mnuEditPaste: TMenuItem;
    mnuHelp: TMenuItem;
    mnuHelpTopics: TMenuItem;
    mnuHelpAbout: TMenuItem;
    mnuFileNew: TMenuItem;
    mnuViewUpdate: TMenuItem;
    mnuFileSaveImageAs: TMenuItem;
    mnuViewGlyphs: TMenuItem;
    OpenDialog1: TOpenDialog;
    SaveDialog1: TSaveDialog;
    SavePictureDialog1: TSavePictureDialog;
    Separator4: TMenuItem;
    ScrollBox1: TScrollBox;
    Separator3: TMenuItem;
    mnuViewVertical: TMenuItem;
    mnuViewHorizontal: TMenuItem;
    Separator2: TMenuItem;
    mnuFileOpen: TMenuItem;
    mnuFileSaveText: TMenuItem;
    mnuFileSaveTextAs: TMenuItem;
    mnuFileExit: TMenuItem;
    mnuView: TMenuItem;
    mnuToolsGlyphs: TMenuItem;
    Panel1: TPanel;
    Separator1: TMenuItem;
    Splitter1: TSplitter;
    procedure actCopyExecute(Sender: TObject);
    procedure actCutExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actPasteExecute(Sender: TObject);
    procedure cboGardinerChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure mnuFileSaveImageAsClick(Sender: TObject);
    procedure mnuFileSaveTextAsClick(Sender: TObject);
    procedure mnuFileSaveTextClick(Sender: TObject);
    procedure mnuToolsGlyphsClick(Sender: TObject);
    procedure mnuToolsOptionsClick(Sender: TObject);
    procedure txtMainEditorChange(Sender: TObject);
    procedure txtMainEditorExit(Sender: TObject);
    procedure mnuHelpAboutClick(Sender: TObject);
    procedure mnuViewUpdateClick(Sender: TObject);
    procedure mnuFileNewClick(Sender: TObject);
    procedure mnuFileOpenClick(Sender: TObject);
    procedure mnuFileExitClick(Sender: TObject);
    procedure updateview;
    procedure glyphbuttonClick(Sender: TObject);
    procedure processhierofile(afilename:string);
    procedure initdata;
    procedure generate_image(characters: TList; afilename:string);
    function builddatafile: integer;
  private

  public

  end;

var
  frmMain: TfrmMain;
  rawdata, combinations:TStringList;
  glyphs:TList;
  glyph:TGlyphData;
  config:TStringList;
  unsaved:boolean;
  currentfilename:string;

implementation
uses
  ufrmabout, ufrmglyphs, ufrmoptions;
{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.mnuFileExitClick(Sender: TObject);
begin
close;
end;

procedure TfrmMain.updateview;
var
  bmp:TBitMap;
begin
screen.Cursor:=crHourGlass;
txtMainEditor.lines.SaveToFile('default.txt');
//processhierofile('');
bmp:=texttoimage(txtMainEditor.Text);
//imgMainDisplay.Canvas.CopyRect(bmp.canvas.ClipRect, bmp.canvas, bmp.canvas.ClipRect);
//imgMainDisplay.Picture.assign(bmp);// loadfromfile('tmp.bmp');
imgMainDisplay.Picture.loadfromfile('tmp.bmp');
imgMainDisplay.Picture.SaveToFile('default.png');
screen.Cursor:=crDefault;
txtMainEditor.SetFocus;
end;

procedure TfrmMain.glyphbuttonClick(Sender: TObject);
begin
txtMainEditor.SelText:=' ' + (Sender as TImage).Hint + ' ';
txtMainEditor.SetFocus;
end;

procedure TfrmMain.GroupBox1Click(Sender: TObject);
begin

end;

procedure TfrmMain.Image2Click(Sender: TObject);
begin

end;

procedure TfrmMain.mnuFileSaveImageAsClick(Sender: TObject);
begin
SavePictureDialog1.FileName:=StringReplace(currentfilename, '.hiero', '.png', [rfReplaceAll]);
if SavePictureDialog1.execute then begin
   imgMainDisplay.Picture.SaveToFile(SavePictureDialog1.FileName);
   end;

end;

procedure TfrmMain.mnuFileSaveTextAsClick(Sender: TObject);
begin
SaveDialog1.FileName:=currentfilename;
if SaveDialog1.execute then begin
   currentfilename:=SaveDialog1.FileName;
   txtMainEditor.Lines.SaveToFile(SaveDialog1.FileName);
   unsaved:=false;
   end;
end;

procedure TfrmMain.mnuFileSaveTextClick(Sender: TObject);
begin
if currentfilename=''  then begin
   if SaveDialog1.execute then begin
     currentfilename:=SaveDialog1.FileName;
     txtMainEditor.Lines.SaveToFile(SaveDialog1.FileName);
     unsaved:=false;
     end;
   end else begin
   txtMainEditor.Lines.SaveToFile(currentfilename);
   unsaved:=false;
   end;
end;

procedure TfrmMain.mnuToolsGlyphsClick(Sender: TObject);
begin
frmGlyphs.show;
end;

procedure TfrmMain.mnuToolsOptionsClick(Sender: TObject);
begin
frmOptions.showmodal;
ini:=TIniFile.Create(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'panghiero.ini');
if frmOptions.ModalResult = mrOK then begin
   screen.cursor:=crHourGlass;
   ini.writeString('Editor Font', 'Name', frmOptions.FontDialog1.font.Name);
   ini.writeInteger('Editor Font', 'Size', frmOptions.FontDialog1.font.Size);
   ini.writeInteger('Graphic Options', 'Image Border', frmOptions.spnTextBorder.Value);
   ini.writeInteger('Graphic Options', 'Line Height', frmOptions.spnTextLineHeight.Value);
   ini.writeInteger('Graphic Options', 'Maximum Text Width', frmOptions.spnTextMaxWidth.Value);
   ini.writeInteger('Graphic Options', 'Maximum Text Height', frmOptions.spnTextMaxHeight.Value);
   ini.writeInteger('Graphic Options', 'Character Spacing', frmOptions.spnTextSpace.Value);
   ini.writeInteger('Graphic Options', 'Interlinear Space', frmOptions.spnTextLineSpace.Value);
   txtMainEditor.font.Name:=ini.ReadString('Editor Font', 'Name', 'Aegyptus');
   txtMainEditor.font.Size:=ini.ReadInteger('Editor Font', 'Size', 20);
   screen.cursor:=crDefault;
   end;
end;

procedure TfrmMain.txtMainEditorChange(Sender: TObject);
begin
unsaved:=true;
end;

procedure TfrmMain.txtMainEditorExit(Sender: TObject);
begin
updateview;
end;

procedure TfrmMain.mnuHelpAboutClick(Sender: TObject);
begin
frmAbout.showmodal;
end;

procedure TfrmMain.mnuViewUpdateClick(Sender: TObject);
begin
updateview;
end;

procedure TfrmMain.mnuFileNewClick(Sender: TObject);
var
  ok:boolean;
  answer:integer;

begin
ok:=true;

if unsaved then begin
  ok:=false;
  SaveDialog1.FileName:=currentfilename;
  case application.MessageBox('The current file has been modified. Do you want to save it before switching to a new file?', 'Unsaved file', MB_YESNOCANCEL + MB_ICONWARNING) of
       IDYES: begin
         if currentfilename=''  then begin
           if SaveDialog1.execute then begin
             currentfilename:=SaveDialog1.FileName;
             txtMainEditor.Lines.SaveToFile(SaveDialog1.FileName);
             ok:=true;
             end;
           end else begin
           txtMainEditor.Lines.SaveToFile(currentfilename);
           ok:=true;
           end;
         end;
       IDNO: begin
         ok:=true;
         end;
       IDCANCEL: begin
         end;
       end;
  end;

if ok then begin
  txtMainEditor.Lines.Clear;
  imgMainDisplay.Picture.Clear;
  unsaved:=false;
  end;
end;

procedure TfrmMain.mnuFileOpenClick(Sender: TObject);
var
  ok:boolean;
  answer:integer;

begin   
ok:=true;

if unsaved then begin
  ok:=false;
  SaveDialog1.FileName:=currentfilename;
  case application.MessageBox('The current file has been modified. Do you want to save it before opening another file?', 'Unsaved file', MB_YESNOCANCEL + MB_ICONWARNING) of
       IDYES: begin
         if currentfilename=''  then begin
           if SaveDialog1.execute then begin
             showmessage(SaveDialog1.FileName);
             currentfilename:=SaveDialog1.FileName;
             txtMainEditor.Lines.SaveToFile(SaveDialog1.FileName);
             ok:=true;
             end;
           end else begin
           txtMainEditor.Lines.SaveToFile(currentfilename);
           ok:=true;
           end;
         end;
       IDNO: begin
         ok:=true;
         end;
       IDCANCEL: begin
         end;
       end;
  end;

if ok then begin
  if OpenDialog1.Execute then begin
    txtMainEditor.Lines.LoadFromFile(OpenDialog1.FileName);
    //processhierofile(OpenDialog1.FileName);
    texttoimage(txtMainEditor.Text);
    imgMainDisplay.Picture.LoadFromFile('tmp.bmp');
    unsaved:=false;
    end;
  end;

end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i:integer;
  src:TStringList;

begin
initdata;
unsaved:=false;
ini:=TIniFile.Create(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'panghiero.ini');
if (paramcount()>0) then begin
  for i:=1 to paramcount() do begin
    src:=TStringList.create;
    src.LoadFromFile(paramstr(i));
    texttoimage(txtMainEditor.Text).SaveToFile(StringReplace(paramstr(i), '.hiero', '.png', [rfReplaceAll]));
    //processhierofile(ParamStr(i));
    end;
  Application.Terminate;
  end else begin
  currentfilename:='';
  panel1.align:=alClient;
  if (fileexists('default.txt')) then begin
    txtMainEditor.lines.loadfromfile('default.txt');
    end;
  if (fileexists('default.png')) then begin
    imgMainDisplay.picture.loadfromfile('default.png');
    end;
  end;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
txtMainEditor.Width:=panel1.Width div 2;

end;

procedure TfrmMain.FormShow(Sender: TObject);
begin
txtMainEditor.font.Name:=ini.ReadString('Editor Font', 'Name', 'Aegyptus');
txtMainEditor.font.Size:=ini.ReadInteger('Editor Font', 'Size', 20);

end;

procedure TfrmMain.cboGardinerChange(Sender: TObject);
var
  prefix:string;
  i:integer;
  btn:TImage;
  bl, test:string;
  ok:boolean;
  isnum, k:integer;

begin
prefix:='A';
case cboGardiner.ItemIndex of
     0: prefix := 'A'; //Man and his occupations
     1: prefix := 'B'; //Woman and her occupations
     2: prefix := 'C'; //Anthropomorphic deities
     3: prefix := 'D'; //Parts of the human body
     4: prefix := 'E'; //Mammals
     5: prefix := 'F'; //Parts of mammals
     6: prefix := 'G'; //Birds
     7: prefix := 'H'; //Parts of birds
     8: prefix := 'I'; //Amphibious animals, reptiles, etc.
     9: prefix := 'K'; //Fishes and parts of fishes
     10: prefix := 'L'; //Invertebrata and lesser animals
     11: prefix := 'M'; //Trees and plants
     12: prefix := 'N'; //Sky, earth, water
     13: prefix := 'NU'; //Upper nile
     14: prefix := 'NL'; //Lower nile
     15: prefix := 'O'; //Buildings, parts of buildings, etc.
     16: prefix := 'P'; //Ships and parts of ships
     17: prefix := 'Q'; //Domestic and funerary furniture
     18: prefix := 'R'; //Temple furniture and sacred emblems
     19: prefix := 'S'; //Crowns, dress, staves, etc.
     20: prefix := 'T'; //Warfare, hunting, butchery
     21: prefix := 'U'; //Agriculture, crafts, and professions
     22: prefix := 'V'; //Rope, fibre, baskets, bags, etc.
     23: prefix := 'W'; //Vessels of stone and earthenware
     24: prefix := 'X'; //Loaves and cakes
     25: prefix := 'Y'; //Writings, games, music
     26: prefix := 'Z'; //Strokes, signs derived from Hieratic, geometrical features
     27: prefix := 'Aa'; //Unclassified signs
     end;
FileListBox1.Mask:='hiero_' + prefix + '*.png';
FileListBox1.Directory:=IncludeTrailingBackslash(extractfiledir(paramstr(0))) + 'img';
for i:=pnlGlyphs.ComponentCount-1 downto 0 do begin
    pnlGlyphs.Controls[i].Destroy;
    end;
for i:=0 to FileListBox1.Items.count -1 do begin
  bl:=StringReplace(FileListBox1.Items[i], 'hiero_', '', [rfReplaceAll]);
  bl:=stringreplace(bl, '.png', '', [rfReplaceAll]);
  ok := false;
  if (trim(bl)<>'') then begin
    test:=StringReplace(bl, prefix, '', [rfReplaceAll]);
    val(test, k, isnum);
    if (isnum=0) then begin
      ok:=true;
      end;
    end;
  if ok then begin
    btn:=TImage.Create(pnlGlyphs);
    btn.Picture.LoadFromFile(IncludeTrailingBackslash(extractfiledir(paramstr(0))) + IncludeTrailingBackslash('img') + FileListBox1.Items[i]);
    btn.Hint:=bl;
    btn.ShowHint:=true;
    btn.OnClick:=@glyphbuttonClick;
    btn.AutoSize:=true;
    btn.Parent:=pnlGlyphs;
    end;
  end;
txtMainEditor.SetFocus;
end;

procedure TfrmMain.actCopyExecute(Sender: TObject);
begin
txtMainEditor.CopyToClipboard;
//Clipboard.AsText:=txtMainEditor.SelText;
end;

procedure TfrmMain.actCutExecute(Sender: TObject);
begin
txtMainEditor.CutToClipboard;
end;

procedure TfrmMain.actDeleteExecute(Sender: TObject);
begin
txtMainEditor.SelText:='';
end;

procedure TfrmMain.actPasteExecute(Sender: TObject);
begin
txtMainEditor.PasteFromClipboard;
end;

procedure TfrmMain.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin

end;

procedure TfrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
CanClose:=true;
if unsaved then begin
  CanClose:=false;
  SaveDialog1.FileName:=currentfilename;
  case application.MessageBox('The current file has been modified. Do you want to save it before closing the program?', 'Unsaved file', MB_YESNOCANCEL + MB_ICONWARNING) of
       IDYES: begin
         if currentfilename=''  then begin
           if SaveDialog1.execute then begin
             currentfilename:=SaveDialog1.FileName;
             txtMainEditor.Lines.SaveToFile(SaveDialog1.FileName);
             CanClose:=true;
             end;
           end else begin
           txtMainEditor.Lines.SaveToFile(currentfilename);
           CanClose:=true;
           end;
         end;
       IDNO: begin
         CanClose:=true;
         end;
       IDCANCEL: begin
         CanClose:=false;
         end;
       end;
  end;

end;

procedure TfrmMain.processhierofile(afilename:string);
var
  lines:TStringList;
  src, token:string;
  parsed, tmp, subtokens, subsubtokens:TStringArray;
  i,d,c,t,v,h,s:integer;
  characters:TList;
  character:TCharacterInfo;
  done:Boolean;

begin
config:=TStringList.create;
config.Clear;
//writeln('Processing source file ''' + filename + '''...');
characters:=TList.create;
lines:=TStringList.create;
//lines.LoadFromFile(filename);
if (FileExists(afilename)) then begin
  if (Pos('.hiero', afilename)<>0) then begin
    lines.LoadFromFile(afilename);
    end;
  end else begin
  lines.Text:=txtMainEditor.text;
  end;
src:='';
for i:=0 to lines.count-1 do begin
    if (pos('config', lines[i])=0) then begin
      src += lines[i] + ' ';
      end else begin
      //writeln('Configuration option found: ' + stringreplace(lines[i], 'config:', '', [rfReplaceAll]));
      config.add(lines[i]);
      end;
    end;
src:=trim(src);
src:=StringReplace(src, '-', ' ', [rfReplaceAll]);
//src:=StringReplace(src, #13#10, ' ', [rfReplaceAll]);
//src:=StringReplace(src, #13, ' ', [rfReplaceAll]);
//src:=StringReplace(src, #10, ' ', [rfReplaceAll]);
src:=StringReplace(src, '!', ' ! ', [rfReplaceAll]);
src:=StringReplace(src, '	', ' ', [rfReplaceAll]);
while (Pos('  ', src)>0) do begin
  src:=StringReplace(src, '  ', ' ', [rfReplaceAll]);
  end;
src:=StringReplace(src, '* ', '*', [rfReplaceAll]);
src:=StringReplace(src, ' *', '*', [rfReplaceAll]);
src:=StringReplace(src, ': ', ':', [rfReplaceAll]);
src:=StringReplace(src, ' :', ':', [rfReplaceAll]);
//writeln('Processed source text: '#13#10'----------------------');
//writeln(src);
//writeln('----------------------');
parsed:=src.Split(' ');
for i:=0 to length(parsed)-1 do begin
  token:=trim(parsed[i]);
  done:=false;
  if (token='!') then begin
    character:=TCharacterInfo.create;
    character.name:=token;
    character.code:=token;
    character.position:='eol';
    characters.add(character);
    done:=true;
    end;
  //check for pre-composed groups
  if ((pos(':', token)>0)or(pos('*', token)>0)) then begin
    for d:=0 to combinations.count-1 do begin
      if (token=combinations[d]) then begin
        character:=TCharacterInfo.create;
        character.code:=token;
        character.name:='pre';
        characters.add(character);
        done:=true;
        end;
      end;
    end;

  if not done then begin
    if (pos(':', token)=0) then begin
      //no vertical group; so, ignore horizontal grouping
      tmp:=token.Split('*');
      for t:=0 to Length(tmp)-1 do begin
        character:=TCharacterInfo.create;
        character.code:=tmp[t];
        characters.add(character);
        end;
      end else begin
      //vertical grouping
      subtokens:=token.split(':');
      if (pos('*', subtokens[0])=0) then begin
        //no horizontal composition
        character:=TCharacterInfo.create;
        character.code:=subtokens[0];
        character.position:='top';
        characters.add(character);
        end else begin
        //horizontal composition
        subsubtokens:=subtokens[0].split('*');
        character:=TCharacterInfo.create;
        character.code:=subsubtokens[0];
        character.position:='top-left';
        characters.add(character);

        character:=TCharacterInfo.create;
        character.code:=subsubtokens[1];
        character.position:='top-right';
        characters.add(character);
        end;
      if (pos('*', subtokens[1])=0) then begin
        //no horizontal composition
        character:=TCharacterInfo.create;
        character.code:=subtokens[1];
        character.position:='bottom';
        characters.add(character);
        end else begin
        //horizontal composition
        subsubtokens:=subtokens[1].split('*');
        character:=TCharacterInfo.create;
        character.code:=subsubtokens[0];
        character.position:='bottom-left';
        characters.add(character);

        character:=TCharacterInfo.create;
        character.code:=subsubtokens[1];
        character.position:='bottom-right';
        characters.add(character);
        end;

      end;
    end;
  //////////////////////////////
  end;
generate_image(characters, afilename);
end;

procedure TfrmMain.initdata;
var
  i,j:integer;

begin
combinations:=TStringList.create;
rawdata:=TStringList.create;
if (not FileExists('img/hiero_A1.png')) then begin
  //writeln('[!] ERROR: Image files NOT FOUND!');
  halt(1);
  end;
if (FileExists('glyphdata.csv')) then begin
   //writeln('Loading glyph data...');
   rawdata.LoadFromFile('glyphdata.csv');
   end else begin
   //writeln('[!] Data file glyphdata.csv NOT FOUND!');
   //writeln('Trying to load alternate data file...');
   if (FileExists('altglyphdata.csv')) then begin
      //writeln('Loading glyph data from alternate file...');
      rawdata.LoadFromFile('altglyphdata.csv');
      end else begin
      //writeln('[!] Alternate data file altglyphdata.csv NOT FOUND!');
      //writeln('Trying to generate alternate data file from image files...');
      j:=builddatafile;
      if (FileExists('altglyphdata.csv')) then begin
         //writeln('Loading glyph data from alternate file...');
         rawdata.LoadFromFile('altglyphdata.csv');
         end else begin
         //writeln('[!] Alternate data file altglyphdata.csv NOT FOUND!');
         halt(1);
         end;
      end;
   end;
glyphs:=TList.Create;
for i:=0 to rawdata.count-1 do begin
  glyph:=TGlyphData.create(rawdata[i]);
  glyphs.add(glyph);
  if ((pos(':', glyph.code.text)>0)or(pos('*', glyph.code.text)>0)) then begin
    for j:= 0 to glyph.code.Count-1 do begin
      combinations.add(glyph.code[j]);
      end;
    end;
  end;

end;

procedure TfrmMain.generate_image(characters: TList; afilename:string);
var
  glyph, finalimage:TPortableNetworkGraphic;
  bmp:TBitMap;
  r:TRect;
  lineheight, textwidth, maxwidth, maxheight, space,
  x, y,
  glyphx, glyphy,
  groupwidth,
  nextx,
  finalwidth, finalheight,
  i, g, j, k :integer;
  glyphfilename:string;
  tmp:string;
  isnum:integer;

begin
lineheight:=0;
textwidth:=0;
maxwidth:=1000;
maxheight:=5000;
space:=5;
for i:=0 to config.count-1 do begin
  if (pos(':maxwidth=', config.text)>0) then begin
    tmp:=trim(StringReplace(config[i], 'config:maxwidth=', '', [rfReplaceAll]));
    val(tmp, k, isnum);
    if (isnum=0) then begin
      maxwidth:=StrToInt(tmp);
      end;
    end;
  if (pos(':maxheight=', config.text)>0) then begin
    tmp:=trim(StringReplace(config[i], 'config:maxheight=', '', [rfReplaceAll]));
    val(tmp, k, isnum);
    if (isnum=0) then begin
      maxheight:=StrToInt(tmp);
      end;
    end;
  if (pos(':lineheight=', config.text)>0) then begin
    tmp:=trim(StringReplace(config[i], 'config:lineheight=', '', [rfReplaceAll]));
    val(tmp, k, isnum);
    if (isnum=0) then begin
      lineheight:=StrToInt(tmp);
      end;
    end;
  if (pos(':space=', config.text)>0) then begin
    tmp:=trim(StringReplace(config[i], 'config:space=', '', [rfReplaceAll]));
    val(tmp, k, isnum);
    if (isnum=0) then begin
      space:=StrToInt(tmp);
      end;
    end;
  end;
x:=0;
y:=0;
bmp:=TBitmap.Create;
bmp.Width:=maxwidth;
bmp.Height:=maxheight;
bmp.Canvas.Pen.Color:=clWhite;
bmp.Canvas.Brush.Color:=clWhite;
bmp.Canvas.FillRect(0,0,maxwidth,maxheight);
for i:=0 to characters.count-1 do begin
  for g:=0 to glyphs.count-1 do begin
    if (
    (TGlyphData(glyphs[g]).matchcode(TCharacterInfo(characters[i]).code))
    or
    (TCharacterInfo(characters[i]).code=TGlyphData(glyphs[g]).name)) then begin
      TCharacterInfo(characters[i]).name:=TGlyphData(glyphs[g]).name;
      TCharacterInfo(characters[i]).width:=TGlyphData(glyphs[g]).width;
      TCharacterInfo(characters[i]).height:=TGlyphData(glyphs[g]).height;
      end;
    end;
  end;

for i:=0 to characters.count-1 do begin
  if (TCharacterInfo(characters[i]).height>lineheight) then begin
    lineheight:=TCharacterInfo(characters[i]).height;
    end;
  if (TCharacterInfo(characters[i]).name='!')then begin
    x := 0;
    y := y + lineheight + space;
    end else begin
    case TCharacterInfo(characters[i]).position of
       'regular': begin
         if (x+TCharacterInfo(characters[i]).width > maxwidth) then begin
           x := 0;
           y := y + lineheight + space;
           end;
         end;
       'top': begin
         if (x+TCharacterInfo(characters[i]).width > maxwidth) then begin
           x := 0;
           y := y + lineheight + space;
           end;
         end;
       'top-left':begin
         if (x+TCharacterInfo(characters[i+2]).width > maxwidth) then begin
           x := 0;
           y := y + lineheight + space;
           end;
         end;
       end;

    glyphx := x;
    glyphy := y + ((lineheight - TCharacterInfo(characters[i]).height) div 2);
    nextx := x + TCharacterInfo(characters[i]).width + space;
    case TCharacterInfo(characters[i]).position of
         'top': begin
           glyphy := y;
           nextx := x;
           if (i<characters.Count) then begin
             if (TCharacterInfo(characters[i+1]).width > TCharacterInfo(characters[i]).width) then begin
               glyphx := glyphx + (TCharacterInfo(characters[i+1]).width - TCharacterInfo(characters[i]).width) div 2;
               end;
             glyphy := y + ((lineheight div 2) - TCharacterInfo(characters[i]).height) div 2;
             end;
           end;
         'bottom': begin
           glyphy := y * (lineheight div 2);
           if (i>0) then begin
             if (TCharacterInfo(characters[i-1]).width > TCharacterInfo(characters[i]).width) then begin
               glyphx := glyphx + ((TCharacterInfo(characters[i-1]).width - TCharacterInfo(characters[i]).width) div 2);
               if (TCharacterInfo(characters[i]).width > TCharacterInfo(characters[i-1]).width) then begin
                 nextx := x + TCharacterInfo(characters[i]).width + space;
                 end else begin
                 nextx := x + TCharacterInfo(characters[i-1]).width + space;
                 end;
               end;
             glyphy := y + (lineheight div 2) + ((lineheight div 2) - TCharacterInfo(characters[i]).height) div 2;
             end;
           end;
         'top-left': begin
           glyphy := y;
           nextx := glyphx + TCharacterInfo(characters[i]).width;
           end;
         'top-right': begin
           glyphy := y;
           nextx := glyphx - TCharacterInfo(characters[i-1]).width;
           end;
         'bottom-left': begin
           glyphy := y + (lineheight div 2);
           nextx := glyphx + TCharacterInfo(characters[i]).width;
           end;
         'bottom-right': begin
           glyphy := y + (lineheight div 2);
           nextx := glyphx + TCharacterInfo(characters[i]).width + space;
           end;
         end;
    end;
  if (TCharacterInfo(characters[i]).name<>'!') then begin
    glyphfilename:=StringReplace('img/hiero_' + TCharacterInfo(characters[i]).name + '.png', 'hiero_blank', 'blank', [rfReplaceAll]);

    if (FileExists(glyphfilename, true)) then begin
      if (TCharacterInfo(characters[i]).name='blank') then begin
        //writeln(#13#10'[!] glyph [' + TCharacterInfo(characters[i]).code + '] NOT FOUND, loading placeholder image ' + glyphfilename + ' [!]...');
        end else begin
        write('Loading glyph [' + TCharacterInfo(characters[i]).code + '] from file ' + glyphfilename + '...');
        end;
      writeln;
      glyph:=TPortableNetworkGraphic.Create;
      glyph.LoadFromFile(glyphfilename);
      r:=glyph.Canvas.ClipRect;
      r.Left:=glyphx;
      r.top:=glyphy;
      //x:=x + glyph.Width + space;
      bmp.Canvas.CopyRect(r, glyph.Canvas, glyph.Canvas.ClipRect);
      glyph.free;
      x := nextx;
      if (x > textwidth) then begin
        textwidth:=x;
        end;
      end else begin
      //writeln('[!] file ' + glyphfilename + ' NOT FOUND!');
      end;
    end;
  end;
finalimage:=TPortableNetworkGraphic.Create;
finalimage.Width:=textwidth;
finalimage.height:=y + lineheight;
r:=bmp.canvas.ClipRect;
r.Right:=textwidth;
r.Bottom:=y + lineheight;
finalimage.canvas.CopyRect(bmp.canvas.ClipRect, bmp.canvas, bmp.canvas.ClipRect);
finalimage.SaveToFile('tmp.png');
if (FileExists(afilename)) then begin
  if (Pos('.hiero', afilename)<>0) then begin
    finalimage.SaveToFile(StringReplace(afilename, '.hiero', '.png', [rfReplaceAll]));
    end;
  end;
imgMainDisplay.Picture.LoadFromFile('tmp.png');
//writeln('Generated image file ' + StringReplace(filename, '.hiero', '.png', [rfReplaceAll]));
//writeln('======================');
//writeln('');
//bmp.SaveToFile(StringReplace(filename, '.hiero', '.bmp', [rfReplaceAll]));
bmp.Free;
finalimage.free;
//glyph.free;
end;

function TfrmMain.builddatafile: integer;
var
  Info : TSearchRec;
  files: TStringList;
  f:integer;
  datafile:TStringList;
  glyph:TPortableNetworkGraphic;

begin
files:=TStringList.create;
datafile:=TStringList.create;

if FindFirst('./img/*.png', faAnyFile, Info)=0 then begin
  repeat
       files.add(Info.Name);
  until
       FindNext(Info) <> 0;
  end;
FindClose(Info);
for f:=0 to files.count-1 do begin
  glyph:=TPortableNetworkGraphic.Create;
  glyph.LoadFromFile('img/' + files[f]);
  files[f]:=StringReplace(files[f], '.png', '', [rfReplaceAll]);
  files[f]:=StringReplace(files[f], 'hiero_', '', [rfReplaceAll]);
  datafile.add(files[f] + '||' + inttostr(glyph.Width) + '|' + inttostr(glyph.Height));
  end;
datafile.SaveToFile('altglyphdata.csv');
result:=files.Count;
end;
end.

