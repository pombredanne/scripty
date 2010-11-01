#!/usr/bin/env bash

bitbucket_username=dkmurthy
sf_username=dkmurthy
sf_projectname=vidyalaya

bitbucket_repos()
{
python << _EOF_1

import urllib2
import json

url = 'https://api.bitbucket.org/1.0/users/${bitbucket_username}/'
f = urllib2.urlopen(url)
response = json.loads(f.read())

for repo in response['repositories']:
    print repo['slug']

_EOF_1
}

backup_to_sourceforge()
{
    repo_name=$1
    echo Processing $repo_name

    # example : repo_base=/home/scm_hg/v/vi/vidyalaya
    repo_base=/home/scm_hg/${sf_projectname:0:1}/${sf_projectname:0:2}/${sf_projectname}
    frs_base=/home/frs/project/${sf_projectname:0:1}/${sf_projectname:0:2}/${sf_projectname}
    repo=${repo_base}/${repo_name}

    ssh ${sf_username},${sf_projectname}@shell.sourceforge.net << _EOF_2
        if [ -d  $repo ]
        then
            hg fetch http://bitbucket.org/${bitbucket_username}/${repo_name} -R $repo
        else
            hg clone http://bitbucket.org/${bitbucket_username}/${repo_name} $repo
        fi

        zip -q -r ${frs_base}/${repo_name}.zip ${repo}
_EOF_2
}

# Create shell session
ssh ${sf_username},${sf_projectname}@shell.sourceforge.net create

for repo in `bitbucket_repos`
do
    backup_to_sourceforge $repo
done
