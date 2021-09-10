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
  sudo pacman -S --needed --noconfirm $@
}

install_aur_packages() {
  install_yay
  if [ ${#aur_packages[@]} -ne 0 ]; then
    fancy_echo 'Installling AUR packages ...'
    map aur_install "${aur_packages[@]}"
  fi
}

aur_install() {
  if pacman -Qkq $@ &> /dev/null; then
    fancy_echo "Package '%s' is already installed. Skipping ..." $@
  else
    yay -S "$@"
  fi
}

aur_package_url='https://aur.archlinux.org/packages/%s'
aur_snapshot_url='https://aur.archlinux.org/cgit/aur.git/snapshot/%s.tar.gz'
yay_build_dir='/tmp/yay-build'

install_yay() {
  if ! command -v yay &> /dev/null; then
    pacman_install 'base-devel'
    fancy_echo "Installing yay from ${aur_package_url}" yay
    mkdir -p "${yay_build_dir}"
    pushd "${yay_build_dir}" &>/dev/null
    curl -L -O $(printf "${aur_snapshot_url}" yay)
    tar -xvf yay.tar.gz
    cd yay
    makepkg -si
    popd &>/dev/null
  fi
}
