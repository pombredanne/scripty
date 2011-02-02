#! /usr/bin/env bash

shopt -s nocaseglob
shopt -s nullglob

for input in *.avi
do
    echo "Processing $input"

    output=${input%\.*}.mp4

    # First Pass
    ffmpeg \
        -pass 1 \
        -vcodec libx264 -b 500k -s 640x480 \
        -an \
        -i "$input" "$output"

    # Second Pass
    ffmpeg \
        -pass 2 \
        -vcodec libx264 -b 500k -s 640x480 \
        -acodec mp3 -ab 24k \
        -i "$input" "$output"
done
