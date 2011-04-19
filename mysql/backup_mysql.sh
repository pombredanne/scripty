#!/usr/bin/env bash

#Enable/Disable Debugging
#set -x

db_dest=${HOME}/mysql_dumps
db_src=localhost
db_user=root
# db_pass is specified in .my.cnf

backup_dest=${HOME}/backups/mysql_dumps

offpeak_hour=04
this_hour=`date +%H`

####### Take MySQL Backup #################
echo "`date` : Dumping DBs"

databases=`mysql \
            --silent \
            --raw \
            --host=${db_src} \
            --user=${db_user} \
            --execute="select schema_name from schemata where schema_name != 'information_schema'" \
            information_schema`

for database in ${databases}
do
    mysqldump \
        --order-by-primary \
        --skip-extended-insert \
        --host=${db_src} \
        --user=${db_user} \
        ${database} \
        > ${db_dest}/${database}.${HOSTNAME}.sql
done

echo "`date` : Taking Backup"
rdiff-backup ${db_dest} ${backup_dest}

if [ ${this_hour} -eq ${offpeak_hour} ]
then
    echo "`date` : Deleting older Backups"
    #Remove backups older than 30days
    rdiff-backup --remove-older-than 30D --force ${backup_dest}
fi
