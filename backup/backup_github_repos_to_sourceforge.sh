#!/usr/bin/env bash

# Pre-requisites:
# 1. Install python-github2 (http://github.com/ask/python-github2)
#       $ pip install github2
#
# 2. Setup password-less login to sourceforge ssh.


github_username=Vidyalaya
sf_username=dkmurthy
sf_projectname=vidyalaya

github_repos()
{
python << _EOF_1

from github2.client import Github
github = Github()

for repo in github.repos.list('${github_username}'):
    print repo.name

_EOF_1
}

backup_to_sourceforge()
{
    repo_name=$1
    echo Processing $repo_name

    # example : repo_base=/home/scm_git/v/vi/vidyalaya
    repo_base=/home/scm_git/${sf_projectname:0:1}/${sf_projectname:0:2}/${sf_projectname}
    repo=${repo_base}/${repo_name}

    ssh ${sf_username},${sf_projectname}@shell.sourceforge.net << _EOF_2
        if [ -d  $repo ]
        then
            cd $repo
            git --work-tree=. pull http://github.com/${github_username}/${repo_name}.git
        else
            mkdir -p $repo
            git --git-dir=$repo init --shared=all --bare
            cd $repo
            git --work-tree=. pull http://github.com/${github_username}/${repo_name}.git
        fi
_EOF_2
}

# Create shell session
ssh ${sf_username},${sf_projectname}@shell.sourceforge.net create

for repo in `github_repos`
do
    backup_to_sourceforge $repo
done
