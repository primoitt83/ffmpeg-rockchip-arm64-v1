#!/bin/bash
## Ref
## https://github.com/nyanmisaka/ffmpeg-rockchip

## Dependencies
export DEBIAN_FRONTEND=noninteractive
apt update
apt install -y \
  wget \
  autoconf automake \
  libtool \
  diffutils \
  cmake meson \
  git \
  texinfo \
  yasm nasm \
  build-essential \
  ninja-build \
  pkg-config \
  zlib1g-dev \
  bzip2

## Build MPP
cd /opt
git clone -b jellyfin-mpp --depth=1 https://github.com/nyanmisaka/mpp.git rkmpp
cd rkmpp
mkdir rkmpp_build
cd rkmpp_build
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_TEST=OFF \
    ..
make -j $(nproc)
make install

cd /opt
tar cvf rkmpp.tar rkmpp

## Copy files
mkdir -p /root/deb
cp /opt/rkmpp.tar /root/deb