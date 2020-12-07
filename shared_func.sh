#!/bin/bash

set -e

# --- export variables

source ./.env

# --- help functions

function error_exit () {
  unsetVar "$(getEnvVars)"
  echo "${PROGNAME}: ${1:-"Unknown Error"}" 1>&2
  echo "Exit codes link: https://tldp.org/LDP/abs/html/exitcodes.html"
  exit 100
}

function getEnvVars () {
  echo "$(cat .env | grep -Ev "^$" | cut -d' ' -f2 | awk -F'=' '{ print $1}' | xargs echo)"
}

function getEnvVarsFull_dependsOn () {
  local vars=$*
  for i in $vars
    do
      echo "$i ~> $(getEnvVarValue $i)"
  done
}

function getEnvVarValue () {
  # desc: this function take somevar without '$' and return somevar value
  local var=$1
  echo "$(eval "echo $(eval "echo '$'$var")")"
}

function checkVar () {
  local vars=$*
  for i in $vars
    do
      if [ -z "$(getEnvVarValue $i)" ]
        then
          error_exit "Error:$?, line: $LINENO. Variable $i doesn't set"
      fi
    done
}

function unsetVar () {
  local vars=$*
  for i in $vars
    do
      unset $i
    done
}

function CheckDependences() {
  for i in "$@"
    do
      local j=$(which $i)
      [[ -n "$j" ]] || error_exit "Error:$?, line: $LINENO. $i - Command not found, please install it!"
    done
}

# --- main functions

function getDBnames () {
  local dblist=$(/usr/bin/psql -l -t -U postgres |  /usr/bin/cut -d'|' -f1 | sed '/^ *$/d' | grep -v template* | grep -v postgres)
  if [ -n "$dblist" ]
    then
      echo $dblist
    else
    error_exit "Error:$?, line: $LINENO. There isn't databases."
  fi
}

function reindex () {
  local db=$1
  local logfile=$db.log.$$.$RANDOM
  echo "$(date "+%F ::: %T")" > /tmp/$logfile
  if time (/usr/bin/psql -t -U postgres --dbname $db --command "REINDEX DATABASE \"$db\";") >> /tmp/$logfile 2>&1
  then
      echo "$(cat /tmp/$logfile)"
      rm -f /tmp/$logfile
      return 0
  else
      echo "$(cat /tmp/$logfile)"
      rm -f /tmp/$logfile
      return 120
  fi
}

function makeid () {
  local db=$1
  echo "$SERVNAME, DB: $db"
}

function sendEmail () {
  local id=$1
  local body=$2
  local event=$3
  local result=$4

  if $result
    then
      echo "$body" | s-nail -d -v -r "$GMAILUSER" -s "$id. $event is completed SUCCESSFULLY" -S smtp="smtp.gmail.com:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$GMAILUSER" -S smtp-auth-password="$GMAILPASSWORD" -S ssl-verify=ignore $MAILDEST
    else
      echo "$body" | s-nail -d -v -r "$GMAILUSER" -s "$id. $event is FAILED" -S smtp="smtp.gmail.com:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$GMAILUSER" -S smtp-auth-password="$GMAILPASSWORD" -S ssl-verify=ignore $MAILDEST
  fi
}
