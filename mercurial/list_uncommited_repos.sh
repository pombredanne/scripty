#!/usr/bin/env bash

for dir in /scripts/*/.hg /projects/*/.hg
do
    repo=`dirname $dir`
    st=`hg status -R $repo`

    if [ "$st" != "" ]
    then
        echo "----------------------------------------------------------"
        echo "Repo - $repo"
        hg st -R $repo
    fi
done
