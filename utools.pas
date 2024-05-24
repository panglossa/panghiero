unit utools;

{$mode ObjFPC}{$H+}

interface

uses
  Classes, SysUtils, graphics, inifiles, dialogs,
  ucharacterinfo, uglyphdata;

function listfiles:TStringList;
procedure processhierofile(filename:string);
procedure initdata;
procedure generate_image(characters: TList; filename:string);
function builddatafile:integer;
function processaliases(sourcetext:string):string;
function texttoimage(sourcetext:string):TBitMap;//TPortableNetworkGraphic;

implementation

var
  rawdata, combinations:TStringList;
  glyphs:TList;
  glyph:TGlyphData;
  userconfig:TStringList;
  appconfig:TINIFile;


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
userconfig:=TStringList.create;
userconfig.Clear;
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
      userconfig.add(lines[i]);
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
if (FileExists('glyphdata.dat')) then begin
   writeln('Loading glyph data...');
   rawdata.LoadFromFile('glyphdata.dat');
   end else begin
   writeln('[!] Data file glyphdata.dat NOT FOUND!');
   writeln('Trying to load alternate data file...');
   if (FileExists('altglyphdata.dat')) then begin
      writeln('Loading glyph data from alternate file...');
      rawdata.LoadFromFile('altglyphdata.dat');
      end else begin
      writeln('[!] Alternate data file altglyphdata.dat NOT FOUND!');
      writeln('Trying to generate alternate data file from image files...');
      j:=builddatafile;
      if (FileExists('altglyphdata.dat')) then begin
         writeln('Loading glyph data from alternate file...');
         rawdata.LoadFromFile('altglyphdata.dat');
         end else begin
         writeln('[!] Alternate data file altglyphdata.dat NOT FOUND!');
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
for i:=0 to userconfig.count-1 do begin
  if (pos(':maxwidth=', userconfig[i])>0) then begin
    tmp:=trim(StringReplace(userconfig[i], 'config:maxwidth=', '', [rfReplaceAll]));
    val(tmp, k, isnum);
    if (isnum=0) then begin
      maxwidth:=StrToInt(tmp);
      end;
    end;
  if (pos(':maxheight=', userconfig[i])>0) then begin
    tmp:=trim(StringReplace(userconfig[i], 'config:maxheight=', '', [rfReplaceAll]));
    val(tmp, k, isnum);
    if (isnum=0) then begin
      maxheight:=StrToInt(tmp);
      end;
    end;
  if (pos(':lineheight=', userconfig[i])>0) then begin
    tmp:=trim(StringReplace(userconfig[i], 'config:lineheight=', '', [rfReplaceAll]));
    val(tmp, k, isnum);
    if (isnum=0) then begin
      lineheight:=StrToInt(tmp);
      end;
    end;
  if (pos(':space=', userconfig[i])>0) then begin
    tmp:=trim(StringReplace(userconfig[i], 'config:space=', '', [rfReplaceAll]));
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
datafile.SaveToFile('altglyphdata.dat');
result:=files.Count;
end;

function processaliases(sourcetext: string): string;
var
  rawaliases:TStringList;
  parts:TStringArray;
  i:integer;
  res:string;

begin
if (fileexists('aliases.dat')) then begin
  res:=sourcetext;
  rawaliases:=TStringList.create;
  rawaliases.LoadFromFile('aliases.dat');
  for i:=0 to rawaliases.Count-1 do begin
    parts:=rawaliases[i].Trim().Split('|');
    if (length(parts)=2) then begin
      res:=StringReplace(res, parts[0], parts[1], [rfReplaceAll]);
      end;
    end;
  result:=res;
  end else begin
  result:=sourcetext;
  end;
end;

