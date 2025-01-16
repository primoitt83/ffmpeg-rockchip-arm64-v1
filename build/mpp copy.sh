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

## Install deb packages dependencies
apt install -y \
  devscripts \
  debhelper \
  dh-make \
  dh-exec

## Build MPP
cd /opt
git clone -b jellyfin-mpp --depth=1 https://github.com/nyanmisaka/mpp.git rkmpp
cd rkmpp
rm debian/rockchip-mpp-demos.install
rm debian/rules

printf '%s\n' '#!/usr/bin/make -f
DPKG_EXPORT_BUILDFLAGS = 1
include /usr/share/dpkg/default.mk

ifneq ($(DEB_HOST_GNU_TYPE),$(DEB_BUILD_GNU_TYPE))
    export CMAKE_TOOLCHAIN_FILE=/etc/dpkg-cross/cmake/CMakeCross.txt
endif

# main packaging script based on dh7 syntax
%:
	dh $@ --parallel --buildsystem=cmake

override_dh_auto_configure:
	mkdir -p obj-arm-linux-gnueabihf
	cd obj-arm-linux-gnueabihf
	cmake -DCMAKE_INSTALL_PREFIX=/usr -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=ON -DBUILD_TEST=OFF
	cd /opt/rkmpp

override_dh_auto_build:
	cd obj-arm-linux-gnueabihf
	make -j$(nproc)

override_dh_auto_install:
	cd obj-arm-linux-gnueabihf
	make install DESTDIR=$(CURDIR)/debian/tmp
' > debian/rules

## build package
debuild --no-lintian --build=binary -us -uc -Zxz -z1

## copy deb files
mkdir /root/deb
cp /opt/*.deb /root/deb