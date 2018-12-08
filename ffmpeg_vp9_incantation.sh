#!/bin/bash

AVGBR="95M"
MINBR="90M"
MAXBR="100M"

FFMPEG="./ffmpeg"
SOURCEFILE="./HDR_master.mov"
OUTPUTFILE="./HDR_VP9_output.mp4"
# mp4, webm, and mkv should work.  I had problems with mov.
OUTPUTCONTAINER="mp4"
# 0 is slowest/best quality, 4 is fastest/lowest quality
SPEED=1

if [ -f $FFMPEG ]
then
  echo "SUCCESS: ffmpeg was found"
else
  echo "ERROR: $FFMPEG was NOT found, where is it?"
  exit
fi

if [ -f $SOURCEFILE ]
then
  echo "SUCCESS: file $SOURCEFILE was found"
else
  echo "ERROR: file $SOURCEFILE was not found"
  exit
fi

if [ -f $OUTPUTFILE ]
then
  echo "WARNING: file $OUTPUTFILE was found and is being automatically overwritten!"
fi

# 2 pass
$FFMPEG -y -report -i $SOURCEFILE -b:v $AVGBR -speed 4 -pass 1 -pix_fmt yuv420p10le -color_primaries 9 -color_trc 16 -colorspace 9 -color_range 1 -maxrate $MAXBR -minrate $MINBR -profile:v 2 -vcodec libvpx-vp9 -f $OUTPUTCONTAINER -bf 2 -flags +cgop /dev/null && $FFMPEG -y -report -i $SOURCEFILE -b:v $AVGBR -auto-alt-ref 1 -lag-in-frames 25 -pass 2 -pix_fmt yuv420p10le -color_primaries 9 -color_trc 16 -colorspace 9 -color_range 1 -maxrate $MAXBR -minrate $MINBR -profile:v 2 -vcodec libvpx-vp9 -bf 2 -movflags +faststart -speed $SPEED -flags +cgop $OUTPUTFILE

read -p "Press enter to exit"
exit
