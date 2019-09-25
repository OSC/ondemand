#!/usr/bin/env bash

set -ex

# Remove nodocs that breaks some things
sed -i -r '/^tsflags/d' /etc/yum.conf

# Get dependencies
yum install -y centos-release-scl
yum install -y https://yum.osc.edu/ondemand/latest/ondemand-release-web-latest-1-4.noarch.rpm
yum install -y \
  make \
  curl \
  sqlite-devel \
  git \
  rh-ruby24 \
  rh-ruby24-rubygem-rake \
  rh-ruby24-rubygem-bundler \
  rh-ruby24-ruby-devel \
  rh-nodejs6 \
  ondemand-runtime

# Setup environment
source scl_source enable ondemand || :

# Build and install
rake -mj ${NUM_TASKS:-$(nproc)} && rake install
