unit utools;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, graphics, ucharacterinfo, uglyphdata;

function listfiles:TStringList;
procedure processhierofile(filename:string);
procedure initdata;
procedure generate_image(characters: TList; filename:string);
function builddatafile:integer;

implementation

var
  rawdata, combinations:TStringList;
  glyphs:TList;
  glyph:TGlyphData;
  config:TStringList;


function listfiles:TStringList;
var
  Info : TSearchRec;
begin
Result:=TStringList.create;
if FindFirst('./*.hiero', faAnyFile, Info)=0 then begin
  repeat
       result.add(Info.Name);
  until
       FindNext(Info) <> 0;
  end;
FindClose(Info);
end;

procedure processhierofile(filename: string);
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
writeln('Processing source file ''' + filename + '''...');
characters:=TList.create;
lines:=TStringList.create;
lines.LoadFromFile(filename);
src:='';
for i:=0 to lines.count-1 do begin
    if (pos('config', lines[i])=0) then begin
      src += lines[i];
      end else begin
      writeln('Configuration option found: ' + stringreplace(lines[i], 'config:', '', [rfReplaceAll]));
      config.add(lines[i]);
      end;
    end;
src:=trim(src);
src:=StringReplace(src, '-', ' ', [rfReplaceAll]);
src:=StringReplace(src, '!', ' ! ', [rfReplaceAll]);
src:=StringReplace(src, '	', ' ', [rfReplaceAll]);
while (Pos('  ', src)>0) do begin
  src:=StringReplace(src, '  ', ' ', [rfReplaceAll]);
  end;
src:=StringReplace(src, '* ', '*', [rfReplaceAll]);
src:=StringReplace(src, ' *', '*', [rfReplaceAll]);
src:=StringReplace(src, ': ', ':', [rfReplaceAll]);
src:=StringReplace(src, ' :', ':', [rfReplaceAll]);
writeln('Processed source text: '#13#10'----------------------');
writeln(src);
writeln('----------------------');
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
generate_image(characters, filename);
end;

procedure initdata;
var
  i,j:integer;

begin
combinations:=TStringList.create;
rawdata:=TStringList.create;
if (not FileExists('img/hiero_A1.png')) then begin
  writeln('[!] ERROR: Image files NOT FOUND!');
  halt(1);
  end;
if (FileExists('glyphdata.csv')) then begin
   writeln('Loading glyph data...');
   rawdata.LoadFromFile('glyphdata.csv');
   end else begin
   writeln('[!] Data file glyphdata.csv NOT FOUND!');
   writeln('Trying to load alternate data file...');
   if (FileExists('altglyphdata.csv')) then begin
      writeln('Loading glyph data from alternate file...');
      rawdata.LoadFromFile('altglyphdata.csv');
      end else begin
      writeln('[!] Alternate data file altglyphdata.csv NOT FOUND!');
      writeln('Trying to generate alternate data file from image files...');
      j:=builddatafile;
      if (FileExists('altglyphdata.csv')) then begin
         writeln('Loading glyph data from alternate file...');
         rawdata.LoadFromFile('altglyphdata.csv');
         end else begin
         writeln('[!] Alternate data file altglyphdata.csv NOT FOUND!');
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

procedure generate_image(characters: TList; filename: string);
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
        writeln(#13#10'[!] glyph [' + TCharacterInfo(characters[i]).code + '] NOT FOUND, loading placeholder image ' + glyphfilename + ' [!]...');
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
      writeln('[!] file ' + glyphfilename + ' NOT FOUND!');
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
finalimage.SaveToFile(StringReplace(filename, '.hiero', '.png', [rfReplaceAll]));
writeln('Generated image file ' + StringReplace(filename, '.hiero', '.png', [rfReplaceAll]));
writeln('======================');
writeln('');
//bmp.SaveToFile(StringReplace(filename, '.hiero', '.bmp', [rfReplaceAll]));
bmp.Free;
finalimage.free;
//glyph.free;
end;

function builddatafile: integer;
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

