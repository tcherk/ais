#!/bin/bash
latex ais2.tex && latex ais2.tex
dvips -f ais2.dvi -o ais2.ps -t a5 -O0in,3.2in
psbook -s20 ais2.ps 2.ps
psnup -2 -s1 -pa4 2.ps 3.ps
psnup -2 -s1 -pa4 ais2.ps 4.ps
rm {2,3,4}.ps
