#!/usr/bin/env bash

# This script automatically creates version.py and ChangeLog.txt files in the project root directory.
# version.py will contain the version id and last modified timestamp.
# ChangeLog.txt will contain list of all versions, timestamp and description of change.
# To use this script, put these two lines in .hg/hgrc file of the project repo
#
# [hooks]
# pre-commit.versioning = /work/scripty/mercurial/create_revision_file.sh


PROJECT_ROOT=`hg root`
REVISION_FILE=${PROJECT_ROOT}/__init__.py

if [[ `hg st | wc -l` -eq 0 ]]
then
    echo "Nothing to commit. Exiting"
    exit 1
fi

revision_number=`hg -q id -n | tr -d +`
let revision_number++

last_modified_timestamp=`date +"%F %T %Z"`

# Delete old data, if any
if [ -f ${REVISION_FILE} ]
then
    sed -i /^revision/d ${REVISION_FILE}
    sed -i /^last_modified_timestamp/d ${REVISION_FILE}

    echo "revision = '$revision_number'
last_modified_timestamp = '$last_modified_timestamp' " >> ${REVISION_FILE}
fi

hg log --template 'Revision {rev} \t {date|shortdate} \t {desc|firstline} \n' > ${PROJECT_ROOT}/CHANGELOG
