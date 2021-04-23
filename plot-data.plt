#
# Erzeuge Grafiken aus den Daten der CSV-Datei mit den RKI-DAten
#

# erzeuge png-Dateien
#set term png

# erzeuge svg-Bilder
set terminal svg size 600,400 dynamic \
   enhanced font 'arial,10' \
   mousing name "array_1" butt dashlength 1.0 \
   jsdir "./js"

# damit versteht Gnuplot deutschsprachige Datumsangaben
set locale 'de_DE.utf8'

#set decimalsign ',' # wirkt nur auf Ausgabe :-(
# damit erkennt Gnuplot 0,89 statt 0.89 auch beim Lesen der Daten
#set decimalsign locale


#set key top left
set key outside below

# "deutsches" CSV mit Semikolon als Trenner
set datafile separator ";"


# Date Format	Explanation
# %a	abbreviated name of day of the week
# %A	full name of day of the week
# %b or %h	abbreviated name of the month
# %B	full name of the month
# %d	day of the month, 01–31
# %D	shorthand for %m/%d/%y (only output)
# %F	shorthand for %Y-%m-%d (only output)
# %k	hour, 0–23 (one or two digits)
# %H	hour, 00–23 (always two digits)
# %l	hour, 1–12 (one or two digits)
# %I	hour, 01–12 (always two digits)
# %j	day of the year, 1–366
# %m	month, 01–12
# %M	minute, 0–60
# %p	"am" or "pm"
# %r	shorthand for %I:%M:%S %p (only output)
# %R	shorthand for %H:%M (only output)
# %S	second, integer 0–60 on output, (double) on input
# %s	number of seconds since start of year 1970
# %T	shorthand for %H:%M:%S (only output)
# %U	week of the year (week starts on Sunday)
# %w	day of the week, 0–6 (Sunday = 0)
# %W	week of the year (week starts on Monday)
# %y	year, 0-99 in range 1969-2068
# %Y	year, 4-digit

set xdata time
#set timefmt "%a, %d. %B %Y"  # "Di, 10. März 2020"
set timefmt "%Y-%m-%d"  # "Di, 10. März 2020"
# set format x "%F"  # "2020-03-10"
set format x "%d.%m.%y" # "06.08.20"
set format x "%d.%m." # "06.08."

#set xrange ['Sa, 1. August 2020':'Sa, 10. Oktober 2020']
# set xrange ['"Sat, 1. August 2020"':]

# Define a function to calculate average over previous 3 points ($0 is the record index)
samples3(x) = $0 > 2 ? 3 : ($0+1)
avg3(x) = (shift3(x), (avg3_back1+avg3_back2+avg3_back3)/samples3($0))
shift3(x) = (avg3_back3 = avg3_back2, avg3_back2 = avg3_back1, avg3_back1 = x)
# Initialize a running sums
init3(x) = (avg3_back1 = avg3_back2 = avg3_back3 = avg3_sum = 0)

# Define a function to calculate average over previous 4 points ($0 is the record index)
samples4(x) = $0 > 3 ? 4 : ($0+1)
avg4(x) = (shift4(x), (avg4_back1+avg4_back2+avg4_back3+avg4_back4)/samples4($0))
shift4(x) = (avg4_back4 = avg4_back3, avg4_back3 = avg4_back2, avg4_back2 = avg4_back1, avg4_back1 = x)
# Initialize a running sums
init4(x) = (avg4_back1 = avg4_back2 = avg4_back3 = avg4_back4 = avg4_sum = 0)

# Define a function to calculate average over previous 5 points ($0 is the record index)
samples5(x) = $0 > 4 ? 5 : ($0+1)
avg5(x) = (shift5(x), (avg5_back1+avg5_back2+avg5_back3+avg5_back4+avg5_back5)/samples5($0))
shift5(x) = (avg5_back5 = avg5_back4, avg5_back4 = avg5_back3, avg5_back3 = avg5_back2, avg5_back2 = avg5_back1, avg5_back1 = x)
# Initialize a running sums
init5(x) = (avg5_back1 = avg5_back2 = avg5_back3 = avg5_back4 = avg5_back5 = avg5_sum = 0)


