# Random Notes

For context of random people reading this. The EmCommTools OS is intended to be used entirely offline and to be a dedicated use appliance based on Debian but not following it religiously.

!!!Some of these are very bad ideas outside of this context!!!

<a id="mirror-snapshot-for-development-environment"></a>
## Mirror Snapshot for Development Environment
It is possible to create a local mirror of the apt repos on development machines to 
1. Speed up building the ISOs
2. Allow for static packages or strictly controlled updates.
* This is typically not a great idea but it would meet the goals of the project.

<a id="on-iso-apt-mirror"></a>
## On ISO apt mirror
It is possible to include a mirror of apt repos in part or in whole in the ISO. This would allow users to install the OS entirely offline. The same mirror can be used in the development environment and the ISO. This will slow down the builds since it greatly increases the amount of data being copied and compressed (not necessarily too big to fit on a CD).

<a id="live-installed-system"></a>
## Live Installed System
While running the installer in "expert" mode I came across the option to install the OS as the live OS rather than a regular install. This would be something like dumping the ISO to the hard drive of the system being installed on. The live OS would boot from the hard drive. There are ways to make it so that the /home directory (or any other AFAIK) can be persistent. This would limit the ability to customize the OS as a whole which might be desireable in some cases such as deploying to a limited userbase of people who aren't techincal enough to safely administer their own Linux system but need to be able to use the tools as part of a group exercise.

<a id="include-iso-in-the-installed-system"></a>
## Include ISO in the installed system
Maybe include the live OS ISO in the installed system with a GUI/TUI to use to install it to an external drive. This would facilitate completely offline propigation of the tools. Combined with the [on ISO mirror](#on-iso-mirror) it would allow the entirely offline install and spread of the system.

<a id="in-an-ideal-world"></a>
## In An Ideal World
* Everything should be in deb packages rather than stuck in `config.includes*`.
  * It makes thing in debian run a little smother.
* The ISO would be available only in `cdrom` installer mode to keep everything entirely offline.
* A firewall is enabled by default that prevents all inbound and almost all or all outbound traffic.
  * This would prevent things like WinLink from phoning home and keep any local services from accidentally listening on to external network traffic.
  * A toggle can easily be added to allow outbound traffic and users that are doing unsupported things can drop to the console and poke at things themselves.

<a id="out-of-scope-things"></a>
### Out of Scope Things (or at least out-of-scope-ish)
  * Packages should be kept up to date for security purposes.
  * Builds should be frequent and available for alpha testers to try without building it themselves.
  * The packages that contain customizations and other EmCommTools specific stuff (see the first bullet point in [In An Ideal World](#in-an-ideal-world)) should be in an apt repo.
    * Even if it isn't super public it would make it easier to debug issues if everyone involved can get the exact same packages.
    * It doesn't have to be officially supported.
    * It can be used to roll out hot-fixes to installed OS's without a full reinstall.
