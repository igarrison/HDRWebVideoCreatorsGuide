# Windows 10 HDR VP9 Instructions for YouTube

When publishing HDR videos to YouTube it behooves us content creators to make the very best videos we can to showcase the technology and not continue to spread the bad HDR videos.  Its my intent to attempt to upload my MOV/DNxHR HQX 4K masters to YouTube right out of Resolve Studio so long as the size and duration of the video fall within a range I feel is acceptable (right now that is roughly less than 12GB).  I also generally like the process of exporting a high quality master video and then transcoding lower resolution and different resolutions and codec encodings of a video for web delivery from there.  I'll be fine uploading DNxHR HDR masters to YouTube provided they are less than 15 minutes long.  With these 4K DNxHR HDR masters eating a fixed 104Mbps you can end up in situations where if you need to record more than 35 minutes worth of footage you might even exceed YouTube's 128GB file upload limit!  So we need a solution on how to re-encode our HDR10 masters to smaller sizes for cases when we go for longer videos and larger resolutions like 8K.

I'll mention that while YouTube doesn't list support for ingesting h265 with HDR metadata it still does seem to work if you can send them a properly crafted file.  As of 12/2018 Resolve Studio doesn't export h265 with HDR metadata.  Premiere can do it technically but I get strange shifts in color/gamma.  Premiere also has other major problems with grading HDR10 where its still not recommended for finishing HDR content.  Resolve Studio on MacOS has support for VP9 built in.  The Windows/Linux versions of Resolve Studio do not support VP9 which is what this document aims to workaround.

