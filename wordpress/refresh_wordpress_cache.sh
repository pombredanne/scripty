#!/usr/bin/env bash

root=/var/www/vidyalaya_wordpress

sudo rm -rf $root/wp-content/cache/supercache/*

cd /tmp

wget --wait=2 --recursive --spider --force-html http://rmv.ac.in
