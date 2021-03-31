#!/bin/bash

# Convert Week Number to date
#
#  ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ ./week_nr_to_date.sh 1 2021
#  "Mo Jan 04 2021" - "So Jan 10 2021"
#  ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ ./week_nr_to_date.sh 13 2021
#  "Mo Mär 29 2021" - "So Apr 04 2021"
#  ofenloch@teben:~/workspaces/COVID19/rki-data-evaluation$ 
#

# I found this on stackoverflow: https://stackoverflow.com/questions/15606567/unix-date-how-to-convert-week-number-date-w-to-a-date-range-mon-sun

function weekof()
{
    local week=${1} year=${2}
    local week_num_of_Jan_1 week_day_of_Jan_1
    local first_Mon
    local date_fmt="+%a %b %d %Y" // something like "So Apr 04 2021"
    local date_fmt="+%Y-%m-%d" // something like "2021-08-29"
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
    echo "\"${mon}\" - \"${sun}\""
}
if [ "$#" -ne 2 ]; then
    echo "Usage:"
    echo "  ${0} WeekNumber Year"
    echo "Example:"
    echo "  ${0} 12 2021"
    echo "  $(weekof 12 2021)"
    exit 1
fi

weekof ${1} ${2}