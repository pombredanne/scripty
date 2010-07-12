#!/usr/bin/env bash

this_dir=`dirname $0`

# Convert InnoDB to MyISAM.
# We disabed InnoDB on server to save some memory.
sed -i s/InnoDB/MyISAM/g /var/www/redmine/redmine_localhost.sql

mysql -uredmine -p${REDMINE_PASS} redmine < /var/www/redmine/redmine_localhost.sql
mysql -uredmine -p${REDMINE_PASS} redmine < ${this_dir}/redmine_settings.sql

cp /var/www/redmine/app/views/layouts/base_with_google_analytics.rhtml /var/www/redmine/app/views/layouts/base.rhtml
touch /var/www/redmine/tmp/restart.txt
