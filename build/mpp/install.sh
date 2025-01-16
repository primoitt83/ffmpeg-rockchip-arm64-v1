#!/bin/bash

dpkg -i librockchip-*
dpkg -i rockchip-mpp-demos_1.5.0-1_armhf.deb 
dpkg -i librga*
dpkg -i ffmpeg_4.2.1-1_armhf.deb 

cp /usr/lib/test/pkgconfig/librga.pc /usr/lib/pkgconfig/
cp /usr/lib/test/librga.so* /usr/lib
ldconfig

export DEBIAN_FRONTEND=noninteractive
apt install -y alsa-base libasound2-dev libdrm-dev libfdk-aac-dev    

ffmpeg version b81c3bf Copyright (c) 2000-2023 the FFmpeg developers
  built with gcc 13 (Ubuntu 13.3.0-6ubuntu2~24.04)
  configuration: --prefix=/usr --arch=arm --enable-nonfree --enable-version3 --enable-libdrm --enable-rkmpp --enable-rkrga --enable-libfdk-aac --enable-indev=alsa --enable-outdev=alsa --disable-doc
  libavutil      58. 29.100 / 58. 29.100
  libavcodec     60. 31.102 / 60. 31.102
  libavformat    60. 16.100 / 60. 16.100
  libavdevice    60.  3.100 / 60.  3.100
  libavfilter     9. 12.100 /  9. 12.100
  libswscale      7.  5.100 /  7.  5.100
  libswresample   4. 12.100 /  4. 12.100
Hyper fast Audio and Video encoder
usage: ffmpeg [options] [[infile options] -i infile]... {[outfile options] outfile}...
