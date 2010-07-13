#!/usr/bin/env bash

repos="
scripty
vidyalaya-apps
vidyalaya-results
vidyalaya-config
"

for repo in $repos
do
    repo_dir="$HOME/scripts/${repo//-/_}"
    hg fetch -R $repo_dir ssh://hg@bitbucket.org/dkmurthy/$repo
    hg push  -R $repo_dir ssh://hg@bitbucket.org/dkmurthy/$repo
done