# more or less autogenerate avg7 functions (see moving_average.plt and https://stackoverflow.com/questions/42855285/plotting-average-curve-for-points-in-gnuplot)
samples7(x) = $0 > 6 ? 7 : ($0+1)
avg7(x) = (shift7(x), (avg7_back1+avg7_back2+avg7_back3+avg7_back4+avg7_back5+avg7_back6+avg7_back7)/samples7($0))
shift7(x) = (avg7_back7 = avg7_back6, avg7_back6 = avg7_back5, avg7_back5 = avg7_back4, avg7_back4 = avg7_back3, avg7_back3 = avg7_back2, avg7_back2 = avg7_back1, avg7_back1 = x)
init7(x) = (avg7_back7 = avg7_back6 = avg7_back5 = avg7_back4 = avg7_back3 = avg7_back2 = avg7_back1 = avg7_sum = 0)


# found this on stackoverflow https://stackoverflow.com/a/11902907
delta_v(x) = ( delta_vD = x - delta_old_v, delta_old_v = x, delta_vD )
delta_old_v = NaN
# do something like 
#  plot 'delta.dat' using 0:($1) title 'Values' with points, \
#       '' using 0:(delta_v($1)) title 'Delta' with linespoints


# Umrechnung absolut -> Inzidenz
# 83166711 Einwohner 2019-12-31 gemäß ./other-data/bevölkerungsstand_alter_de_2019_12_31.csv
# 20000 positive Tests entsprechen 20000/SCALE_INCIDENCE=24.048 positiven Tests pro 100000 Einwohner
SCALE_INCIDENCE=831.66711
# Umrechnung abolut -> Prozent der Bevölkerung
# 1% der Bevölkerung sind 831667.11 Personen
# 0.1% der Bevölkerung sind 83166.711 Personen
# 200000 positive Tests entsprechen  200000/SCALE_PERCENTAGE=0.24 % der Bevölkerung
SCALE_PERCENTAGE=831667.11




set output "./graph_cases_cumulative.svg"
set title "Cumulative Cases"
plot './data-cases.csv' using 1:2 title "Cumulative Cases" with lines lt 3 lw 1 , \
     './data-cases.csv' using 1:5 title "Cumulative Deaths" with lines lt 4 lw 1

set output "./graph_daily_cases.svg"
set title "Daily Cases"
plot avg7_sum = init7(0), \
     './data-cases.csv' using 1:4 title "Daily Cases" with lines lt 3 lw 1, \
     './data-cases.csv' using 1:(avg7($4)) title "Daily Cases (7 day avg)" with lines lt 7 lw 2

set output "./graph_daily_cases_vs_tests.svg"
set title "Daily Cases"
plot avg7_sum = init7(0), \
     './data-cases.csv' using 1:4 title "Daily Cases" with lines lt 3 lw 1, \
     './data-cases.csv' using 1:(avg7($4)) title "Daily Cases (7 day avg)" with lines lt 7 lw 2 ,\
     './data-tests.csv' using 2:($5/7) title "Daily Positive Tests (7 day avg)" with linespoints lt 0 lw 2
#     './data-tests.csv' using 2:($4/7) title "Daily Tests (7 day avg)" with linespoints lt 4, \
    


set output "./graph_r_4_days.svg"
set title "4 Day R"
plot avg7_sum = init7(0), \
     1 notitle lt -1 lw 1, \
     './data-nowcasting.csv' using 1:8 title "4 Day R" with lines lt 3 lw 1, \
     './data-nowcasting.csv' using 1:(avg7($8)) title "4 Day R (7 day avg)" with lines lt 7 lw 2

set output "./graph_r_7_days.svg"
set title "7 Day R"
plot avg7_sum = init7(0), \
     1 notitle lt -1 lw 1, \
     './data-nowcasting.csv' using 1:11 title "7 Day R" with lines lt 3 lw 1, \
     './data-nowcasting.csv' using 1:(avg7($11)) title "7 Day R (7 day avg)" with lines lt 7 lw 2


set style histogram cluster gap 1
set style fill solid border -1

set output "./graph_tests.svg"
set title "PCR Tests"
# not sure whether I should use boxes or linespoints
# plot './data-tests.csv' using 2:4 title "Total Nr of Tests Per Week" with boxes lt 3 , \
#     './data-tests.csv' using 2:5 title "Nr of Positive Tests Per Week" with boxes lt 7 

plot './data-tests.csv' using 2:4 title "Total Nr of Tests Per Week" with linespoints lt 3 , \
     './data-tests.csv' using 2:5 title "Nr of Positive Tests Per Week" with linespoints lt 7 


