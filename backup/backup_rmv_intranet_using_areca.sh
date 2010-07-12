#!/usr/bin/env bash

#Enable/Disable Debugging
# set -x

log=${HOME}/scripts/logs/backup_rmv_intranet.log
lock=${log}.lock

db_dest=${HOME}/mysql_dumps
db_src=localhost
db_user=root
# db_pass is specified in .my.cnf

offpeak_hour=16
this_hour=`date +%H`
this_day_of_week=`date +%w`
this_day_of_month=`date +%d`




#backup_dest=hanjin.dreamhost.com
#backup_user=b599811
# backup_pass is not required. I already set up password-less login through authorized_keys

#Xms=20M
#Xmx=20M
areca_cl=${HOME}/scripts/areca/bin/areca_cl.sh
areca_config=${HOME}/scripts/rmv_intranet_areca_conf.xml
# areca_dump_dir should match with the destination specified in areca_config
areca_dump_dir=/backup

### End of Config ############################################################

cd ${HOME}

if [ -f ${lock} ]
then
  echo " `date` : ************************* Lock file found. Exiting ********************** " >> ${log}
  exit 1
fi
touch ${lock}

echo "" >> ${log}
echo "-----------------------------------------------------------------" >> ${log}
echo "`date` : Script Started" >> ${log}

####### Take MySQL Backup #################
echo "`date` : Dumping DBs" >> ${log}
echo "select schema_name from schemata where schema_name != 'information_schema'" >query.sql
for db_name in `mysql -s -r -h ${db_src} -u ${db_user} information_schema <query.sql`
do
  mysqldump -h ${db_src} -u ${db_user} ${db_name} > ${db_dest}/${db_name}_${db_src}.sql
done
rm query.sql

############ Backup ####################
echo "`date` : Taking Backup with Areca" >> ${log}
${areca_cl} backup -config ${areca_config} -target 1 

############ Delete Hourly Backups older than 7 days ####################
############ Will run once in a day                  ####################
if [ ${this_hour} -eq ${offpeak_hour} ]
then
  echo "`date` : Merging Hourly Backups" >> ${log}
  ${areca_cl} merge -config ${areca_config} -target 1 -from 8 -to 7
fi



############ Delete Daily Backups older than 30 days ####################
############ Will run once in a week                ####################

if [ ${this_hour} -eq ${offpeak_hour} ] && [ ${this_day_of_week} -eq 1 ]
then
  echo "`date` : Merging Daily Backups" >> ${log}
  ${areca_cl} merge -config ${areca_config} -target 1 -from 37 -to 30
fi

############ Delete Weekly Backups older than 180 days ####################
############ Will run once in a month                 ####################
if [ ${this_hour} -eq ${offpeak_hour} ] && [ ${this_day_of_month} -eq 1 ]
then
  echo "`date` : Merging Weekly Backups" >> ${log}
  ${areca_cl} merge -config ${areca_config} -target 1 -from 360 -to 180
fi

############ Delete All Backups older than 365 days ####################
############ Will run once in a month               ####################
if [ ${this_hour} -eq ${offpeak_hour} ] && [ ${this_day_of_month} -eq 1 ]
then
  echo "`date` : Merging Monthly Backups" >> ${log}
  ${areca_cl} merge -config ${areca_config} -target 1 -delay 365
fi



######## Now finally rsync to Backup server #################
#echo "`date` : Rsyncing to Backup Server" >> ${log}
#rsync -avz --del ${areca_dump_dir} ${backup_user}@${backup_dest}:~/backup_from_havana


rm -f ${lock}
echo "`date` : Script Finished" >> ${log}
echo "-----------------------------------------------------------------" >> ${log}

