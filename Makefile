ET_LB_EXTRA_OPTS ?= ''
UPSTREAM_VERSION ?= 20251128-r5-final-5.0.0

all: ectde-image-amd64.hybrid.iso

ectde-image-amd64.hybrid.iso: prepare
	sudo lb build 2>&1 | tee build.log

.PHONY: prepare
prepare: config
prepare: config/apt/preferences
prepare: config/hooks/normal/6100-install-emcomm-tools.hook.chroot
prepare: config/hooks/normal/7900-remove-unused-gnome-packages.hook.chroot
prepare: config/includes.chroot_before_packages/tmp/source
prepare: config/package-lists/desktop.list.chroot

ifneq (,$(wildcard overrides))
prepare: overrides | config
	cp -RT $< config
endif

emcomm-tools-os-community-$(UPSTREAM_VERSION).tar.gz:
	curl --location --output $@ https://github.com/thetechprepper/emcomm-tools-os-community/archive/refs/tags/emcomm-tools-os-community-$(UPSTREAM_VERSION).tar.gz

source: emcomm-tools-os-community-$(UPSTREAM_VERSION).tar.gz
	mkdir $@
	tar -C $@ --strip-components 1 -x -f $<

config/includes.chroot_before_packages/tmp/source: source | config
	mkdir -p $@
	cp -RT $< $@

config:
	lb config \
		--archive-areas 'main non-free-firmware contrib' \
		--backports true \
		--debian-installer live \
		--debian-installer-distribution trixie \
		--distribution trixie \
		--ignore-system-defaults \
		--iso-application 'EmComm Tools Debian Edition' \
		--iso-publisher 'Christian HB9HOX; qsl@hb9hox.radio' \
		--iso-volume "ECTDE $(shell date --iso-8601)" \
		--memtest none \
		--security true \
		--source false \
		--updates true \
		$(ET_LB_EXTRA_OPTS)

.ONESHELL:
config/package-lists/desktop.list.chroot: | config
	cat <<EOF >$@
	live-task-gnome
	epiphany-browser
	EOF

.ONESHELL:
config/apt/preferences: | config
	cat <<EOF >$@
	Package: live-task-localisation*
	Pin: version *
	Pin-Priority: -1
	
	Package: task-*-gnome-desktop
	Pin: version *
	Pin-Priority: -1
	
	Package: gnome
	Pin: version *
	Pin-Priority: -1
	
	Package: gnome-terminal
	Pin: version *
	Pin-Priority: -1
	
	Package: gnome-tour
	Pin: version *
	Pin-Priority: -1
	
	Package: firefox*
	Pin: version *
	Pin-Priority: -1
	EOF

.ONESHELL:
config/hooks/normal/6100-install-emcomm-tools.hook.chroot: | config
	cat <<EOF >$@
	#!/bin/sh

	set -e

	cd /tmp/source/scripts
	./install.sh
	EOF
	chmod +x $@

.ONESHELL:
config/hooks/normal/7900-remove-unused-gnome-packages.hook.chroot: | config
	cat <<EOF >$@
	#!/bin/sh
	apt purge -y \
		gnome-calendar \
		gnome-contacts \
		gnome-maps \
		gnome-software\* \
		gnome-weather
		
	apt autopurge -y
	EOF
	chmod +x $@

.PHONY: clean
clean:
	sudo rm -rf \
		.build/ \
		.lock \
		auto/ \
		binary* \
		build.log \
		cache/ \
		chroot* \
		config/ \
		live-image* \
		local/ \
		source/ \
		wget-log* \
