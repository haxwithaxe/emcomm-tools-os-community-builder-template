#!/bin/bash

test -f  || (date > /first-boot.flag)

test -f "/first-boot.flag" || (date -u "+%Y-%m-%d %T.%N" > "/first-boot.flag")
systemctl disable first-boot.service
# Optionally
rm -f --one-file-system /etc/systemd/system/first-boot.service $0
