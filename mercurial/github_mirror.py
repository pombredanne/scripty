from mercurial import commands
from hgext import bookmarks

def post_push(ui, repo, pats, opts, *args, **kwargs):
    """ Push to Github after pushing to BitBucket """

    dest = pats and pats[0]
    dest = ui.expandpath(dest or 'default-push', dest or 'default')

    if 'bitbucket.org' in dest:
        dest = dest.rstrip('/')
        reponame = dest.split('/')[-1]
        username = dest.split('/')[-2]

        github = 'git+ssh://git@github.com/{username}/{reponame}.git'
        github = github.format(username=username, reponame=reponame)

        # Move "master" bookmark to point to tip
        bookmarks.bookmark(ui, repo, mark='master', rev='tip', force=True)

        return commands.push(ui, repo, github, **opts)
