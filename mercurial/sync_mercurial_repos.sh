#!/usr/bin/env bash

repos="
scripty
vidyalaya-apps
vidyalaya-results
vidyalaya-config
vidyalaya-active-directory
"

for repo in $repos
do
    repo_dir="$HOME/scripts/${repo//-/_}"
    
    if [ ! -d $repo_dir ]
    then
        hg clone http://bitbucket.org/dkmurthy/$repo $repo_dir
    fi
    
    hg fetch -R $repo_dir ssh://hg@bitbucket.org/dkmurthy/$repo
    hg push  -R $repo_dir ssh://hg@bitbucket.org/dkmurthy/$repo
done
