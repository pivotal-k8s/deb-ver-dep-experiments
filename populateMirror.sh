#!/usr/bin/env bash

set -e
set -u
set -o pipefail

readonly TMPL_DIR="/testbed/pkg_src_tmpl"
readonly MIRROR_DIR="/testbed/pkgs"


createPkg() {
	local pkg_name="$1"
	local pkg_ver="$2"
	local pkg_deps="${3:-}"
	local d
	shift 3

	d="$( mktemp -d )"

	cp -r "$TMPL_DIR" "${d}/pkg"
	pushd "${d}/pkg" >/dev/null

	for apt_prefs in "$@"
	do
		local pin_name="installed-by-${pkg_name}"
		echo "$apt_prefs" >> "$pin_name"
		echo "${pin_name}	etc/apt/preferences.d" >> debian/install
	done

	find . -type f -print0 \
		| xargs -0 sed -i \
			-e "s/__PKG_NAME__/${pkg_name}/g" \
			-e "s/__PKG_DEPS__/${pkg_deps}/g" \
			-e "s/__PKG_VER__/${pkg_ver}/g"

	dpkg-buildpackage --no-sign -b

	cd ..
	cp ./*deb "${MIRROR_DIR}"

	popd >/dev/null

	rm -rf -- "$d"
}

genPin() {
	local pkg="$1"
	local pin="$2"
	local prio="${3:-1001}"

	echo "
Package: ${pkg}
Pin: version ${pin}
Pin-Priority: ${prio}
"
}

updateMirror() {
	pushd "$MIRROR_DIR"
	dpkg-scanpackages -m . /dev/null | gzip -9c > Packages.gz
	echo "deb [trusted=yes] file:${MIRROR_DIR} ./" > /etc/apt/sources.list.d/local.list

	apt-get update
}

main() {
	createPkg kubelet 1.10.0 '' "$(genPin kubeadm '1.10.*')" "$(genPin kubelet '1.10.0')"
	createPkg kubelet 1.10.1 '' "$(genPin kubeadm '1.10.*')" "$(genPin kubelet '1.10.1')"
	createPkg kubelet 1.11.2 '' "$(genPin kubeadm '1.11.*')" "$(genPin kubelet '1.11.2')"
	createPkg kubelet 1.11.3 '' "$(genPin kubeadm '1.11.*')" "$(genPin kubelet '1.11.3')"
	createPkg kubelet 1.12.4 '' "$(genPin kubeadm '1.12.*')" "$(genPin kubelet '1.12.4')"
	createPkg kubelet 1.12.5 '' "$(genPin kubeadm '1.12.*')" "$(genPin kubelet '1.12.5')"

	createPkg kubeadm 1.10.0 'kubelet (>= 1.9), kubelet (< 1.11)'
	createPkg kubeadm 1.10.1 'kubelet (>= 1.9), kubelet (< 1.11)'
	createPkg kubeadm 1.11.2 'kubelet (>= 1.10), kubelet (< 1.12)'
	createPkg kubeadm 1.11.3 'kubelet (>= 1.10), kubelet (< 1.12)'
	createPkg kubeadm 1.12.4 'kubelet (>= 1.11), kubelet (< 1.13)'
	createPkg kubeadm 1.12.5 'kubelet (>= 1.11), kubelet (< 1.13)'

	updateMirror

	echo '----[ available packages ]----'
	apt-cache show kubeadm kubelet | awk '/Package|Version/{print $2}' | sed -rn 'N;s/\n/ /;p'
	echo '----'
}

main "$@"