I found a [google document written by Steve Robertson who works on HDR at YouTube that is dense with good information on publishing HDR to YouTube](https://docs.google.com/document/u/1/d/1OHGOE4Ihv6SKazfiub_DP1lJbR9PdMMPOQYxPJQAES4/pub#h.jd3wzt48geu).  Steve doesn't even mention h265.  He recommends VP9 maybe because [Google developed it](https://en.wikipedia.org/wiki/VP9), they [seem to promote it](https://youtube-eng.googleblog.com/2015/04/vp9-faster-better-buffer-free-youtube.html), have widely adopted it on YouTube, and VP9 competes directly against h265.

I stumbled on [a wonderful document written by some Google engineers about the VP9 codec used to compress HDR video](https://developers.google.com/media/vp9/hdr-encoding/).  This also included a reference to a [well maintained build script to compile ffmpeg optimized for 10-bit/vp9 support](https://github.com/id3as/ffmpeg-libvpx-HDR-static).

Next I sought the official windows build of ffmpeg to confirm if it supported the incantations of Google's VP9 HDR Encoding guide.  Any attempt to use it in a powershell/msdos prompt results in it exiting silently even with the highest debug level set (debug 56).  I then used Google's build script to compile ffmpeg with the correct VP9 support and found it to be suprisingly easy.

This repo contains a full set of instructions for using the ["Windows Subsystem for Linux" on Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to compile ffmpeg with vp9/10-bit support using Googles build script.  This repo also contains ```runme.bat``` MSDOS batch file which simply executes a ```ffmpeg_vp9_incantation.sh``` bash shell script that launches a particular ffmpeg incantation for VP9 encoding a DNxHR HQX HDR master video file.  ```runme.bat``` can be clicked in the windows explorer for easy launching.  The shell script will look for a file named ```HDR_master.mov``` which should ideally be DNxHR HQX in a MOV container.  This will output a file named ```HDR_VP9_output.mp4```, and if this file already exists it will be automatically overwritten which is why I recommend single project directories for processing one file at a time.  Also you can look for a ```ffmpeg-YYYYMMDD-######.log``` file which is created on every run of the script that can contain errors if they occur.

## Requirements

You will need:

1. A running Windows 10 install, or a Centos/RHEL, or Debian/Apt Linux distribution.  Linux users can skip to step #4 in the next section.

2. My batch file and bash shell script in [the zip file that you can download right here](https://github.com/igarrison/HDR2VP9/archive/master.zip).

3. To install the Windows Subsystem for Linux as instructed in the next section below.  This is needed to compile ffmpeg, its dependencies, and to run an application that seems to run better in a linux/posix environment.

4. I also recommended downloading [Wesley Knapp's HDR_MetaJECTOR.bat](http://www.wesleyknapp.com/s/Wesley_Knapp-HDR_Tools_v3.zip) and [YouTube's Matroska Colour Metadata Ingestion Utility](https://github.com/YouTubeHDR/hdr_metadata).  These will be used for embedding HDR to SDR LUT files into your HDR files uploaded to YouTube if you find the automatic HDR to SDR conversion unsatisfactory.

## Compile vp9 enabled ffmpeg

1. In Windows 10 head to Control Panel > Programs > Turn Windows Features On Or Off. Enable the "Windows Subsystem for Linux" option in the list, and then click the OK button.  This will have you reboot your system when its finished.

2. open the Microsoft Store from the Start menu, and search for "Ubuntu".  As of 12/7/2018 I went with Ubuntu 18.04 LTS and it worked fine.  Click the "Get" button to download it.

3. Once Ubuntu 18.04 LTS is installed you'll see a "Launch" button, click that or in your Start Menu run "Bash on Ubuntu on Windows".  This is going to ask you to create a new user and password (does not need to match your Windows login) and will finish setting up Ubuntu.

4. Run the following commands below in the shell window to grab the ffmpeg-libvpx-HDR-static build script from Google's HDR engineers.  Note, this will prompt you for a password from the previous step to get some administrative permissions.  The script needs this to install a bunch of Ubuntu packages needed to fill dependencies needed for the build).  It will take roughly 30 minutes to compile ffmpeg and all of its dependencies.

```bash
$ curl https://raw.githubusercontent.com/id3as/ffmpeg-libvpx-HDR-static/master/build_static_ffmpeg_centos-debian.sh > ffmpeg-build-script.sh
$ chmod 766 ffmpeg-build-script.sh
$ sudo ./ffmpeg-build-script.sh
```

5. Assuming the build ran successfully we should have an 'ffmpeg' binary we can run.  Lets copy this file outside of this Linux environment to a place where you can easily click launch the script with the Windows Explorer.  In the bash shell lets make a directory on your C drive called "HDR2VP9" and copy the ffmpeg binary into it.

```bash
mkdir -p /mnt/c/HDR2VP9
cp ffmpeg_sources/ffmpeg/ffmpeg /mnt/c/HDR2VP9
```

## How To Compress an HDR master to VP9

1. Using the Windows Explorer make a new project directory inside C:\HDR2VP9

2. Extract the contents of the [zip file in this repo](https://github.com/igarrison/HDR2VP9/archive/master.zip) into it.

3. Copy the C:\HDR2VP9\ffmpeg file into it.  This is the same file compiled from the Insta

3. Copy your mov/DNxHR HQX HDR master file into the project directory and rename it to HDR_master.mov

4. Double click on runme.bat.  If all works correctly you'll see this program periodically output a log of text as its encoding.  When its done you should find a file 2pass_vp9_output.mp4 in the same directory.

## Creating a Custom HDR to SDR LUT

YouTube will automatically convert SDR versions of your HDR videos uploaded to them, however if you dislike this color grade you can embed a LUT file into the video uploaded to YouTube that they will use for the SDR conversion process.  This is roughly how its done in Resolve Studio.

<more notes here>

## Embedding Custom HDR to SDR LUT files

1. Download [YouTube's Matroska Colour Metadata Ingestion Utility](https://github.com/YouTubeHDR/hdr_metadata) for your given platform.  Copy mkvinfo.exe/mkvmerge.exe into the same project directory.

2. I recommend grabbing [Wesley Knapp's HDR_MetaJECTOR batch file](http://www.wesleyknapp.com/s/Wesley_Knapp-HDR_Tools_v3.zip) to simplify launching the mkvmerge incantation to inject HDR metadata or attach a SDR to SDR LUT file.  Copy the HDR_MetaJECTOR batch file into the same project directory.

3. Double click on the ```HDR_MetaJECTOR.bat``` script in Windows Explorer.  This will launch an MSDOS window which you can drag-and-drop both your ```HDR_VP9_output.mp4``` and any LUT files to embed into your video file prior to uploading to YouTube.  It only takes a couple seconds to run and will produce a new file with your VP9 stream in a new ```.mkv``` container.

## HDR Bitrates

You should know the bitrate of all your cameras and footage they produce.  If you don't have this information use some media inspection tools (VLC, exiftool) or internet searches to try and determine the bitrates.  My my Panasonic GH5 shoots 150Mbps at 4k 10-bit 4:2:2 so this is my maximum upper limit on bitrate for my HDR videos.

[YouTube has their own recommendations for bitrates on uploaded videos](https://support.google.com/youtube/answer/1722171?hl=en).  Note that HDR videos are given a small additional amount of bitrate over SDR videos, just 2Mbps at 1080p but it can go up to +17Mbps in the most extreme case with 4k at the highest frame rates.

#### Recommended video bitrates for SDR uploads

| Type | Video Bitrate, Standard Frame Rate (24, 25, 30) | Video Bitrate, High Frame Rate (48, 50, 60) |
|------|-------------------------------------------------|---------------------------------------------|
| 2160p (4k) | 35-45 Mbps |	53-68 Mbps |
| 1080p	| 8 Mbps | 12 Mbps |
| 720p | 5 Mbps | 7.5 Mbps |

#### Recommended video bitrates for HDR uploads

| Type | Video Bitrate, Standard Frame Rate (24, 25, 30) | Video Bitrate, High Frame Rate (48, 50, 60) |
|------|-------------------------------------------------|---------------------------------------------|
| 2160p (4k) | 44-56 Mbps | 66-85 Mbps |
| 1080p | 10 Mbps | 15 Mbps |
| 720p | 6.5 Mbps | 9.5 Mbps |

I'm going to focus on DNxHR as its the preferred high quality mastering codec on Windows right out of Resolve.  Lets look at [DNxHR codec bandwidth specifications for 1080p and 4k UHD](http://avid.force.com/pkb/articles/en_US/White_Paper/DNxHR-Codec-Bandwidth-Specifications).  Lets ignore HQ, SQ, and LB profiles for DNxHR as they do not support 10-bit color (HDR is serious).  444 is listed below as it would support 10-bit color but its bitrate is excessively high for uploading to YouTube and I'm having a hard time imagining when its practical (if you really wanted to maintain high bitrates maybe?).

| Resolution | Codec | 23.976 | 29.97 | 59.94 |
|------------|-------|--------|-------|-------|
| HD | DNxHR 444 | 41.68Mbps | 52.10Mbps | 104.19Mbps |
| HD | DNxHR HQX | 20.79Mbps | 25.99Mbps | 51.98Mbps |
| UHD | DNxHR 444 | 166.61Mbps | 208.27Mbps | 416.54Mbps |
| UHD | DNxHR HQX | 83.26Mbps | 104.08Mbps | 208.15Mbps |

With encoding being a garbage-in/garbage-out operation we know that we should be uploading at bitrates meeting YouTube's recommendations at a minimum.  So with this information and my intent to publish at 4k@29.97p I can determine that ideally I go no lower than 56Mbps as my minimum bitrate and no higher than 104Mbps (DNXHR HQX at 4k@30p lowers my 150Mbps bitrate out of camera down to 104Mbps).

The default bitrate in ```ffmpeg_vp9_incantation.sh``` is 90Mbps minimum, 95Mbps average, and 100Mbps maximum.  These bitrates are optimized for 4k at 29.97fps which may be really high for 1080p HDR but you can use a text editor to modify the bash script to change these values.

## YouTube Optimizations for ffmpeg & Resolve Studio

Resolve and other editing suites may expose some but not all of a codec's parameters so videos may not always strictly comply with YouTube's recommendations.  Their video ingestion systems are fairly flexible and mostly do a great job of making the best video as quickly as they can with what you upload to them.  I've already added these flags to ```ffmpeg_vp9_incantation.sh```.

* [YouTube recommends a moov atom at the front of the file (Fast Start)](https://support.google.com/youtube/answer/1722171?hl=en).  Make sure to use a streaming format, like an mkv, .mp4 or a .mov, with the metadata at the front of the container YouTube will begin processing your video WHILE you are uploading it, drastically reducing overall turnaround time. This will make things MUCH faster, with no negative side effect."  This is ```-movflags +faststart``` in ffmpeg.

* [YouTube recommends 2 consecutive B frames](https://support.google.com/youtube/answer/1722171?hl=en).  This is ```-bf 2``` in ffmpeg.

* [YouTube recommends close GOP](https://support.google.com/youtube/answer/1722171?hl=en).  This is ```-flags +cgop``` in ffmpeg.

* [Consider this Encoding for Youtube article which contains tips written by google video infrastructure engineer Colleen Henry](http://www.streamingmedia.com/Articles/Editorial/Featured-Articles/Encoding-for-YouTube-How-to-Get-the-Best-Results-83876.aspx) which says "You can noticeably improve the quality of your video on YouTube by using a sophisticated, scene aware, denoising filter prior to uploading."  The denoise features in Resolve Studio is pretty good and we should use it (though carefully as it can reduce image details if pushed too far).

## Results

In a test I reduced a 3.9GB MOV DNxHR HQX HDR master from 3.9GB to 364MB without stripping HDR metadata using this workflow recommended by Google VP9/HDR Engineers.  This was a 47 second video and it took 49 minutes to encode on a i9 7900X 10-core CPU with 64GB RAM (WARNING: it is slow).  You can tune the speed by editing ```ffmpeg_vp9_incantation.sh``` if you are willing to sacrifice some quality for speed.  Its a value between 0 (slowest/best quality) and 4 (fastest/lowest quality) and the default is 1.  You can also adjust other things like the container, bitrate, and input/output filenames as well.

<include some before/after photos but stress that the goal is to use vp9 compression only in cases where HDR content is long in duration or otherwise too large to upload to YouTube>

## Additional Resources

[WebM Project's VP9 Encoding Guide](http://wiki.webmproject.org/ffmpeg/vp9-encoding-guide).

[FFMPEG.org's VP9 Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/VP9).

[Wesley Knapp's blog article on Grading HDR video on a rec709 monitor for youtube & beyond](http://www.wesleyknapp.com/blog/hdr).

Mystery Box has written many excellent blog posts on HDR: [like this](https://www.mysterybox.us/blog/2016/10/27/hdr-video-part-5-grading-mastering-and-delivering-hdr) and [this one](https://www.mysterybox.us/blog/2016/11/7/how-to-upload-hdr-video-to-youtube-with-a-lut), and they also [sell a bunch of HDR LUT files on their online store for cameras like the GH5/GH5S](https://www.mysterybox.us/blog/2018/1/8/panasonic-gh5s-hdr10).

[Alexis Van Hurksman's blog on HDR, Resolve, and Creative Grading](http://vanhurkman.com/wordpress/?p=3548).

[YouTube video from CRFTSHO titled Easy HDR video for YOUTUBE/vimeo tutorial part 2 - how to set up your project for HDR workflow](https://www.youtube.com/watch?v=QJAiR6lh9Z0).
