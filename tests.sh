#!/usr/bin/env bash

set -ex

# Get dependencies
yum install -y centos-release-scl
yum install -y \
  make \
  curl \
  sqlite-devel \
  rh-ruby22 \
  rh-ruby22-rubygem-rake \
  rh-ruby22-rubygem-bundler \
  rh-ruby22-ruby-devel \
  nodejs010 \
  git19

# Setup environment
source scl_source enable rh-ruby22 nodejs010 git19

# Build and install
rake && rake install
