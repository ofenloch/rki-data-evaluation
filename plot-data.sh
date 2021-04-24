#!/bin/bash

#
# use sed to format the data file
#
sed -f ./sed-cases ./rki-data/RKI-Fallzahlen_Kum_Tab-csv/Fälle-Todesfälle-gesamt.csv > ./my-data/data-cases.csv
sed -f ./sed-nowcasting ./rki-data/RKI-Nowcasting_Zahlen-csv/Nowcast_R.csv > ./my-data/data-nowcasting.csv
# we would do this:
#   sed -f ./sed-tests ./rki-data/RKI-Testzahlen-gesamt-csv/1_Testzahlerfassung.csv > ./my-data/data-tests.csv
# but we have to convert the weeknr/year to proper date ranges for plotting (e.g. "50 2020" to  "2020-12-14;2020-12-20")
# so we read the file ./rki-data/RKI-Testzahlen-gesamt-csv/1_Testzahlerfassung.csv line by line and
# process each line and use the funtion iso_week_num_to_date() on the first coumn
# the result is file ./my-data/data-tests.csv.tmp which is then processed with sed


# The data about the PCR tests is only given per week. I assume, RKI uses ISO week numbers for this information:
# * year 2020 ends with week number 53
# * year 2021 starts with week 01

# ISO week 53/2020 starts with Monday, 2020-12-28, and ends with Sunday, 2021-01-03.
# ISO week 01/2021 starts with Monday, 2021-01-04, and ends with Sunday, 2021-01-10.

# we use this function to convert weeknumber to date range
#  e.g. "43/2020" to "2020-10-26;2020-11-01"
function iso_week_num_to_date() {

    local week=${1} year=${2}
    local dow_jan_4
    local first_mon_in_year
    local date_fmt="+%a %b %d %Y" # something like "So Apr 04 2021"
    local date_fmt="+%Y-%m-%d" # something like "2021-08-29"
    local mon sun

    if ((week>53)) ; then 
        echo "maximal ISO week number is 53"
        exit 1
    fi
    if ((week<1)) ; then
        echo "minimal ISO week number is 1"
        exit 2
    fi
    #echo "${week}/${year}"
    # by definition, the 4th of January is in (ISO) week number 1
    # ISO conform: %u     day of week (1..7); 1 is Monday
    dow_jan_4=$(/usr/bin/date -d ${year}-01-04 +%u)
    if ((dow_jan_4==1)) ; then
        # Jan 4 is a Monday and this the first Monday in the year
        first_mon_in_year=${year}-01-04
        mon=$(/usr/bin/date -d "${first_mon_in_year} +$((week - 1)) week" "${date_fmt}")
        sun=$(/usr/bin/date -d "${first_mon_in_year} +$((week - 1)) week + 6 day" "${date_fmt}")
    else
        if ((dow_jan_4<4)) ; then
            # the first Monday is in this year
            first_mon_in_year=${year}-01-$((04 - dow_jan_4))
            mon=$(/usr/bin/date -d "${first_mon_in_year} +$((week - 1)) week" "${date_fmt}")
            sun=$(/usr/bin/date -d "${first_mon_in_year} +$((week - 1)) week + 6 day" "${date_fmt}")
        else
            # the first Monday is in the previous year
            first_mon_in_year=${year}-01-$((04 + 7 - dow_jan_4 + 1))
            mon=$(/usr/bin/date -d "${first_mon_in_year} +$((week - 2)) week" "${date_fmt}")
            sun=$(/usr/bin/date -d "${first_mon_in_year} +$((week - 2)) week + 6 day" "${date_fmt}")
        fi
    fi
    #echo "   first_mon_in_year is ${first_mon_in_year}   ( $(/usr/bin/date -d ${first_mon_in_year} +%a) )"
    echo "${mon};${sun}"
} # function iso_week_num_to_date() {

