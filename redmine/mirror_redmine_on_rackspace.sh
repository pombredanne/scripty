#!/usr/bin/env bash

source_dirs="
/var/www/redmine/
/var/www/svn/
/var/www/hg/
/var/www/project_docs/
/tmp/redmine.sql
"

LOG="/var/log/`basename $0`.log"

echo "-----------------------------------------------------------" >> $LOG
echo "`date` : Script started" >> $LOG

sudo network-config -ta Internet

# Update repos
hg -R /var/www/hg/apps fetch
hg -R /var/www/hg/results fetch

# Refresh commit info
ruby /var/www/redmine/script/runner "Repository.fetch_changesets" -e production >/dev/null 2>&1


>/var/www/redmine/log/production.log
mysqldump -uroot redmine > /tmp/redmine.sql

for f in ${source_dirs}
do
    echo "`date` : Syncing ${f} " >> $LOG
    rsync -avz --delete --progress ${f} ${MYSERVER}:${f}
done
    
echo "`date` : Running update on remote machine" >> $LOG    
ssh ${MYSERVER} /home/rmvadmin/scripts/redmine_update.sh 

sudo network-config -ta LAN

echo "`date` : Script finished" >> $LOG 



