#!/bin/bash

#
# use sed to format the data file
#
sed -f ./sed-cases ./rki-data/RKI-Fallzahlen_Kum_Tab-csv/Fälle-Todesfälle-gesamt.csv > ./data-cases.csv
sed -f ./sed-nowcasting ./rki-data/RKI-Nowcasting_Zahlen-csv/Nowcast_R.csv > ./data-nowcasting.csv
# we would do this:
#   sed -f ./sed-tests ./rki-data/RKI-Testzahlen-gesamt-csv/1_Testzahlerfassung.csv > ./data-tests.csv
# but we have to convert the weeknr/year to proper date ranges for plotting (e.g. "50 2020" to  "2020-12-14;2020-12-20")
# so we read the file ./rki-data/RKI-Testzahlen-gesamt-csv/1_Testzahlerfassung.csv line by line and
# process each line and use the funtion weekof() on the first coumn
# the result is file ./data-tests.csv.tmp which is then processed with sed


# The DIVI data comes in one file for all German states. So, we split it up:
for f in DEUTSCHLAND HAMBURG THUERINGEN SCHLESWIG_HOLSTEIN SACHSEN BADEN_WUERTTEMBERG SACHSEN_ANHALT BAYERN BERLIN MECKLENBURG_VORPOMMERN BREMEN NIEDERSACHSEN RHEINLAND_PFALZ SAARLAND NORDRHEIN_WESTFALEN HESSEN BRANDENBURG; do
    echo "creating DIVI data for ${f} ..."
    /bin/rm -f ./data-divi-${f}.csv.tmp
    /usr/bin/head -1 rki-data/bundesland-zeitreihe.csv > ./data-divi-${f}.csv.tmp
    /usr/bin/grep ${f} rki-data/bundesland-zeitreihe.csv >> ./data-divi-${f}.csv.tmp
    /usr/bin/sed -f ./sed-divi ./data-divi-${f}.csv.tmp > ./data-divi-${f}.csv
    /bin/rm -f ./data-divi-${f}.csv.tmp
done

# we use this function to convert weeknumber to date range
#  e.g. "43/2020" to "2020-10-26;2020-11-01"
function weekof()
{
    local week=${1} year=${2}
    local week_num_of_Jan_1 week_day_of_Jan_1
    local first_Mon
    local date_fmt="+%Y-%m-%d" # something like "2021-08-29"
    local mon sun

    week_num_of_Jan_1=$(/usr/bin/date -d ${year}-01-01 +%W)
    week_day_of_Jan_1=$(/usr/bin/date -d ${year}-01-01 +%u)

    if ((week_num_of_Jan_1)); then
        first_Mon=${year}-01-01
    else
        first_Mon=${year}-01-$((01 + (7 - week_day_of_Jan_1 + 1) ))
    fi

    mon=$(/usr/bin/date -d "${first_Mon} +$((week - 1)) week" "${date_fmt}")
    sun=$(/usr/bin/date -d "${first_Mon} +$((week - 1)) week + 6 day" "${date_fmt}")
    echo "${mon};${sun}"
}

# delete the temporary file
/bin/rm -f ./data-tests.csv.tmp

# initialize the line counter
n=1

# Set semicolon as the delimiter
delimiter=";"

# read the file line by line
while read -r line; do 
    #echo "line ${n} is \"${line}\""
    echo -n "processing line ${n}:"
    n=$((n+1))
    # split the line at the delimiter
    s=${line}${delimiter}
    #echo "  s is \"${s}\""
    array=();
    while [[ $s ]]; do
        array+=( "${s%%"$delimiter"*}" );
        s=${s#*"$delimiter"};
    done;
    #echo "array[0] is \"${array[0]}\""
    first=${array[0]}
    weeknr=1
    year=2022
    if [[ ${#first} == 7 ]] ; then
        # we have something like "43/2020"
        weeknr=${first:0:2}
        year=${first:3:5}
    fi
    if [[ ${#first} == 6 ]] ; then
        # we have something like "3/2021"
        weeknr=${first:0:1}
        year=${first:2:5}
    fi
    echo "  weeknr = ${weeknr} ; year = ${year}"
    firstnew=$(weekof ${weeknr} ${year})
    if [[ ${#first} > 5 ]] ; then
        # we should have a valid  week number and a valid date range
        echo -n "${firstnew};" >> ./data-tests.csv.tmp
    else
        # no valid week number
        echo -n ";;" >> ./data-tests.csv.tmp
    fi
    # simply append the original line
    echo "${line}" >> ./data-tests.csv.tmp
    # declare -p array
done < ./rki-data/RKI-Testzahlen-gesamt-csv/1_Testzahlerfassung.csv

sed -f ./sed-tests ./data-tests.csv.tmp > ./data-tests.csv
/bin/rm -f ./data-tests.csv.tmp

#
# use gnuplot to plot some graphs
#
gnuplot plot-data.plt