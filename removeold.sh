#!/bin/bash

set -e

export PROGNAME="$(basename "$0")"
export THEMONTH="$(date +%m -d "1 month ago")"
# export THEMONTH=$(date +%m -d "2 months ago")
export THEYEAR="$(date +%Y)"
export BACKUP_FOLDER="$1"

function delOldBackups () {
  local bdate=$1
  local edate=$2
  # find $BACKUP_FOLDER -newermt "$bdate" ! -newermt "$edate" -type d -exec ls -lh {} \;
  find "$BACKUP_FOLDER" -newermt "$bdate" ! -newermt "$edate" -type d -exec rm -vrf {} \;
}

function error_exit () {
  echo "$PROGNAME: ${1:-"Unknown Error"}" 1>&2
  return 100
  exit 100
}

function checkVar () {
  if [[ -n "$1" ]]
    then 
      return 0
  else
    error_exit "Error! Line: $LINENO. Variable doesn't set"
  fi
}

#main go

checkVar "$BACKUP_FOLDER"


for YEAR in "$(seq 2020 "$THEYEAR")"
  do
    for MONTH in "$(seq 1 "$THEMONTH")"
      do
        case $MONTH in
          1|3|5|7|8|10|12)
            for DAY in {1..31}
              do
                if [[ $DAY -eq 1 ]] || [[ $DAY -eq 15 ]]
                  then
                    echo "It's the first or fifteenth day of the month. DAY=$DAY" > /dev/null
                else
                  if delOldBackups "$(date +%F -d "$YEAR/$MONTH/$DAY")" "$(date +%F -d "$YEAR/$MONTH/$DAY +1 day")"
                    then 
                      echo "Delete was success" > /dev/null
                  else
                    echo "$?"
                    exit 4
                  fi
                fi
              done
            ;;
          2)
            FEBRDAYS=$(date -d  "$(date +"$YEAR"'/02/01')+1month -1day" +%d)
            echo "February has $FEBRDAYS days." > /dev/null
            for DAY in "$(seq 1 "$FEBRDAYS")"
              do
                if [[ $DAY -eq 1 ]] || [[ $DAY -eq 15 ]]
                  then
                    echo "It's the first or fifteenth day of the month. DAY=$DAY" > /dev/null
                else
                  if delOldBackups "$(date +%F -d "$YEAR/$MONTH/$DAY")" "$(date +%F -d "$YEAR/$MONTH/$DAY +1 day")"
                    then 
                      echo "Delete was success" > /dev/null
                  else
                    echo "$?"
                    exit 5
                  fi
                fi
              done
            ;;
          4|6|9|11)
            for DAY in {1..30}
              do
                if [[ $DAY -eq 1 ]] || [[ $DAY -eq 15 ]]
                  then
                    echo "It's the first or fifteenth day of the month. DAY=$DAY" > /dev/null
                else
                  if delOldBackups "$(date +%F -d "$YEAR/$MONTH/$DAY")" "$(date +%F -d "$YEAR/$MONTH/$DAY +1 day")"
                    then 
                      echo "Delete was success" > /dev/null
                  else
                    echo "$?"
                    exit 6
                  fi
                fi
              done
            ;;
        esac
      done
  done

exit 0
