#!/usr/bin/env bash

REPOS="
scripty
vidyalaya-apps
vidyalaya-results
vidyalaya-config
vidyalaya-active-directory
pysis
"

REPOS_BACKUP_DIR=/tmp

for REPO in $REPOS
do

  REPO_DIR=$REPOS_BACKUP_DIR/$REPO

  if [ ! -d $REPO_DIR ]
  then
    hg clone http://bitbucket.org/dkmurthy/$REPO $REPO_DIR
  fi

  hg fetch -R $REPO_DIR http://bitbucket.org/dkmurthy/$REPO

  hg push -R $REPO_DIR https://${GOOGLECODE_USERNAME}:${GOOGLECODE_PASSWD}@${REPO}.googlecode.com/hg/

  # Sourceforge allows only 15 chars in project url
  REPO1=${REPO:0:15}
  hg push -R $REPO_DIR ssh://dkmurthy@${REPO1}.hg.sourceforge.net/hgroot/${REPO1}/${REPO1}

done
