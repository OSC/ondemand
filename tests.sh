#!/usr/bin/env bash

set -ex

# Remove nodocs that breaks some things
sed -i -r '/^tsflags/d' /etc/yum.conf

# Get dependencies
yum install -y --skip-broken centos-release-scl
yum install -y https://yum.osc.edu/ondemand/latest/ondemand-release-web-latest-1-6.noarch.rpm
yum install -y \
  make \
  gcc \
  gcc-c++ \
  zlib-devel \
  libxslt-devel \
  curl \
  rsync \
  sqlite-devel \
  git \
  redhat-rpm-config \
  selinux-policy-devel \
  ondemand-ruby \
  ondemand-python \
  ondemand-nodejs \
  ondemand-runtime

# Build SELinux module
pushd packaging
sed -i 's/@VERSION@/1/g' ondemand-selinux.te
make -f /usr/share/selinux/devel/Makefile
popd

# Setup environment
source scl_source enable ondemand || :

# Build and install
rake -mj ${NUM_TASKS:-$(nproc)} build && rake install
