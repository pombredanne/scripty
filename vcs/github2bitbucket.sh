#!/usr/bin/env bash

# This script backs up all public repos of a GitHub user to BitBucket.

bitbucket_username=$BITBUCKET_USERNAME
bitbucket_password=$BITBUCKET_PASSWORD
github_username=$GITHUB_USERNAME

github_repos()
{
python << _EOF_1

from github2.client import Github
github = Github()

for repo in github.repos.list('${github_username}'):
    print repo.name

_EOF_1
}


backup_to_bitbucket()
{
repo_name=$1
echo Processing $repo_name

curl -d "name=${repo_name}" -u ${bitbucket_username}:${bitbucket_password} https://api.bitbucket.org/1.0/repositories/ #>/dev/null 2>&1

TMP=/tmp/${repo_name}
if [ -d $TMP ]
then
    hg fetch git+ssh://git@github.com/${github_username}/${repo_name} -R $TMP
else
    hg clone git+ssh://git@github.com/${github_username}/${repo_name} $TMP
fi

hg push ssh://hg@bitbucket.org/${bitbucket_username}/${repo_name} -R $TMP

}

for repo in `github_repos`
do
    backup_to_bitbucket $repo
done
