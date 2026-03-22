#!/bin/bash

set -e -o pipefail

if [ "$(whoami)" != "root" ]; then
	echo "This must be run as root"
	exit 1
fi

BUILD_SH_REPO_DIR="$(dirname "$0")"
export BUILD_SH_REPO_DIR


print_usage() {
	cat - 1>&2 <<EOF
Usage: $(basename "$0") [-h|--help] [-b|--build] [-c|--clean|--clean-all] [--config|--post-build|--pre-build] [--log|--no-log]
    This must be run as root so the build tools can create and manage chroots.
    -h|--help: Print this message.
    -b|--build|<no arguments>: Run the pre-build scripts, post-build scripts,
    	and the build process.
    -c|--clean: Cursory cleaning. Run the pre-clean scripts, post-clean
		scripts, and build environment clean up.
    --clean-all: Deep cleaning. Run the pre-clean-all scripts, post-clean-all
		scripts, and build environment clean up.
    --config: Run just the config step of the build process.
	--log: Log the output of this script without removing the colors in stdout.
		The "unbuffer" command from the "expect" package is required for this
		to work as expected. If it is not available the build will continue
		without redirecting to a log file afer showing a brief message and
		pausing momentarily for you to read it. After the pause the script will
		continue as if this option was not given.
	--no-log: For internal use. It just negates --log when both are used.
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
			"./$script" || return $?
		done
	else
		echo No pre-clean-all scripts
	fi

	clean --all

	set -x
	# Completely wipe out the cache
	rm -rf --one-file-system "${BUILD_SH_REPO_DIR}/cache"

	set +x

	if compgen -G 'build.sh.d/*.post-clean-all'; then
		echo Running post-clean-all scripts
		for script in build.sh.d/*.post-clean-all; do
			"./$script" || return $?
		done
	else
		echo No post-clean-all scripts
	fi
}


# Run the scripts that do build directory clean up.
clean() {
	if compgen -G 'build.sh.d/*.pre-clean'; then
		echo Running pre-clean scripts
		for script in build.sh.d/*.pre-clean; do
			"./$script" || return $?
		done
	else
		echo No pre-clean scripts
	fi

	echo "Running clean step"

	set -x

	lb clean "$@" || return $?

	set +x

	if compgen -G 'build.sh.d/*.post-clean'; then
		echo Running post-clean scripts
		for script in build.sh.d/*.post-clean; do
			"./$script" || return $?
		done
	else
		echo No post-clean scripts
	fi
}


config() {
	echo Running config step

	set -x

	# FIXME: Maybe? 'live' should probably be 'cdrom' once
	#   packages are included in the  ISO.
	lb config \
		--debian-installer live \
		--archive-areas "main contrib non-free non-free-firmware" \
		--backports true \
		--proposed-updates true \
		|| return $?

	set +x

	post_config

}

post_config() {
	if compgen -G 'build.sh.d/*.post-config'; then
		echo Running post-config scripts
		for script in build.sh.d/*.post-config; do
			"./$script"
		done
	else
		echo No post-config scripts
	fi
}

onfail() {
	if compgen -G 'build.sh.d/*.onfail'; then
		echo "Running on-fail scripts for $1"
		for script in build.sh.d/*.onfail; do
			"./$script" "$@"
		done
	else
		echo "No on-fail scripts for $1"
	fi
}


onsuccess() {
	if compgen -G 'build.sh.d/*.onsuccess'; then
		echo "Running on-success scripts for $1"
		for script in build.sh.d/*.onsuccess; do
			"./$script" "$@"
		done
	else
		echo "No on-success scripts for $1"
	fi
}


post_build() {
	if compgen -G 'build.sh.d/*.post-build'; then
		echo Running post-build scripts
		for script in build.sh.d/*.post-build; do
			"./$script" || return $?
		done
	else
		echo No post-build scripts
	fi
}


pre_build() {
	if compgen -G 'build.sh.d/*.pre-build'; then
		echo Running pre-build scripts
		for script in build.sh.d/*.pre-build; do
			"./$script" || return $?
		done
	else
		echo No pre-build scripts
	fi
}


# Run the scripts that build and test or support either.
build() {
	pre_build || return $?

	config || return $?

	echo Running build step

	set -x

	lb build || return $?

	set +x
	post_build || return $?
}


main() {
	local do_build=false
	local do_clean=false
	local do_clean_all=false
	local do_log=false
	local no_log=false
	local orig_opts="$*"
	OPTS=$(getopt --name "$(basename "$0")" --options hbc --longoptions help,build,clean,clean-all,config,log,no-log,post-build,pre-build -- "$orig_opts")
	eval set -- "$OPTS"
	while (($#)); do
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
			--no-log)
				shift
				# Don't do_log if --no-log so there isn't an infinte loop
				do_log=false
				no_log=true
				;;
			--log)
				shift
				# Don't do_log if --no-log so there isn't an infinte loop
				$no_log && continue
				do_log=true
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
	# Log but keep the pretty colors in stdout/stderr
	if $do_log; then
		if which -s unbuffer; then
			# unbuffer only works on executables not functions
			unbuffer "$0" "--no-log $orig_opts" \
				| tee "build-$(\
					git log -1 --abbrev-commit --oneline \
					| cut -d ' ' -f 1\
				)-$(date +%F-%T).log" \
				|| exit 1
			exit 0
		else
			# In case the unbuffer executable isn't available
			# shellcheck disable=SC2016
			echo 'The "unbuffer" executable was not found in $PATH. The Debian \
				package "expect" is needed to use the fancy logging feature.'
			echo 'To get log in the same way without the pretty colors you \
				can abort now with Ctl-c and use the following command:'
			if [[ -n "$SUDO_USER" ]]; then
				# shellcheck disable=SC2016
				echo -n '$ sudo '
				echo -n "$0 $orig_opts"
				# shellcheck disable=SC2016
				echo '| tee "build-$(\
					git log -1 --abbrev-commit --oneline \
					| cut -d " " -f 1\
					)-$(date +%F-%T).log"'
			else
				echo -n '#'
				echo -n "$0 $orig_opts"
				# shellcheck disable=SC2016
				echo '| tee "build-$(\
					git log -1 --abbrev-commit --oneline \
					| cut -d " " -f 1\
					)-$(date +%F-%T).log"'
			fi
			sleep 5  # Give the user a moment to read
			echo 'Now continuing with out redirecting to a log file.'
		fi
	fi
	# Allow clean_all or clean to be run before build when arguments are given together.
	if $do_clean_all; then
		if clean_all; then
			onsuccess "clean-all" $? "Clean-all stage finished successfully"
		else
			onfail "clean-all" "$?" "Clean-all stage failed with return code $?"
		fi
	fi
	if $do_clean; then
		if clean; then
			onsuccess "clean" $? "Clean stage finished successfully"
		else
			onfail "clean" "$?" "Clean stage failed with return code $?"
		fi

	fi
	if $do_build; then
		if build; then
			onsuccess "build" $? "Build stage finished successfully"
		else
			onfail "build" "$?" "Build stage failed with return code $?"
		fi
	fi
}


main "$@"
