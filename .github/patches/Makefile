ifeq ($(PREFIX),)
	PREFIX := /var/www/venus/gui-beta
endif

ifeq ($(EXTRAFONTS),)
	EXTRAFONTS=/usr/lib/fonts/DroidSansFallback.ttf /usr/lib/fonts/NotoSansThai.ttf /usr/lib/fonts/DejaVuSans.ttf
endif

FILES=index.html qtloader.js qtloader-controller.js venus-gui-v2.js \
	  venus-gui-v2.wasm.sha256 venus-gui-v2.wasm.gz victronenergy.svg

all: venus-gui-v2.wasm.sha256 venus-gui-v2.wasm.gz

venus-gui-v2.wasm.sha256:
	sha256sum venus-gui-v2.wasm > venus-gui-v2.wasm.sha256

venus-gui-v2.wasm.gz: venus-gui-v2.wasm.sha256
	gzip -k -9 venus-gui-v2.wasm

.PHONY: clean

clean:
	rm venus-gui-v2.wasm.sha256 venus-gui-v2.wasm.gz

install: all
	install -d $(DESTDIR)$(PREFIX)/
	install -m 644 $(FILES) $(DESTDIR)$(PREFIX)/
ifdef LINKFONT
	  ln -s $(EXTRAFONTS) $(DESTDIR)$(PREFIX)/
endif

