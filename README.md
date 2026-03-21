# EmCommTools OS Build System Example/Template

This is a template for the [emcomm-tools-os project] to use for building Debian based Live OS and installer ISOs. It uses the [live-build] tools used by the Debian project to build their [official live OS ISOs](https://wiki.debian.org/DebianLive).

The scope of the [emcomm-tools-os project] is a little unusual so this should not be used as is for general purpose live OS builds without a thorough audit. Any advice given should be taken in the context of the [emcomm-tools-os project] and not for general use.

The main branch is "dev/fiddle-around-and-find-out" for a reason. This is primarily documentation for the developers of a specific project and the tools created to flesh out that documentation. It will need a little prep to make it ready to use in production.


# Build Docs
Instructions on how to build live OS images with this repo and details on the build automation are in [BUILD.md].


# Where Things Go If You Want To Do A Thing
Some notes on what goes where when you put them in certain places is in [MAP.md]. That file also includes some notes on what to remove from this repo to use it in real development or production.

# Automation

## Build
See [BUILD.md].

## Insallation
Current status is I clearly don't understand the scope or vocabulary of parts of the `preseed.cfg`. 
* The language and keyboard selection seems to be outside thescope of the preseed system when using the ``live`` build config option.
* The tasksel and pkgsel options also seem to have no affect when the ``live`` build option is used.
  * The `config/package-lists/*.chroot_install` files might take care of that problem. <!-- FIXME: verify this -->
* Everything else seems to be able to be automated when running the install from either the live OS or the install options in the boot menu.
  * Includes powering off and ejecting the live media.

The "debian-installer" and the installer used in the live OS environment aren't the same software and the latter works much better. I have not checked if the live environment installer respects the `preseed.cfg` in the ways the "debian-installer" doesn't. <!-- FIXME: verify this -->


# License
This repo is licensed under the GPLv3 but may be provided for use under other licenses on request. The license modification will be documented in a commit message or wherever the project keeps it's license text as a Curve25519 or PGP signed string. From a key listed [here](https://github.com/haxwithaxe.keys) or [here](https://github.com/haxwithaxe.gpg).


<!-- Footnotes -->
<!-- PROD: Make sure to change the links to this repo to match the branch name. -->
[BUILD.md]: https://github.com/haxwithaxe/emcomm-tools-os-community-builder-template/blob/dev/fiddle-around-and-find-out/BUILD.md
[emcomm-tools-os project]: https://github.com/thetechprepper/emcomm-tools-os-community
[live-build]: https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html
[MAP.md]: https://github.com/haxwithaxe/emcomm-tools-os-community-builder-template/blob/dev/fiddle-around-and-find-out/MAP.md
