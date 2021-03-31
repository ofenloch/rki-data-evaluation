#
# Erzeuge Grafiken aus den Daten der CSV-Datei mit den RKI-DAten
#

# damit versteht Gnuplot deutschsprachige Datumsangaben
set locale 'de_DE.utf8'

#set decimalsign ',' # wirkt nur auf Ausgabe :-(
# damit erkennt Gnuplot 0,89 statt 0.89 auch beim Lesen der Daten
#set decimalsign locale

# erzeuge png-Dateien
set term png
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
set format x "%d.%m" # "06.08"

#set xrange ['Sa, 1. August 2020':'Sa, 10. Oktober 2020']
# set xrange ['"Sat, 1. August 2020"':]

datafile = 'data-cases.csv'

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







set output "./graph_cases_cumulative.png"
set title "Cases Cumulative"
plot datafile using 1:2 title "Cases"

set output "./grafik_cases_daily.png"
set title "Cases Daily"
plot avg7_sum = init7(0) \
     datafile using 1:4 title "Cases Daily" with lines lt 3 lw 1,\
     datafile using 1:(avg7($4)) title "7 day avg" with lines lt 7 lw 2


datafile = 'data-nowcasting.csv'

set output "./graph_r_4_days.png"
set title "R (4 Days)"
plot avg7_sum = init7(0) \
     datafile using 1:8 title "4 day R" ,\
     datafile using 1:(avg7($8)) title "7 day avg" with lines lt 7 lw 2

set output "./graph_r_7_days.png"
set title "R (7 Days)"
plot avg7_sum = init7(0) \
     datafile using 1:11 title "7 day R" ,\
     datafile using 1:(avg7($11)) title "7 day avg" with lines lt 7 lw 2


set output "./graph_tests.png"
set title "PCR Tests"
plot './data-tests.csv' using 2:4 title "Total Nr of Tests" with lines, \
     './data-tests.csv' using 2:5 title "Nr of Positive Tests" with lines