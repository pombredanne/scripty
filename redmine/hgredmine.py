from base64 import b64decode
import logging
import os, re, time
import hashlib

#import mutils
#from mutils import log

from mercurial import ui, hg, util, templater

from mercurial.hgweb.request import wsgirequest
from mercurial.hgweb.hgwebdir_mod import hgwebdir
from mercurial.hgweb.hgweb_mod import hgweb
from mercurial import error, encoding
from mercurial.hgweb.common import ErrorResponse, get_mtime, staticfile, paritygen,\
                   get_contact, HTTP_OK, HTTP_NOT_FOUND, HTTP_SERVER_ERROR, \
                   HTTP_UNAUTHORIZED

class HgRedmine(hgwebdir):
    """A simple HTTP basic authentication implementation (RFC 2617) usable
    as WSGI middleware.
    """

    def __init__(self, realm, dsn, conf, baseui=None):
        self.dsn = dsn
        self.realm = realm

        hgwebdir.__init__(self, conf, baseui)

    def findrepos(self, db):
        """
        Find repos from Redmine database.
        """
        dbcur = db.cursor()
        dbcur.execute('SELECT projects.identifier, repositories.url FROM projects, repositories '
                      'WHERE repositories.type="Mercurial" AND projects.id = repositories.project_id'
                     )

        repos = {}
        row = dbcur.fetchone()

        while row:
            repos[row[0]] = row[1]
            row = dbcur.fetchone()

        self.repos = repos.items()

    def _send_challenge(self, req):
        #log.debug(" Inside HgRedmine::_send_challenge ")
        req.header([('WWW-Authenticate', 'Basic realm="%s"' % self.realm)])
        raise ErrorResponse(HTTP_UNAUTHORIZED, 'List Redmine repositories is unauthorized')

    def _user_login(self, db, req):

        req.env['REMOTE_USER'] = None

        header = req.env.get('HTTP_AUTHORIZATION')
        #log.debug("Inside _user_login : header = " + str(header))
        if not header or not header.startswith('Basic'):
            return False

        creds = b64decode(header[6:]).split(':')
        if len(creds) != 2:
            return False

        username, password = creds

        hashed_password = hashlib.sha1(password).hexdigest()

        dbcur = db.cursor()
        dbcur.execute('SELECT users.admin FROM users WHERE users.login=%s AND users.hashed_password=%s',
                      (username, hashed_password)
                     )

        row = dbcur.fetchone()
        if not row:
            return False

        req.env['AUTH_TYPE'] = 'Basic'
        req.env['REMOTE_USER'] = username
        req.env['REMOTE_USER_ADMIN'] = row[0]

        return True


    def _is_admin(self, req):
        """
        Find repos from Redmine database.

        @return True / False
        """
        return req.env.get('REMOTE_USER_ADMIN', 'f') == 't'

    def _setup_repo(self, db, repo, project_id):
        dbcur = db.cursor()
        dbcur.execute('SELECT projects.name, projects.description FROM projects WHERE projects.identifier=%s',
                      project_id
                     )

        row = dbcur.fetchone()
        if not row:
            return

        repo.ui.setconfig('web', 'name', row[0])
        repo.ui.setconfig('web', 'description', row[1])
        repo.ui.setconfig('web', 'contact', 'Project Owner')

    def run_wsgi(self, req):
        try:
            try:
                #log.debug("Inside HgRedmine::run_wsgi : " + str(req.env))


                db = connect(self.dsn)

                self.refresh()
                self.findrepos(db)

                virtual = req.env.get("PATH_INFO", "").strip('/')

                tmpl = self.templater(req)
                ctype = tmpl('mimetype', encoding=encoding.encoding)
                ctype = templater.stringify(ctype)

                # a static file
                if virtual.startswith('static/') or 'static' in req.form:
                    if virtual.startswith('static/'):
                        fname = virtual[7:]
                    else:
                        fname = req.form['static'][0]
                    static = templater.templatepath('static')
                    return (staticfile(static, fname, req),)

                self._user_login(db, req)
                # top-level index
                #if not virtual:
                    ## only administrators can list repositories
                    #if self._is_admin(req):
                        #req.respond(HTTP_OK, ctype)
                        #return self.makeindex(req, tmpl)
                    #else:
                        #self._send_challenge(req)

                # navigate to hgweb
                project_id = virtual.split('/')[0]

                repos = dict(self.repos)

                real = repos.get(project_id)

                if real:
                    req.env['REPO_NAME'] = project_id

                    try:
                        repo = hg.repository(self.ui.copy(), str(real))
                        self._setup_repo(db, repo, project_id)
                        #log.debug("Calling HgWebRedmine with " + str(self.realm) + str(repo))
                        return HgwebRedmine(db, self.realm, repo).run_wsgi(req)
                    except IOError, inst:
                        msg = inst.strerror
                        raise ErrorResponse(HTTP_SERVER_ERROR, msg)
                    except error.RepoError, inst:
                        raise ErrorResponse(HTTP_SERVER_ERROR, str(inst))

                # prefixes not found
                req.respond(HTTP_NOT_FOUND, ctype)
                return tmpl("notfound", repo=virtual)

            except ErrorResponse, err:
                req.respond(err.code, ctype)
                return tmpl('error', error=err.message or '')
        finally:
            db.close()
            db = None
            tmpl = None

