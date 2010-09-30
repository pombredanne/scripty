#!/usr/bin/env bash

bitbucket_username=dkmurthy
sf_username=dkmurthy
sf_projectname=vidyalaya

bitbucket_repos()
{
# I know this code is ugly. But we have to bear with it until Bitbucket's API work properly.
python << _EOF_1

import urllib2

url='http://bitbucket.org/${bitbucket_username}'
all_html=urllib2.urlopen(url).read()
repos_html = all_html.split('repository-list')[1].split('</table>')[0]
for line in repos_html.split('\n'):
    if 'href' in line:
        repo = line.split('href=')[2].split('>')[0].strip('"').strip('/').split('/src')[0].split('/')[-1]
        print repo

_EOF_1
}

backup_to_sourceforge()
{
    repo_name=$1
    echo Processing $repo_name

    # example : repo_base=/home/scm_hg/v/vi/vidyalaya
    repo_base=/home/scm_hg/${sf_projectname:0:1}/${sf_projectname:0:2}/${sf_projectname}
    repo=${repo_base}/${repo_name}

    ssh ${sf_username},${sf_projectname}@shell.sourceforge.net << _EOF_2
        if [ -d  $repo ]
        then
            cd $repo
            hg fetch http://bitbucket.org/${bitbucket_username}/${repo_name}
        else
            mkdir -p $repo
            cd $repo
            hg clone http://bitbucket.org/${bitbucket_username}/${repo_name} .
        fi
_EOF_2
}

# Create shell session
ssh ${sf_username},${sf_projectname}@shell.sourceforge.net create

for repo in `bitbucket_repos`
do
    backup_to_sourceforge $repo
done
