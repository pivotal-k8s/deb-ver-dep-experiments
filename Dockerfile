FROM debian:sid

RUN apt-get -y update \
  && apt-get -y upgrade \
  && apt-get -y install \
    devscripts \
    dh-make \
    dpkg-dev \
    equivs \
    vim \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /testbed


COPY pkg_src_tmpl pkg_src_tmpl
COPY populateMirror.sh .

RUN mkdir pkgs && ./populateMirror.sh

