
# Makefile for njurepo

# Compiling method: latex/xelatex
METHOD = latexmk
LATEXMKOPTS = -xelatex -file-line-error -halt-on-error -interaction=nonstopmode

EXAMPLE= main
PACKAGE= njurepo
SOURCES= $(PACKAGE).ins $(PACKAGE).dtx
EXAMPLECONTENTS= $(EXAMPLE).tex mains/*.tex $(FIGURES)
FIGURES=$(wildcard figures/*.pdf)
BIBFILE=ref/*.bib
BSTFILE=*.bst
CLSFILES=dtx-style.sty $(PACKAGE).cls $(PACKAGE).cfg

# make deletion work on Windows
ifdef SystemRoot
	RM = del /Q
	OPEN = start
else
	RM = rm -f
	OPEN = open
endif

.PHONY: all clean distclean main doc cls texdoc viewmain FORCE_MAKE

all: doc main 

cls: $(CLSFILES)

$(CLSFILES): $(SOURCES)
	xelatex $(PACKAGE).ins

viewdoc: doc
	$(OPEN) $(PACKAGE).pdf

doc: $(PACKAGE).pdf

viewmain: main
	$(OPEN) $(EXAMPLE).pdf

main: $(EXAMPLE).pdf

ifeq ($(METHOD),latexmk)

$(PACKAGE).pdf: $(CLSFILES) $(EXAMPLE) FORCE_MAKE
	$(METHOD) $(LATEXMKOPTS) $(PACKAGE).dtx

$(EXAMPLE).pdf: $(CLSFILES) FORCE_MAKE
	$(METHOD) $(LATEXMKOPTS) $(EXAMPLE)

else ifneq (,$(filter $(METHOD),xelatex pdflatex))

$(PACKAGE).pdf: $(CLSFILES) $(EXAMPLE).tex
	$(METHOD) $(PACKAGE).dtx
	makeindex -s gind.ist -o $(PACKAGE).ind $(PACKAGE).idx
	makeindex -s gglo.ist -o $(PACKAGE).gls $(PACKAGE).glo
	$(METHOD) $(PACKAGE).dtx
	$(METHOD) $(PACKAGE).dtx

$(EXAMPLE).pdf: $(CLSFILES) $(THESISCONTENTS) $(EXAMPLE).bbl
	$(METHOD) $(EXAMPLE)
	$(METHOD) $(EXAMPLE)

$(EXAMPLE).bbl: $(BIBFILE) $(BSTFILE)
	$(METHOD) $(EXAMPLE)
	-bibtex $(EXAMPLE)
	$(RM) $(EXAMPLE).pdf

else
$(error Unknown METHOD: $(METHOD))

endif

clean:
	latexmk -c $(PACKAGE).dtx $(EXAMPLE) 
	-@$(RM) parts/*.aux
	-@$(RM) parts/examples/*.aux
	-@$(RM) *~

cleanall: clean
	-@$(RM) $(PACKAGE).pdf $(EXAMPLE).pdf 

distclean: cleanall
	-@$(RM) $(CLSFILES)
	-@$(RM) -r dist