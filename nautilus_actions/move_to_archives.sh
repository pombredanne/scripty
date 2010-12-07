#!/usr/bin/env bash
# Moves the selected file/folder to Archives.zip

source="$@"

parent=`dirname "$source"`
parent_name=`basename "$parent"`
dest="${parent}/${parent_name}_Archives.zip"

echo "Moving $source to $dest"
zip --move --recurse-paths --test "$dest" "$source"
