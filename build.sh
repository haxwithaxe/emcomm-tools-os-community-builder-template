#!/bin/bash

set -e

if [ "$(whoami)" != "root" ]; then
	echo "This must be run as root"
	exit 1
fi

if compgen -G 'build.sh.d/*.pre'; then
	echo Running pre-build scripts
	set -x
	for script in build.sh.d/*.pre; do
		bash $script
	done
	set +x
fi

set -x

lb clean
lb config --debian-installer live
lb build

set +x

if compgen -G 'build.sh.d/*.post'; then
	echo Running post-build scripts
	set -x
	for script in build.sh.d/*.post; do
		bash $script
	done
	set +x
fi
# FIXME: Add upload step?

