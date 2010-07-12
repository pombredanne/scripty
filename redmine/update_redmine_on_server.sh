#!/usr/bin/env bash

LOG="/var/log/`basename $0`.log"
this_dir=`dirname $0`

echo "-----------------------------------------------------------" >> $LOG
echo "`date` : Script started" >> $LOG

# Convert InnoDB to MyISAM.
# We disabed InnoDB on server to save some memory.
sed -i s/InnoDB/MyISAM/g /var/www/redmine/redmine_localhost.sql

mysql -uredmine -p${REDMINE_PASS} redmine < /var/www/redmine/redmine_localhost.sql
mysql -uredmine -p${REDMINE_PASS} redmine < ${this_dir}/redmine_settings.sql

cp /var/www/redmine/app/views/layouts/base_with_google_analytics.rhtml /var/www/redmine/app/views/layouts/base.rhtml
touch /var/www/redmine/tmp/restart.txt

echo "`date` : Script finished" >> $LOG
