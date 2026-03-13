#!/bin/bash

set -e

if [ "$(whoami)" != "root" ]; then
	echo "This must be run as root"
	exit 1
fi

export BUILD_SH_REPO_DIR="$(dirname "$0")"


print_usage() {
	cat - 1>&2 <<EOF
Usage: $(basename "$0") [-h|--help] [-b|--build] [-c|--clean] [--clean-all]
    This must be run as root so the build tools can create and manage chroots.
    -h|--help: Print this message.
    -b|--build|<no arguments>: Run the pre-build scripts, post-build scripts, 
    	and the build process.
    -c|--clean: Cursory cleaning. Run the pre-clean scripts, post-clean 
		scripts, and build environment clean up.
    --clean-all: Deep cleaning. Run the pre-clean-all scripts, post-clean-all 
		scripts, and build environment clean up.
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
	fi

	clean

	if compgen -G 'build.sh.d/*.post-clean-all'; then
		echo Running post-clean-all scripts
		for script in build.sh.d/*.post-clean-all; do
			"./$script"
		done
	fi
}

# Run the scripts that do build directory clean up.
clean() {
	if compgen -G 'build.sh.d/*.pre-clean'; then
		echo Running pre-clean scripts
		for script in build.sh.d/*.pre-clean; do
			"./$script"
		done
	fi

	set -x

	lb clean

	set +x

	if compgen -G 'build.sh.d/*.post-clean'; then
		echo Running post-clean scripts
		for script in build.sh.d/*.post-clean; do
			"./$script"
		done
	fi
}

# Run the scripts that build and test or support either.
build() {
	if compgen -G 'build.sh.d/*.pre-build'; then
		echo Running pre-build scripts
		for script in build.sh.d/*.pre-build; do
			"./$script"
		done
	fi

	set -x

	lb config --debian-installer live
	lb build

	set +x

	if compgen -G 'build.sh.d/*.post-build'; then
		echo Running post-build scripts
		for script in build.sh.d/*.post-build; do
			"./$script"
		done
	fi
	# FIXME: Add upload step?
}


main() {
	local do_build=false
	local do_clean=false
	local do_clean_all=false

	OPTS=$(getopt -a -o hbc --long help,build,clean,clean-all -- "$@") || getopt_rc=$?
	# If getopt failed because it got no arguments assume the user wants to 
	#   clean and build.
	if [[ "$getopt_rc" != "0" ]]; then
		if [[ "${#@}" != "0" ]]; then
			print_usage
			exit 1
		fi
		do_clean=true
		do_build=true
	else
		while true; do
			case $1 in
				-h|--help)
					print_usage
					exit 1
					;;
				-c|--clean)
					# Don't run both clean and clean-all
					$do_clean_all || continue
					do_clean=true
					exit 0
					;;
				-b|--build)
					do_build=true
					shift
					;;
				--clean-all)
					do_clean_all=true
					# Don't run both clean and clean-all
					do_clean=false  
					shift
					;;
				--)
					shift
					break
					;;
				*)
					echo ERROR: Unknown argument "$1"
					print_usage
					exit 1
					;;
			esac
		done
	fi
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


main $@


