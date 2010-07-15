#!/usr/bin/env bash

source_dirs="
/var/www/redmine/
/var/www/svn/
/var/www/hg/
/var/www/project_docs/
"

sudo network-config -ta Internet

>/var/www/redmine/log/production.log

hg commit -A -m "Auto-commit for batch job" -R /var/www/redmine
hg push -R /var/www/redmine

for f in ${source_dirs}
do
    echo "`date` : Syncing ${f} "
    rsync -az --delete ${f} ${MYSERVER}:${f}
done

echo "`date` : Running update on remote machine"
ssh ${MYSERVER} \$HOME/scripts/scripty/redmine/update_redmine_on_server.sh

sudo network-config -ta LAN
