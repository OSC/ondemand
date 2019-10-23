FROM centos:7
LABEL maintainer="tdockendorf@osc.edu; johrstrom@osc.edu"

# setup the ondemand repositories
COPY files/ondemand-web.repo /etc/yum.repos.d/ondemand-web.repo
COPY files/ondemand-ci-web.repo /etc/yum.repos.d/ondemand-ci-web.repo
RUN curl https://yum.osc.edu/ondemand/RPM-GPG-KEY-ondemand -o /etc/pki/rpm-gpg/RPM-GPG-KEY-ondemand
RUN rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-ondemand

# update
RUN yum install -y centos-release-scl 
RUN yum -y update

# install all the dependencies
RUN yum install -y \
        file \
        lsof \
        sqlite-devel \
        sudo \
        httpd24 \
        rh-ruby25 \
        rh-nodejs10 \
        ondemand-passenger-6.0.4-2.el7.x86_64 \
        ondemand-nginx-1.17.3-2.p6.0.4.el7.x86_64

RUN yum clean all && rm -rf /var/cache/yum/*
RUN rm -rf /var/cache/yum/*

# copy basic stuff to /opt/ood and /var/www/ood/apps
RUN mkdir -p /opt/ood
RUN mkdir -p /var/www/ood/{apps,public,discover}
RUN mkdir -p /var/www/ood/apps/{sys,dev,usr}

COPY ../../mod_ood_proxy          /opt/ood/mod_ood_proxy
COPY ../../nginx_stage/           /opt/ood/nginx_stage
COPY ../../ood-portal-generator   /opt/ood/ood-portal-generator
COPY ../../ood_auth_map           /opt/ood/ood_auth_map
COPY ../../build/apps             /var/www/ood/apps/sys

# copy configuration files
COPY ../../nginx_stage/share/nginx_stage_example.yml            /etc/ood/config/nginx_stage.yml
COPY ../../ood-portal-generator/share/ood_portal_example.yml    /etc/ood/config/ood_portal.yml

# make some misc directories & files
RUN mkdir -p /var/lib/ondemand-nginx/config/apps/{sys,dev,usr}
RUN touch /var/lib/ondemand-nginx/config/apps/sys/{dashboard,shell,files,file-editor,activejobs,myjobs}.conf

# copy needed files into the image
COPY files/service-environment    /opt/rh/httpd24/service-environment
COPY files/ood-sudoers            /etc/sudoers.d/ood

# run the OOD binaries to setup the env
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal
RUN /opt/ood/nginx_stage/sbin/update_nginx_stage

EXPOSE 80
CMD [ "/opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper", "-DFOREGROUND" ]
