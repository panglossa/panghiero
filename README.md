# panghiero

![PangHiero Icon](https://github.com/panglossa/panghiero/blob/main/panghieroicon64.png) Generates Egyptian hieroglyphs (in png) from a source text in MdC format.

This is a very simple command line tool that converts source texts in MdC format to image files containing Egyptian hieroglyphic text.

Source files must: 
- be in MdC (Manuel de Codage) format;
- have the file extension `.hiero`
- be placed in the same folder as the program

For example, consider the sample file (`sample.hiero`). It contains the following text:

    
    w b n:N5 r:a N5 m p*t:N1


After you run `./panghiero`, the file `sample.png` is generated, containing the corresponding hieroglyphic text:

![Sample Hieroglyphic Text](https://github.com/panglossa/panghiero/blob/main/sample.png)

