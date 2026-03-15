#!/bin/bash

set -e

if [ "$(whoami)" != "root" ]; then
	echo "This must be run as root"
	exit 1
fi

export BUILD_SH_REPO_DIR="$(dirname "$0")"


print_usage() {
	cat - 1>&2 <<EOF
Usage: $(basename "$0") [-h|--help] [-b|--build] [-c|--clean|--clean-all] [--config|--post-build|--pre-build]
    This must be run as root so the build tools can create and manage chroots.
    -h|--help: Print this message.
    -b|--build|<no arguments>: Run the pre-build scripts, post-build scripts, 
    	and the build process.
    -c|--clean: Cursory cleaning. Run the pre-clean scripts, post-clean 
		scripts, and build environment clean up.
    --clean-all: Deep cleaning. Run the pre-clean-all scripts, post-clean-all 
		scripts, and build environment clean up.
    --config: Run just the config step of the build process.
    --post-build: Run just the post-build scripts.
    --pre-build: Run just the pre-build scripts.
EOF
}


# Run the scripts that do the deep cleaning like purging deployed test ISOs as 
# 	well as a regular clean.
clean_all() {
	if compgen -G 'build.sh.d/*.pre-clean-all'; then
		echo Running pre-clean-all scripts
		for script in build.sh.d/*.pre-clean-all; do
			"./$script"
		done
	else
		echo Skipping pre-clean-all scripts
	fi

	clean

	if compgen -G 'build.sh.d/*.post-clean-all'; then
		echo Running post-clean-all scripts
		for script in build.sh.d/*.post-clean-all; do
			"./$script"
		done
	else
		echo Skipping post-clean-all scripts
	fi
}

# Run the scripts that do build directory clean up.
clean() {
	if compgen -G 'build.sh.d/*.pre-clean'; then
		echo Running pre-clean scripts
		for script in build.sh.d/*.pre-clean; do
			"./$script"
		done
	else
		echo Skipping pre-clean scripts
	fi

	echo "Running clean step"

	set -x

	lb clean

	set +x

	if compgen -G 'build.sh.d/*.post-clean'; then
		echo Running post-clean scripts
		for script in build.sh.d/*.post-clean; do
			"./$script"
		done
	else
		echo Skipping post-clean scripts
	fi
}

config() {
	echo Running config step

	set -x

	lb config --debian-installer live

	set +x
}

post_build() {
	if compgen -G 'build.sh.d/*.post-build'; then
		echo Running post-build scripts
		for script in build.sh.d/*.post-build; do
			"./$script"
		done
	else
		echo Skipping post-build scripts
	fi
}


pre_build() {
	if compgen -G 'build.sh.d/*.pre-build'; then
		echo Running pre-build scripts
		for script in build.sh.d/*.pre-build; do
			"./$script"
		done
	else
		echo Skipping pre-build scripts
	fi
}


# Run the scripts that build and test or support either.
build() {
	pre_build

	config
	
	echo Running build step
	
	set -x

	lb build

	set +x
	post_build
}


main() {
	local do_build=false
	local do_clean=false
	local do_clean_all=false
	OPTS=$(getopt --name "$(basename "$0")" --options hbc --longoptions help,build,clean,clean-all,config,post-build,pre-build -- $*) || getopt_rc=$? 
	eval set -- "$OPTS"
	while (($#)); do
		echo $1
		case $1 in
			-h|--help)
				print_usage
				exit 1
				;;
			-c|--clean)
				# Don't run both clean and clean-all
				shift
				$do_clean_all && continue
				do_clean=true
				;;
			--config)
				shift
				config
				exit 0
				;;
			--post-build)
				shift
				post_build
				exit 0
				;;
			--pre-build)
				shift
				pre_build
				exit 0
				;;
			-b|--build)
				shift
				do_build=true
				;;
			--clean-all)
				shift
				do_clean_all=true
				# Don't run both clean and clean-all
				do_clean=false  
				;;
			--)
				shift
				if ! $do_build && ! $do_clean && ! $do_clean_all; then
					do_build=true
					do_clean=true
				fi
				break
				;;
			*)
				echo ERROR: Unknown argument "$1"
				shift
				print_usage
				exit 1
				;;
		esac
	done
	# Allow clean_all to be run before build when arguments are given together.
	if $do_clean_all; then
		clean_all
	fi
	if $do_clean; then
		clean
	fi
	if $do_build; then
		build
	fi
}


main $*


