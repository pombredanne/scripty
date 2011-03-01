#!/usr/bin/env bash

root=`hg root`

sudo rm -rf $root/wp-content/cache/supercache/*

cd /tmp

wget --wait=2 --recursive --spider --force-html http://rmv.ac.in
