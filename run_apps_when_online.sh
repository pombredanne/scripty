#!/usr/bin/env bash

apps_to_run=~/run_apps_when_online.txt

check_internet_connection()
{
    host google.com >/dev/null 2>&1
}

run_apps()
{
    while read app
    do
        #Don't run the app if running already
        if ! pgrep -f "${app}" >/dev/null 2>&1;
        then
            nohup ${app} >/dev/null 2>&1 &
        fi
    done < ${apps_to_run}
}


while true
do
    check_internet_connection && run_apps && exit 0
    sleep 600
done
