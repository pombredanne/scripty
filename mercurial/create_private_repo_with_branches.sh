#!/usr/bin/env bash

TMP=/tmp
main_repo=$TMP/private_repo

rm -rf $main_repo
hg init $main_repo

touch $main_repo/main.txt
hg commit -A -m "Main Branch" -R $main_repo

counter=1
while [ $counter -lt 21 ]
do

    child_repo=$TMP/b${counter}

    hg clone $main_repo $child_repo

    hg branch b${counter} -R $child_repo

    touch $child_repo/b${counter}
    hg commit -A -m "New Branch b${counter}" -R $child_repo

    hg push -f -R $child_repo

    rm -rf $child_repo

    ((counter++))
done
