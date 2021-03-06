#!/bin/bash

set -e
set -o xtrace

apt-get -y install ca-certificates
sed -i -e 's/http:\/\/deb/https:\/\/deb/g' /etc/apt/sources.list
echo 'deb https://deb.debian.org/debian buster-backports main' >/etc/apt/sources.list.d/backports.list
apt-get update
apt-get -y install \
	abootimg \
	android-sdk-ext4-utils \
	autoconf \
	automake \
	bc \
	bison \
	ccache \
	cmake \
	cpio \
	debootstrap \
	fastboot \
	flex \
	g++ \
	git \
	lavacli \
	libdrm-dev \
	libelf-dev \
	libexpat1-dev \
	llvm-8-dev \
	pkg-config \
	python \
	python3-mako \
	python3-pil \
	python3-requests \
	python3-pip \
	python3-setuptools \
	unzip \
	wget \
	xz-utils \
	zlib1g-dev

pip3 install git+http://gitlab.freedesktop.org/freedesktop/ci-templates@6f5af7e5574509726c79109e3c147cee95e81366

apt install -y --no-remove -t buster-backports \
    meson

arch=armhf
. .gitlab-ci/container/cross_build.sh

. .gitlab-ci/container/container_pre_build.sh

# dependencies where we want a specific version
export LIBDRM_VERSION=libdrm-2.4.102

wget https://dri.freedesktop.org/libdrm/$LIBDRM_VERSION.tar.xz
tar -xvf $LIBDRM_VERSION.tar.xz && rm $LIBDRM_VERSION.tar.xz
cd $LIBDRM_VERSION; meson build -D vc4=true -D freedreno=true -D etnaviv=true; ninja -C build install; cd ..
rm -rf $LIBDRM_VERSION

. .gitlab-ci/container/container_post_build.sh
