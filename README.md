# Debian package version & dependency experiments

How do we need or can we set up dependencies, pinning, ... in a way that
`kubeadm` and `kubelet` play nice together?

## What's that?

**Attention**

This is just a playground to explore option on how to set up package dependencies.
There is some nasty stuff in here (e.g. setting up pinning in
`/etc/apt/preferences.d`, esp. package A setting up pinning of package B).

This is just for experimenting ...

## Building the image and the packages

`mkae build` will build a container image `debtest` and a couple of faux debian
packages (packages with no content, but with dependencies and pinning set up)
in different versions.

Those packages will be put on an internal (to the container) local debian
repository and the local package management system will be configured to use
this repository. In other words: inside the container those packages are just a
`apt-get install` away.

### Available packages

The available packages, which versions and which dependencies they have, is
currently hardcoded in `populateMirror.sh`.

As one of the last steps `make build` will print a list of available packages:
```
   [...]
----[ available packages ]----
kubeadm 1.12.5
kubeadm 1.12.4
kubeadm 1.11.3
kubeadm 1.11.2
kubeadm 1.10.1
kubeadm 1.10.0
kubelet 1.12.5
kubelet 1.12.4
kubelet 1.11.3
kubelet 1.11.2
kubelet 1.10.1
kubelet 1.10.0
----
  [...]
```

The dependencies are setup:
- `kubeadm-1.X.Y` depends on `kubelet >= 1.(X-1) && kubelet < 1.(X+1)`
- `kubelet` has no special dependencies set up

The pinning is set up:
- `kubeadm` does not setup any pinning
- `kubelet-1.X.Y` sets up pinning to `kubelet 1.X.Y` and `kubeadm 1.X.*` 


## Running some tests

`make test` will run all the tests which match the glob `./tests/*_test.sh`.

For each of the test cases, a fresh container with the previously build image
will be started, all of `./tests/` will be mounted into the container and the
test script will be run. In this way we have a fresh system per test and don't
have to fear cross-test-polution.

To add a new test, you just need to drop a file into `./tests/` with the name
`*_test.sh`. You can source `shared.inc.sh` in the same directory which sets up
some common things and provides some helper functions.

## When do I need to rebuild the image

Adding new test cases does not need a rebuild.

When adding/removing packages or package versions or when you want to change
their dependency setup, you need to change `populateMirror` and run `make
build`.

