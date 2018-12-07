# HDR2VP9

I learned about some vp9 guidance for HDR encoding from Google here:

https://developers.google.com/media/vp9/hdr-encoding/

Google has a well maintained build script compile ffmpeg optimized for 10-bit/vp9 support here:

https://github.com/id3as/ffmpeg-libvpx-HDR-static

There is where I produced this 'ffmpeg' binary.  It was built on 12/5/2018 and I'm mostly putting it here to help a friend.

This repo also contains a batch script which simply executes a bash shell script that launches a particular ffmpeg incantation.  While this sounds silly this was done so the runme.bat can be clicked in the windows explorer.  The shell script will look for a file named HDR_master.mov which should ideally be DNxHR HQX in a MOV container.  This will output a file named HDR_output_2pass_vp9_100M.mp4, and if this file exists it will be automatically overwritten.  Also you can look for a ffmpeg-YYYYMMDD-######.log file which is created on every run of the script.  If there are any errors, look for the errors in the most recent logfile.

## Requirements and Installation

This ffmpeg version was built inside an Ubuntu environment installed by "Windows Service for Linux" on Windows 10.  You will need to install it to get the linux environment to launch ffmpeg.  This ffmpeg binary does run in an msdos/powershell native shell, however it exits without error (even with DEBUG 56) on the second pass for reasons unclear to me.  The official windows builds of ffmpeg don't seem to be built correctly with VP9.

https://docs.microsoft.com/en-us/windows/wsl/install-win10

## How To Run

1. Make a new project directory
2. Copy the contents of this repo into it
3. Copy your mov/DNxHR HQX HDR master file into the project directory and rename it to HDR_master.mov
4. Double click on runme.bat

## Extra Links

https://docs.google.com/document/u/1/d/1OHGOE4Ihv6SKazfiub_DP1lJbR9PdMMPOQYxPJQAES4/pub#h.jd3wzt48geu

http://www.wesleyknapp.com/blog/hdr

https://www.mysterybox.us/blog/2016/10/27/hdr-video-part-5-grading-mastering-and-delivering-hdr

http://vanhurkman.com/wordpress/?p=3548
