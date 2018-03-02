#!/bin/bash

# Evolved from the thoughtbot laptop script.
# Be prepared to turn your laptop (or desktop, no haters here)
# into an awesome development machine.
#
# Also powered by lotem's scripting-fu.
#
# Usage:
#
#     ./bootstrap.sh
#     ./bootstrap.sh run=customize
#     ./bootstrap.sh skip=brew_update skip=setup_zsh
#     ./bootstrap.sh exclude='package_x' exclude='package_y'

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

commands=()

excludes=()

# TODO: set the array variables in boostrap.conf

# pacman -Qenqt | sed "s/.*/  '\\0'/"
archlinux_packages=()

# pacman -Qemqt | sed "s/.*/  '\\0'/"
aur_packages=()

brew_formulas=()

brew_tap_formulas=()

brew_casks=()

global_node_modules=()

# TODO: override this function in bootstrap.conf
customize() {
  true
}

source "$(dirname $0)/modules/prelude.sh"

import_module 'archlinux'
import_module 'editor'
import_module 'fedora'
import_module 'homebrew'
import_module 'programming'
import_module 'ubuntu'
import_module 'zsh'

load_config 'bootstrap.conf'

main() {
  # Install software packages.
  if [[ "$OSTYPE" =~ darwin ]]; then

    install_homebrew
    brew_update
    install_homebrew_packages

  elif [[ "$OSTYPE" =~ linux-gnu ]]; then

    if command -v pacman &>/dev/null; then
      install_archlinux_packages
    elif command -v dnf &>/dev/null; then
      install_fedora_packages
    elif command -v apt-get &>/dev/null; then
      # TODO: try other Debian-based distros?
      install_ubuntu_packages
    else
      fancy_echo 'Only Arch Linux, Fedora and Ubuntu are supported at the moment.'
      return 1
    fi

  fi

  # Setup configuration (creates .zshrc) before switching to zsh.
  if [ "$MY_ZSH_CONFIG" = 'omz' ]; then
    install_omz
  elif [ "$MY_ZSH_CONFIG" = 'zprezto' ]; then
    install_prezto
  fi
  setup_zsh

  # This creates .emacs.d/ before setup_dotfiles adds symlinks in the directory.
  setup_emacs
  setup_dotfiles
  setup_nano
  setup_vim

  customize

  install_nodejs
  map npm_install_global "${global_node_modules[@]}"
  install_rust
  map cargo_install "${cargo_install_crates[@]}"
}

process_args "$@"

run_commands "${commands[@]}"

fancy_echo 'all done.'

# vim:set et sw=2:
