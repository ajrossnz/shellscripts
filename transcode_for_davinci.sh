#!/bin/bash

echo "Will transcode the following files:"
find . -maxdepth 1 -name "*.MP4"
echo "Hit return to transcode..."
read x

for i in *MP4; do
	ffmpeg -i $i -c:v dnxhd -vf scale=1920:1080 -b:v 45M -c:a pcm_s16le $i-converted.mov
	#lower bitrate -> ffmpeg -i $i -c:v dnxhd -vf scale=1920:1080 -b:v 36M -c:a pcm_s16le $i-converted.mov
done
