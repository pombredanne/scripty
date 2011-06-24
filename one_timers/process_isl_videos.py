#!/usr/bin/env python

import os
import sqlite3
import subprocess

from path import path
import pyblog
from logbook import debug, error


db = "/work/tmp/isl_videos.sqlite"
videos_dir = "/home/ram/Desktop/Physics"
parent_category = 'Physics Dictionary'
isl_wp_url = 'http://indiansignlanguage.org/xmlrpc.php'

isl_yt_username = os.environ['ISL_YT_USERNAME']
isl_yt_password = os.environ['ISL_YT_PASSWORD']
isl_wp_username = os.environ['ISL_WP_USERNAME']
isl_wp_password = os.environ['ISL_WP_PASSWORD']


def run_query(query):
    conn = sqlite3.connect(db, timeout=300)
    conn.execute(query)
    conn.commit()
    conn.close()


def select_query(query):
    conn = sqlite3.connect(db, timeout=300)
    cursor = conn.cursor()
    data = list(cursor.execute(query))
    conn.close()
    return data


def create_db():
    run_query("create table if not exists \
               isl(id integer primary key autoincrement not null, \
                   title, category, file, youtube_url, wordpress_id)")
    run_query("create unique index if not exists \
               isl_tc on isl (title asc, category asc)")


def put_files_in_db():
    debug("Scanning " + videos_dir)
    p = path(videos_dir)

    for file in p.walkfiles('*.flv'):
        title = file.namebase.title()
        category = file.parent.namebase.title()

        run_query("insert or ignore into isl(title, category, file) \
                   values('%s', '%s', '%s')" % (title, category, file))


def upload_to_youtube(id, title, category, file):
    debug("Uploading " + title + " to youtube")

    command = ["youtube-upload"]
    command.append("--email=" + isl_yt_username)
    command.append("--password=" + isl_yt_password)
    command.append("--title=" + title)
    command.append("--description=" + title +
                   " in Indian Sign Language (category = " + category +
                   "). For more words, visit http://indiansignlanguage.org")
    command.append("--category=Education")
    command.append("--keywords=isl, indian sign language, dictionary, deaf")
    command.append(file)

    p = subprocess.Popen(command, stdout=subprocess.PIPE)
    (youtube_url, stderr) = p.communicate()

    if stderr:
        error(stderr)

    run_query("update isl set youtube_url='%s' where id=%s" % (youtube_url, id))

    return youtube_url


def create_wordpress_post(id, title, category, youtube_id):
    debug("Posting " + title + " to wordpress")

    blog = pyblog.WordPress(isl_wp_url, isl_wp_username, isl_wp_password)
    parent = blog.new_category({'name':parent_category})
    blog.new_category({'name':category, 'parent_id':parent})

    wp_id = blog.new_post({ 'title' : title,
                            'description' : '[youtube]' + youtube_id + '[/youtube]',
                            'categories' : ( category, ) })

    run_query("update isl set wordpress_id=%s where id=%s" % (wp_id, id))



def process():
    data = select_query("select id, title, category, file, youtube_url, wordpress_id \
                         from isl")
    for id, title, category, file, youtube_url, wordpress_id in data:
        if not youtube_url:
            youtube_url = upload_to_youtube(id, title, category, file)

        youtube_url = youtube_url.strip()
        youtube_id = youtube_url.replace('http://www.youtube.com/watch?v=', '')

        if not wordpress_id:
            create_wordpress_post(id, title, category, youtube_id)


def main():
    create_db()
    put_files_in_db()
    process()


if __name__ == '__main__':
    main()

