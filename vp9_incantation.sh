#!/bin/bash

if [ -f ./ffmpeg ]
then
  echo "ffmpeg was found"
else
  echo "ffmpeg was NOT found, where is it?"
fi

if [ -f ./HDR_master.mov ]
then
  echo "file HDR_master.mov was found"
else
  echo "file HDR_master.mov was not found"
fi

if [ -f ./HDR_output_2pass_vp9_100M.mov ]
then
  echo "file ./HDR_output_2pass_vp9_100M.mov was found and will be overwritten!"
fi

./ffmpeg -y -report -i ./HDR_master.mov -b:v 95M -speed 4 -pass 1 -pix_fmt yuv420p10le -color_primaries 9 -color_trc 16 -colorspace 9 -color_range 1 -maxrate 100M -minrate 90M -profile:v 2 -vcodec libvpx-vp9 -tile-columns 0 -frame-parallel 0 -f mp4 -bf 2 -flags +cgop /dev/null && ./ffmpeg -y -report -i HDR_master.mov -b:v 95M -auto-alt-ref 1 -lag-in-frames 25 -pass 2 -pix_fmt yuv420p10le -color_primaries 9 -color_trc 16 -colorspace 9 -color_range 1 -maxrate 100M -minrate 90M -profile:v 2 -vcodec libvpx-vp9 -bf 2 -movflags +faststart -tile-columns 0 -frame-parallel 0 -flags +cgop ./HDR_output_2pass_vp9_100M.mp4

read -p "Press enter to exit"
exit
