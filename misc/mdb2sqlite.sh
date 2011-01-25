#!/usr/bin/env bash
#set -x

if [ $# -ne 2 ]
then
  echo "Usage : $0 <mdb_file> <sqlite_db>"
  exit 1
fi

mdb_file=$1
sqlite_db=$2
csv_file=$2.tmp

touch $sqlite_db

if [ ! -w $sqlite_db ]
then
  echo "$sqlite_db is not writable. Aborting."
  exit 1
fi

# Delete the db if already exists
rm ${sqlite_db}

# Create schema
mdb-schema ${mdb_file} oracle | sed s/"DROP TABLE"/"DROP TABLE IF EXISTS"/g | sqlite3 ${sqlite_db}

for table in `mdb-tables ${mdb_file}`
do

echo Processing ${table}
mdb-export -Q -H -d "|||" ${mdb_file} ${table} >${csv_file}
    
sqlite3 ${sqlite_db} << _EOF_QUERY
.separator "|||"
.import ${csv_file} ${table}
_EOF_QUERY

done

rm ${csv_file}

