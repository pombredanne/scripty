#/usr/bin/env bash

if [ $# -ne 1 ]
then
  echo "Usage : $0 <dbname>"
  exit 1
fi

user_id=$1
passwd=$1
db_name=$1


mysql -u root <<_EOF_
CREATE DATABASE ${db_name};
GRANT ALL PRIVILEGES ON ${db_name}.*
       TO '${user_id}'@'localhost'
       IDENTIFIED BY '${passwd}'
       WITH GRANT OPTION;

_EOF_

if [ $? -eq 0 ]
then
  echo "Successfully created ${db_name}"
else
  echo "ERROR. Please check mysql logs"
fi

