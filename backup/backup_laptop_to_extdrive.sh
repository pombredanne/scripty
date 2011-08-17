#!/usr/bin/env bash

backup()
{
    src=$1
    dest=$2
    tmp=/tmp/`date +%s`

    password=`python -m vault get truecrypt backup`
    mkdir $tmp

    truecrypt --mount --password=$password $dest $tmp
    rsync -av --progress --delete $src/ $tmp/
    echo "Last backed up on `date`" > /$tmp/last_update.log
    truecrypt --dismount $dest
}

# Backup work
backup /work /backup/work_truecrypt

# Backup home
backup $HOME /backup/home_truecrypt

# Backup data
rsync -av --progress --delete /data/ /backup/data/

echo "Last backed up on `date`" > /backup/data/last_update.log
