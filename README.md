# Panghiero ![PangHiero Icon](https://github.com/panglossa/panghiero/blob/main/panghieroicon64.png) 
## Overview

**Panghiero** is a very simple editor that generates Egyptian hieroglyphs (in png) from a source text in [MdC format](https://en.wikipedia.org/wiki/Manuel_de_Codage).


For example, if you type in the following text:

    
    w b n:N5 r:a N5 m p*t:N1


You will get an image, containing the corresponding hieroglyphic text:

![Sample Hieroglyphic Text](https://github.com/panglossa/panghiero/blob/main/sample.png)

## Dependencies
For this program to work, you need the individual glyphs as separate `.png` files. The provided file `glyphdata.csv`, containing aliases and dimensions for each glyph, is based on the images provided with the [WikiHiero Project](https://github.com/wikimedia/mediawiki-extensions-wikihiero). You just need to place the `img` folder from wikihiero, with all its contents, in the same location as the `panghiero` executable. (That is, all the glyph images are contained inside the `img` folder which must be placed in the same folder as the `panghiero` program.)

## Source Code
This project is written in Lazarus ([https://www.lazarus-ide.org/](https://www.lazarus-ide.org/)) with plain Pascal code. No external libraries or components are necessary. In theory, it can be compiled and run in any plataform Lazarus is available in (Linux, Windows, Mac OS X). 

## Limitations
Currently, character grouping is quite limited: you can have at most two rows, and only one of these rows may have a horizontal group, which can consist of no more than two items. I.e., you can have `r:n`, but not `r:n:f`; `p*t:N1` is possible, as well as `N16:N23*Z1`; but `N16:N23*Z1:f` is out of the question.

Also, the grouping algorithm is still a bit crude, and sometimes doesn't give very good results, especially with horizontal grouping. It certainly needs a lot of improvement. 

## Conclusion
This is a very basic tool, which started as a weekend idea for a LaTeX extension using PGF/TikZ. It was promising, but quite limited, and didn't work for creating ebooks. It then turned into a `.php` script which grew into a larger project until I decided to "transfer" it to `lazarus`. 

This is an amateur project, intended to be a simple tool for simple use cases. 

If you want or need a **real** editor for Egyptian hieroglyphic texts, you'd better have a look at the amazingly wonderful, wonderfully amazing [JSesh](https://jsesh.qenherkhopeshef.org/), which is an essential tool for anyone studying or working with Egyptian hieroglyphs.


