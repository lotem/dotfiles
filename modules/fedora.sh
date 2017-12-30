#!/bin/bash

copr_install() {
  local repo="${1%/*}"
  local package="${1##*/}"
  sudo dnf copr enable "$repo"
  sudo dnf install -y "$package"
}

install_fedora_packages() {
  if [ ${#fedora_groups[@]} -ne 0 ]; then
    fancy_echo 'Installling RPM groups ...'
    map 'sudo dnf groupinstall' "${fedora_groups[@]}"
  fi

  if [ ${#fedora_packages[@]} -ne 0 ]; then
    fancy_echo 'Installling packages ...'
    map 'sudo dnf install -y' "${fedora_packages[@]}"
  fi

  if [ ${#fedora_copr_packages[@]} -ne 0 ]; then
    fancy_echo 'Installling packages from Copr ...'
    map copr_install "${fedora_copr_packages[@]}"
  fi
}
