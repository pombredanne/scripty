#!/usr/bin/env bash

backup()
{
    src=$1
    dest=$2
    tmp=/tmp/`date +%s`

    password=`python -m vault get truecrypt backup`
    mkdir $tmp

    truecrypt --mount --password=$password $dest $tmp
    rsync -avz --progress --delete $src/ $tmp/
    truecrypt --dismount $dest
}

# Backup work
backup /work /backup/work_truecrypt

# Backup home
backup /home/ramana /backup/home_truecrypt

# Backup data
rsync -avz --progress --delete /data/ /backup/data/
