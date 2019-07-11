#!/bin/bash

install_rcm() {
  if [[ "$OSTYPE" =~ darwin ]]; then
    brew install thoughtbot/formulae/rcm
  else
    install_rcm_from_source
  fi
}

install_rcm_from_source() {
  pushd /tmp

  curl -LO https://thoughtbot.github.io/rcm/dist/rcm-1.3.1.tar.gz && \

  sha=$(sha256sum rcm-1.3.1.tar.gz | cut -f1 -d' ') && \
  [ "$sha" = "9c8f92dba63ab9cb8a6b3d0ccf7ed8edf3f0fb388b044584d74778145fae7f8f" ] && \

   tar -xvf rcm-1.3.1.tar.gz && \
  cd rcm-1.3.1 && \

  ./configure && \
  make && \
  sudo make install

  popd
}
