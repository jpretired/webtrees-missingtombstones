BUILD_DIR=build
LANGUAGE_DIR=src/missingtombstones/language
LANGUAGE_SRC=$(shell git grep -I --name-only --fixed-strings -e I18N:: -- "*.php" "*.xml")
MO_FILES=$(patsubst %.po,%.mo,$(PO_FILES))
PO_FILES=$(wildcard $(LANGUAGE_DIR)/*.po)
SHELL=bash
MKDIR=mkdir -p

.PHONY: clean update vendor build/missingtombstones

all: src/missingtombstones/language/messages.pot update build/missingtombstones.tar.bz2

clean:
	rm -Rf build/* src/missingtombstones/language/messages.pot
	rm -Rf build

update: src/missingtombstones/language/messages.pot $(MO_FILES)

vendor:
	composer.phar self-update
	composer.phar update
	composer.phar dump-autoload --optimize

build/missingtombstones: src/missingtombstones/language/messages.pot update
	$(MKDIR) build 
	cp -R src/missingtombstones/ build/

build/missingtombstones.tar.bz2: build/missingtombstones
	tar cvjf $@ $^

src/missingtombstones/language/messages.pot: $(LANGUAGE_SRC)
	echo $^ | xargs xgettext --package-name="webtrees-missingtombstones" --package-version=1.0 --msgid-bugs-address=bmarwell@gmail.com --no-wrap --language=PHP --add-comments=I18N --from-code=utf-8 --keyword=translate:1 --keyword=translateContext:1c,2 --keyword=plural:1,2 --output=$@

$(PO_FILES): src/missingtombstones/language/messages.pot
	msgmerge --no-wrap --sort-output --no-fuzzy-matching --output=$@ $@ $<

%.mo: %.po
	msgfmt --output=$@ $<


# vim:noexpandtab
