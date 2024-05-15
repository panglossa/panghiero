unit ufrmmain;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Menus, StdCtrls,
  ExtCtrls, Buttons, FileCtrl, uglyphdata, ucharacterinfo;

type

  { TfrmMain }

  TfrmMain = class(TForm)
    BitBtn3: TBitBtn;
    ComboBox1: TComboBox;
    FileListBox1: TFileListBox;
    FlowPanel1: TFlowPanel;
    GroupBox1: TGroupBox;
    Image1: TImage;
    Image2: TImage;
    MainMenu1: TMainMenu;
    Memo1: TMemo;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem15: TMenuItem;
    MenuItem16: TMenuItem;
    MenuItem17: TMenuItem;
    MenuItem18: TMenuItem;
    MenuItem19: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem20: TMenuItem;
    ScrollBox1: TScrollBox;
    Separator3: TMenuItem;
    MenuItem22: TMenuItem;
    MenuItem23: TMenuItem;
    Separator2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;
    Panel1: TPanel;
    Separator1: TMenuItem;
    Splitter1: TSplitter;
    procedure ComboBox1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure GroupBox1Click(Sender: TObject);
    procedure Image2Click(Sender: TObject);
    procedure Memo1Exit(Sender: TObject);
    procedure MenuItem19Click(Sender: TObject);
    procedure MenuItem20Click(Sender: TObject);
    procedure MenuItem6Click(Sender: TObject);
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

implementation
uses
  ufrmabout;
{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.MenuItem6Click(Sender: TObject);
begin
close;
end;

procedure TfrmMain.updateview;
begin
memo1.lines.SaveToFile('default.txt');
processhierofile('');
image1.Picture.SaveToFile('default.png');
end;

procedure TfrmMain.glyphbuttonClick(Sender: TObject);
begin
memo1.SelText:=' ' + (Sender as TImage).Hint + ' ';
memo1.SetFocus;
end;

procedure TfrmMain.GroupBox1Click(Sender: TObject);
begin

end;

procedure TfrmMain.Image2Click(Sender: TObject);
begin

end;

procedure TfrmMain.Memo1Exit(Sender: TObject);
begin
updateview;
end;

procedure TfrmMain.MenuItem19Click(Sender: TObject);
begin
frmAbout.showmodal;
end;

procedure TfrmMain.MenuItem20Click(Sender: TObject);
begin
updateview;
end;

procedure TfrmMain.FormCreate(Sender: TObject);
var
  i:integer;

begin
initdata;
if (paramcount()>0) then begin
  for i:=1 to paramcount() do begin
    processhierofile(ParamStr(i));
    end;
  Application.Terminate;
  end else begin
  panel1.align:=alClient;
  if (fileexists('default.txt')) then begin
    memo1.lines.loadfromfile('default.txt');
    end;
  if (fileexists('default.png')) then begin
    image1.picture.loadfromfile('default.png');
    end;
  end;
end;

procedure TfrmMain.FormResize(Sender: TObject);
begin
memo1.Width:=panel1.Width div 2;

end;

procedure TfrmMain.ComboBox1Change(Sender: TObject);
var
  prefix:string;
  i:integer;
  btn:TImage;
  bl, test:string;
  ok:boolean;
  isnum, k:integer;

begin
prefix:='A';
case ComboBox1.ItemIndex of
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
for i:=FlowPanel1.ComponentCount-1 downto 0 do begin
    FlowPanel1.Controls[i].Destroy;
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
    btn:=TImage.Create(FlowPanel1);
    btn.Picture.LoadFromFile(IncludeTrailingBackslash(extractfiledir(paramstr(0))) + IncludeTrailingBackslash('img') + FileListBox1.Items[i]);
    btn.Hint:=bl;
    btn.ShowHint:=true;
    btn.OnClick:=@glyphbuttonClick;
    btn.AutoSize:=true;
    btn.Parent:=FlowPanel1;
    end;
  end;
memo1.SetFocus;
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
  lines.Text:=Memo1.text;
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
image1.Picture.LoadFromFile('tmp.png');
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

