#!/bin/bash
## Dependencies
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y curl \
  alsa-base libasound2-dev \
  libdrm-dev \
  libfdk-aac-dev \
  v4l-utils \
  nginx \
  libnginx-mod-rtmp

## install packages
cd /root/deb
dpkg -i *.deb

## fix librga libs location
cp /usr/lib/test/pkgconfig/librga.pc /usr/lib/pkgconfig
cp /usr/lib/test/librga.so* /usr/lib

## nginx bkp
cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bkp