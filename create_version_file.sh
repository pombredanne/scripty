#!/usr/bin/env bash

# This script automatically creates version.py and ChangeLog.txt files in the project root directory.
# version.py will contain the version id and last modified timestamp.
# ChangeLog.txt will contain list of all versions, timestamp and description of change.
# To use this script, put these two lines in .hg/hgrc file of the project repo
#
# [hooks]
# pre-commit.versioning = /path_to/create_version_file.sh


PROJECT_ROOT=`hg root`

if [[ `hg st | wc -l` -eq 0 ]]
then
    echo "Nothing to commit. Exiting"
    exit 1
fi

version_id=`hg -q id -n | tr -d +`
let version_id++

echo version = "'$version_id'" > ${PROJECT_ROOT}/version.py
echo last_modified_timestamp = "'`date +"%F %T %Z"`'" >> ${PROJECT_ROOT}/version.py

hg log --template 'Version {rev} \t {date|shortdate} \t {desc|firstline} \n' > ${PROJECT_ROOT}/CHANGELOG
