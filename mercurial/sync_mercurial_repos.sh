#!/usr/bin/env bash

repos="
scripty
vidyalaya-apps
vidyalaya-results
vidyalaya-config
vidyalaya-active-directory
blogs-planet
"

remote_url_base=ssh://hg@bitbucket.org/dkmurthy

for repo in $repos
do
    repo_dir="$HOME/scripts/${repo//-/_}"

    if [ ! -d $repo_dir ]
    then
        hg clone $remote_url_base/$repo $repo_dir
    fi

    hg fetch -R $repo_dir $remote_url_base/$repo
    hg push  -R $repo_dir $remote_url_base/$repo
done
