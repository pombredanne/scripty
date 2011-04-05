#!/usr/bin/env bash

# For converting a video to svi format for Samsung YP-P2 portable music player.

input="$1"
output=${input%\.*}.svi

ffmpeg \
    -i "$input" \
    -acodec libmp3lame -ab 128k -ac 2 \
    -vcodec mpeg4 -r 30 -s 480x272 \
    -f avi -sameq \
    "$output"
