 #!/usr/bin/env bash

drupal_root=/var/www/drupal/
LOG="/var/log/`basename $0`.log"

exec >> $LOG 2>&1

cd ${drupal_root}

echo "`date` : Taking Database Backup"
drush sql-dump \
    --root=${drupal_root} \
    --result-file=dumps/drupal.rmv.ac.in.sql \
    --structure-tables-key=common \
    --ordered-dump

mysqldump -uroot --no-data --skip-dump-date drupal > ${drupal_root}/dumps/drupal_schema.rmv.ac.in.sql

hg commit -A -m 'Auto commit from nightly batch job' -R ${drupal_root}

echo "`date` : Pushing to Bitbucket"
hg push ssh://hg@bitbucket.org/dkmurthy/vidyalaya-drupal/ -R ${drupal_root}


# Version = $Revision$
# Last Modified on $Date$
# By $Author$
# $Source$

