#!/bin/bash

##
apt install -y devscripts
apt install -y debhelper dh-make dh-exec rsync vim

## Build MPP
# mkdir -p ~/dev && cd ~/dev
# git clone -b jellyfin-mpp --depth=1 https://github.com/nyanmisaka/mpp.git rkmpp
# pushd rkmpp
# mkdir obj-arm-linux-gnueabihf
# pushd obj-arm-linux-gnueabihf
# cmake \
#     -DCMAKE_INSTALL_PREFIX=/usr \
#     -DCMAKE_BUILD_TYPE=Release \
#     -DBUILD_SHARED_LIBS=ON \
#     -DBUILD_TEST=OFF \
#     ..
# make -j $(nproc)
# make install

## check files after build
cd ~/dev/rkmpp
#echo "set(ROCKCHIP_MPP_DEMOS ON)" >> CMakeLists.txt
rm debian/rockchip-mpp-demos.install

## changelog ok
# cat debian/changelog

## control ok
# cat debian/control  |grep Architecture
# Architecture: any
# Architecture: any
# Architecture: any
# Architecture: any

## rules
## cp debian/rules debian/rules.bkp
## watch out the tabs
## cat > debian/rules
#!/usr/bin/make -f

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
    cmake \
       		-DCMAKE_INSTALL_PREFIX=/usr \
        	-DCMAKE_BUILD_TYPE=Release \
	        -DBUILD_SHARED_LIBS=ON \
	        -DBUILD_TEST=OFF \
          -DRKPLATFORM=ON \
          -DHAVE_DRM=ON 
    cd /opt/mpp

override_dh_auto_build:
    cd obj-arm-linux-gnueabihf 
    make -j$(nproc)

override_dh_auto_install:
    cd obj-arm-linux-gnueabihf 
    make install DESTDIR=$(CURDIR)/debian/tmp

EOF    

## build package
debuild --no-lintian --build=binary -us -uc -Zxz -z1

## results
# cd ~/dev
#  ls -lah *.deb 
# -rw-r--r-- 1 root root  46K Dec 27 15:58 librockchip-mpp-dev_1.5.0-1_armhf.deb
# -rw-r--r-- 1 root root 885K Dec 27 15:58 librockchip-mpp1_1.5.0-1_armhf.deb
# -rw-r--r-- 1 root root  30K Dec 27 15:58 librockchip-vpu0_1.5.0-1_armhf.deb
# -rw-r--r-- 1 root root 4.6K Dec 27 15:58 rockchip-mpp-demos_1.5.0-1_armhf.deb

## test ok
# dpkg -i *.deb
# Selecting previously unselected package librockchip-mpp-dev.
# (Reading database ... 36608 files and directories currently installed.)
# Preparing to unpack librockchip-mpp-dev_1.5.0-1_armhf.deb ...
# Unpacking librockchip-mpp-dev (1.5.0-1) ...
# Selecting previously unselected package librockchip-mpp1.
# Preparing to unpack librockchip-mpp1_1.5.0-1_armhf.deb ...
# Unpacking librockchip-mpp1 (1.5.0-1) ...
# Selecting previously unselected package librockchip-vpu0.
# Preparing to unpack librockchip-vpu0_1.5.0-1_armhf.deb ...
# Unpacking librockchip-vpu0 (1.5.0-1) ...
# Selecting previously unselected package rockchip-mpp-demos.
# Preparing to unpack rockchip-mpp-demos_1.5.0-1_armhf.deb ...
# Unpacking rockchip-mpp-demos (1.5.0-1) ...
# Setting up librockchip-mpp1 (1.5.0-1) ...
# Setting up librockchip-vpu0 (1.5.0-1) ...
# Setting up rockchip-mpp-demos (1.5.0-1) ...
# Setting up librockchip-mpp-dev (1.5.0-1) ...
# Processing triggers for libc-bin (2.39-0ubuntu8.3) ...


## Build RGA
# mkdir -p ~/dev && cd ~/dev
# git clone -b jellyfin-rga --depth=1 https://github.com/nyanmisaka/rk-mirrors.git rkrga
# meson setup rkrga rkrga_build \
#     --prefix=/usr \
#     --libdir=lib \
#     --buildtype=release \
#     --default-library=shared \
#     -Dcpp_args=-fpermissive \
#     -Dlibdrm=false \
#     -Dlibrga_demo=false
# meson configure rkrga_build
# ninja -C rkrga_build install

## check files after build
cd ~/dev/rkrga
rm -Rf ~/dev/rkrga_build

## changelog ok
# cat debian/changelog

# cat debian/control  |grep Architecture
# Architecture: any
# Architecture: any

## rules
## cp debian/rules debian/rules.bkp
## watch out the tabs
## cat > debian/rules
#!/usr/bin/make -f
# See debhelper(7) (uncomment to enable)
# output every command that modifies files on the build system.
export DH_VERBOSE = 1

source_dir ?= $(CURDIR)
build_dir ?= $(source_dir)/obj-arm-linux-gnueabihf

%:
	dh $@ --buildsystem=meson

