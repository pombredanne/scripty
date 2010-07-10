#!/usr/bin/env bash

if [ $USER != root ]
then
  echo "Error: Require sudo privileges"
  exit 1
fi

/opt/nginx/sbin/nginx -s quit
/opt/nginx/sbin/nginx

urls=`find /var/www/cache -name \* | \
      xargs grep -h --binary-files=text "KEY:" | \
      sed -e 's/KEY: //' | \
      sort`

rm -rf /var/www/cache/*

for url in $urls
do
  wget -O - $url >/dev/null
done

/opt/nginx/sbin/nginx -s quit
/opt/nginx/sbin/nginx
