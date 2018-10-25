#!/bin/bash

# Evolved from the thoughtbot laptop script.

install_homebrew() {
  if ! command -v brew >/dev/null; then
    fancy_echo "Installing Homebrew ..."
      curl -fsS \
        'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

      append_to_zshrc '# recommended by brew doctor'

      # shellcheck disable=SC2016
      append_to_zshrc 'export PATH="/usr/local/bin:$PATH"' 1

      export PATH="/usr/local/bin:$PATH"

      setup_homebrew_mirror
  else
    fancy_echo "Homebrew already installed. Skipping ..."
  fi
}

setup_homebrew_mirror() {
  if [ "$HOMEBREW_MIRROR" = 'ustc' ]; then
    # https://mirrors.ustc.edu.cn/help/brew.git.html
    (
      cd "$(brew --repo)"
      git remote set-url origin https://mirrors.ustc.edu.cn/brew.git
    )
    # https://mirrors.ustc.edu.cn/help/homebrew-core.git.html
    (
      cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
      git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-core.git
    )
    # https://mirrors.ustc.edu.cn/help/homebrew-cask.git.html
    (
      cd "$(brew --repo)"/Library/Taps/homebrew/homebrew-cask
      git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git
    )
    brew_update

    # https://mirrors.ustc.edu.cn/help/homebrew-bottles.html
    append_to_zshrc 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew-bottles'

  elif [ "$HOMEBREW_MIRROR" = 'tuna' ]; then
    # https://mirrors.tuna.tsinghua.edu.cn/help/homebrew/
    (
      cd "$(brew --repo)"
      git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/brew.git
    )
    (
      cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
      git remote set-url origin https://mirrors.tuna.tsinghua.edu.cn/git/homebrew/homebrew-core.git
    )
    brew_update

    # https://mirrors.tuna.tsinghua.edu.cn/help/homebrew-bottles/
    append_to_zshrc 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.tuna.tsinghua.edu.cn/homebrew-bottles'
 fi
}

install_homebrew_packages() {
  map brew_install "${brew_formulas[@]}"
  map brew_tap_install "${brew_tap_formulas[@]}"
  map brew_cask_install "${brew_casks[@]}"
  map brew_install "${brew_fuse_formulas[@]}"
}

brew_update() {
  fancy_echo "Updating Homebrew formulas ..."
  brew update
}

brew_install() {
  if brew_is_installed "$1"; then
    if brew_is_upgradable "$1"; then
      fancy_echo "Upgrading %s ..." "$1"
      brew upgrade "$@"
    else
      fancy_echo "Already using the latest version of %s. Skipping ..." "$1"
    fi
  else
    fancy_echo "Installing %s ..." "$1"
    local brew_install_options
    if [ -n "$liveusb" ]; then
      # disable optimization for the target CPU to work for older machines
      brew_install_options+=' --build-bottle --force-bottle'
    fi
    brew install $brew_install_options "$@"
  fi
}

brew_is_installed() {
  local name="$(brew_expand_alias "$1")"

  brew list -1 | grep -Fqx "$name"
}

brew_is_upgradable() {
  local name="$(brew_expand_alias "$1")"

  ! brew outdated --quiet "$name" >/dev/null
}

brew_tap() {
  brew tap "$1" 2> /dev/null
}

brew_tap_install() {
  local tap="${1%/*}"
  local formula="${1##*/}"
  brew_tap "$tap"
  brew_install "$formula"
}

brew_expand_alias() {
  brew info "$1" 2>/dev/null | head -1 | awk '{gsub(/:/, ""); print $1}'
}

brew_launchctl_restart() {
  local name="$(brew_expand_alias "$1")"
  local domain="homebrew.mxcl.$name"
  local plist="$domain.plist"

  fancy_echo "Restarting %s ..." "$1"
  mkdir -p "$HOME/Library/LaunchAgents"
  ln -sfv "/usr/local/opt/$name/$plist" "$HOME/Library/LaunchAgents"

  if launchctl list | grep -Fq "$domain"; then
    launchctl unload "$HOME/Library/LaunchAgents/$plist" >/dev/null
  fi
  launchctl load "$HOME/Library/LaunchAgents/$plist" >/dev/null
}

brew_cask_expand_alias() {
  brew cask info "$1" 2>/dev/null | head -1 | awk '{gsub(/:/, ""); print $1}'
}

brew_cask_is_installed() {
    local NAME=$(brew_cask_expand_alias "$1")
    brew cask list -1 | grep -Fqx "$NAME"
  }

brew_cask_install() {
  if brew_cask_is_installed "$1"; then
    fancy_echo "%s is already installed, brew cask upgrade is not yet implemented" "$1"
  else
    brew cask install "$@"
  fi
}
