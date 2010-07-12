#!/usr/bin/env python

import MySQLdb
import os
import os.path
from mercurial import ui, hg, cmdutil

import mutils
from mutils import log

repo_root = '/var/www/hg'

DSN = {
    'ENGINE' : 'mysql',
    'HOST'   : 'localhost',
    'PORT'   : 3306,
    'NAME'   : 'redmine',
    'USER'   : 'redmine',
    'PASSWORD' : os.environ['REDMINE_PASS'],
    'OPTIONS': {},
}

_hgrc_content = """\
[web]
style = monoblue
push_ssl = false

[extensions]
hgext.keyword=
hgext.convert=

[keyword]
** =

[keywordmaps]
Author = {author}
Revision = {rev} ({node|short})
Date = {date|date}
Source = {root}/{file}
Header = {root}/{file} {node|short} {date|date} {author}
Id = {file|basename} {node|short} {date|date} {author}
"""

_hgignore_content = """\
syntax: glob
*~
*.o
*.O
*.exe
*.EXE
*.tmp
*.TMP
*.bkp
*.BKP
*.save
*.SAVE
*.lo
*.la
*.al
libs
*.so
*.so.[0-9]*
*.a
*.pyc
*.pyo
*.rej
*.swp
\#*\#
*.bin
*RECYCLE*
*Trash*
*TRASH*
*.orig
*.ORIG
*.log
*.LOG
"""

def connect(dsn):
    """
    Connect to database parsing dsn.

    @param dsn Database specification.
    @return Database object.
    """
    driver = dsn['ENGINE']
    host = dsn['HOST']
    user = dsn['USER']
    password = dsn['PASSWORD']
    dbname = dsn['NAME']
    port = dsn['PORT']

    log.debug("Connecting to %s as %s" % (dbname, user))

    db = MySQLdb.connect(
        user=user, passwd=password, host=host,
        port=port, db=dbname, use_unicode=True
    )

    return db

def create_repo_for_project(db, project_id, project_identifier):
    """Creates Repository for the given project
    """
    log.debug("Creating Repo for %s" % project_identifier)

    repo_path = os.path.join(repo_root, project_identifier)

    if not os.path.exists(repo_path):
        #Create the directory
        os.makedirs(repo_path)

        #Create the repository
        r = hg.repository(ui=ui.ui(), path=repo_path, create=True)

        #Create .hgignore
        hgignore = os.path.join(repo_path, '.hgignore')
        open(hgignore, 'w').write(_hgignore_content)

        #Create hgrc
        hgrc = os.path.join(repo_path, '.hg', 'hgrc')
        open(hgrc, 'w').write(_hgrc_content)

        #Add .hgignore to repo and commit
        cmdutil.addremove(r)
        r.commit(text="Created Repository")


    #Insert a record into repositories table
    c = db.cursor()
    c.execute("insert into repositories(project_id, url, root_url, type) "
              "values ('%s', '%s', '%s', 'Mercurial')"
              % (project_id, repo_path, repo_path)
             )
    db.commit()
    log.debug("Inserted a record into repositories table with "
              "project_id = %s and url = %s" % (project_id, repo_path)
             )


def main():

    db = connect(DSN)

    dbcur = db.cursor()
    dbcur.execute('select projects.id, projects.identifier '
                  'from projects LEFT OUTER JOIN repositories '
                  'ON projects.id = repositories.project_id '
                  'where repositories.project_id is null'
                 )

    row = dbcur.fetchone()

    while row:
        project_id = row[0]
        project_identifier = row[1]

        create_repo_for_project(db, project_id, project_identifier)
        row = dbcur.fetchone()

    db.close()


if __name__ == '__main__':
    import sys
    sys.exit(main())
