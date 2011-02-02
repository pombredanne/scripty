#! /usr/bin/env bash

for f in *.mp4
do
    out=`basename "$f" .mp4`
    /usr/bin/ffmpeg -ab 24kb -i "$f" "$out.mp3"
done
