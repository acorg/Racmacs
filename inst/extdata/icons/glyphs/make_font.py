
import fontforge
import os

# Generate the font
font = fontforge.font()
font.fontname   = "ViewerGlyphs"
font.fullname   = "Viewer Glyphs"
font.familyname = "Viewer Glyphs"

# Map the characters
glyph = font.createMappedChar('A')
folderpath = '/Users/samwilks/Desktop/LabBook/R-acmacs/Racmacs/inst/htmlwidgets/lib/styles/glyphs/'
svgpath = folderpath+"svg/"

svgfiles = os.listdir(svgpath)
for svg in svgfiles:
	if not svg.startswith('.'):
	    mappedChar = os.path.splitext(svg)[0]
	    glyph = font.createMappedChar(mappedChar)
	    glyph.importOutlines(svgpath+svg)
	    glyph.width = glyph.boundingBox()[2] + 50;

font.generate(folderpath+'glyphs.ttf')
font.generate(folderpath+'glyphs.woff')

