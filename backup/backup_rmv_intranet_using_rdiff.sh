#!/usr/bin/env bash

#Enable/Disable Debugging
# set -x

db_dest=${HOME}/mysql_dumps
db_src=localhost
db_user=root
# db_pass is specified in .my.cnf

offpeak_hour=16
this_hour=`date +%H`
this_day_of_week=`date +%w`
this_day_of_month=`date +%d`

####### Take MySQL Backup #################
echo "`date` : Dumping DBs"
echo "select schema_name from schemata where schema_name != 'information_schema'" >query.sql
for db_name in `mysql -s -r -h ${db_src} -u ${db_user} information_schema <query.sql`
do
  mysqldump -h ${db_src} -u ${db_user} ${db_name} > ${db_dest}/${db_name}_${db_src}.sql
done
rm query.sql

############ Backup ####################
rdiff-backup /var/www/ /backup_rdiff/var_www
rdiff-backup /home/rmvadm /backup_rdiff/home_rmvadm

############ Delete Backups older than 30 days ####################
############ Will run once in a week           ####################

if [ ${this_hour} -eq ${offpeak_hour} ] && [ ${this_day_of_week} -eq 1 ]
then
  echo "`date` : Deleting Old Backups"
  rdiff-backup --remove-older-than 30D --force /backup_rdiff/var_www
  rdiff-backup --remove-older-than 30D --force /backup_rdiff/home_rmvadm
fi
