#!/bin/bash
set -x

/opt/ood/ood-portal-generator/sbin/update_ood_portal

/usr/sbin/httpd -DFOREGROUND