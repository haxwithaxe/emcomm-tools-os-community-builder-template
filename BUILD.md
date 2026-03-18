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

## Build Stages
The hook "scripts" are executed so they can be written in anything or even be compiled binaries.

### Clean Stage
This stage runs basic cleanup on the build directory.

#### Pre-Clean Step
Scripts that end in `.pre-clean` will run in alphabetical order in this step.

#### Clean Step
`lb clean` is run.

#### Post-Clean Step
Scripts that end in `.post-clean` will run in alphabetical order in this step.


### Clean-All Stage
This step runs very thorough cleaning. The pre/post scripts can be used to purge build artifacts from pre/post build scripts.
`lb clean --all` is called in this step which purges all caches and build artifacts in the build environment.

#### Pre-Clean-All Step
Scripts that end in `.pre-clean-all` will run in alphabetical order in this step.

#### Clean-All Step
The "clean" stage is run with the `--all` argument being passed to `lb clean`.

#### Post-Clean-All Step
Scripts that end in `.post-clean-all` will run in alphabetical order in this step.


### Build Stage
This stage builds the live OS ISO.

#### Pre-Build Step
Scripts that end in `.pre-build` will run in alphabetical order in this step.

#### Build Step
`lb config ...` and `lb build` are run.

#### Post-Build Step
Scripts that end in `.post-build` will run in alphabetical order in this step.


## Error Handling
When any of the "clean-all", "clean", or "build" stages fail a message is passed to the `onfail` function that runs all the scripts that end in `.onfail`.


### OnFail/OnSuccess Scripts

* The first argument is the stage that failed ("clean-all", "clean", or "build").
* The second argument is the return code of the stage.
* The third argument is a message suitable for human consumption.


#### OnFail Scripts
These scripts are run when a build stage returns non-zero.

Scripts that end in `.onfail` will run in alphabetical order in this step.

`build.sh.d/notify-stage-failed.onfail.example` can be used to send notifications on the failure of any stage.


#### OnSuccess Scripts
These scripts are run when a build stage returns zero.

Scripts that end in `.onsuccess` will run in alphabetical order in this step.

`build.sh.d/notify-build-success.onsuccess.example` can be used to send notifications on "build" stage success.


## Production and Production-like Prep
WIP
