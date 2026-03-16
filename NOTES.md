# Random Notes

For context of random people reading this. The EmCommTools OS is intended to be used entirely offline and to be a dedicated use appliance based on Debian but not following it religiously.

## Mirror snapshot for development environment
It is possible to create a local mirror of the apt repos on development machines to 
1. Speed up building the ISOs
2. Allow for static packages or strictly controlled updates.

## On ISO apt mirror
It is possible to include a mirror of apt repos in part or in whole in the ISO. This would allow users to install the OS entirely offline. The same mirror can be used in the development environment and the ISO. This will slow down the builds since it greatly increases the amount of data being copied and compressed (not necessarily too big to fit on a CD).

## Live Installed System
While running the installer in "expert" mode I came across the option to install the OS as the live OS rather than a regular install. This would be something like dumping the ISO to the hard drive of the system being installed on. The live OS would boot from the hard drive. There are ways to make it so that the /home directory (or any other AFAIK) can be persistent. This would limit the ability to customize the OS as a whole which might be desireable in some cases such as deploying to a limited userbase of people who aren't techincal enough to safely administer their own Linux system but need to be able to use the tools as part of a group exercise.

## Include ISO in the installed system
Maybe include the live OS ISO in the installed system with a GUI/TUI to use to install it to an external drive. This would facilitate completely offline propigation of the tools. Combined with the [on ISO mirror](#on-iso-mirror) it would allow the entirely offline install and spread of the system.
