#!/usr/bin/gnuplot

set term qt persist
set xrange [6:20]
set yrange [0:1.2]
set grid

plot 'examples/03-raw1.dat' using 1:2 title 'Data' at .8, .1 with points pointtype 9 pointsize 2, 'examples/03-raw2.dat' using 1:2 title 'Cubic' at .8, .15 with lines linewidth 3, 'examples/03-raw2.dat' using 1:3 title 'Akima' at .8, .2 with lines linewidth 3, 'examples/03-raw2.dat' using 1:4 title 'Steffen' at .8, .25 with lines linewidth 3
