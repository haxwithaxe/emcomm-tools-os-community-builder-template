#!/bin/bash

# This is the companion to the "build.sh.d/example-custom-config.pre-build" hook.

# This example uses a bash/posix shell specific pattern but whatever consumes the config in
#   the real installed or live OS can use the custom config however it wants. 

source /etc/some-program/some-program.conf

# Do something useful with the variables we just got from the config
# For example we could download map data based on the user's specified location.
# wget "https://mapdata.example.com/${USER_LOCATION}" -O "/var/cache/some-program/mapdata/${USER_LOCATION}.geo"
