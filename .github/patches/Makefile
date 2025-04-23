ifeq ($(PREFIX),)
	PREFIX := /var/www/venus/gui-beta
endif

FILES=index.html qtloader.js venus-gui-v2.js venus-gui-v2.wasm.gz venus-gui-v2.wasm.sha256 \
	victronenergy.svg LICENSE.txt \
	icons/android-chrome-192x192.png icons/android-chrome-512x512.png icons/apple-touch-icon.png \
	icons/browserconfig.xml icons/favicon-16x16.png icons/favicon-32x32.png icons/favicon.ico icons/manifest.json \
	icons/mstile-150x150.png icons/safari-pinned-tab.svg

.PHONY: all clean install

all: ;

clean: ;

install:
	install -d $(DESTDIR)$(PREFIX)/
	install -m 644 $(FILES) $(DESTDIR)$(PREFIX)/
