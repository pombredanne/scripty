#/usr/bin/env bash

this_dir=`dirname $0`

python $this_dir/hgredmine.py >/dev/null 2>&1 &
