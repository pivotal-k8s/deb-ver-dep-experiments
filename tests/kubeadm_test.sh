#!/usr/bin/env bash

. ./shared.inc.sh

step 'install kubelet in 1.10.0 and kubeadm in no specific version'
	pkgInstall kubelet=1.10.0
	pkgInstall kubeadm

	test "$(pkgVersion kubelet)" = '1.10.0' || fail 'Expected kubelet installed in version 1.10.0'
	test "$(pkgVersion kubeadm)" = '1.10.1' || fail 'Expected kubeadm installed in version 1.10.1'

step 'bump kubeadm to the next minor'
	pkgInstall kubeadm='1.11.*'

	test "$(pkgVersion kubelet)" = '1.10.0' || fail 'Expected kubelet installed in version 1.10.0'
	test "$(pkgVersion kubeadm)" = '1.11.3' || fail 'Expected kubeadm installed in version 1.11.2'

step 'bump kubelet to the next minor'
	pkgInstall kubelet='1.11.*'

	test "$(pkgVersion kubelet)" = '1.11.3' || fail 'Expected kubelet installed in version 1.10.0'
	test "$(pkgVersion kubeadm)" = '1.11.3' || fail 'Expected kubeadm installed in version 1.11.2'


