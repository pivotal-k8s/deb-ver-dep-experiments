#!/usr/bin/env bash

set -e
set -u
set -o pipefail

ql_gray=$(tput setaf 7)
ql_magenta=$(tput setaf 5)
ql_cyan=$(tput setaf 6)
ql_orange=$(tput setaf 3)
ql_green=$(tput setaf 2)
ql_red=$(tput setaf 4)
ql_no_color=$(tput sgr0)

pkgVersion() {
	dpkg -l "$1" 2>/dev/null \
		| awk '/^ii/{ print $3}'
}

pkgCandidate() {
	apt-cache policy "$1" 2>/dev/null \
		| awk '/Candidate/{ print $2 }'
}

aptGet() {
	apt-get -qq -y -o Dpkg::Use-Pty=0 "$@"
}

pkgInstall() {
	aptGet install "$@" 2>/dev/null
}

start() {
	echo -e "${ql_magenta}# test:" "${@}" "${ql_no_color}"
}

step() {
	echo -e "${ql_magenta}## step:" "${@}" "${ql_no_color}"
}

ok() {
	echo -e "${ql_green}# OK${ql_no_color}"
}

fail() {
	echo -n "${ql_red}# FAIL" "${@}" "${ql_no_color}"
	exit 1
}
