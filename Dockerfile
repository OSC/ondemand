FROM centos:7
LABEL maintainer="tdockendorf@osc.edu; johrstrom@osc.edu"

# setup the ondemand repositories
RUN yum -y install https://yum.osc.edu/ondemand/latest/ondemand-release-web-latest-1-6.noarch.rpm

# install all the dependencies
RUN yum install -y centos-release-scl && \
    yum -y update && \
    yum install -y \
        file \
        lsof \
        sqlite-devel \
        sudo \
        httpd24 \
        rh-ruby25 \
        rh-nodejs10 \
        ondemand-runtime \
        ondemand-passenger-6.0.4-2.el7.x86_64 \
        ondemand-nginx-1.17.3-2.p6.0.4.el7.x86_64

RUN yum clean all && rm -rf /var/cache/yum/*

# copy basic stuff to /opt/ood and /var/www/ood/apps
RUN mkdir -p /opt/ood
RUN mkdir -p /var/www/ood/{apps,public,discover}
RUN mkdir -p /var/www/ood/apps/{sys,dev,usr}

COPY mod_ood_proxy          /opt/ood/mod_ood_proxy
COPY nginx_stage/           /opt/ood/nginx_stage
COPY ood-portal-generator   /opt/ood/ood-portal-generator
COPY ood_auth_map           /opt/ood/ood_auth_map
COPY build/apps             /var/www/ood/apps/sys

# copy configuration files
COPY nginx_stage/share/nginx_stage_example.yml            /etc/ood/config/nginx_stage.yml
COPY ood-portal-generator/share/ood_portal_example.yml    /etc/ood/config/ood_portal.yml

# make some misc directories & files
RUN mkdir -p /var/lib/ondemand-nginx/config/apps/{sys,dev,usr}
RUN touch /var/lib/ondemand-nginx/config/apps/sys/{dashboard,shell,files,file-editor,activejobs,myjobs}.conf

# setup sudoers for apache
RUN echo -e 'Defaults:apache !requiretty, !authenticate \n\
Defaults:apache env_keep += "NGINX_STAGE_* OOD_*" \n\
apache ALL=(ALL) NOPASSWD: /opt/ood/nginx_stage/sbin/nginx_stage' >/etc/sudoers.d/ood

# run the OOD executables to setup the env
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal
RUN /opt/ood/nginx_stage/sbin/update_nginx_stage
RUN sed -i 's#HTTPD24_HTTPD_SCLS_ENABLED=.*#HTTPD24_HTTPD_SCLS_ENABLED="httpd24 ondemand"#g'  /opt/rh/httpd24/service-environment

EXPOSE 80
CMD [ "/opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper", "-DFOREGROUND" ]
