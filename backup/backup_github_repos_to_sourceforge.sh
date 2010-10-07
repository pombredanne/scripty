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
    git_repo_name=$1
    hg_repo_name=${git_repo_name}_github
    tmp_repo=/tmp/${git_repo_name}

    echo Processing $git_repo_name

    # example : repo_base=/home/scm_hg/v/vi/vidyalaya
    repo_base=/home/scm_hg/${sf_projectname:0:1}/${sf_projectname:0:2}/${sf_projectname}
    frs_base=/home/frs/project/${sf_projectname:0:1}/${sf_projectname:0:2}/${sf_projectname}

    ssh ${sf_username},${sf_projectname}@shell.sourceforge.net << _EOF_2

        cd ${repo_base}
        git clone http://github.com/${github_username}/${git_repo_name}.git ${tmp_repo}

        hg convert ${tmp_repo} ${hg_repo_name}
        hg update -R ${hg_repo_name}

        rm -rf ${tmp_repo}

        zip -q -r ${frs_base}/${hg_repo_name}.zip ${hg_repo_name}

_EOF_2
}

# Create shell session
ssh ${sf_username},${sf_projectname}@shell.sourceforge.net create

for repo in `github_repos`
do
    backup_to_sourceforge $repo
done
