#!/bin/bash

apt_get_install() {
  local package="$1"
  sudo apt-get install -y "$package"
}

apt_get_update() {
  sudo apt-get update
}

install_ubuntu_packages() {
  if [ ${#ubuntu_packages[@]} -ne 0 ]; then
    apt_get_update
    fancy_echo 'Installling packages ...'
    map apt_get_install "${ubuntu_packages[@]}"
  fi
}
