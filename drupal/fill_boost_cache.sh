#!/usr/bin/env bash

rm -rf /var/www/drupal/cache/normal/rmv.ac.in/*

cd /tmp
rm hts-in_progress.lock

count=0

while [ $count -lt 50 ]
do
  httrack --quiet -p0 --sockets=1 --connection-per-second=0.5  -F "Mozilla" http://rmv.ac.in -*/events_calendar/* -*/just-ask/* -*feed* -*=*

  #wget -w 2 -r --spider --force-html -R "*/events_calendar/*, */just-ask/*, *feed*, *=*" http://rmv.ac.in

  count=`find /var/www/drupal/cache/normal/rmv.ac.in/ -name \*.gz | wc -l`
done
