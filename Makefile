NAME=ais2
# BIBROOT=$(PWD)/../..

.PHONY: FORCE_MAKE

all: $(NAME).pdf

%.pdf: %.tex FORCE_MAKE
	BIBINPUTS=$(BIBROOT) latexmk -pdfps -dvi- -ps- $<

clean:
	BIBINPUTS=$(BIBROOT) latexmk -C
	rm -f $(NAME).{bbl,aux,ps)

view: all
	evince $(NAME).pdf
