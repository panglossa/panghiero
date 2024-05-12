# Panghiero
## Overview
![PangHiero Icon](https://github.com/panglossa/panghiero/blob/main/panghieroicon64.png) 

Generates Egyptian hieroglyphs (in png) from a source text in MdC format.

This is a very simple command line tool that converts source texts in MdC format to image files containing Egyptian hieroglyphic text.

Source files must: 
- be in MdC (Manuel de Codage) format ([MdC at Wikipedia](https://en.wikipedia.org/wiki/Manuel_de_Codage));
- have the file extension `.hiero`
- be placed in the same folder as the program

For example, consider the sample file (`sample.hiero`). It contains the following text:

    
    w b n:N5 r:a N5 m p*t:N1


After you run `./panghiero`, the file `sample.png` is generated, containing the corresponding hieroglyphic text:

![Sample Hieroglyphic Text](https://github.com/panglossa/panghiero/blob/main/sample.png)

## Dependencies
For this program to work, you need the individual glyphs as separate `.png` files. The provided file `glyphdata.csv`, containing aliases and dimensions for each glyph, is based the images provided with the [WikiHiero Project](https://github.com/wikimedia/mediawiki-extensions-wikihiero). You just need to place the `img` folder from wikihiero, with all its contents, in the same location as the `panghiero` executable. (That is, all the glyph images are contained inside the `img` folder which must be placed in the same folder as the `panghiero` program.)

## Limitations
Currently, character grouping is quite limited: you can have at most two rows, and only one of these rows may have a horizontal group, which can consist of no more than two items. I.e., you can have `r:n`, but not `r:n:f`; `p*t:N1` is possible, as well as `N16:N23*Z1`; but `N16:N23*Z1:f` is out of the question.

Also, the grouping algorithm is still quite crude, and sometimes doesn't give very good results, especially with horizontal grouping. It certainly needs a lot of improvement. 

## Conclusion
This is a very basic tool, which started as a weekend idea for a LaTeX extension using PGF/TikZ. It was promising, but quite limited, and didn't work for creating ebooks. It then turned into a `.php` script which grew into a larger project until I decided to "transfer" it to `lazarus`. 

This is an amateur project, intended to be a simple tool for simple use cases. 

If you want or need a **real** editor for Egyptian hieroglyphic texts, you'd better have a look at the amazingly wonderful, wonderfully amazing [JSesh](https://jsesh.qenherkhopeshef.org/), which is an essential tool for anyone studying or working with Egyptian hieroglyphs.


