FROM rockylinux/rockylinux:8
LABEL maintainer="tdockendorf@osc.edu; johrstrom@osc.edu"

ARG VERSION=3.1

# setup the ondemand repositories
RUN dnf -y install https://yum.osc.edu/ondemand/${VERSION}/ondemand-release-web-${VERSION}-1.el8.noarch.rpm

# install all the dependencies
RUN dnf -y update && \
    dnf install -y dnf-utils epel-release && \
    dnf config-manager --set-enabled powertools && \
    dnf -y module enable nodejs:18 ruby:3.1 && \
    dnf install -y \
        ondemand \
        ondemand-dex && \
    dnf clean all && rm -rf /var/cache/dnf/*

COPY launch-ood      /opt/ood/launch

# copy configuration files
RUN mkdir -p /etc/ood/config
RUN cp /opt/ood/nginx_stage/share/nginx_stage_example.yml            /etc/ood/config/nginx_stage.yml
RUN cp /opt/ood/ood-portal-generator/share/ood_portal_example.yml    /etc/ood/config/ood_portal.yml

# make some misc directories & files
RUN mkdir -p /var/lib/ondemand-nginx/config/apps/{sys,dev,usr}
RUN touch /var/lib/ondemand-nginx/config/apps/sys/{dashboard,shell,myjobs}.conf

# setup sudoers for apache
RUN echo -e 'Defaults:apache !requiretty, !authenticate \n\
Defaults:apache env_keep += "NGINX_STAGE_* OOD_*" \n\
apache ALL=(ALL) NOPASSWD: /opt/ood/nginx_stage/sbin/nginx_stage' >/etc/sudoers.d/ood

# run the OOD executables to setup the env
RUN /opt/ood/ood-portal-generator/sbin/update_ood_portal --insecure
RUN /opt/ood/nginx_stage/sbin/update_nginx_stage
# this one bc centos:8 doesn't generate localhost cert
RUN /usr/libexec/httpd-ssl-gencerts

EXPOSE 8080
EXPOSE 5556
EXPOSE 3035
CMD [ "/opt/ood/launch" ]
