#! /usr/bin/env python

''' This script uploads PDFs, Audio and Videos to www.archive.org
'''

import os
import shutil
from fnmatch import fnmatch
from subprocess import call

# Conf
bucket = "youth-convention-2009"
title = "Youth Convention"
date = "2009-12-04"
creator = "Ramakrishna Mission Vidyalaya"
website = "http://rmv.ac.in"
description = title + ' by ' + creator + \
              '. Website : <a href=' + website + '> ' + website + ' </a>'

# get these keys from http://www.archive.org/account/s3.php
access_key = os.environ['ARCHIVEORG_S3_ACCESS_KEY']
secret_key = os.environ['ARCHIVEORG_S3_SECRET_KEY']


def move(item):
    if not os.path.exists('processed/'):
        os.mkdir('processed')

    shutil.move(item, 'processed/')


def upload(item, mediatype, collection, keywords, url_suffix):
    print 'Processing ' + item

    cmd = []

    def add(key, value):
        cmd.append('--header')
        cmd.append(str(key) + ':' + str(value))

    #cmd.append('echo') # for testing
    cmd.append('curl')
    cmd.append('--location')

    add('x-archive-auto-make-bucket', 1)
    add('x-archive-ignore-preexisting-bucket', 1)
    add('authorization', ' LOW ' + access_key + ':' + secret_key)
    add('x-archive-meta-mediatype', mediatype)
    add('x-archive-meta-collection', collection)
    add('x-archive-meta-title', title)
    add('x-archive-meta-description', description)
    add('x-archive-meta-creator', creator)
    add('x-archive-meta-date', date)
    add('x-archive-meta-subject', keywords)
    add('x-archive-meta-licenseurl', 'http://creativecommons.org/licenses/by-nc/3.0/')

    cmd.append('--progress-bar')
    #cmd.append('--max-time')
    #cmd.append('3600')
    #cmd.append('--retry')
    #cmd.append('3')
    #cmd.append('--verbose')
    cmd.append('--output')
    cmd.append(item + '.log')
    cmd.append('--upload-file')
    cmd.append(item)
    cmd.append('http://s3.us.archive.org/' + bucket + url_suffix + '/' + item)

    try:
        call(cmd)
    except KeyboardInterrupt:
        # Sometimes curl is hanging even after uploading the item is 100% done.
        # In that case, I have to press ctrl+c to continue with next item.
        pass

    move(item)
    print 'Finished ' + item



def get_keywords(pattern, mediatype):
    kw = [title, mediatype, creator]
    items = os.listdir(os.curdir) + os.listdir('processed')
    for item in items:
        if fnmatch(item, pattern):
            cleaned_item = '.'.join(item.split('.')[0:-1])
            kw.append(cleaned_item)

    return '; '.join(kw).title()


def process(pattern, mediatype, collection, url_suffix=''):
    keywords = get_keywords(pattern, mediatype)
    for item in os.listdir(os.curdir):
        if fnmatch(item, pattern):
            upload(item, mediatype, collection, keywords, url_suffix)


def main():
    process('*.pdf', 'texts', 'opensource', '')
    process('*.mp3', 'audio', 'opensource_audio', '-audio')
    process('*.mp4', 'movies', 'opensource_movies', '-videos')


if __name__ == "__main__":
    import sys
    sys.exit(main())
