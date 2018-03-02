#!/bin/bash

apt_get_install() {
  local package="$1"
  sudo apt-get install -y "$package"
}

install_ubuntu_packages() {
  if [ ${#ubuntu_packages[@]} -ne 0 ]; then
    sudo apt-get update
    fancy_echo 'Installling packages ...'
    map apt_get_install "${ubuntu_packages[@]}"
  fi
}
