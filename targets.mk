# Version
export version := v0.0.1

# Defaults
export OOD_IP ?= *:80
export OOD_SUBDOMAIN ?= apps.ood.org
export OOD_LUA_ROOT ?= /opt/ood/mod_ood_proxy/lib
export OOD_PUN_STAGE_CMD ?= sudo /opt/ood/nginx_stage/sbin/nginx_stage
export OOD_USER_MAP_CMD ?= /opt/ood/osc-user-map/bin/osc-user-map
export OOD_PUN_SOCKET_ROOT ?= /var/run/nginx
export OOD_PUBLIC_ROOT ?= /var/www
export OOD_PUN_URI ?= /pun
export OOD_NODE_URI ?= /node
export OOD_RNODE_URI ?= /rnode
export OOD_NGINX_URI ?= /nginx
export OOD_PUBLIC_URI ?= /public
export OOD_AUTH_TYPE ?= openid-connect

# Available environment variables when substituting in template
vars := $$version $$OOD_IP $$OOD_SUBDOMAIN $$OOD_LUA_ROOT $$OOD_PUN_STAGE_CMD \
	$$OOD_USER_MAP_CMD $$OOD_PUN_SOCKET_ROOT $$OOD_PUBLIC_ROOT $$OOD_PUN_URI \
	$$OOD_NODE_URI $$OOD_RNODE_URI $$OOD_NGINX_URI $$OOD_PUBLIC_URI $$OOD_AUTH_TYPE

# Targets below here

$(BUILDDIR)/$(CONFFILE): $(TMPLDIR)/$(CONFFILE).tmpl | $(BUILDDIR)
	envsubst '$(vars)' < $^ > $@

$(BUILDDIR):
	mkdir -p $@

.PHONY: install
install: $(BUILDDIR)/$(CONFFILE)
	mkdir -p $(DESTDIR)$(PREFIX)
	cp $< $(DESTDIR)$(PREFIX)/$(CONFFILE)

.PHONY: clean
clean:
	rm $(BUILDDIR)/$(CONFFILE)

.PHONY: version
version:
	@echo ood-portal-generator $(version)
