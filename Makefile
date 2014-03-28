NAME=ais2
# BIBROOT=$(PWD)/../..
#	BIBINPUTS=$(BIBROOT) latexmk -pdfps -dvi- -ps- $(NAME)

.PHONY: FORCE_MAKE clean view all emacs edit

all: $(NAME).pdf

%.ps: %.tex FORCE_MAKE
	BIBINPUTS=$(BIBROOT) latexmk -ps $(NAME)

%.pdf:%.ps
	BIBINPUTS=$(BIBROOT) latexmk -pdfps $(NAME)

clean:
	BIBINPUTS=$(BIBROOT) latexmk -C
	rm -f $(NAME).{bbl,aux,ps}

view: all
	evince $(NAME).pdf

edit: emacs

emacs:
	emacsclient -c $(NAME).tex --alternate-editor emacs  &
