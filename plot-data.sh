#!/bin/bash

#
# use sed to format the data file
#
sed -f ./sed-cases ./rki-data/RKI-Fallzahlen_Kum_Tab-csv/Fälle-Todesfälle-gesamt.csv > ./data-cases.csv

#
# use gnuplot to plot some graphs
#
gnuplot plot-data.plt