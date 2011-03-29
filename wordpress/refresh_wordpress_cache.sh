#!/usr/bin/env bash

root=$1

sudo rm -rf $root/wp-content/cache/supercache/*

cd /tmp

wget --wait=2 --recursive --spider --force-html $2
