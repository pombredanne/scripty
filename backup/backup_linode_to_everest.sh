#!/usr/bin/env bash

while read source
do
    rsync -az --delete $source everest:/backups_from_linode
done < /work/scripty/backup/dropbox_list.txt
