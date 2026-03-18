# Map of what to put where to do things

## Live OS
* `grep '\.flag$' *.files *.contents` in the repository root after building will show where the various flag files in the `config/includes*` end up.
* `grep '\.flag$' sample-manifests/*.files sample-manifests/*.contents` will show the same thing just for the build that was last run by the commiter of the current git HEAD ref.
* Everthing in `config` and `binary` are used to make the live OS and installer.
  * Files in `config.` are used to make the post boot live OS.
  * Files with the `binary` suffix are used to make the live OS image itself (such as the boot loader as opposed to the running live OS).
* Files/directories in `config/includes.chroot*` will show up in both the Live OS and installed OS.
  * The different suffixes on these directories refer to build stages.
* Files/directories in `config/includes.binary` will only show up in the installer.  # FIXME: verify
* Files/directories in `config/includes.bootstrap` don't seem to show up anywhere.
  * Maybe the bootstrap environment when installing?
* Files/directories in `config/includes.installer` don't seem to show up anywhere.
  * Maybe the installer?
* Packages installed in the live OS will not always be installed in the installed OS.
  * Packages installed in the live OS via the `*.list.chroot` package lists will be installed in the installed OS.
    * This may be a function of the `live` option passed to `lb config --debian-installer`.
* To install from the live OS, the live OS and the installer need to have the same kernel and they might not be in sync. A script in `config/includes.chroot_after_packages` explicitly installing the right version of the kernel and removing the default version will fix that.
  * This seems to be due to a little lag in the dev cycle of the installer compared to the Debian stable updates.

### Branding
* The isolinux boot logo is located in `binary/isolinux/splash.png` in the build output and can be overridden with `config/includes.binary/isolinux/splash.png`.  # FIXME: Verify this by replacing it.
* The grub boot logo is located in `binary/boot/grub/splash.png` in the build output and can be overridden with `config/includes.binary/boot/grub/splash.png`.  # FIXME: Verify this by replacing it.


## Installer
As in the dedicated installer environment accessed from the boot menu.
* Not much to do to the installer.
* The `preseed.cfg` lives in `config/includes.binary/install/preseed/preseed.cfg`.
* Potentially useful options for the preseed.cfg https://www.debian.org/releases/stable/amd64/apbs05.en.html
  * 
* To install the default gnome desktop suite add `tasksel tasksel/first multiselect standard, gnome-desktop` to the `preseed.cfg` including any other tasksel tasks in the same statement.
* `/target` is the location of the installed system.
  * Files in the includes directories that go on the installed system can be found relative to this directory.
* `d-i preseed/late_command ...`
  * Can be used to dump files without packaging them but the `config/includes` directory will be a cleaner option if you don't care about the files being readable in their final locations in the live OS.
  * Runs in the installer environment *not* the installed system. Not a terribly good option for installing anything.

### Branding
* Rebranding appears to be relatively difficult due to the way the installer is architected.
* TODO
  * GUI installer banner location


## Installed OS
* Use `preseed.cfg` to do anything you want to do during the install process.
  * Set the path to `preseed.cfg` with `LB_DEBIAN_INSTALLER_PRESEEDFILE` in `config/binary` (example set in that config file already). # FIXME: this might be an issue since something keeps appending the `file=...` to the variable. If it isn't set in the first place it might not be an issue. verify this

### Branding
* Anything that needs to show up in the installed OS can be put in `config.includes.chroot_after_packages` if it isn't packaged itself.


<a id="development-cruft"></a>
## Development Cruft
A list of files and config blocks that need to be removed before production builds.
* `config/hooks/live/0099-remove-kernel.hook.chroot`
* `config/package-lists/{dev,test}.*`
* `config/**/*.flag`
* `config/includes.chroot_before_packages/create-dated-flag.sh`
* Blocks of code are marked for removal in `config/includes.binary/install/preseed/preseed.cfg`


# Mapping Methodology
Appart from just RTFM flag files were added to most of the directories under `config` and where they end up is recored conveniently in the build output manifests. The manifests from the last build are in the `sample-manifests` directory.
