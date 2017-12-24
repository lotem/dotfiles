#!/bin/bash

install_archlinux_packages() {
  if [ ${#archlinux_packages[@]} -ne 0 ]; then
    sudo pacman -Syu
    fancy_echo 'Installling packages ...'
    map 'sudo pacman -S --needed' ${archlinux_packages[@]}
  fi

  install_packer
  if [ ${#aur_packages[@]} -ne 0 ]; then
    fancy_echo 'Installling AUR packages ...'
    map aur_install ${aur_packages[@]}
  fi
}

aur_install() {
  if pacman -Qkq $@ &> /dev/null; then
    fancy_echo "Package '%s' is already installed. Skipping ..." $@
  else
    packer -S --noedit $@
  fi
}

packer_url='https://aur.archlinux.org/packages/packer'

install_packer() {
  if ! command -v packer &> /dev/null; then
    fancy_echo 'Not implemented; please install packer manually:\n%s' ${packer_url}
    return 1
  fi
}
