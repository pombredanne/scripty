#! /usr/bin/env bash

shopt -s nocaseglob
shopt -s nullglob

for input in *.mp4 *.avi
do
    output=${input%\.*}.mp3
    ffmpeg -i "$input" -vn -ab 24k "$output"
done
