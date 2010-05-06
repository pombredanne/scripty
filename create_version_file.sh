#!/usr/bin/env bash

PROJECT_ROOT=`hg root`

if [[ `hg st | wc -l` -eq 0 ]]
then
    echo "Nothing to commit. Exiting"
    exit 1
fi

version_id=`hg -q id -n | tr -d +`
let version_id++

echo version = "' $version_id '" > ${PROJECT_ROOT}/version.py
echo last_modified_timestamp = "' `date +"%F %T %Z"` '" >> ${PROJECT_ROOT}/version.py