class HgwebRedmine(hgweb):
    def __init__(self, dbconn, realm, repo, name=None):
        #log.debug("Inside HgwebRedmine : " + str(repo))
        self.db = dbconn
        self.realm = realm

        hgweb.__init__(self, repo, name)

    def _send_challenge(self, req, msg):
        #log.debug("Inside HgwebRedmine::send-chal : " + str(req.env.get('REMOTE_USER')))
        req.header([('WWW-Authenticate', 'Basic realm="%s"' % self.realm)])
        raise ErrorResponse(HTTP_UNAUTHORIZED, 'aaaaaaaaaaaa')

    def _get_perms(self, user, project_id):
        """
        Find member permissions from Redmine database.

        Redmine repository relate permissions:
            - :manage_repository
            - :browse_repository
            - :view_changesets
            - :commit_access

        @return (allow_read, allow_push) tuple
        """
        #log.debug("Inside HgwebRedmine::get_perms : user = " + str(user) )
        is_public = self._is_public_repo(project_id)

        if not user: # anonymous user
            if is_public:
                return (True, False)

            return (False, False)

        # Redmine member

        dbcur = self.db.cursor()
        dbcur.execute('SELECT roles.permissions FROM users, projects, members, roles, member_roles '
                            'WHERE users.login=%s AND projects.identifier=%s '
                            'AND projects.id = members.project_id AND users.id = members.user_id '
                            'AND members.id = member_roles.member_id '
                            'AND roles.id = member_roles.role_id',
                      (user, project_id)
                     )

        row = dbcur.fetchone()
        if not row:
            # user doesn't have any permits
            return (False, False)

        perms = row[0].splitlines()

        if '- :manage_repository' in perms or '- :commit_access' in perms:
            return (True, True)
        elif '- :view_changesets' in perms or '- :browse_repository' in perms:
            return (True, False)
        else:
            return (False, False)

    def _is_public_repo(self, project_id):
        #log.debug("Inside HgwebRedmine::is_public : " + str(project_id))
        dbcur = self.db.cursor()
        dbcur.execute('SELECT projects.is_public FROM projects WHERE projects.identifier=%s',
                      project_id
                     )

        row = dbcur.fetchone()
        if not row:
            return False

        return row[0] == 1

    def check_perm(self, req, op):
        '''Check permission for operation based on request data (including
        authentication info). Return if op allowed, else raise an ErrorResponse
        exception.'''


        user = req.env.get('REMOTE_USER')
        project_id = req.env.get('REPO_NAME')

        #log.debug("Inside HgwebRedmine::check_perm : user = " + str(user))

        allow_read, allow_push = self._get_perms(user, project_id)

        if not allow_read:
            #log.debug(" Read not auth ")
            self._send_challenge(req, 'read not authorized')

        if op == 'pull' and not self.allowpull:
            self._send_challenge(req, 'pull not authorized')
        elif op == 'pull' or op is None: # op is None for interface requests
            return

        # enforce that you can only push using POST requests
        if req.env['REQUEST_METHOD'] != 'POST':
            msg = 'push requires POST request'
            raise ErrorResponse(HTTP_METHOD_NOT_ALLOWED, msg)

        # require ssl by default for pushing, auth info cannot be sniffed
        # and replayed
        scheme = req.env.get('wsgi.url_scheme')
        if self.configbool('web', 'push_ssl', True) and scheme != 'https':
            raise ErrorResponse(HTTP_OK, 'ssl required')

        if not allow_push:
            self._send_challenge(req, 'push not authorized')


def connect(dsn):
    """
    Connect to database parsing dsn.

    @param dsn Database specification.
    @return Database object.
    """
    #log.debug("Connecting to db " + dsn['NAME'])
    driver = dsn['ENGINE']
    host = dsn['HOST']
    user = dsn['USER']
    password = dsn['PASSWORD']
    dbname = dsn['NAME']
    port = dsn['PORT']

    # Try to import database driver
    if driver == 'mysql':
        import MySQLdb

        # Create database
        db = MySQLdb.connect(
            user=user, passwd=password, host=host,
            port=port, db=dbname, use_unicode=True
        )

    elif driver == 'postgresql':
        import psycopg2, psycopg2.extras, psycopg2.extensions
        psycopg2.extensions.register_type(psycopg2.extensions.UNICODE)

        if not port:
            port = '5432'

        dsn = "dbname='%s' user='%s' host='%s' password='%s' port=%s" % (
                dbname, user, host, password, port
        )

        db = psycopg2.connect(dsn)
        db.set_client_encoding('UTF-8')

    elif driver == 'sqlite3':
        import sqlite3

        # Create database
        db = sqlite3.connect(dbname)
    else:
        raise ValueError('Unknown database type %s' % (driver, ))

    return db


if __name__ == '__main__':
    from wsgiref.simple_server import make_server
    from hgredmine import HgRedmine

    # 'postgresql', 'mysql', 'sqlite3', and 'oracle'
    DSN = {
        'ENGINE' : 'mysql',
        'HOST'   : 'localhost',
        'PORT'   : 3306,
        'NAME'   : 'redmine',
        'USER'   : 'redmine',
        'PASSWORD' : os.environ['REDMINE_PASS'],
        'OPTIONS': {},
    }

    TITLE = 'Projects @ RMV CAS Intranet'
    HGWEB_CFG_PATH = 'hgweb.config'

    application = HgRedmine(TITLE, DSN, HGWEB_CFG_PATH)
    httpd = make_server('', 8070, application)
    print "Serving on port 8070..."

    # Serve until process is killed
    httpd.serve_forever()
