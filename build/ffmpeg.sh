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
#dpkg -i mpp-dev.deb  

## copy package
mkdir -p /root/deb
cp mpp-dev.deb /root/deb

## Build RGA
cd /opt
git clone -b jellyfin-rga --depth=1 https://github.com/nyanmisaka/rk-mirrors.git rkrga
cd rkrga
rm debian/rules
printf '%s\n' '#!/usr/bin/make -f
export DH_VERBOSE = 1

source_dir ?= $(CURDIR)
build_dir ?= $(source_dir)/obj-aarch64-linux-gnu

%:
	dh $@ --buildsystem=meson

override_dh_auto_configure:
	@echo "Diretório atual: $(CURDIR)"
	@echo "Diretório fonte: $(source_dir)"
	@echo "Diretório de build: $(build_dir)"
	mkdir -p $(build_dir)
	meson setup $(source_dir) $(build_dir) --prefix=/usr --libdir=lib --buildtype=release --default-library=shared -Dcpp_args=-fpermissive -Dlibdrm=false -Dlibrga_demo=false
	meson configure $(build_dir)

override_dh_auto_install:
	@echo "Instalando no diretório temporário: $(CURDIR)/debian/tmp"
	mkdir -p $(CURDIR)/debian/tmp/usr/lib/pkgconfig
	mkdir -p $(CURDIR)/debian/tmp/usr/include/rga
	mkdir -p $(CURDIR)/debian/tmp/usr/lib/test
	DESTDIR=$(CURDIR)/debian/tmp ninja -C $(build_dir) install
	rsync -av --exclude='"test"' $(CURDIR)/debian/tmp/usr/lib/ $(CURDIR)/debian/tmp/usr/lib/test
' > debian/rules

## build package
debuild --no-lintian --build=binary -us -uc -Zxz -z1

## install packages
cd /root/deb
dpkg -i *.deb
cd /opt
dpkg -i *.deb

## fix librga libs location
cp /usr/lib/test/pkgconfig/librga.pc /usr/lib/pkgconfig
cp /usr/lib/test/librga.so* /usr/lib

# Build the minimal FFmpeg (You can customize the configure and install prefix)
cd /opt
git clone --depth=1 https://github.com/nyanmisaka/ffmpeg-rockchip.git ffmpeg
cd ffmpeg
./configure \
  --prefix=/usr \
  --arch=arm64 \
  --enable-nonfree \
  --enable-version3 \
  --enable-libdrm \
  --enable-rkmpp \
  --enable-libfdk-aac \
  --enable-indev=alsa \
  --enable-outdev=alsa \
  --disable-doc \
  --disable-htmlpages
make -j $(nproc)
make install
rm /usr/share/ffmpeg/examples/Makefile
checkinstall -y --deldoc=yes --pkgversion=10:4.2.1 --pkgname=ffmpeg-arm64

## copy deb files
# mkdir /root/deb
cp /opt/*.deb /root/deb
cp /opt/ffmpeg/*.deb /root/deb