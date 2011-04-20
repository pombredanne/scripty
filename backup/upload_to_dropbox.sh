#!/usr/bin/env bash

while read source
do
    size=`sudo du -s $source |awk '{print $1}'`
    if [[ -d "$source" && $size -lt 500000 ]]
    then
        echo Syncing $source
        sudo rsync -az --delete $source /etc/dropbox/Dropbox/${source////_}/
    else
        echo Not processing $source
    fi
done < /work/scripty/backup/dropbox_list.txt

sudo su -l dropbox -s /bin/bash -c "python /etc/dropbox/bin/dropbox.py start"

sleep 1800

sudo su -l dropbox -s /bin/bash -c "python /etc/dropbox/bin/dropbox.py stop"