override_dh_auto_configure:
	@echo "Diretório atual: $(CURDIR)"
	@echo "Diretório fonte: $(source_dir)"
	@echo "Diretório de build: $(build_dir)"
	mkdir -p $(build_dir)
	meson setup $(source_dir) $(build_dir) \
        	--prefix=/usr \
        	--libdir=lib \
	        --buildtype=release \
        	--default-library=shared \
	        -Dcpp_args=-fpermissive \
	        -Dlibdrm=false \
        	-Dlibrga_demo=false
	meson configure $(build_dir)

override_dh_auto_install:
	@echo "Instalando no diretório temporário: $(CURDIR)/debian/tmp"
    mkdir -p $(CURDIR)/debian/tmp/usr/lib/pkgconfig
    mkdir -p $(CURDIR)/debian/tmp/usr/include/rga
    mkdir -p $(CURDIR)/debian/tmp/usr/lib/test
    DESTDIR=$(CURDIR)/debian/tmp ninja -C $(build_dir) install
    rsync -av --exclude='test' $(CURDIR)/debian/tmp/usr/lib/ $(CURDIR)/debian/tmp/usr/lib/test

## build package
debuild --no-lintian --build=binary -us -uc -Zxz -z1

## results
# cd ~/dev
# ls -lah librga*.deb 
# -rw-r--r-- 1 root root 18K Dec 27 21:18 librga-dev_2.2.0-1_armhf.deb
# -rw-r--r-- 1 root root 70K Dec 27 21:18 librga2_2.2.0-1_armhf.deb

## test ok
# dpkg -i librga*.deb 
# Selecting previously unselected package librga-dev.
# (Reading database ... 36694 files and directories currently installed.)
# Preparing to unpack librga-dev_2.2.0-1_armhf.deb ...
# Unpacking librga-dev (2.2.0-1) ...
# Selecting previously unselected package librga2.
# Preparing to unpack librga2_2.2.0-1_armhf.deb ...
# Unpacking librga2 (2.2.0-1) ...
# Setting up librga-dev (2.2.0-1) ...
# Setting up librga2 (2.2.0-1) ...
# Processing triggers for libc-bin (2.39-0ubuntu8.3) ...

## Build libyuv
cd /opt
git clone https://chromium.googlesource.com/libyuv/libyuv/
cd libyuv
cmake \
    -DCMAKE_INSTALL_PREFIX=/usr \
    -DCMAKE_BUILD_TYPE=Release \
    -DBUILD_SHARED_LIBS=ON
make -j$(nproc) 
make install

## Gen deb package
mkdir -p libyuv-dev/usr/bin libyuv-dev/usr/lib libyuv-dev/usr/include
cp /usr/bin/yuvconvert libyuv-dev/usr/bin/
cp /usr/lib/libyuv.* libyuv-dev/usr/lib/
cp -r /usr/include/libyuv libyuv-dev/usr/include/
mkdir libyuv-dev/DEBIAN

cat <<EOF | tee libyuv-dev/DEBIAN/control
Package: libyuv
Version: 1.0
Section: libs
Priority: optional
Architecture: armhf
Maintainer: Seu Nome <seuemail@exemplo.com>
Description: Biblioteca YUV para conversão de formatos de vídeo.
EOF

dpkg-deb --build libyuv-dev
#dpkg -i libyuv-dev.deb

## Build ffmpeg
apt update
apt-get install -y libavcodec-extra libjs-bootstrap devscripts
git clone --branch mpp-rga-ffmpeg-6.1.1 https://github.com/hbiyik/FFmpeg.git --depth=1 ffmpeg-mpp-rga
cd ffmpeg-mpp-rga
./configure \
  --prefix=/usr \
  --arch=arm \
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
checkinstall -y --deldoc=yes --pkgversion=10:4.2.1 --pkgname=ffmpeg-mpp-rga

## Build ffmpeg
apt update
apt-get install -y libavcodec-extra libjs-bootstrap devscripts

# mkdir -p ~/dev && cd ~/dev
# git clone --depth=1 https://github.com/nyanmisaka/ffmpeg-rockchip.git ffmpeg
# cd ffmpeg
# ./configure \
#   --prefix=/usr \
#   --arch=arm \
#   --enable-nonfree \
#   --enable-version3 \
#   --enable-libdrm \
#   --enable-rkmpp \
#   --enable-rkrga \
#   --enable-libfdk-aac \
#   --enable-indev=alsa \
#   --enable-outdev=alsa \
#   --disable-doc
# make -j $(nproc)
# make install

## ffmpeg from ffmpeg10.tar
cd /opt/FFmpeg
./configure \
  --prefix=/usr \
  --arch=arm \
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
checkinstall -y --deldoc=yes --pkgversion=10:4.2.1 --pkgname=ffmpeg-arm32

git clone --branch mpp-rga-ffmpeg-6 https://github.com/hbiyik/FFmpeg.git --depth=1
cd /opt/FFmpeg
./configure \
  --prefix=/usr \
  --arch=arm \
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
checkinstall -y --deldoc=yes --pkgversion=10:4.2.1 --pkgname=ffmpeg-arm32-v1
