FEATURE := $(notdir $(shell pwd))
VERSION := $(shell bash -c '. src/lib/$(FEATURE) 2>/dev/null; echo $$HD5WEB_VERSION')
INSTALL_PATH := /usr/local

.PHONY: tests clean

all: build/bin build/lib/$(FEATURE) build/bin/$(FEATURE) \
	build/share/$(FEATURE)/static build/share/$(FEATURE)/plugins build/share/$(FEATURE)/examples \
	build/share/$(FEATURE)/tools/webserve build/share/$(FEATURE)/static/d3.min.js build/share/$(FEATURE)/static/ajax.js
	@rsync -azL src/static/ build/share/$(FEATURE)/static/
	@rsync -azL src/plugins/ build/share/$(FEATURE)/plugins/
	@rsync -azL examples/ build/share/$(FEATURE)/examples/

install: tests
	@rsync -az build/ $(INSTALL_PATH)/

version: all
	@build/bin/$(FEATURE) --version

build/bin/$(FEATURE): build/lib/$(FEATURE) build/bin
	@install -m 755 src/tools/$(FEATURE) $@

build/lib/$(FEATURE): build/lib/hd5web-$(VERSION) build/lib
	@install -m 755 src/lib/hd5web $@

build/lib/$(FEATURE)-$(VERSION): build/lib
	@rsync -az src/lib/hd5web-latest/ $@/

build/share/$(FEATURE): build/share
	@mkdir $@

build/share/$(FEATURE)/static: build/share/$(FEATURE)
	@mkdir $@

build/share/$(FEATURE)/examples: build/share/$(FEATURE)
	@rsync -az examples/ $@/

build/share/$(FEATURE)/tools/webserve: build/share/$(FEATURE)/tools checkouts/webserve
	@rsync -az checkouts/webserve/build/bin/$(notdir $@) $@

build/share/$(FEATURE)/static/d3.min.js: build/share/$(FEATURE)/static
	@curl -q -s https://d3js.org/d3.v4.min.js -o $@

build/share/$(FEATURE)/static/ajax.js: build/share/$(FEATURE)/static checkouts/recipes
	@cp checkouts/recipes/www/js/ajax/$(notdir $@) $@

build/share/$(FEATURE)/static/Grid.js: build/share/$(FEATURE)/static checkouts/Grid
	@cp checkouts/Grid/src/$(notdir $@) $@

build/share/$(FEATURE)/static/Grid.css: build/share/$(FEATURE)/static checkouts/Grid
	@cp checkouts/Grid/src/$(notdir $@) $@

checkouts/recipes: checkouts
	@git clone https://github.com/damionw/recipes.git $@
	@touch checkouts/*

checkouts/webserve: checkouts
	@git clone https://github.com/damionw/webserve.git $@
	@$(MAKE) -C $@ tests
	@touch checkouts/*

checkouts/Grid: checkouts
	@git clone https://github.com/mmurph211/Grid.git $@
	@touch checkouts/*

checkouts:
	@install -d $@

build/%:
	@install -d $@

tests: all
	@PATH="$(shell readlink -f build/bin):$(PATH)" unittests/testsuite

clean:
	-@rm -rf build checkouts
