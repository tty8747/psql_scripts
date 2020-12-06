#!/bin/bash

# export PGBIN=
# export PGDATABASE=
export PGHOST=$1
export PGPORT=$2
export PGUSER=$3
export PGPASSWORD=$4
export SMTPPASSWORD=$5
export BACKUP_ROOT=$6
export MAIL_SEND=$7
export MAIL_RECV=$8
export MAIL_SMTP=$9
export ORG=${10}
export progName=$(basename $0)

export RUNLOG=/tmp/$DB.log.$$.$RANDOM

# 1. year
# 2. month
# 3. week
# 4. day

function sendMessage() {
  local LOG=$1
  local MESSAGE=$2
  if cat $LOG | mailx -v -r "$MAIL_SEND" -s "$MESSAGE" -S smtp="$MAIL_SMTP:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$MAIL_SEND" -S smtp-auth-password="$SMTPPASSWORD" -S ssl-verify=ignore $MAIL_RECV > /dev/null 2>&1
    then 
      echo "Send file success"
  elif echo "$LOG" | mailx -v -r "$MAIL_SEND" -s "$MESSAGE" -S smtp="$MAIL_SMTP:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$MAIL_SEND" -S smtp-auth-password="$SMTPPASSWORD" -S ssl-verify=ignore $MAIL_RECV
    then
      echo "Send text success"
  else
    echo "Send error $?" 
  fi

---

if cat "ttt"
 then
   111
 elif echo "ttt"
   then
     222
 else
   333
fi 

---

 #  if [[ "$(echo $MESSAGE | cut -d " " -f2 )" -eq "Error" ]]
 #    then
 #      echo "$LOG" | mailx -v -r "$MAIL_SEND" -s "$MESSAGE" -S smtp="$MAIL_SMTP:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$MAIL_SEND" -S smtp-auth-password="$SMTPPASSWORD" -S ssl-verify=ignore $MAIL_RECV
 #  elif cat $LOG | mailx -v -r "$MAIL_SEND" -s "$MESSAGE" -S smtp="$MAIL_SMTP:587" -S smtp-use-starttls -S smtp-auth=login -S smtp-auth-user="$MAIL_SEND" -S smtp-auth-password="$SMTPPASSWORD" -S ssl-verify=ignore $MAIL_RECV
 #    then
 #      echo "Send success" > /dev/null
 #  else
 #    echo "Send error $?" 
 #  fi
}

function checkVar () {
  if [[ -n "$1" ]]
    then 
      return 0
  else
    echo -e "\nExample:\n \$ ssh-proxy.sh 11.22.33.44 8844 someuser\n"
    error_exit "Error! Line: $LINENO. Variable doesn't set"
  fi
}

function createBackupFolder() {
  local date=$1
  if [ "$date" -eq "5" ]
    then 
    BACKUP_DIR="$BACKUP_ROOT/weekly/$(date +%F)"
  else
    BACKUP_DIR="$BACKUP_ROOT/daily/$(date +%F)"
  fi
  if mkdir -p $BACKUP_DIR
    then return 0
  else
    return 77
  fi
}

function createBackup () {
  local fullpath=$1
  if time (/usr/bin/pg_dump --no-password --quote-all-identifiers --format=plain --dbname=postgresql://$PGUSER:$PGPASSWORD@$PGHOST/$DB | /bin/gzip -c > "$1") > $RUNLOG 2>&1
    then
      du -hsx "$1" >> $RUNLOG
      return 0
  else
    return 98
  fi
}


# main go

# sendMessage "Test text" "TEXT"
# sendMessage "Test file" "File"
# sendMessage "" ""

exit 0

# Making list of databases
# DB_LIST=`/usr/bin/psql -l -t -U $PGUSER |  /usr/bin/cut -d'|' -f1 | sed '/^ *$/d' | grep -v template* | grep -v postgres`
DB_LIST="gilev01 gilev02 gilev03"

if [[ -n "$DB_LIST" ]]
  then
    for DB in $DB_LIST
      do
        if createBackupFolder "$(date +%w)"
          then
            if createBackup "$BACKUP_DIR/$DB--`date +%F--%H-%M`.sql.gz"
              then
                sendMessage "$RUNLOG" "$ORG: $DB backup completed SUCCESSFULLY!"
                rm -f $RUNLOG
              else
                sendMessage "$RUNLOG" "$ORG: $DB Backup FAILED!"
                rm -f $RUNLOG
            fi
          else
            sendMessage "$ORG: Error! The folder wasn't created. Error $?" "Backup FAILED"
        fi
      done
  else
    sendMessage "$ORG: var DB_LIST isn't set. Error $?" "Backup FAILED"
fi

unset PGHOST
unset PGPORT
unset PGUSER
unset PGPASSWORD
unset SMTPPASSWORD
unset BACKUP_ROOT
unset MAIL_SEND
unset MAIL_RECV
unset MAIL_SMTP
unset ORG

exit 0

