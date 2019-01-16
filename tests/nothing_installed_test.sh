#!/usr/bin/env bash

. ./shared.inc.sh

test -z "$(pkgVersion kubeadm)" || fail 'Expected kubeadm not to be installed'
test -z "$(pkgVersion kubelet)" || fail 'Expected kubelet not to be installed'

test "$(pkgCandidate kubeadm)" = '1.12.5' || fail 'Expected kubeadm candidate to be 1.12.5'
test "$(pkgCandidate kubelet)" = '1.12.5' || fail 'Expected kubelet candidate to be 1.12.5'
