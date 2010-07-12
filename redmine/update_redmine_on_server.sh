#!/usr/bin/env bash

LOG="/var/log/`basename $0`.log"
this_dir=`dirname $0`

echo "-----------------------------------------------------------" >> $LOG
echo "`date` : Script started" >> $LOG

mysql -uredmine -p${REDMINE_PASS} redmine < /tmp/redmine.sql
mysql -uredmine -p${REDMINE_PASS} redmine < ${this_dir}/redmine_settings.sql

cp /var/www/redmine/app/views/layouts/base_with_google_analytics.rhtml /var/www/redmine/app/views/layouts/base.rhtml
touch /var/www/redmine/tmp/restart.txt 

echo "`date` : Script finished" >> $LOG 
