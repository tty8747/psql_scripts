#!/bin/bash

set -e

source ./shared_func.sh

checkVar "$(getEnvVars)"
CheckDependences s-nail

for db in $(getDBnames)
  do
      if log="$(vacuumAnalize "$db")"
      then
        sendEmail "$(makeid $db)" "$log" "vacuum, analize" true
    else
        sendEmail "$(makeid $db)" "$log" "vacuum, analize" false
    fi
  done

unsetVar "$(getEnvVars)"
exit 0
