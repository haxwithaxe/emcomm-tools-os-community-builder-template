# Map of what to put where to do things

## Live OS
The booted full OS directly from the ISO.
* `grep '\.flag$' *.files *.contents` in the repository root after building will show where the various flag files in the `config/includes*` end up.
* `grep '\.flag$' sample-manifests/*.files sample-manifests/*.contents` will show the same thing just for the build that was last run by the committer of the current git HEAD ref.
* Files/directories in `config` are used to make the [live OS], [installer], and ISO filesystem.
  * Files with the `binary` suffix are used to make the ISO filesystem.
* Files/directories in `config/includes` will show up in the live OS root, [installed OS], and ISO root.
* Files/directories in `config/includes.chroot*` will show up in both the live OS root and [installed OS] root.
  * The different suffixes on these directories refer to build stages.
* Files/directories in `config/includes.binary` will only show up in the ISO root.
* Files/directories in `config/includes.bootstrap` don't seem to show up anywhere.
  * Maybe the bootstrap environment when installing? I haven't found a way to instrument this yet. I haven't tried terribly hard yet though.
* Files/directories in `config/includes.installer` show up in the [installer] environment launched from the boot menu.
* Packages installed in the live OS via `config/package-lists/*` will not always be installed in the [installed OS].
  * Packages installed in the live OS via the `*.list.chroot` package lists will be installed in the live OS but not the [installed OS].
  * Packages installed in the live OS via the `*.list.chroot_install` package lists will be installed in the live OS and the [installed OS].
  * Packages installed in the live OS via the `*.list` (without a stage suffix) package lists will be installed in all stages.
* Packages in `config/packages-lists/*.list.chroot_live` are removed after the installation of the [installed OS].
* To install from the live OS via the installer software in the GUI nothing special needs to happen.
* To install from the live OS via the CLI (`debian-installer-launcher --plugins live`), the live OS and the [installer] need to have the same kernel and they might not be in sync. 
  * Removed -A-script-in-`config/includes.chroot_after_packages`-explicitly-installing-the-right-version-of-the-kernel-and-removing-the-default-version-will-fix-that.-
  * This seems to be due to a little lag in the dev cycle of the installer software compared to the Debian stable updates.
  * This is not an issue. The GUI installer in the live desktop environment is a different piece of software.

### Live OS Branding
* The isolinux boot logo is located in `binary/isolinux/splash.png` in the build output and can be overridden with `config/includes.binary/isolinux/splash.png`.  # FIXME: Verify this by replacing it.
* The grub boot logo is located in `binary/boot/grub/splash.png` in the build output and can be overridden with `config/includes.binary/boot/grub/splash.png`.  # FIXME: Verify this by replacing it.


## Installer
As in the dedicated installer environment accessed from the boot menu.
* Not much to do to the installer.
* The `preseed.cfg` lives in `config/includes.binary/install/preseed/preseed.cfg`. It isn't used entirely.
* Potentially useful options for the `preseed.cfg` in this [comprehensive example preseed.cfg].
* `/target` is the location of the installed system in the installer environment.
  * Files in the includes directories that go on the installed system can be found relative to this directory.
* `d-i preseed/late_command ...`
  * This is a semicolon separated list of commands. 
  * The `in-target` prefix is tied to only one command at a time so `in-target` and unprefixed commands can be intermixed.
  * Can be used to dump files without packaging them but the `config/includes` or `config/includes.chroot*` directories will be a cleaner option if you don't care about the files being readable in their final locations in the [live OS], [installed OS], installer, and ISO, or [live OS] and [installed OS] respectively.
  * If the command starts with `in-target` it runs in the [installed OS].
  * If the command is not prefixed it runs in the installer environment *not* the [installed OS]. Not a terribly good option for installing most things, but it is useful to do cleanup-type tasks.

### Installer Branding
* Rebranding appears to be relatively difficult due to the way the installer is architected.
* TODO
  * GUI installer banner location


## Installed OS
* Use `preseed.cfg` to do anything you want to do during the install process.
  * Set the path to `preseed.cfg` with `LB_DEBIAN_INSTALLER_PRESEEDFILE` in `config/binary` (example set in that config file already). The `lb config` command adds an extra one every time it is run so there is a `.post-config` hook to clean up after it.
* Use a list in `package-lists` with the suffix `.list.chroot_install` to install packages in the installed OS.

### Installed OS Branding
* Anything that needs to show up in the installed OS can be put in `config.includes.chroot_after_packages` if it isn't packaged itself.


## Development Cruft
A list of files and config blocks that need to be removed or modified before production builds.
* Removed -`config/hooks/live/0099-remove-kernel.hook.chroot`-
* `config/package-lists/{dev,test}.*`
* `config/**/*.flag`
* `config/includes.chroot_before_packages/create-dated-flag.sh`
* `config/includes.chroot_after_packages/dev-tools.sh`
* `config/package-lists/placeholder.emcomm-tools.list.chroot`
  * If it is being used it should get renamed to omit the "placeholder"
  * If it isn't being used it should be removed.
* Blocks of code are marked for removal in `config/includes.binary/install/preseed/preseed.cfg`.
* If they aren't being reused `config/includes.chroot_after_packages/first-boot.sh`, `config/includes.chroot_after_packages/etc/systemd/system/first-boot.service`, and the blocks of `config/includes.binary/install/preseed/preseed.cfg` referring to them should be removed.
* See [Production and Production-like Prep] in [BUILD.md]

# Mapping Methodology
Apart from just RTFM, flag files were added to most of the directories under `config` and where they end up is recorded conveniently in the build output manifests. The manifests from the last build are in the `sample-manifests` directory.

## External Resources (The "M"s that were RTFed)
* [The official debian build config]

### live-build
The system used for the official Debian live OS and installer ISO builds.
* [live-build manual]
* [customize content]
* [customize installed packages]

#### lb command
The Debian live-build utility used in `build.sh`.
* [lb config]
* [lb build]
* [lb clean]

### Preseed
* [preesed docs]
* [comprehensive example preseed.cfg]
* [automated installation with preseed]


<!-- Footnotes -->
<!-- PROD: Make sure to change the links to this repo to match the branch name. -->
[automated installation with preseed]: https://www.linux.it/~ema/posts/custom-debian-installer-usb-stick/
[BUILD.md]: https://github.com/haxwithaxe/emcomm-tools-os-community-builder-template/blob/dev/fiddle-around-and-find-out/BUILD.md
[comprehensive example preseed.cfg]: https://github.com/paullockaby/debian-preseed/blob/main/preseed.cfg
[customize content]: https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-contents.en.html
[customize installed packages]: https://live-team.pages.debian.net/live-manual/html/live-manual/customizing-package-installation.en.html
[lb build]: https://manpages.debian.org/testing/live-build/lb_build.1.en.html
[lb clean]: https://dyn.manpages.debian.org/testing/live-build/lb_clean.1.en.html
[lb config]: https://manpages.debian.org/testing/live-build/lb_config.1.en.html
[live-build manual]: https://live-team.pages.debian.net/live-manual/html/live-manual/index.en.html
[preesed docs]: https://www.debian.org/releases/stable/amd64/apbs05.en.html
[Production and Production-like Prep]: https://github.com/haxwithaxe/emcomm-tools-os-community-builder-template/blob/dev/fiddle-around-and-find-out/BUILD.md#production-and-production-like-prep
[the official debian build config]: https://salsa.debian.org/live-team/live-images/-/tree/debian?ref_type=heads
[installed OS]: #installed-os
[live OS]: #live-os
[installer]: #installer
