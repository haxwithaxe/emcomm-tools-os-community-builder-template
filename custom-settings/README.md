# Custom Settings

This is part of an example of how you can easily and cleanly deploy configs that users can easily find and edit in a build.
For instance to download the appropriate map data for a given locaiton.

* There are other parts to this example.
  * `config/custom-settings.pre-clean`: The build environment clean up part of the process.
  * `config/custom-settings.pre-build`: The pre-build deployment of the config file.
  * `config/include.chroot_before_packages/example-custom-config.sh`: A script that consumes the config.
  * `config/hooks/normal/5052-example-custom-config.hook.chroot`: The hook to run a program that consumes the config during the installed OS install process. (this file) # FIXME: Verify this happens for the installed OS
  * `config/hooks/live/0091-example-custom-config.hook.chroot`: The hook to run a program that consumes the config during the live OS build process.
  * `custom-settings/example-custom-config.conf`: The config file to use during the build process or to include in the live OS and/or the installed OS.
