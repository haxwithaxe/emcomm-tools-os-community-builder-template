
if ! (return 0 2>/dev/null); then
	echo To use this file source it and call the functions directly.
	echo Example:
	echo '# source /dev-tools.sh'
	echo '# bootstrap_apt'
	exit 1
fi

# When the apt sources aren't setup right in the installed system.
bootstrap_apt() {
	set -x
	echo deb http://deb.debian.org/debian/ \
		trixie \
		main \
		contrib \
		non-free \
		non-free-firmware \
		>  /etc/apt/sources.list
	apt update
	set +x
}

# Mostly to make transfering files easier.
install_ssh_server() {
	apt update
	apt install openssh-server
}

dump_manifests() {
	echo '# dpkg --get-selections' > /tmp/installed.packages
	echo '# find / -xdev 2>/dev/null' > /tmp/installed.files
	set -x
	dpkg --get-selections >> /tmp/installed.packages
	find / -xdev 2>/dev/null >> /tmp/installed.files
	set +x
	chmod a+r /tmp/installed.packages /tmp/installed.files
}
