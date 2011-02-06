#! /usr/bin/env bash

shopt -s nocaseglob
shopt -s nullglob

echo -n "
Select your option :
    1. Speech for web
    2. Performance for web
    3. Performance for Archival

    Option : "

read option

if [ "$option" == "1" ]
then
    vbitrate="512k"
    size="640x480"
    abitrate="32k"
    achannels="1"
elif [ "$option" == "2" ]
then
    vbitrate="1024k"
    size="640x480"
    abitrate="32k"
    achannels="1"
elif [ "$option" == "3" ]
then
    vbitrate="2048k"
    size="640x480"
    abitrate="64k"
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
