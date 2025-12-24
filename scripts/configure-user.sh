#!/bin/bash
#
# Author  : Gaston Gonzalez
# Date    : 16 March 2024
# Updated : 9 October 2024
# Purpose : Configure users and groups
set -e

et-log "Configuring users..."

cp -r ../overlay/etc/skel /etc/
[ ! -e /etc/skel/Desktop ] && mkdir /etc/skel/Desktop

et-log "Add all users to dialout group..."
sed \
  -i \
  -e 's/^#\?ADD_EXTRA_GROUPS=.*/ADD_EXTRA_GROUPS=1/' \
  -e 's/^#\?EXTRA_GROUPS=.*/EXTRA_GROUPS="audio bluetooth cdrom dialout floppy plugdev tty users video"/' \
  /etc/adduser.conf
