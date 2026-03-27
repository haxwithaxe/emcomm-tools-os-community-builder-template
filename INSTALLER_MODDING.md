# Modifying the Calamares Installer
There are two ways to modify the behavior of the live OS GUI installer with modules and/or configs.
1. Adding extra/modified files to the build.
1. Rebuilding the package with extra/modified files. (Probably overkill)

* In either case the `/etc/calamares/settings.conf` in the target environment determines what is run when and the files in `/etc/calamares/modules` configure the modules run from `settings.conf`.
* The default `/etc/calamares/modules/packages.conf` for the live OS and installed OS removes some files that prevent running calamares in the installed OS.
* The additional module `post-install` is added to the build and used to run extra scripts just after package install.

## Adding Modules Via Includes Directories
1. Dump the new module in `usr/lib/x86_64-linux-gnu/calamares/modules` in one of the `config/includes*` directories. `config/includes.chroot_after_packages` is almost certainly the one you want. The files being added and edited might conflict with what is in the calamares package and the installer booted from the boot menu doesn't use calamares configs or modules.
1. Add the config file for the module to `etc/calamares/modules` in the same `config/includes*` directory.
1. Add or edit `etc/calamares/settings.conf` and include the module where you want it in the build process.

## Rebuilding the installer
This should be done outside the emcomm-tools-os-builder repo. It generates a bunch of files and uses externally controlled configs and code that aren't in VCS in the form you get them. Redoing the process from the [download the package source] step for each major revision of the emcomm-tools-os build or if it's been more than a week since the last time the package was built. Keeping it in sync with the upstream package will help reduce weird behavior or dependency mismatches.

1. Prep dev environment
        ```sh
        apt install g++ gettext qtbase5-dev qttools5-dev qtwebengine5-dev qtdeclarative5-dev libqt5svg5-dev libyaml-cpp-dev libpolkit-qt5-1-dev libkf5parts-dev libkpmcore-dev libparted-dev libatasmart-dev libboost-dev python3-dev libboost-python-dev devscripts python3-yaml python3-jsonschema
        apt build-dep calamares
        mkdir calamares-rebuild
        ```
1. Get the package source.<a id="get-the-package-source-step"></a>
        ```sh
        cd calamares-rebuild
        apt source calamares  # This generates a bunch of files without organizing them in a single directory
        ```
1. Add '-DWITH_QT6=ON' to `calamares-<version>/debian/rules` so the `override_dh_auto_configure` section looks like this (as of 3.3.14-1).
        ```
        override_dh_auto_configure:
            dh_auto_configure -- -DWEBVIEW_FORCE_WEBKIT=1 -DKDE_INSTALL_USE_QT_SYS_PATHS=ON -DWITH_QT6=ON

        ```
1. Run the build before making changes to be sure it works.
        ```sh
        pushd calamares-<version>
        debuild -us -uc
        popd
        ```
1. Make changes.
1. Change the version in `calamares-<version>/debian/control`. Don't just bump the [Debian revision number] (the `-<number>` after the upstream version). Something like `<upstream version>-<debian revision>+<short project name abreviation><project package revision>`. You may need to add a `Version:` field if one doesn't exist.
1. Update the changelog.
        ```sh
        rm calamares-<version>/debian/changelog
        dch -i
        ```
1. Build the changed package.
        ```sh
        debuild -us -uc
        ```
1. Copy the `calamares-<upstream version>-<debian revision>+<short project name abreviation><project package revision>_amd64.deb` to the appropriate package directory in the emcomm-tools-os-community-builder repo. See [MAP.md] for info on what goes where.

## External Resources
* [Rebuilding Debian packages](https://www.linuxjournal.com/content/rebuilding-and-modifying-debian-packages)
* [Debian version policy](version)

<!-- Footnotes -->
[download the package source]: https://github.com/haxwithaxe/emcomm-tools-os-community-builder-template/blob/dev/fiddle-around-and-find-out/INSTALLER_MODDING.md#get-the-package-source-step
[MAP.md]: https://github.com/haxwithaxe/emcomm-tools-os-community-builder-template/blob/dev/fiddle-around-and-find-out/MAP.md
[Debian revision number]: https://www.debian.org/doc/debian-policy/ch-controlfields.html#s-f-version
