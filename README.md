# HDR Video Creator Guide

<!-- TOC depthFrom:1 depthTo:8 withLinks:1 updateOnSave:1 orderedList:0 -->

- [HDR Video Creator Guide](#hdr-video-creator-guide)
	- [Introduction and Call For Quality](#introduction-and-call-for-quality)
- [How To Shoot HDR Video?](#how-to-shoot-hdr-video)
	- [Online Video Platform HDR Requirements](#online-video-platform-hdr-requirements)
		- [YouTube](#youtube)
		- [Vimeo](#vimeo)
	- [Recommended Hardware for HDR](#recommended-hardware-for-hdr)
	- [Recommended Software for HDR](#recommended-software-for-hdr)
- [Compiling ffmpeg With VP9 support](#compiling-ffmpeg-with-vp9-support)
	- [Requirements For Compiling ffmpeg With VP9 Support](#requirements-for-compiling-ffmpeg-with-vp9-support)
	- [Compile VP9 Enabled ffmpeg](#compile-vp9-enabled-ffmpeg)
	- [How To Compress an HDR Master to VP9](#how-to-compress-an-hdr-master-to-vp9)
	- [HDR Bitrates](#hdr-bitrates)
	- [YouTube Optimizations for ffmpeg & Resolve Studio](#youtube-optimizations-for-ffmpeg-resolve-studio)
	- [Results](#results)
- [HDR to SDR Conversion LUTs (YouTube)](#hdr-to-sdr-conversion-luts-youtube)
	- [Creating a Custom HDR to SDR LUT](#creating-a-custom-hdr-to-sdr-lut)
	- [Embedding Custom HDR to SDR LUT Files](#embedding-custom-hdr-to-sdr-lut-files)
- [FAQ](#faq)
- [Special Thanks](#special-thanks)
- [Author](#author)
- [Additional Resources](#additional-resources)

<!-- /TOC -->

## Introduction and Call For Quality

In April of 2017 I got a Panasonic GH5 which is a mirrorless digital camera and I was intensely curious about how it could record 10-bit color internally at 4:2:2 chroma-subsampling, and having a decent LOG gamma profile (V-LOG) grants an extra stop of dynamic range for a total of 12 stops.  Later the GH5 received a firmware update which allowed recording directly in HLG, a dynamic HDR standard that uses a rec2020 color space in camera.  And then again another year later the GH5 receive a firmware update allowing an All-Intraframe 400Mbps codec which could reduce some of the compression of interframe h264/h265 in the previous acquisition codec selection.  Shooting HDR on the GH5 just looked more and more attractive so I gave it a shot.  Progress was slow as there just aren't many people communicating about HDR content creation.

When publishing HDR videos to YouTube I think us content creators should make the very best videos we can to showcase this new technology and not continue to spread bad HDR videos.  I see an unsettling number of people on YouTube making HDR tutorials where they seem to shoot video in 8-bit color, using low dynamic range sensors like smartphones, without looking at scopes or adjusting highlights at all above 100 nits SDR ranges, and even cranking contrast curves + saturation for a "HDR Look".  I'm not going to be that guy!  I want to aim for 10-bit color, 4k resolution or higher if possible, wide gamut color space (rec2020, not DCI-P3 or rec709 though both are supported by YouTube for HDR), and 1000 nits brightness unless the times call for even more brightness.  Lets try and make content that pushes HDR as far as our hardware/software allows to make the most visually stunning videos!

# How To Shoot HDR Video?

## Online Video Platform HDR Requirements

### YouTube

**It is my intent to attempt to upload my 4k 10-bit HDR MOV/DNxHR HQX masters to YouTube right out of Resolve Studio whenever possible** so long as the size and duration of the video fall within a range is acceptable (roughly less than 12GB).  I also like the process of exporting a high quality master video and then transcoding lower resolution and different resolutions and codec encodings of a video for web delivery from there.  I'll be fine uploading DNxHR HDR masters to YouTube provided they are less than 15 minutes long.  With these 4K DNxHR HDR masters eating a fixed 104Mbps for my videos (explained below) you can end up in situations where if you need to record more than 35 minutes worth of footage you might even exceed YouTube's 128GB file upload limit!  So we need a solution on how to re-encode our HDR10 masters to smaller sizes for cases when we go for longer videos and larger resolutions like 8K.  We need to workaround Resolve Studio not having a web deliverable codec with HDR metadata support on Windows or Linux.  This likely means either h265 or VP9.

I'll mention that while YouTube doesn't list support for ingesting h265 with HDR metadata it still works if you can send them a properly crafted file.  As of 12/2018 Resolve Studio doesn't export h265 with HDR metadata, only.  Resolve Studio on MacOS has HDR metadata support for VP9 built in, but not on Windows/Linux.  Basically Resolve on Windows doesn't have a convenient web deliverable codecs that supports HDR metadata which was one of the main motivations for creating this document to provide a workaround.  Premiere can export h265 with HDR metadata but I get strange shifts in color/gamma I can't fix.  Premiere also has other major problems with grading HDR10 where its still not recommended for finishing HDR content.

| NLE Suite | Support for HDR | Recommended |
|-----------|--------------------------|-------------|
| Premiere | h265, h264 in mp4 triggers as HDR on YouTube but color is bad, DNxHR won't work in Premiere because its in an mxf instead of a mov container | Not yet |
| Resolve Studio | Prores (Macos-only), VP9 (Macos-only), DNxHR | Yes |
| Final Cut Pro | Does have some HDR support but I'm unclear on the details | Maybe? |

16bit TIFF files, OpenEXR, and Cineform 12-bit are also fairly commonly supported and are good suitable intermediate HDR codecs.

I found a [google document written by Steve Robertson who works on HDR at YouTube that is dense with good information on publishing HDR to YouTube](https://docs.google.com/document/u/1/d/1OHGOE4Ihv6SKazfiub_DP1lJbR9PdMMPOQYxPJQAES4/pub#h.jd3wzt48geu).  Steve doesn't even mention h265.  He recommends VP9 maybe because [Google developed it](https://en.wikipedia.org/wiki/VP9), they [seem to promote it](https://youtube-eng.googleblog.com/2015/04/vp9-faster-better-buffer-free-youtube.html), have widely adopted it on YouTube, and VP9 competes directly against h265.

I stumbled on [a wonderful document written by some Google engineers about the VP9 codec used to compress HDR video](https://developers.google.com/media/vp9/hdr-encoding/).  This also included a reference to a [well maintained build script to compile ffmpeg optimized for 10-bit/vp9 support](https://github.com/id3as/ffmpeg-libvpx-HDR-static).

Next I sought the official windows build of ffmpeg to confirm if it supported the incantations of Google's VP9 HDR Encoding guide.  Any attempt to use it in a powershell/msdos prompt results in it exiting silently even with the highest debug level set (debug 56).  I then used Google's build script to compile ffmpeg with the correct VP9 support and found it to be suprisingly easy.

This repo contains a full set of instructions for using the ["Windows Subsystem for Linux" on Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10) to compile ffmpeg with vp9/10-bit support using Googles build script.  This repo also contains ```runme.bat``` MSDOS batch file which simply executes a ```ffmpeg_vp9_incantation.sh``` bash shell script that launches a particular ffmpeg incantation for VP9 encoding a DNxHR HQX HDR master video file.  ```runme.bat``` can be clicked in the windows explorer for easy launching.  The shell script will look for a file named ```HDR_master.mov``` which should ideally be DNxHR HQX in a MOV container.  This will output a file named ```HDR_VP9_output.mp4```, and if this file already exists it will be automatically overwritten which is why I recommend single project directories for processing one file at a time.  Also you can look for a ```ffmpeg-YYYYMMDD-######.log``` file which is created on every run of the script that can contain errors if they occur.

### Vimeo

I don't currently use Vimeo but it does have HDR support.  I'm more keen to document HDR workflows with YouTube initially but it might also be fun sometime to more thoroughly test Vimeo with HDR see what advantages it has over YouTube if any.

## Recommended Hardware for HDR

To engage in HDR content creation you will need:

1. An HDR monitor, TV, possibly even a phone/tablet with an HDR display.  To my surprise there are some great tips for grading HDR on an SDR display using monitor LUTs which have allowed me to get HDR grades that look great on an HDR display, however I still really want to see it in HDR before publishing anything.  I also recommend something like a [DeckLink Mini Monitor 4K HDMI output card](https://www.blackmagicdesign.com/products/decklink/techspecs/W-DLK-32) capable of sending a full 444 HDMI signal with HDR metadata to your HDR TV/Monitor so it can be used for 10-bit HDR display inside Resolve Studio as a dedicated monitor.

## Recommended Software for HDR

<p align="center">
  <img width="978" height="409" src="images/bmd_davinci_resolve_studio.png">
</p>

1. Resolve Studio.  If you are new to HDR and haven't already been making HDR videos you probably will want Resolve Studio.  It may not be used in some of the tutorials in this guide but its the top tool for HDR content creation right with its excellent color management, HDR support, and color grading capabilities.

# Compiling ffmpeg With VP9 support

here we go


## Requirements For Compiling ffmpeg With VP9 Support

1. A running Windows 10 install, or a Centos/RHEL, or Debian/Apt Linux distribution.

2. [YouTube's Matroska Colour Metadata Ingestion Utility](https://github.com/YouTubeHDR/hdr_metadata)

3. My batch file and bash shell script in [the zip file that you can download right here](https://github.com/igarrison/HDRYouTubeCreatorGuide/archive/master.zip) and installing the Windows Subsystem for Linux (WSL) as instructed in the next section below.  WSL is needed to compile ffmpeg, its dependencies, and to run the resulting binary in a linux/posix environment where they encode VP9 more reliably.  If you don't care about VP9 on Windows or smaller HDR files then you don't need to bother with WSL or my zip file.

4. I also recommended downloading [Wesley Knapp's HDR_MetaJECTOR.bat](http://www.wesleyknapp.com/s/Wesley_Knapp-HDR_Tools_v3.zip) and .  These will be used for embedding HDR to SDR LUT files into your HDR files uploaded to YouTube if you find the automatic HDR to SDR conversion unsatisfactory.

## Compile VP9 Enabled ffmpeg

1. Linux users can skip to step 4.  In Windows 10 head to Control Panel > Programs > Turn Windows Features On Or Off. Enable the "Windows Subsystem for Linux" option in the list, and then click the OK button.  This will have you reboot your system when its finished.

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

## How To Compress an HDR Master to VP9

1. Using the Windows Explorer make a new project directory inside C:\HDR2VP9

2. Extract the contents of the [zip file in this repo](https://github.com/igarrison/HDRYouTubeCreatorGuide/archive/master.zip) into your new empty project directory.

3. Copy the ```C:\HDR2VP9\ffmpeg``` file into it.  This is the same file compiled from the previous section.

4. Copy your mov/DNxHR HQX HDR master file into the project directory and rename it to HDR_master.mov

5. Double click on runme.bat.  If all works correctly you'll see this program periodically output a log of text as its encoding.  When its done you should find a file 2pass_vp9_output.mp4 in the same directory.

## HDR Bitrates

You should know the bitrate of all your cameras and footage they produce.  If you don't have this information use some media inspection tools (VLC, exiftool) or internet searches to try and determine the bitrates.  My my Panasonic GH5 shoots 150Mbps at 4k 10-bit 4:2:2 so this is my maximum upper limit on bitrate for my HDR videos.

[YouTube has their own recommendations for bitrates on uploaded videos](https://support.google.com/youtube/answer/1722171?hl=en).  Note that HDR videos are given a small additional amount of bitrate over SDR videos, just 2Mbps at 1080p but it can go up to +17Mbps in the most extreme case with 4k at the highest frame rates.

**Recommended bitrates for SDR uploads**

| Type | Video Bitrate, Standard Frame Rate (24, 25, 30) | Video Bitrate, High Frame Rate (48, 50, 60) |
|------|-------------------------------------------------|---------------------------------------------|
| 2160p (4k) | 35-45 Mbps |	53-68 Mbps |
| 1080p	| 8 Mbps | 12 Mbps |
| 720p | 5 Mbps | 7.5 Mbps |

**Recommended bitrates for HDR uploads**

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

With encoding being a garbage-in/garbage-out operation we know that we should be uploading at bitrates meeting YouTube's recommendations at a minimum.  So with this information and my intent to publish at 4k at 29.97yfps I can determine that ideally I go no lower than 56Mbps as my minimum bitrate and no higher than 104Mbps (DNXHR HQX at 4k 29.976fps lowers my 150Mbps bitrate out of camera down to 104Mbps).

The default bitrate in ```ffmpeg_vp9_incantation.sh``` is 90Mbps minimum, 95Mbps average, and 100Mbps maximum.  These bitrates are optimized for 4k at 29.97fps which may be really high for 1080p HDR but you can use a text editor to modify the bash script to change these values.

## YouTube Optimizations for ffmpeg & Resolve Studio

Resolve and other editing suites may expose some but not all of a codec's parameters so videos may not always strictly comply with YouTube's recommendations.  Their video ingestion systems are fairly flexible and mostly do a great job of making the best video as quickly as they can with what you upload to them.  I've already added these flags to ```ffmpeg_vp9_incantation.sh```.

* [YouTube recommends a moov atom at the front of the file (fast start)](https://support.google.com/youtube/answer/1722171?hl=en).  Make sure to use a streaming format, like an mkv, .mp4 or a .mov, with the metadata at the front of the container YouTube will begin processing your video WHILE you are uploading it, drastically reducing overall turnaround time. This will make things MUCH faster, with no negative side effect."  The "Network Optimization" checkbox under delivery in Resolve Studio does this but we want it maintained through our ffmpeg encodes as we could be dealing with huge files.  This is ```-movflags +faststart``` in ffmpeg.

* [YouTube recommends 2 consecutive B frames](https://support.google.com/youtube/answer/1722171?hl=en).  This is ```-bf 2``` in ffmpeg.

* [YouTube recommends close GOP](https://support.google.com/youtube/answer/1722171?hl=en).  This is ```-flags +cgop``` in ffmpeg.

* [Consider this Encoding for Youtube article which contains tips by google video infrastructure engineer Colleen Henry](http://www.streamingmedia.com/Articles/Editorial/Featured-Articles/Encoding-for-YouTube-How-to-Get-the-Best-Results-83876.aspx) which says "You can noticeably improve the quality of your video on YouTube by using a sophisticated, scene aware, denoising filter prior to uploading."  The denoise features in Resolve Studio is pretty good and we should use it whenever, but don't push it too far as it the reduces details in your image.

## Results

You can tune the encoding speed by editing ```ffmpeg_vp9_incantation.sh``` if you are willing to sacrifice some quality for speed.  Its a value between 0 (slowest/best quality) and 4 (fastest/lowest quality) and the default is 1.  You can also adjust other things like the container, bitrate, and input/output filenames as well.

Click on the images to see the example video on YouTube.  TODO: replace the images with the exact same video frame for a better side by side comparison.

**BEFORE VP9 ENCODING:** Consider this the scientific control.  Its a 3.9GB 47 second MOV/DNxHR HQX HDR master straight out of Resolve Studio to Youtube and processed by YouTube's automatic HDR to SDR conversion.  [Link to high quality image](images/HDR_master.png).

[![Before VP9 Encoding, High Quality Original Master](images/HDR_master_thumbnail.png)](https://www.youtube.com/watch?v=5eDVhFBoc20)

 **AFTER VP9 ENCODING**: the VP9 encode it took 49 minutes to reduce this 47 second 3.9GB video to 362MB without stripping HDR metadata using the workflow recommended by Google VP9/infrastructure/HDR engineers.   This also uses YouTube's automatic HDR to SDR conversion.  WARNING: My PC is a beefy 10-core i9-7900X with 64GB RAM and this encoding is very slow but the speed is configurable!  [Link to high quality image](images/HDR_VP9_output.png)

[![After VP9 Encoding, Highly Compressed](images/HDR_VP9_output_thumbnail.png)](https://www.youtube.com/watch?v=dV4p5qQx9Kw)

Image quality differences can be seen especially in areas of motion (the waterfall) and there does appear to be a slight shift in color tint towards green or yellow.  I think the sharpness and quality of details is remarkably good for the static portions of the video in a side by side comparison.  Is it as high of quality as the DNxHR master?  No, but that wasn't the goal though!  We should only be using VP9 because our DNxHR masters are too large to upload to YouTube, our back is to a wall, and we need options like VP9/h265 to make some size/image quality trade-offs!  In the context of the 3.9GB -> 362MB reduction in file size while maintaining 10-bit color and HDR metadata I think the VP9 results here are still a huge win.

# HDR to SDR Conversion LUTs (YouTube)

## Creating a Custom HDR to SDR LUT

YouTube will automatically convert SDR versions of your HDR videos uploaded to them, however if you dislike this color grade you can embed a LUT file into the video uploaded to YouTube that they will use for the SDR conversion process.  This is roughly how its done in Resolve Studio.

<more notes here>

## Embedding Custom HDR to SDR LUT Files

1. Download [YouTube's Matroska Colour Metadata Ingestion Utility](https://github.com/YouTubeHDR/hdr_metadata) for your given platform.  Copy mkvinfo.exe/mkvmerge.exe into the same project directory.

2. I recommend grabbing [Wesley Knapp's HDR_MetaJECTOR batch file](http://www.wesleyknapp.com/s/Wesley_Knapp-HDR_Tools_v3.zip) to simplify launching the mkvmerge incantation to inject HDR metadata or attach a SDR to SDR LUT file.  Copy the HDR_MetaJECTOR batch file into the same project directory.

3. Double click on the ```HDR_MetaJECTOR.bat``` script in Windows Explorer.  This will launch an MSDOS window which you can drag-and-drop both your ```HDR_VP9_output.mp4``` and any LUT files to embed into your video file prior to uploading to YouTube.  It only takes a couple seconds to run and will produce a new file with your VP9 stream in a new ```.mkv``` container.


# FAQ

Q. Premiere for HDR video?

A. No, not yet!  It does have rec2020/HDR scopes, the ability to export 10-bit h265 with HDR metadata, but a few of its major flaws: 1) The viewports and external monitors managed by Premiere are rec709-only and everything being displayed will peak as soon as brightness is pushed at or above 120 nits.  [Mysterybox writes about the problem here if you search for 120 nits](https://www.mysterybox.us/blog/2016/11/17/adobe-premiere-cc-2017-real-world-feature-review).  This means you cannot ever see what you grade in Premiere no matter what you do, and I'm not jedi enough to ONLY use the scopes. and 2) Premiere lacks any real color management support which is something that instantly becomes more complicated when you leave the srgb/rec709 world for the wild west of rec2020 and are having to deal with LOG gamma curves directly because there aren't as many rec2020 LUTs as there are for rec709/SRGB.  I love Premiere for editing but it has been a big disappointment when it comes to HDR as I lost months trying to make it work until I became aware of its shortcomings.

---

Q. This whole Rube Goldberg machine with a Linux environment to run a custom compiled version of ffmpeg with a shell script called by a bath file... really?  Why can't you suggest something better?  What about XYZ?

A. I couldn't find any windows builds of ffmpeg with vp9 support that didn't have problems with a 2-pass encodes.  Maybe this will get fixed in a future build.  If anyone sees workflow improvements please email me.  I'm a Linux guy so solutions in that ecosystem are easy to me even if they seem awkward on the Windows platform.

---

Q. Why not HEVC/h265 instead of VP9 out of ffmpeg?

A. It performs similarly to VP9 and is gaining more support all the time.  It has the advantage that you could just use the official ffmpeg builds for h265 and skip on compiling ffmpeg entirely.  I think h265 is great and probably would have used it if I hadn't stumbled on some of those google engineer writings about VP9.  I've used h265 a fair bit but haven't ever done anything with VP9 before.  I have also heard a few smart engineers talking about some of the technical merits of vp9 over h265 for more efficient compression that I've been meaning to see for myself.

---

Q. What is the deal with 10-bit color on Geforce cards on Windows?  Do I need to buy a Quadro card for HDR?

A. TODO: I've got some good responses the 10-bit/HDR display problems.

---

Q. How to integrate RAW/DNG images and OpenEXR's into Resolve Studio for HDR?

A. TODO: Something I'd like to know.

---

Q. How do you manage different color spaces and gammas in Resolve Studio in an HDR project?  All of my photos and motion graphics are SRGB apparently!

A. TODO: I'm aware of a few ways to do this, but should just pick one method and document it.  If there is a better way hopefully somebody will tell me.

---

Q. Is HDR Photography like HDR Video?

A. No!


# Special Thanks

Daniel Gordon

# Author

Ian Garrison <garrison@technoendo.net>

# Additional Resources

[WebM Project's VP9 Encoding Guide](http://wiki.webmproject.org/ffmpeg/vp9-encoding-guide).

[FFMPEG.org's VP9 Encoding Guide](https://trac.ffmpeg.org/wiki/Encode/VP9).

[Wesley Knapp's blog article on Grading HDR video on a rec709 monitor for youtube & beyond](http://www.wesleyknapp.com/blog/hdr).

Mystery Box has written many excellent blog posts on HDR: [like this](https://www.mysterybox.us/blog/2016/10/27/hdr-video-part-5-grading-mastering-and-delivering-hdr) and [this one](https://www.mysterybox.us/blog/2016/11/7/how-to-upload-hdr-video-to-youtube-with-a-lut), and they also [sell a bunch of HDR LUT files on their online store for cameras like the GH5/GH5S](https://www.mysterybox.us/blog/2018/1/8/panasonic-gh5s-hdr10).

[Alexis Van Hurksman's blog on HDR, Resolve, and Creative Grading](http://vanhurkman.com/wordpress/?p=3548).

[YouTube video from CRFTSHO titled Easy HDR video for YOUTUBE/vimeo tutorial part 2 - how to set up your project for HDR workflow](https://www.youtube.com/watch?v=QJAiR6lh9Z0).