//////////////////////////////////////
{ Now that everything works, let's put everything
in a nice function by which you can feed some text
and get the resulting image.
}
{ #note : main focus }
function texttoimage(sourcetext: string):TBitMap;// TPortableNetworkGraphic;
var
  lines:TStringList;
  src, token:string;
  parsed, tmp, subtokens, subsubtokens:TStringArray;
  i,d,c,t,v,h,s:integer;
  characters:TList;
  character:TCharacterInfo;
  done:Boolean;
  glyph:TPortableNetworkGraphic;
  finalimage:TBitmap;
  bmp:TBitMap;
  r:TRect;
  border, lineheight, textwidth, maxwidth, maxheight, space, linespace,
  x, y,
  glyphx, glyphy,
  groupwidth,
  cartouchestart,
  {nextx,}
  finalwidth, finalheight,
  g, j, k :integer;
  glyphfilename:string;
  buffer:string;
  isnum:integer;

begin
initdata;
cartouchestart:=-1;
appconfig:=TIniFile.Create(IncludeTrailingBackslash(ExtractFilePath(ParamStr(0))) + 'panghiero.ini');
userconfig:=TStringList.create;
userconfig.Clear;
//writeln('Processing source file ''' + filename + '''...');
characters:=TList.create;
lines:=TStringList.create;
lines.text:=processaliases(sourcetext);
src:='';
for i:=0 to lines.count-1 do begin
    if (pos('config', lines[i])=0) then begin
      src += lines[i] + ' ';
      end else begin
      //writeln('Configuration option found: ' + stringreplace(lines[i], 'config:', '', [rfReplaceAll]));
      userconfig.add(lines[i]);
      end;
    end;
src:=trim(src);
src:=StringReplace(src, '-', ' ', [rfReplaceAll]);
src:=StringReplace(src, #13#10, ' ', [rfReplaceAll]);
src:=StringReplace(src, #13, ' ', [rfReplaceAll]);
src:=StringReplace(src, #10, ' ', [rfReplaceAll]);
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
//showmessage(src);
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
//generate_image(characters, '');
//config options
border:=appconfig.ReadInteger('Graphic Options', 'Image Border', 0);
lineheight:=appconfig.ReadInteger('Graphic Options', 'Line Height', 0);
maxwidth:=appconfig.ReadInteger('Graphic Options', 'Maximum Text Width', 1000);
maxheight:=appconfig.ReadInteger('Graphic Options', 'Maximum Text Height', 5000);
space:=appconfig.ReadInteger('Graphic Options', 'Character Spacing', 0);
linespace:=appconfig.ReadInteger('Graphic Options', 'Interlinear Space', 0);
/////////////////////////
textwidth:=0;

for i:=0 to userconfig.count-1 do begin
  if (pos(':maxwidth=', userconfig[i])>0) then begin
    buffer:=trim(StringReplace(userconfig[i], 'config:maxwidth=', '', [rfReplaceAll]));
    val(buffer, k, isnum);
    if (isnum=0) then begin
      maxwidth:=StrToInt(buffer);
      end;
    end;
  if (pos(':maxheight=', userconfig[i])>0) then begin
    buffer:=trim(StringReplace(userconfig[i], 'config:maxheight=', '', [rfReplaceAll]));
    val(buffer, k, isnum);
    if (isnum=0) then begin
      maxheight:=StrToInt(buffer);
      end;
    end;
  if (pos(':lineheight=', userconfig[i])>0) then begin
    buffer:=trim(StringReplace(userconfig[i], 'config:lineheight=', '', [rfReplaceAll]));
    val(buffer, k, isnum);
    if (isnum=0) then begin
      lineheight:=StrToInt(buffer);
      end;
    end;
  if (pos(':space=', userconfig[i])>0) then begin
    buffer:=trim(StringReplace(userconfig[i], 'config:space=', '', [rfReplaceAll]));
    val(buffer, k, isnum);
    if (isnum=0) then begin
      space:=StrToInt(buffer);
      end;
    end;
  if (pos(':linespace=', userconfig[i])>0) then begin
    buffer:=trim(StringReplace(userconfig[i], 'config:linespace=', '', [rfReplaceAll]));
    val(buffer, k, isnum);
    if (isnum=0) then begin
      linespace:=StrToInt(buffer);
      end;
    end;
  if (pos(':border=', userconfig[i])>0) then begin
    buffer:=trim(StringReplace(userconfig[i], 'config:border=', '', [rfReplaceAll]));
    val(buffer, k, isnum);
    if (isnum=0) then begin
      border:=StrToInt(buffer);
      end;
    end;
  end;
x:=border;
y:=border;
bmp:=TBitmap.Create;
bmp.Width:=maxwidth;
bmp.Height:=maxheight;
bmp.Canvas.Pen.Color:=clBlack;
bmp.Canvas.Pen.Width:=3;
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
      if (TCharacterInfo(characters[i]).height>lineheight) then begin
        lineheight:=TCharacterInfo(characters[i]).height;
        end;
      end;
    end;
  end;
////////////////////////////////////////////////////
{note: Let's draw!!!}
groupwidth:=0;
for i:=0 to characters.count-1 do begin
  case TCharacterInfo(characters[i]).position of
       'regular': begin
         groupwidth:=TCharacterInfo(characters[i]).width;
         end;
       'top': begin
         groupwidth:=TCharacterInfo(characters[i]).width;
         if (i<characters.count-1) then begin
           if (TCharacterInfo(characters[i+1]).position='bottom') then begin
             if (TCharacterInfo(characters[i+1]).width > groupwidth) then begin
                groupwidth:=TCharacterInfo(characters[i+1]).width;
                end;
             end else if (TCharacterInfo(characters[i+1]).position='bottom-left') then begin
             if (i<characters.count-2) then begin
               if (TCharacterInfo(characters[i+2]).position='bottom-right') then begin
                 if (TCharacterInfo(characters[i+1]).width + TCharacterInfo(characters[i+2]).width > groupwidth) then begin
                    groupwidth:=TCharacterInfo(characters[i+1]).width + TCharacterInfo(characters[i+2]).width;
                    end;
                 end;
               end;
             end;
           end;
         end;
       'top-left': begin
         groupwidth:=TCharacterInfo(characters[i]).width;
         if (i<characters.count-1) then begin
           groupwidth:=TCharacterInfo(characters[i]).width + TCharacterInfo(characters[i+1]).width;
           if (i<characters.count-2) then begin
             if (TCharacterInfo(characters[i+2]).width > groupwidth) then begin
                groupwidth:=TCharacterInfo(characters[i+2]).width;
                end;
             end;
           end;
         end;
       'bottom': begin
         if (i>0) then begin
           if (TCharacterInfo(characters[i]).height + TCharacterInfo(characters[i-1]).height > lineheight) then begin
             lineheight:=TCharacterInfo(characters[i]).height + TCharacterInfo(characters[i-1]).height;
             end;
           end;
         end;
       end;
  if (TCharacterInfo(characters[i]).name='!')then begin
    x := border;
    y := y + lineheight + linespace;
    end else begin
    case TCharacterInfo(characters[i]).position of
       'regular': begin
         if (x + groupwidth + border > maxwidth) then begin
           x := border;
           y := y + lineheight + linespace;
           end;
         end;
       'top': begin
         if (x + groupwidth + border > maxwidth) then begin
           x := border;
           y := y + lineheight + linespace;
           end;
         end;
       'top-left':begin
         if (x + groupwidth + border > maxwidth) then begin
           x := border;
           y := y + lineheight + linespace;
           end;
         end;
       end;

    //glyphx := x;
    //glyphy := y + ((lineheight - TCharacterInfo(characters[i]).height) div 2);
    //nextx := x + TCharacterInfo(characters[i]).width + space;
    case TCharacterInfo(characters[i]).position of
         'regular': begin
           glyphx := x;
           glyphy := y + ((lineheight div 2) - (TCharacterInfo(characters[i]).height div 2));
           x:=x + groupwidth + space;
           end;
         'top': begin
           if (groupwidth=TCharacterInfo(characters[i]).width) then begin
             glyphx := x;
             end else if (groupwidth > TCharacterInfo(characters[i]).width) then begin
             glyphx := x + ((groupwidth div 2) - (TCharacterInfo(characters[i]).width div 2));
             end;
           //glyphy := y;
           //nextx := x;
           {if (i<characters.Count-1) then begin
             if (TCharacterInfo(characters[i+1]).position='bottom') then begin
               if (TCharacterInfo(characters[i+1]).width > TCharacterInfo(characters[i]).width) then begin
                 glyphx := x + (TCharacterInfo(characters[i+1]).width - TCharacterInfo(characters[i]).width) div 2;
                 end;
               end else if (TCharacterInfo(characters[i+1]).position='bottom-left') then begin
               if (i<characters.Count-2) then begin
                 if (TCharacterInfo(characters[i+1]).width + TCharacterInfo(characters[i+2]).width > TCharacterInfo(characters[i]).width) then begin
                   glyphx := x + (TCharacterInfo(characters[i+1]).width + TCharacterInfo(characters[i+2]).width - TCharacterInfo(characters[i]).width) div 2;
                   end;
                 end;
               end;
             }
           //vertical position in the middle of the top half of the line
           glyphy := y + (((lineheight div 2) - TCharacterInfo(characters[i]).height) div 2);
           //x:=x + groupwidth + space;
           end;
         'bottom': begin
           if (groupwidth = TCharacterInfo(characters[i]).width) then begin
             glyphx := x;
             end else if (groupwidth > TCharacterInfo(characters[i]).width) then begin
             glyphx := x + ((groupwidth div 2) - (TCharacterInfo(characters[i]).width div 2));
             end;
           //vertical position in the middle of the bottom half of the line
           glyphy := y + (lineheight div 2) + (((lineheight div 2) - TCharacterInfo(characters[i]).height) div 2);
           {
           glyphy := y + (lineheight div 2);
           if (i>0) then begin
             if (TCharacterInfo(characters[i-1]).width > TCharacterInfo(characters[i]).width) then begin
               glyphx := glyphx + ((TCharacterInfo(characters[i-1]).width - TCharacterInfo(characters[i]).width) div 2);
               if (TCharacterInfo(characters[i]).width > TCharacterInfo(characters[i-1]).width) then begin
                 //nextx := x + TCharacterInfo(characters[i]).width + space;
                 end else begin
                 //nextx := x + TCharacterInfo(characters[i-1]).width + space;
                 end;
               end;
             glyphy := y + (lineheight div 2) + ((lineheight div 2) - TCharacterInfo(characters[i]).height) div 2;
             end;      }
           x:=x + groupwidth + space;
           end;
         'top-left': begin
           //oh boy...
           //Horizontal position in the middle of the left half of groupwidth
           glyphx := x + ((groupwidth div 4) - (TCharacterInfo(characters[i]).width div 2));
           //vertical position in the middle of the top half of the line
           glyphy := y + (((lineheight div 2) - TCharacterInfo(characters[i]).height) div 2);
           //nextx := glyphx + TCharacterInfo(characters[i]).width;
           end;
         'top-right': begin
           //Horizontal position in the middle of the right half of groupwidth
           glyphx := x + (groupwidth div 2) + ((groupwidth div 4) - (TCharacterInfo(characters[i]).width div 2));
           //vertical position in the middle of the top half of the line
           glyphy := y + (((lineheight div 2) - TCharacterInfo(characters[i]).height) div 2);
           //nextx := glyphx - TCharacterInfo(characters[i-1]).width;
           //x:=x + groupwidth + space;
           end;
         'bottom-left': begin
           //Horizontal position in the middle of the left half of groupwidth
           glyphx := x + ((groupwidth div 4) - (TCharacterInfo(characters[i]).width div 2));

           //vertical position in the middle of the bottom half of the line
           glyphy := y + (lineheight div 2) + (((lineheight div 2) - TCharacterInfo(characters[i]).height) div 2);

           //glyphy := y + (lineheight div 2);
           //nextx := glyphx + TCharacterInfo(characters[i]).width;
           end;
         'bottom-right': begin
           //Horizontal position in the middle of the right half of groupwidth
           glyphx := x + (groupwidth div 2) + ((groupwidth div 4) - (TCharacterInfo(characters[i]).width div 2));
           //vertical position in the middle of the bottom half of the line
           glyphy := y + (lineheight div 2) + (((lineheight div 2) - TCharacterInfo(characters[i]).height) div 2);
           //glyphy := y + (lineheight div 2);
           //nextx := glyphx + TCharacterInfo(characters[i]).width + space;
           x:=x + groupwidth + space;
           end;
         end;
    end;
  if (TCharacterInfo(characters[i]).name<>'!') then begin
    glyphfilename:=StringReplace('img/hiero_' + TCharacterInfo(characters[i]).name + '.png', 'hiero_blank', 'blank', [rfReplaceAll]);

    if (FileExists(glyphfilename, true)) then begin
      if (TCharacterInfo(characters[i]).name='blank') then begin
        //writeln(#13#10'[!] glyph [' + TCharacterInfo(characters[i]).code + '] NOT FOUND, loading placeholder image ' + glyphfilename + ' [!]...');
        end else if (TCharacterInfo(characters[i]).code='<') then begin
        cartouchestart:=glyphx + groupwidth;
        end else if (TCharacterInfo(characters[i]).code='>') then begin
        bmp.canvas.Line(cartouchestart, glyphy + 1, glyphx, glyphy + 1);
        bmp.canvas.Line(cartouchestart, glyphy + lineheight - 5, glyphx, glyphy + lineheight - 5);
        cartouchestart:=-1;
        end else begin
        //write('Loading glyph [' + TCharacterInfo(characters[i]).code + '] from file ' + glyphfilename + '...');
        end;
      //writeln;
      glyph:=TPortableNetworkGraphic.Create;
      glyph.LoadFromFile(glyphfilename);
      r:=glyph.Canvas.ClipRect;
      r.Left:=glyphx;
      r.top:=glyphy;
      //x:=x + glyph.Width + space;
      writeln('[Glyph ' + TCharacterInfo(characters[i]).code + ']');
      writeln('[filename ' + glyphfilename + ']');
      writeln('width=' + inttostr(TCharacterInfo(characters[i]).width));
      writeln('height=' + inttostr(TCharacterInfo(characters[i]).height));
      writeln('x=' + inttostr(x));
      writeln('glyphx=' + inttostr(glyphx));
      writeln('y=' + inttostr(y));
      writeln('glyphy=' + inttostr(glyphy));
      writeln('lineheight=' + inttostr(lineheight));
      writeln('');
      bmp.Canvas.CopyRect(r, glyph.Canvas, glyph.Canvas.ClipRect);
      glyph.free;
      //x := nextx;
      if (x > textwidth) then begin
        textwidth:=x;
        end;
      end else begin
      //writeln('[!] file ' + glyphfilename + ' NOT FOUND!');
      end;
    end;
  end;
finalimage:=TBitmap.Create;// TPortableNetworkGraphic.Create;
finalimage.Width:=textwidth + border;
finalimage.height:=y + lineheight + border;
r:=bmp.canvas.ClipRect;
r.Right:=textwidth + border;
r.Bottom:=y + lineheight + border;
finalimage.canvas.CopyRect(bmp.canvas.ClipRect, bmp.canvas, bmp.canvas.ClipRect);
if (appconfig.ReadString('Graphic Options', 'Text Direction', 'Left to Right')='Right to Left') then begin
   finalimage.Canvas.CopyRect(Rect(finalimage.Width,0,0,finalimage.Height),finalimage.Canvas,Rect(0,0,finalimage.width,finalimage.Height));
   end;
//finalimage.SaveToFile('tmp.bmp');
//writeln('Generated image file ' + StringReplace(filename, '.hiero', '.png', [rfReplaceAll]));
//writeln('======================');
//writeln('');
//bmp.SaveToFile(StringReplace(filename, '.hiero', '.bmp', [rfReplaceAll]));
bmp.Free;
//finalimage.free;
result:=finalimage;
//glyph.free;
end;

end.

