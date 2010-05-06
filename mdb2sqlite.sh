#!/usr/bin/env bash
#set -x

if [ $# -ne 1 ]
then
  echo "Usage : $0 <mdb_file>"
  exit 1
fi

mdb_file=$1
sqlite_db=$1.sqlite
temp_file=$1.tmp

# Delete the db if already exists
rm ${sqlite_db}

# Create schema
mdb-schema ${mdb_file} oracle | sqlite3 ${sqlite_db}

for table in `mdb-tables ${mdb_file}`
do

echo Processing ${table}
mdb-export -Q -H -d "|||" ${mdb_file} ${table} >${temp_file}
    
sqlite3 ${sqlite_db} << _EOF_QUERY
.separator "|||"
.import ${temp_file} ${table}
_EOF_QUERY

done

rm ${temp_file}