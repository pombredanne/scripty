#! /usr/bin/env bash

root="/var/www/vidyalaya_wordpress"
me=$USER
www="www-data"

cd $root

sudo chown -R ${me}:${www} ${root}
find ${root} -type d -exec chmod u=rwx,g=rx,o= {} \;
find ${root} -type f -exec chmod u=rw,g=r,o= {} \;

chmod -R ug=rwx,o= ${root}/wp-content/uploads/
chmod -R ug=rwx,o= ${root}/wp-content/cache/
chmod ug=rwx,o= ${root}/wp-content/*.php