#!/bin/bash

#
# use sed to format the data file
#
sed -f ./sed-command ./rki-data/RKI-Fallzahlen_Kum_Tab-csv/Fälle-Todesfälle-gesamt.csv > ./plot-data.csv

#
# use gnuplot to plot some graphs
#
gnuplot plot-data.plt