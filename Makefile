.PHONY: all main view book_ps main_book pdf view pdf_book clean

#PICS=pics/AnBase.eps pics/Chunk2.eps pics/Chunk.eps pics/logics_schema_1.eps \
#	pics/Parallel.eps pics/PST2.eps pics/PST.eps
TEXS=main.tex
# DVIPS_ARGS=-t a5 -O0in,3.2in
DVIPS_ARGS=-t a5

all: main book

main: main.pdf

main.pdf: main.ps
	epstopdf main.ps > main.pdf

main_book.pdf: main_book.ps
	epstopdf main_book.ps > main_book.pdf

main.ps: main.dvi $(PICS)
	dvips $(DVIPS_ARGS) -o main.ps main.dvi

main.dvi: $(TEXS)
	latex main.tex
	latex main.tex

view:	main.dvi
	evince main.dvi

pdf:	main.pdf
	evince main.pdf

pdf_book: main_book.pdf
	evince main_book.pdf

main_book.ps:main.ps
	psbook -s20 main.ps 2.ps
	psnup -2 -s1 -pa4 2.ps 3.ps
	psnup -2 -s1 -pa4 main.ps 4.ps
	mv 4.ps main_book.ps
	rm -f 2.ps 3.ps

clean:
	rm -f *.aux *.toc *.log *.pdf main.ps main_book.ps *.dvi _TZ* *.out *.run.xml *.bib

book:	main_book.pdf
