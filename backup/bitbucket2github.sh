#!/usr/bin/env bash

# This script backs up all public repos of a BitBucket user to GitHub.

bitbucket_username=dkmurthy
github_username=dkmurthy
github_api_token=$GITHUB_API_TOKEN

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


backup_to_github()
{
repo_name=$1
echo Processing $repo_name

python << _EOF_2

from github2.client import Github
github = Github(username='${github_username}', api_token='${github_api_token}')

try:
    repo = github.repos.show('${github_username}/${repo_name}')
except RuntimeError:
    print "Creating repo '${repo_name}' in github.com"
    github.repos.create('${repo_name}')

_EOF_2

TMP=/tmp/${repo_name}
if [ -d $TMP ]
then
    hg fetch http://bitbucket.org/${bitbucket_username}/${repo_name} -R $TMP
else
    hg clone http://bitbucket.org/${bitbucket_username}/${repo_name} $TMP
fi

hg push git+ssh://git@github.com/${github_username}/${repo_name} -R $TMP

}

for repo in `bitbucket_repos`
do
    backup_to_github $repo
done
