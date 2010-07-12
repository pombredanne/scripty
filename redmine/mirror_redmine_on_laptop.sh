#!/usr/bin/env bash

source_dirs="
/var/www/redmine/
/var/www/svn/
/var/www/hg/
/var/www/project_docs/
"

LOG="/var/log/`basename $0`.log"

if [ $HOSTNAME = rmv.ac.in ] || [ $HOSTNAME = rmv.lan ]
then
    echo "Error : You can not run this script from this machine."
    exit 1
fi

echo "-----------------------------------------------------------" >> $LOG
echo "`date` : Script started" >> $LOG

for f in ${source_dirs}
do
    echo "`date` : Syncing ${f} " >> $LOG
    rsync -avz --delete --progress rmvadm@192.168.2.89:${f} ${f}
done

echo "`date` : Running update on local machine" >> $LOG
$HOME/scripts/scripty/redmine/update_redmine_on_server.sh

echo "`date` : Script finished" >> $LOG



