#!/bin/bash
## Ref
## https://github.com/hbiyik/FFmpeg

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
  bzip2 \
  alsa-base libasound2-dev \
  libdrm-dev \
  libfdk-aac-dev

## Install deb packages dependencies
apt install -y \
  devscripts \
  debhelper \
  dh-make \
  dh-exec \
  rsync \
  vim \
  libavcodec-extra \
  libjs-bootstrap \
  checkinstall

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

## Gen deb package
mkdir -p mpp-dev/usr/bin mpp-dev/usr/lib/aarch64-linux-gnu/pkgconfig mpp-dev/usr/include
cp /usr/lib/aarch64-linux-gnu/librockchip_mpp.* mpp-dev/usr/lib/aarch64-linux-gnu
cp /usr/lib/aarch64-linux-gnu/pkgconfig/rockchip_mpp.pc mpp-dev/usr/lib/aarch64-linux-gnu/pkgconfig
cp -r /usr/include/rockchip mpp-dev/usr/include/
mkdir mpp-dev/DEBIAN

cat <<EOF | tee mpp-dev/DEBIAN/control
Package: mpp-dev
Version: 1.0
Section: libs
Priority: optional
Architecture: arm64
Maintainer: Seu Nome <seuemail@exemplo.com>
Description: Biblioteca Rockchip-MPP.
EOF

dpkg-deb --build mpp-dev

## install packages
dpkg -i mpp-dev.deb