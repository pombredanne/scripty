#!/usr/bin/env bash

DEST=/media/lan_server/

export PASSWD=
smbmount //192.168.2.253/E\$/intranet_backup ${DEST} -o user=SERVERMCA/bca3 password=

if [ ! -d ${DEST}/backup ]
then
    echo "`date` : Unable to mount lan_server"
    exit 1
fi

############ Zip and Encrypt ####################
echo "`date` : Zipping"
# zip -r --quiet --encrypt --password ${PASSPHRASE} /backup/rmv_lan_intranet.zip /backup_rdiff
7za u -p${PASSPHRASE} -tzip /backup/rmv_lan_intranet.zip /backup_rdiff >/dev/null

############ Push to Server ####################
echo "`date` : Pushing to Server"
rsync -az /backup/rmv_lan_intranet.zip ${DEST}/backup/

smbumount ${DEST}
