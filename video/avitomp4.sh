#!/usr/bin/env bash

shopt -s nocaseglob
shopt -s nullglob

echo -n "
Select your option :
    1. Small Size
    2. Speech for web
    3. Performance for web
    4. For Local Archival

    Option : "

read option

# Formula to calculate file size
# File Size = 0.007324219 * (vbitrate + abitrate) * num of minutes

if [ "$option" == "1" ]
then
    # These settings will create 60MB file for 15 minute video.
    vbitrate="512k"
    size="640x480"
    abitrate="32k"
    achannels="1"
elif [ "$option" == "2" ]
then
    # These settings will create 80MB file for 15 minute video.
    vbitrate="700k"
    size="640x480"
    abitrate="32k"
    achannels="1"
elif [ "$option" == "3" ]
then
    # These settings will create 100MB file for 15 minute video.
    vbitrate="834k"
    size="640x480"
    abitrate="64k"
    achannels="1"
elif [ "$option" == "4" ]
then
    # These settings will create 127MB file for 15 minute video.
    vbitrate="1028k"
    size="640x480"
    abitrate="128k"
    achannels="2"
else
    echo -e "\n Invalid option. Aborting. \n"
    exit 1
fi

for input in *.avi
do
    echo "Processing $input"

    output=${input%\.*}.mp4

    # First Pass
    ffmpeg \
        -i "$input" \
        -an \
        -pass 1 \
        -vcodec libx264 -vpre slow_firstpass -threads 0 -b $vbitrate -s $size \
        -y -timestamp now \
        "$output"

    # Second Pass
    ffmpeg \
        -i "$input" \
        -acodec libfaac -ab $abitrate -ac $achannels \
        -pass 2 \
        -vcodec libx264 -vpre slow -threads 0 -b $vbitrate -s $size \
        -y -timestamp now \
        "$output"
done
