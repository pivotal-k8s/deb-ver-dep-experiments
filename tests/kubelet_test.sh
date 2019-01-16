#!/usr/bin/env bash

. ./shared.inc.sh


step 'installing kubelet in version 1.10.0'
	pkgInstall kubelet=1.10.0

	test "$( pkgVersion kubelet )" = '1.10.0' || fail 'Expected kubelet in version 1.10.0'
	test -z "$( pkgVersion kubeadm )" || fail 'Expected kubeadm not to be installed'

step 'runing apt-get install, upgrade and full-upgrade'
	aptGet update && aptGet upgrade && aptGet full-upgrade

	test "$( pkgVersion kubelet )" = '1.10.0' || fail 'Expected kubelet in version 1.10.0'
	test -z "$( pkgVersion kubeadm )" || fail 'Expected kubeadm not to be installed'

step 'installing kubelet again, without specific version'
	pkgInstall kubelet

	test "$( pkgVersion kubelet )" = '1.10.0' || fail 'Expected kubelet in version 1.10.0'
	test -z "$( pkgVersion kubeadm )" || fail 'Expected kubeadm not to be installed'
