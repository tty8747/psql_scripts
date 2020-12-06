#!/bin/bash

set -e

source ./shared_func.sh

checkVar "$(getEnvVars)"
CheckDependences s-nail

for db in $(getDBnames)
  do
      if log="$(reindex "$db")"
      then
        sendEmail "$(makeid $db)" "$log" "reindex" true
    else
        sendEmail "$(makeid $db)" "$log" "reindex" false
    fi
  done

unsetVar "$(getEnvVars)"
exit 0
