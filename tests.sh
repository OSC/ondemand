#!/usr/bin/env bash

set -ex

# Get dependencies
yum install -y centos-release-scl
yum install -y \
  make \
  curl \
  sqlite-devel \
  rh-ruby24 \
  rh-ruby24-rubygem-rake \
  rh-ruby24-rubygem-bundler \
  rh-ruby24-ruby-devel \
  rh-nodejs6 \
  rh-git29

# Setup environment
source scl_source enable rh-ruby24 rh-nodejs6 rh-git29 || :

# Build and install
rake -mj ${NUM_TASKS:-$(nproc)} && rake install
