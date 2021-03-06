#!/bin/bash

# Convert ISO Week Number to date of corresponding Monday and Sunday
#
#  ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ ./week_nr_to_date.sh 1 2021
#  "Mo Jan 04 2021" - "So Jan 10 2021"
#  ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ ./week_nr_to_date.sh 13 2021
#  "Mo Mär 29 2021" - "So Apr 04 2021"
#  ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ 
#

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
    echo "${week}/${year}"
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
    echo "iso week ${week}/${year} : \"${mon}\" - \"${sun}\""
}

if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  ${0} WeekNumber Year"
    echo "Example:"
    echo "  ${0} 1 2020  -> $(iso_week_num_to_date 1 2020)"
    echo "  ${0} 52 2020 -> $(iso_week_num_to_date 52 2020)"
    echo "  ${0} 53 2020 -> $(iso_week_num_to_date 53 2020)"
    #echo "  ${0} 0 2021  -> $(iso_week_num_to_date 0 2021)"
    echo "  ${0} 1 2021  -> $(iso_week_num_to_date 1 2021)"
    exit 1
fi

#
# TODO: There seems to be an error! Maybe because 2020 was a leap year....
#
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ date --date="2020-12-31" +"%V"
# 53
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ date --date="2021-01-01" +"%V"
# 53
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ date --date="2021-01-02" +"%V"
# 53
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ date --date="2021-01-03" +"%V"
# 53
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ date --date="2021-01-04" +"%V"
# 01
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ 
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ ./week_nr_to_date.sh 51 2020
# "2020-12-21" - "2020-12-27"
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ ./week_nr_to_date.sh 52 2020
# "2020-12-28" - "2021-01-03"
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ ./week_nr_to_date.sh 53 2020
# "2021-01-04" - "2021-01-10"
# ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ 

# week52=$( iso_week_num_to_date 52 2020 )
# week53=$( iso_week_num_to_date 53 2020 )
# week0=$( iso_week_num_to_date 0 2021 )
# week1=$( iso_week_num_to_date 1 2021 )
# echo "DEBUG: iso_week_num_to_date 52 2020 ${week52}"
# echo "DEBUG: iso_week_num_to_date 53 2020 ${week53}"
# echo "DEBUG: iso_week_num_to_date 0 2021  ${week0}"
# echo "DEBUG: iso_week_num_to_date 1 2021  ${week1}"

# Wikipedia says (https://en.wikipedia.org/wiki/ISO_week_date)
#
#    The ISO week date system is effectively a leap week calendar system that is part of the ISO 8601 date 
#    and time standard issued by the International Organization for Standardization (ISO) since 1988 (last 
#    revised in 2019) and, before that, it was defined in ISO (R) 2015 since 1971. It is used (mainly) in 
#    government and business for fiscal years, as well as in timekeeping. This was previously known as 
#    "Industrial date coding". The system specifies a week year atop the Gregorian calendar by defining a 
#    notation for ordinal weeks of the year.
#
#   The Gregorian leap cycle, which has 97 leap days spread across 400 years, contains a whole number of 
#   weeks (20871). In every cycle there are 71 years with an additional 53rd week (corresponding to the 
#   Gregorian years that contain 53 Thursdays). An average year is exactly 52.1775 weeks long; months 
#   (​1⁄12 year) average at exactly 4.348125 weeks.
#
#   An ISO week-numbering year (also called ISO year informally) has 52 or 53 full weeks. That is 364 or 371 days 
#   instead of the usual 365 or 366 days. The extra week is sometimes referred to as a leap week, although 
#   ISO 8601 does not use this term.
#   Weeks start with Monday. Each week's year is the Gregorian year in which the Thursday falls. The first week 
#   of the year, hence, always contains 4 January. ISO week year numbering therefore usually deviates by 1 from 
#   the Gregorian for some days close to 1 January.
#
# According to this, the above outputs of 
#   date --date="2021-01-03" +"%V"  --> 53 (Sunday)
# and
#   date --date="2021-01-04" +"%V"  --> 01 (Monday)
# are correct.


# date's man page says:
#    %U     week number of year, with Sunday as first day of week (00..53)
#    %W     week number of year, with Monday as first day of week (00..53)
#    %V     ISO week number, with Monday as first day of week (01..53)
#    %u     day of week (1..7); 1 is Monday
#    %w     day of week (0..6); 0 is Sunday



iso_week_num_to_date ${1} ${2}