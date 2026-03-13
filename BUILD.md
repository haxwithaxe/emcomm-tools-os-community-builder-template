# Build Instructions

## First Time
1. `sudo apt install live-build debconf-utils`
1. `git clone https://github.com/haxwithaxe/emcomm-tools-os-community-builder-template.git emcomm-tools-os-community-builder`
1. `cd emcomm-tools-os-community-builder`
1. Copy `.build.sh.conf.example` to `.build.sh.conf` and edit it to have the values that match your environment.
1. Copy any of the `*.example` scripts you want to use in `.build.sh.d` to the same filename in the same directory just without the `.example` on the end. Make sure they are executable. `copy-build-manifests.post-build` is enabled by default.
1. `sudo ./build.sh`

## Subsequent Build Runs
1. `cd emcomm-tools-os-community-builder`
1. `sudo ./build.sh`

