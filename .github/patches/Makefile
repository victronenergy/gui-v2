ifeq ($(PREFIX),)
	PREFIX := /var/www/venus/gui-beta
endif

ifeq ($(EXTRAFONTS),)
	EXTRAFONTS=/usr/lib/fonts/DroidSansFallback.ttf /usr/lib/fonts/NotoSansThai.ttf /usr/lib/fonts/DejaVuSans.ttf
endif

FILES=index.html qtloader.js venus-gui-v2.js \
	victronenergy.svg LICENSE.txt

.PHONY: clean

clean:
	rm -f

install:
	install -d $(DESTDIR)$(PREFIX)/
	install -m 644 $(FILES) $(DESTDIR)$(PREFIX)/
ifdef LINKFONT
	ln -s $(EXTRAFONTS) $(DESTDIR)$(PREFIX)/
endif
