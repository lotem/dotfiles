#!/bin/bash

# No holy war over programming languages.

gem_install() {
  if gem list "$1" --installed > /dev/null; then
    fancy_echo "Updating %s ..." "$1"
    gem update "$@"
  else
    fancy_echo "Installing %s ..." "$1"
    gem install "$@"
    rbenv rehash
  fi
}

install_nvm() {
  # nvm
  if [ ! -f ~/.nvm/nvm.sh ]; then
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
  fi
  source ~/.nvm/nvm.sh

  # node
  if ! nvm which node >/dev/null; then
    nvm install node
  fi
  nvm use node
}

install_nodejs() {
  if ! command -v node >/dev/null; then
    brew_install node
  fi

  # cnpm
  if ! command -v cnpm >/dev/null; then
    sudo npm install -g cnpm --registry=http://registry.npm.taobao.org
  fi
}

npm_install_global() {
  local npm='npm'
  if ! [ -w "$(npm prefix -g)/lib/node_modules" ]; then
    npm='sudo npm'
  fi

  if npm ls -g "$1" &>/dev/null; then
    fancy_echo "%s is already installed. Upgrading ..." "$1"
    $npm update -g "$@"
  else
    $npm install -g "$@"
  fi
}

install_rust() {
  PATH=$PATH:$HOME/.cargo/bin
  if [ "$RUST_MIRROR" = 'utsc' ]; then
    RUSTUP_DIST_SERVER=https://mirrors.ustc.edu.cn/rust-static
    RUSTUP_UPDATE_ROOT=https://mirrors.ustc.edu.cn/rust-static/rustup/dist
  fi
  if ! command -v cargo &>/dev/null; then
    if ! command -v rustup &>/dev/null; then
      curl https://sh.rustup.rs -sSf | sh -s -- -y --default-toolchain nightly
    fi
    rustup component add rust-src --toolchain nightly
  fi
  rcup -v -d dot cargo
}

cargo_install() {
  local cmd
  local crate
  for crate in $@; do
    cmd="${crate#*:}"
    crate="${crate%:*}"
    if ! command -v "${cmd}" &>/dev/null; then
      cargo install "${crate}"
    fi
  done
}
