FEATURE := $(notdir $(shell pwd))
VERSION := $(shell bash -c '. src/lib/$(FEATURE) 2>/dev/null; echo $$__HD5WEB_VERSION__')
INSTALL_PATH := /usr/local

.PHONY: tests clean demo

all: build/bin build/lib/$(FEATURE) build/bin/$(FEATURE) \
	build/share/$(FEATURE)/static build/share/$(FEATURE)/plugins \
	build/share/$(FEATURE)/tools/webserve build/share/$(FEATURE)/static/d3.min.js build/share/$(FEATURE)/static/ajax.js \
	build/share/$(FEATURE)/static/Grid.js build/share/$(FEATURE)/static/Grid.css
	@rsync -azL src/static/ build/share/$(FEATURE)/static/
	@rsync -azL src/plugins/ build/share/$(FEATURE)/plugins/
	@touch build/share/$(FEATURE)/static
	@touch build/share/$(FEATURE)/plugins
	@touch build/share/$(FEATURE)/tools

install: tests
	@rsync -az build/ $(INSTALL_PATH)/

demo: all
	build/bin/$(FEATURE) --hdf5=/tmp/demo.h5 --port=7272

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
	@touch $(dir $@)

build/share/$(FEATURE)/static: build/share/$(FEATURE)
	@mkdir $@
	@touch $(dir $@)

build/share/$(FEATURE)/tools/webserve: build/share/$(FEATURE)/tools checkouts/webserve
	@rsync -az checkouts/webserve/build/bin/$(notdir $@) $@

build/share/$(FEATURE)/static/d3.min.js: build/share/$(FEATURE)/static
	@curl -q -s https://d3js.org/d3.v4.min.js -o $@
	@touch $(dir $@)

build/share/$(FEATURE)/static/ajax.js: build/share/$(FEATURE)/static checkouts/recipes
	@cp checkouts/recipes/www/js/ajax/$(notdir $@) $@
	@touch $(dir $@)

build/share/$(FEATURE)/static/Grid.js: build/share/$(FEATURE)/static checkouts/Grid
	@cp checkouts/Grid/src/$(notdir $@) $@
	@touch $(dir $@)

build/share/$(FEATURE)/static/Grid.css: build/share/$(FEATURE)/static checkouts/Grid
	@cp checkouts/Grid/src/$(notdir $@) $@
	@touch $(dir $@)

checkouts/recipes: checkouts
	@git clone https://github.com/damionw/recipes.git $@
	@touch $(dir $@)/*

checkouts/webserve: checkouts
	@git clone https://github.com/damionw/webserve.git $@
	@$(MAKE) -C $@ tests
	@touch $(dir $@)/*

checkouts/Grid: checkouts
	@git clone https://github.com/mmurph211/Grid.git $@
	@touch $(dir $@)/*

checkouts:
	@install -d $@

build/%:
	@install -d $@

tests: all
	@PATH="$(shell readlink -f build/bin):$(PATH)" unittests/testsuite

clean:
	-@rm -rf build checkouts
