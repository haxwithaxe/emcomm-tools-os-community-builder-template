#!/bin/bash

# This is the companion to the "build.sh.d/example-custom-config.pre-build" 
#   hook.
# This is an alternative to "some-program" used in other parts of this example.
#
# There are other parts to this example.
#   config/custom-settings.pre-clean: The build environment clean up part of 
#     the process.
#   config/custom-settings.pre-build: The pre-build deployment of the config 
#     file.
#   config/include.chroot_before_packages/example-custom-config.sh: A script 
#     that consumes the config. (this file)
#   config/hooks/normal/5052-example-custom-config.hook.chroot: The hook to 
#     run a program that consumes the config during the installed OS install 
#     process.  # FIXME: Verify this happens for the installed OS
#   config/hooks/live/0091-example-custom-config.hook.chroot: The hook to run 
#     a program that consumes the config during the live OS build process.
#   custom-settings/example-custom-config.conf: The config file to use during 
#     the build process or to include in the live OS and/or the installed OS. 

# This example uses a bash/posix shell specific pattern but whatever consumes 
#   the config in the real installed or live OS can use the custom config 
#   however it wants. 
# If the config file is optional you can check if it is there and exit cleanly
#    if it isn't or skip sourcing it.

# This example skips sourcing it to use the imaginary default values.
if [ -f /etc/some-program/some-program.conf ];
	source /etc/some-program/some-program.conf
fi

# The alternative or exiting cleanly
# test -f /etc/some-program/some-program.conf || exit 0
# source /etc/some-program/some-program.conf

# Do something useful with the variables you just got from the config
# For example you could download map data based on the user's specified 
#   location.
# wget "https://mapdata.example.com/${USER_LOCATION}" -O "/var/cache/some-program/mapdata/${USER_LOCATION}.geo"

# Optionally remove the parts of this process from the chroot so that they 
#   aren't in the live OS or installed OS.
#rm -f /etc/some-program/some-program.conf "$0"

# If the script doesn't need to exist in the live or installed OS it should be
#    a hook in the "config/hooks/live" or "config/hooks/install" directories 
#    respectively.
