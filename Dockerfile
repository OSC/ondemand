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
        sudo \
        gcc \
        gcc-c++ \
        git \
        patch \
        ondemand-runtime \
        ondemand-build \
        ondemand-apache \
        ondemand-ruby \
        ondemand-nodejs \
        ondemand-passenger \
        ondemand-nginx && \
    yum clean all && rm -rf /var/cache/yum/*

RUN mkdir -p /opt/ood
RUN mkdir -p /var/www/ood/{apps,public,discover}
RUN mkdir -p /var/www/ood/apps/{sys,dev,usr}

COPY mod_ood_proxy          /opt/ood/mod_ood_proxy
COPY nginx_stage/           /opt/ood/nginx_stage
COPY ood-portal-generator   /opt/ood/ood-portal-generator
COPY ood_auth_map           /opt/ood/ood_auth_map
COPY apps                   /opt/ood/apps
COPY Rakefile               /opt/ood/Rakefile

RUN  cd /opt/ood && \
    scl enable ondemand -- rake -mj4 build && \
    mv /opt/ood/apps/* /var/www/ood/apps/sys/ && \
	rm -rf /opt/ood/Rakefile /opt/ood/apps

# copy configuration files
RUN mkdir -p /etc/ood/config
RUN cp /opt/ood/nginx_stage/share/nginx_stage_example.yml            /etc/ood/config/nginx_stage.yml
RUN cp /opt/ood/ood-portal-generator/share/ood_portal_example.yml    /etc/ood/config/ood_portal.yml

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
RUN groupadd ood
RUN useradd --create-home --gid ood ood
RUN echo -n "ood" | passwd --stdin ood
RUN scl enable httpd24 -- htpasswd -b -c /opt/rh/httpd24/root/etc/httpd/.htpasswd ood ood


EXPOSE 80
CMD [ "/opt/rh/httpd24/root/usr/sbin/httpd-scl-wrapper", "-DFOREGROUND" ]
