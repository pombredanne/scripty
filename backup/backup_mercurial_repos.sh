#!/usr/bin/env bash

REPOS="
scripty
vidyalaya-apps
vidyalaya-results
vidyalaya-config
vidyalaya-active-directory
"

REPOS_BACKUP_DIR=~/repos_backup

for REPO in $REPOS
do

  if [ ! -d $REPOS_BACKUP_DIR/$REPO ]
  then
    hg clone http://bitbucket.org/dkmurthy/$REPO $REPOS_BACKUP_DIR/$REPO
  fi

  hg fetch -R $REPOS_BACKUP_DIR/$REPO http://bitbucket.org/dkmurthy/$REPO

  hg push -R $REPOS_BACKUP_DIR/$REPO https://${GOOGLECODE_USERNAME}:${GOOGLECODE_PASSWD}@${REPO}.googlecode.com/hg/

  # Sourceforge allows only 15 chars in project url
  REPO1=${REPO:0:15}
  hg push -R $REPOS_BACKUP_DIR/$REPO ssh://dkmurthy@${REPO1}.hg.sourceforge.net/hgroot/${REPO1}/${REPO1}

done
