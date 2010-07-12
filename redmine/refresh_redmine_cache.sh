#!/usr/bin/env bash

if [ $USER != root ]
then
  echo "Error: Require sudo privileges"
  exit 1
fi

service redmine restart

urls=`find /var/www/cache -name \* | \
      xargs grep --files-without-match --binary-files=text "Status: 404" | \
      xargs grep --no-filename --binary-files=text "KEY:" | \
      sed -e 's/KEY: //' | \
      sort | uniq | \
      tee /var/www/redmine_urls.txt`

rm -rf /var/www/cache/*

for url in $urls
do
  wget -q -O - $url >/dev/null
done

service redmine restart
