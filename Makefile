NAME=ais
MNAME=ais2
# BIBROOT=$(PWD)/../..
#	BIBINPUTS=$(BIBROOT) latexmk -pdfps -dvi- -ps- $(NAME)

.PHONY: FORCE_MAKE clean view all emacs edit

all: $(NAME).pdf

%.pdf: %.tex FORCE_MAKE
	BIBINPUTS=$(BIBROOT) latexmk -pdf -e '$$pdflatex=q/lualatex --synctex=1 %O %S/' $(MNAME)

clean:
	BIBINPUTS=$(BIBROOT) latexmk -C
	rm -f $(NAME).{bbl,aux,ps} $(MNAME).{bbl,aux,ps}

view: all
	evince $(NAME).pdf

edit: emacs

emacs:
	emacsclient -c $(NAME).tex --alternate-editor emacs  &

$(NAME).pdf: $(MNAME).pdf cover.jpg
	pdfjoin -o $(NAME).pdf -- $(MNAME).pdf cover.jpg
