#!/usr/bin/env python

import sys
import youtube_upload

# Split into 15 mins or 100MB, which ever is smaller
print list(youtube_upload.split_video(sys.argv[1], 15*60, 100*1024*1024, 5))
