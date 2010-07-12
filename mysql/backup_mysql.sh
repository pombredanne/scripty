#!/usr/bin/env bash

#Enable/Disable Debugging
#set -x

LOG="/var/log/`basename $0`.log"
lock=${LOG}.lock

db_dest=${HOME}/mysql_dumps
db_src=localhost
db_user=root
# db_pass is specified in .my.cnf

backup_dest=${HOME}/backups/mysql_dumps

offpeak_hour=3
this_hour=`date +%H`
this_day_of_week=`date +%w`
this_day_of_month=`date +%d`

echo "" >> ${LOG}
echo "-----------------------------------------------------------------" >> ${LOG}
echo "`date` : Script Started" >> ${LOG}

####### Take MySQL Backup #################
echo "`date` : Dumping DBs" >> ${LOG}
echo "select schema_name from schemata where schema_name != 'information_schema'" >query.sql
for db_name in `mysql -s -r -h ${db_src} -u ${db_user} information_schema <query.sql`
do
  mysqldump -h ${db_src} -u ${db_user} ${db_name} > ${db_dest}/${db_name}_${db_src}.sql
done
rm query.sql

echo "`date` : Taking Backup" >> ${LOG}
rdiff-backup ${db_dest} ${backup_dest}

if [ ${this_hour} -eq ${offpeak_hour} ]
then
    echo "`date` : Deleting older Backups" >> ${LOG}
    #Remove backups older than 30days
    rdiff-backup --remove-older-than 30D --force ${backup_dest}
fi


echo "`date` : Script Finished" >> ${LOG}
echo "-----------------------------------------------------------------" >> ${LOG}
