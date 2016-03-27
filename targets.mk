export version := v0.0.1

vars := $$version $$OOD_IP $$OOD_SUBDOMAIN $$OOD_LUA_ROOT $$OOD_PUN_STAGE_CMD \
	$$OOD_USER_MAP_CMD $$OOD_PUN_SOCKET_ROOT $$OOD_PUBLIC_ROOT $$OOD_PUN_URI \
	$$OOD_NODE_URI $$OOD_NGINX_URI $$OOD_PUBLIC_URI

$(BUILDDIR)/$(CONFFILE): $(TMPLDIR)/$(CONFFILE).tmpl | $(BUILDDIR)
	$(RENDERER) '$(vars)' < $^ > $@

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
