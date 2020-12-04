#!/bin/bash

set -e

# export variables
source ./.env

function error_exit () {
  bash ./unsetvars.sh
  echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
  echo "Exit codes link: https://tldp.org/LDP/abs/html/exitcodes.html"
  exit 100
}

function checkVar () {
  if [ -n "$1" ]
    then
      return 0
  else
    error_exit "Error:$?, line: $LINENO. Variable doesn't set"
  fi
}

function getDBnames () {
  local DBLIST=$(/usr/bin/psql -l -t -U postgres |  /usr/bin/cut -d'|' -f1 | sed '/^ *$/d' | grep -v template* | grep -v postgres)
  if [ -n "$DBLIST" ]
    then
      echo $DBLIST
    else
    error_exit "Error:$?, line: $LINENO. There isn't databases."
  fi
}

function test () {
  echo "TEST"
}

bash ./unsetvars.sh
