#!/usr/bin/env bash

DEST=/media/lan_server

LOG="/var/log/`basename $0`.log"

echo "`date` : Script Started" >> ${LOG}

export PASSWD=
smbmount //192.168.2.254/f\$/intranet_backup ${DEST} -o user=mca1 password=

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
rsync -avz --delete /backup ${DEST}

smbumount ${DEST}

echo "`date` : Script Finished" >> ${LOG}
echo "-----------------------------------------------------------------" >> ${LOG}
