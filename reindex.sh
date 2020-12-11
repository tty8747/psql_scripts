#!/bin/bash

set -e

source ./shared_func.sh

checkVar "$(getEnvVars)"
CheckDependences s-nail

for db in $(getDBnames)
  do
      if log="$(reindex "$db")"
      then
        sendEmail "SUCCESS. $SERVNAME : $PROGNAME : $db" "$log"
    else
        sendEmail "FAIL. $SERVNAME : $PROGNAME : $db" "$log"
    fi
  done

unsetVar "$(getEnvVars)"
exit 0
