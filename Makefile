ET_LB_EXTRA_OPTS ?= ''
UPSTREAM_VERSION ?= 20251128-r5-final-5.0.0

.PHONY: all
all: live-image-amd64.hybrid.iso

.PHONY: run
run: live-image-amd64.hybrid.iso
	kvm -cdrom $< -smp cpus=4 -cpu host -m 4G -vga qxl

live-image-amd64.hybrid.iso: | prepare
	sudo lb build 2>&1 | tee build.log

.PHONY: prepare
prepare: config
prepare: config/apt/preferences
prepare: config/hooks/normal/6100-install-emcomm-tools.hook.chroot
prepare: config/hooks/normal/7900-remove-unused-gnome-packages.hook.chroot
prepare: config/includes.chroot_before_packages/tmp/source
prepare: config/package-lists/desktop.list.chroot
prepare: config/package-lists/testing.list.chroot

ifneq (,$(wildcard overrides))
OVERRIDE_FILES=$(shell find overrides -type f -exec bash -c 'echo "{}" | sed -e "s/\(\s\)/\\\\\\1/g"' \;)
CONFIG_FILES=$(patsubst overrides/%, config/%, $(OVERRIDE_FILES))
prepare: $(CONFIG_FILES) | config
endif

emcomm-tools-os-community-$(UPSTREAM_VERSION).tar.gz:
	curl --location --output $@ https://github.com/thetechprepper/emcomm-tools-os-community/archive/refs/tags/emcomm-tools-os-community-$(UPSTREAM_VERSION).tar.gz

source: emcomm-tools-os-community-$(UPSTREAM_VERSION).tar.gz
	mkdir $@
	tar -C $@ --strip-components 1 -x -f $<
	quilt push -a

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
		$(LB_EXTRA_OPTS)

.ONESHELL:
config/package-lists/desktop.list.chroot: | config
	cat <<EOF >$@
	live-task-gnome
	epiphany-browser
	EOF

# Packages used to test EmComm Tools within a virtual machine.
.ONESHELL:
config/package-lists/testing.list.chroot: | config
	cat <<EOF >$@
	# Enables automatic resolution adjustment and clipboard integration with the host.
	spice-vdagent
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
	
	$$(env | grep ET_ | sed 's/^\(.*\)/export \1\r/g')
	
	cd /tmp/source/scripts
	./install.sh
	
	cd /tmp/source/tests
	./run-test-suite.sh
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

config/%: overrides/% | config
	mkdir -p '$(shell dirname "$@")'
	cp "$<" "$@"

.PHONY: clean
clean:
	sudo rm -rf \
		.build/ \
		.lock \
		.pc \
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
