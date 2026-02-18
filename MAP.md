# Map of what to put where to do things

## Live OS
* Everthing in `config` and `binary` are used to make the live OS.
  * Files in `config` are used to make the post boot live OS.
  * Files with the `binary` suffix are used to make the live OS image itself (such as the boot loader as opposed to the running live OS).
* `config/includes.*` will show up in both the Live OS and installed OS.
  * The different suffixes on these directories refer to build stages.
* Packages installed in the live OS will not be installed in the installed OS.  # FIXME: verify this
* The isolinux boot logo is located in `binary/isolinux/splash.png` in the build output and can be overridden with `config/includes.binary/isolinux/splash.png`.  # FIXME: verify this
* The grub boot logo is located in `binary/boot/grub/splash.png` in the build output and can be overridden with `config/includes.binary/boot/grub/splash.png`.  # FIXME: verify this

## Installer
* Not much to do to the installer.
* The ``preseed.cfg`` lives in ``config/includes.binary/install/preseed/preseed.cfg``.
* Potentially useful options for the preseed.cfg https://www.debian.org/releases/stable/amd64/apbs05.en.html
* To install the default gnome desktop suite add `tasksel tasksel/first multiselect standard, gnome-desktop` to the `preseed.cfg` including any other tasksel tasks in the same statement.
* Rebranding is relatively difficult due to the way the installer is architected.
* TODO
  * installer banner location

## Installed OS
* Use `preseed.cfg` to do anything you want to do during the install process.
  * Set the path to `preseed.cfg` with `LB_DEBIAN_INSTALLER_PRESEEDFILE` in `config/binary` (example set in that config file already).
* `d-i preseed/late_command ...` can be used to dump files without packaging them but the `config/includes` directory will be a cleaner option if you don't care about the files being readable in their final locations in the live OS.
* TODO
