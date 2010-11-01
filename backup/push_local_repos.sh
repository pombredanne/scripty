#!/usr/bin/env bash

for dir in ~/scripts/*/.hg /projects/*/.hg
do
    repo=`dirname $dir`
    echo hg push -R $repo
done
