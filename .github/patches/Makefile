ifeq ($(PREFIX),)
	PREFIX := /var/www/venus/gui-beta
endif

FILES=index.html qtloader.js venus-gui-v2.js venus-gui-v2.wasm.gz venus-gui-v2.wasm.sha256 \
	victronenergy.svg LICENSE.txt

.PHONY: all clean install

all: ;

clean: ;

install:
	install -d $(DESTDIR)$(PREFIX)/
	install -m 644 $(FILES) $(DESTDIR)$(PREFIX)/
