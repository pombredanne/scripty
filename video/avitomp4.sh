#! /usr/bin/env bash

shopt -s nocaseglob
shopt -s nullglob

for input in *.avi
do
    echo "Processing $input"

    output=${input%\.*}.mp4

    # First Pass
    ffmpeg \
        -i "$input" \
        -an \
        -pass 1 \
        -vcodec libx264 -vpre slow_firstpass -threads 0 -b 500k -s 640x480 \
        "$output"

    # Second Pass
    ffmpeg \
        -i "$input" \
        -acodec libfaac -ab 24k \
        -pass 2 \
        -vcodec libx264 -vpre slow -threads 0 -b 500k -s 640x480 \
        "$output"
done
