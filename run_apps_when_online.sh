#!/usr/bin/env bash

#If internet connection is not detected, retry after 10 minutes
INTERVAL_BETWEEN_RETRIES=600

ping_command="host"

#This is used while testing
#set -x
#ping_command="echo"
#INTERVAL_BETWEEN_RETRIES=0


LOG="/var/log/`basename $0`.log"
tmp_dir=/tmp
apps_to_run=~/run_apps_when_online.txt

while true
#Infinite loop.
do

    ${ping_command} google.com > /dev/null
    if [  $? -eq 0 ];
    then
        #Internet connection is UP.
        #But better confirm.

        ${ping_command} yahoo.com > /dev/null
        if [  $? -eq 0 ];
        then
            #Now we are doubly sure that internet connection is up.
            #Go ahead.
            echo "`date` : Internet Connection is up. " >> ${LOG}

        while read app
        do
            #Don't run the app if running already
            if ! pgrep -f "${app}" >/dev/null 2>&1;
            then
                nohup ${app} >/dev/null 2>&1 &
            fi
        done < ${apps_to_run}

        exit 0

      fi

    else
    #Internet connection is DOWN. Sleep for sometime.
      sleep ${INTERVAL_BETWEEN_RETRIES}
    fi

done
