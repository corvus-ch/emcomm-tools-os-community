ET_LB_EXTRA_OPTS ?= ''

all: ectde-image-amd64.hybrid.iso

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
config/package-lists/desktop.list.chroot: config
	cat <<EOF >$@
	live-task-gnome
	epiphany-browser
	EOF

.ONESHELL:
config/apt/preferences: config
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
config/hooks/normal/6100-install-emcomm-tools.hook.chroot: config
	cat <<EOF >$@
	#!/bin/sh
	
	set -e
	
	apt-get install -y \\
	       tar \\
	       curl \\
	
	curl -sL https://github.com/corvus-ch/emcomm-tools-os-community/archive/refs/heads/debian-edition.tar.gz \\
		| tar -x --gunzip --directory /tmp
	
	cd /tmp/emcomm-tools-os-community-debian-edition/scripts
	
	./install.sh
	
	cd
	rm -rf /tmp/emcomm-tools-os-community-debian-edition
	EOF
	chmod +x $@

.ONESHELL:
config/hooks/normal/7900-remove-unused-gnome-packages.hook.chroot: config
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

apt: config/apt/preferences
hooks: config/hooks/normal/6100-install-emcomm-tools.hook.chroot
hooks: config/hooks/normal/7900-remove-unused-gnome-packages.hook.chroot
packages: config/package-lists/desktop.list.chroot

ectde-image-amd64.hybrid.iso: apt hooks packages
	sudo lb build 2>&1 | tee build.log

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
		wget-log* \
