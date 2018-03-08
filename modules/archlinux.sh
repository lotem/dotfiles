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

packer_url='https://aur.archlinux.org/packages/packer'

install_packer() {
  if ! command -v packer &> /dev/null; then
    fancy_echo 'Not implemented; please install packer manually:\n%s' "${packer_url}"
    return 1
  fi
}
