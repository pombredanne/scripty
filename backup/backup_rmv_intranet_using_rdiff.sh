#!/usr/bin/env bash

#Enable/Disable Debugging
# set -x

offpeak_hour=16
this_hour=`date +%H`
this_day_of_week=`date +%w`
this_day_of_month=`date +%d`

############ Backup ####################
rdiff-backup /var/www/ /backup_rdiff/var_www
rdiff-backup --exclude **Trash /home/rmvadm /backup_rdiff/home_rmvadm

############ Delete Backups older than 30 days ####################
############ Will run once in a week           ####################

if [ ${this_hour} -eq ${offpeak_hour} ] && [ ${this_day_of_week} -eq 1 ]
then
  echo "`date` : Deleting Old Backups"
  rdiff-backup --remove-older-than 30D --force /backup_rdiff/var_www
  rdiff-backup --remove-older-than 30D --force /backup_rdiff/home_rmvadm
fi