function format_test_data() {
    # delete the temporary file ./my-data/data-tests.csv.tmp:
    /bin/rm -f ./mydata/data-tests.csv.tmp
    # initialize the line counter:
    n=1
    # Set semicolon as the delimiter:
    delimiter=";"
    # read the file line by line and process eacj line:
    while read -r line; do 
        #echo "line ${n} is \"${line}\""
        echo -n "processing line ${n}:"
        n=$((n+1))
        # replace '*' e.g. "11/2021*;" by "11/2021;"
        line=${line/\*;/;}
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
        firstnew=$(iso_week_num_to_date ${weeknr} ${year})
        if [[ ${#first} > 5 ]] ; then
            # we should have a valid  week number and a valid date range
            echo -n "${firstnew};" >> ./my-data/data-tests.csv.tmp
        else
            # no valid week number
            echo -n ";;" >> ./my-data/data-tests.csv.tmp
        fi
        # simply append the original line
        echo "${line}" >> ./my-data/data-tests.csv.tmp
        # declare -p array
    done < ./rki-data/RKI-Testzahlen-gesamt-csv/1_Testzahlerfassung.csv
    sed -f ./sed-tests ./my-data/data-tests.csv.tmp > ./my-data/data-tests.csv
    /bin/rm -f ./my-data/data-tests.csv.tmp
} # function format_test_data() {


function format_clinical_data() {
    # delete the temporary file ./my-data/data-clinical.csv.tmp:
    /bin/rm -f ./my-data/data-clinical.csv.tmp
    # initialize the line counter:
    n=1
    # Set semicolon as the delimiter:
    delimiter=";"
    regexp_number='^[0-9]+$'
    # read the file line by line and process eacj line:
    while read -r line; do 
        #echo "line ${n} is \"${line}\""
        echo -n "processing line ${n}:"
        n=$((n+1))
        # replace '*' e.g. "11/2021*;" by "11/2021;"
        line=${line/\*;/;}
        # split the line at the delimiter
        s=${line}${delimiter}
        #echo "  s is \"${s}\""
        array=();
        while [[ $s ]]; do
            array+=( "${s%%"$delimiter"*}" );
            s=${s#*"$delimiter"};
        done;
        #echo "array[0] is \"${array[0]}\""
        year=${array[0]}
        weeknr=${array[1]}
        firstnew="Mon;Sun"
        echo "  weeknr = ${weeknr} ; year = ${year}"
        if [[ ${weeknr} =~ ${regexp_number} ]] ; then
            # we should have a valid  week number and a valid date range
            firstnew=$(iso_week_num_to_date ${weeknr} ${year})
        fi 
        echo -n "${firstnew};" >> ./my-data/data-clinical.csv.tmp
        # simply append the original line
        echo "${line}" >> ./my-data/data-clinical.csv.tmp
        # declare -p array
    done < ./rki-data/RKI-Klinische-Aspekte-csv/Klinische_Aspekte.csv
    sed -f ./sed-clinical ./my-data/data-clinical.csv.tmp > ./my-data/data-clinical.csv
    /bin/rm -f ./my-data/data-clinical.csv.tmp
} # function format_clinical_data() {


format_test_data

format_clinical_data

# The DIVI data comes in one file for all German states. So, we split it up:
for f in DEUTSCHLAND HAMBURG THUERINGEN SCHLESWIG_HOLSTEIN SACHSEN BADEN_WUERTTEMBERG SACHSEN_ANHALT BAYERN BERLIN MECKLENBURG_VORPOMMERN BREMEN NIEDERSACHSEN RHEINLAND_PFALZ SAARLAND NORDRHEIN_WESTFALEN HESSEN BRANDENBURG; do
    echo "creating DIVI data for ${f} ..."
    /bin/rm -f ./my-data/data-divi-${f}.csv.tmp
    /usr/bin/head -1 ./rki-data/bundesland-zeitreihe.csv > ./my-data/data-divi-${f}.csv.tmp
    /usr/bin/grep ${f} ./rki-data/bundesland-zeitreihe.csv >> ./my-data/data-divi-${f}.csv.tmp
    /usr/bin/sed -f ./sed-divi ./my-data/data-divi-${f}.csv.tmp > ./my-data/data-divi-${f}.csv
    /bin/rm -f ./my-data/data-divi-${f}.csv.tmp
done



#
# use gnuplot to plot some graphs
#
gnuplot plot-data.plt