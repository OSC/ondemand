#!/bin/bash

set -x
set -e

export USER=$(whoami) # $USER isn't set!?

APP_DEV_DIR="/home/$USER/ondemand/dev"
OOD_DEV_DIR="/var/www/ood/apps/dev/$USER"

sudo su root <<SETUP
  mkdir -p $OOD_DEV_DIR
  cd $OOD_DEV_DIR
  ln -s $APP_DEV_DIR gateway

  /opt/ood/ood-portal-generator/sbin/update_ood_portal --force --insecure
SETUP

sudo runuser -u ondemand-dex /usr/sbin/ondemand-dex serve /etc/ood/dex/config.yaml &
sudo /usr/sbin/httpd -DFOREGROUND
