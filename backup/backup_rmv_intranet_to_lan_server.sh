#!/usr/bin/env bash

DEST=/media/lan_server/

LOG="/var/log/`basename $0`.log"

echo "`date` : Script Started" >> ${LOG}

export PASSWD=
smbmount //192.168.2.253/E\$/intranet_backup ${DEST} -o user=SERVERMCA/bca3 password=

if [ ! -d ${DEST}/backup ]
then
    echo "`date` : Unable to mount lan_server" >> ${LOG}
    exit 1
fi

############ Zip and Encrypt ####################
echo "`date` : Zipping" >> ${LOG}
# zip -r --quiet --encrypt --password ${PASSPHRASE} /backup/rmv_lan_intranet.zip /backup_rdiff
7za u -p${PASSPHRASE} -tzip /backup/rmv_lan_intranet.zip /backup_rdiff

############ Push to Server ####################
echo "`date` : Pushing to Server" >> ${LOG}
rsync -avz --delete /backup/rmv_lan_intranet.zip ${DEST}/backup

smbumount ${DEST}

echo "`date` : Script Finished" >> ${LOG}
echo "-----------------------------------------------------------------" >> ${LOG}
