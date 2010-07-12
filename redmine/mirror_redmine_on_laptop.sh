#!/usr/bin/env bash

source_dirs="
/var/www/redmine/
/var/www/svn/
/var/www/hg/
/var/www/project_docs/
"

if [ $HOSTNAME = rmv.ac.in ] || [ $HOSTNAME = rmv.lan ]
then
    echo "Error : You can not run this script from this machine."
    exit 1
fi

for f in ${source_dirs}
do
    echo "`date` : Syncing ${f} "
    rsync -az --delete --progress rmvadm@192.168.2.89:${f} ${f}
done

echo "`date` : Running update on local machine"
$HOME/scripts/scripty/redmine/update_redmine_on_server.sh
