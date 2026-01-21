#!/bin/bash

if [ "$(whoami)" != "root" ]; then
	echo "This must be run as root"
	exit 1
fi

set -ex

lb clean
lb config
lb build

# FIXME: Add upload step?

