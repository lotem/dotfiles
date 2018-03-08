#!/bin/bash

install_archlinux_packages() {
  if [ ${#archlinux_packages[@]} -ne 0 ]; then
    pacman_upgrade
    fancy_echo 'Installling packages ...'
    map pacman_install "${archlinux_packages[@]}"
  fi

  install_aur_packages
}

pacman_upgrade() {
  sudo pacman -Syu
}

pacman_install() {
  sudo pacman -S --needed $@
}

install_aur_packages() {
  install_packer
  if [ ${#aur_packages[@]} -ne 0 ]; then
    fancy_echo 'Installling AUR packages ...'
    map aur_install "${aur_packages[@]}"
  fi
}

aur_install() {
  if pacman -Qkq $@ &> /dev/null; then
    fancy_echo "Package '%s' is already installed. Skipping ..." $@
  else
    packer -S --noedit "$@"
  fi
}

aur_package_url='https://aur.archlinux.org/packages/%s'
aur_snapshot_url='https://aur.archlinux.org/cgit/aur.git/snapshot/%s.tar.gz'
packer_build_dir='/tmp/packer-build'

install_packer() {
  if ! command -v packer &> /dev/null; then
    pacman_install 'base-devel'
    fancy_echo "Installing packer from ${aur_package_url}" packer
    mkdir -p "${packer_build_dir}"
    pushd "${packer_build_dir}" &>/dev/null
    curl -L -O $(printf "${aur_snapshot_url}" packer)
    tar -xvf packer.tar.gz
    cd packer
    makepkg -si
    popd &>/dev/null
  fi
}
