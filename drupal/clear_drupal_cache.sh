#!/usr/bin/env bash

cd /var/www/drupal

drush -y cache-clear

rm -rf cache/normal/rmv.ac.in/*