set output "./graph_tests_incidence.svg"
# 83166711 inhabitants at 2019-12-31 according to ./other-data/bevölkerungsstand_alter_de_2019_12_31.csv
set title "PCR Tests Per Week Per 100k (83.17 Mio Inhab)"
plot avg7_sum = init7(0), \
     './data-tests.csv' using 2:($4/SCALE_INCIDENCE) title "Tests / Week / 100k People " with linespoints lt 3 , \
     './data-tests.csv' using 2:($5/SCALE_INCIDENCE) title "Positive Tests / Week / 100k People" with linespoints lt 4, \
     './data-nowcasting.csv' using 1:(avg7($4)/SCALE_INCIDENCE*7) title "Daily Cases / 100k People (7 day avg)" with lines lt 7 lw 2

set output "./graph_tests_incidence_scaled.svg"
# 83166711 inhabitants at 2019-12-31 according to ./other-data/bevölkerungsstand_alter_de_2019_12_31.csv
set title "PCR Tests Per Week Per 100k (83.17 Mio Inhab)"
plot [][0:300]  avg7_sum = init7(0), \
     './data-tests.csv' using 2:($4/SCALE_INCIDENCE) title "Tests / Week / 100k People " with linespoints lt 3 , \
     './data-tests.csv' using 2:($5/SCALE_INCIDENCE) title "Positive Tests / Week / 100k People" with linespoints lt 4, \
     './data-nowcasting.csv' using 1:(avg7($4)/SCALE_INCIDENCE*7) title "Daily Cases / 100k People (7 day avg)" with lines lt 7 lw 2


set output "./graph_icu_load_DEUTSCHLAND.svg"
set title "ICU Load Germany"
plot './data-divi-DEUTSCHLAND.csv' using 1:6 title "Free ICU Beds" with lines lt 2 lw 2, \
     './data-divi-DEUTSCHLAND.csv' using 1:4 title "COVID-19 ICU Patients" with lines lt 7 lw 2, \
     './data-divi-DEUTSCHLAND.csv' using 1:5 title "All ICU Patients" with lines lt 3, \
     './data-divi-DEUTSCHLAND.csv' using 1:($5-$4) title "Non-COVID-19 ICU Patients" with lines lt 9, \
     './data-divi-DEUTSCHLAND.csv' using 1:($5+$6) title "All ICU Beds" with lines lt 4
     
set output "./graph_icu_load_BADEN_WUERTTEMBERG.svg"
set title "ICU Load Baden-Württemberg, Germany"
plot './data-divi-BADEN_WUERTTEMBERG.csv' using 1:6 title "Free ICU Beds" with lines lt 2 lw 2, \
     './data-divi-BADEN_WUERTTEMBERG.csv' using 1:4 title "COVID-19 ICU Patients" with lines lt 7 lw 2, \
     './data-divi-BADEN_WUERTTEMBERG.csv' using 1:5 title "All ICU Patients" with lines lt 3, \
     './data-divi-BADEN_WUERTTEMBERG.csv' using 1:($5-$4) title "Non-COVID-19 ICU Patients" with lines lt 9, \
     './data-divi-BADEN_WUERTTEMBERG.csv' using 1:($5+$6) title "All ICU Beds" with lines lt 4


set output "./graph_correlations.svg"
set title "Correlations"
# need to restrict plot to [0:] because daily deaths of 2020-08-02 is -7
plot [][0:] avg7_sum = init7(0), \
     './data-cases.csv' using 1:(avg7($4)) title "Daily Cases (7 day avg)" with lines lt 7 lw 2, \
     './data-divi-DEUTSCHLAND.csv' using 1:4 title "COVID-19 ICU Patients" with lines, \
     './data-cases.csv' using 1:6 title "Daily COVID-19 Deaths" with lines ,\
     './data-tests.csv' using 2:($5/7) title "Positive Tests (7 day avg)" with linespoints lt 4, \
     './data-clinical.csv' using 1:12 title "Hospitalized COVID-19 Patients" with linespoints lt 12



set output "./graph_clinical_data.svg"
set title "Clinical Data"
plot avg7_sum = init7(0), \
     0 notitle lt -1 lw 1, \
     './data-divi-DEUTSCHLAND.csv' using 1:(delta_v($4)) title 'COVID-19 ICU Admmissions' with lines, \
     './data-divi-DEUTSCHLAND.csv' using 1:4 title "COVID-19 ICU Patients" with lines, \
     './data-clinical.csv' using 1:12 title "Hospitalized COVID-19 Patients" with lines, \
     './data-cases.csv' using 1:6 title "Daily COVID-19 Deaths" with lines
     #, \
     #'./data-cases.csv' using 1:(avg7($6)) title "Daily COVID-19 Deaths (7 day avg)" with lines
     



set output './test.svg'
test