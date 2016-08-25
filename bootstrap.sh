#!/bin/bash

# Welcome to the thoughtbot laptop script!
# Be prepared to turn your laptop (or desktop, no haters here)
# into an awesome development machine.

# Powered also by lotem's scripting-fu.

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  else
    zshrc="$HOME/.zshrc"
  fi

  if ! grep -Fqs "$text" "$zshrc"; then
    if [ "$skip_new_line" -eq 1 ]; then
      printf "%s\n" "$text" >> "$zshrc"
    else
      printf "\n%s\n" "$text" >> "$zshrc"
    fi
  fi
}

replace_zshrc_variable() {
  local variable=$1
  local value=$2

  local zshrc="$HOME/.zshrc"
  if [ -w "$HOME/.zshrc.local" ]; then
    zshrc="$HOME/.zshrc.local"
  fi

  local line="${variable}=\"${value}\""
  if ! grep -q "^${line}\$" "$zshrc" ; then
    if ! grep -q "^${variable}=" "$zshrc" ; then
      # Variable not defined yet. Should append.
      append_to_zshrc "$line"
    else
      # Comment out the previous definition, then reassign.
      local edit_variable="/^${variable}=/ { s/^/#/; a\\
$line
        }"
      # Or just rewrite the definition if a commented-out line is present.
      if grep -q "^#${variable}=" "$zshrc" ; then
        edit_variable="s#^${variable}=.*\$#${line}#"
      fi
      sed "$edit_variable" "$zshrc" > "${zshrc}.tmp"
      mv "${zshrc}.tmp" "$zshrc"
    fi
  fi
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
    brew install "$@"
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
    echo "$1 is already installed, brew cask upgrade is not yet implemented"
  else
    brew cask install "$@"
  fi
}

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

git_clone_or_pull() {
  local repo_src=$1
  shift
  local local_repo=$1
  shift
  local local_repo_vc_dir=$local_repo/.git
  if [ ! -d "$local_repo_vc_dir" ]; then
    git clone --recursive $repo_src $local_repo $@
  else
    pushd $local_repo
    git pull $repo_src && git submodule update --init --recursive
    popd
  fi
}

install_homebrew() {
  if ! command -v brew >/dev/null; then
    fancy_echo "Installing Homebrew ..."
      curl -fsS \
        'https://raw.githubusercontent.com/Homebrew/install/master/install' | ruby

      append_to_zshrc '# recommended by brew doctor'

      # shellcheck disable=SC2016
      append_to_zshrc 'export PATH="/usr/local/bin:$PATH"' 1

      export PATH="/usr/local/bin:$PATH"
  else
    fancy_echo "Homebrew already installed. Skipping ..."
  fi
}

brew_update() {
  fancy_echo "Updating Homebrew formulas ..."
  brew update
}

install_omz() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
  fi
}

install_prezto() {
    if [ ! -d "$HOME/.zprezto" ]; then
      zsh <<'EOF'
git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
setopt EXTENDED_GLOB
for rcfile in "${ZDOTDIR:-$HOME}"/.zprezto/runcoms/^README.md(.N); do
  ln -s "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
EOF
    fi
}

setup_zsh() {
  if [ ! -d "$HOME/.bin/" ]; then
    mkdir "$HOME/.bin"
  fi

  if [ ! -f "$HOME/.zshrc" ]; then
    touch "$HOME/.zshrc"
  fi

  # shellcheck disable=SC2016
  append_to_zshrc 'export PATH="$HOME/.bin:$PATH"'

  case "$SHELL" in
    */zsh) : ;;
    *)
      fancy_echo "Changing your shell to zsh ..."
        chsh -s "$(which zsh)"
      ;;
  esac
}

setup_dotfiles() {
  if ! command -v rcup >/dev/null; then
    brew_tap_install 'thoughtbot/formulae/rcm'
  fi

  gpg --decrypt private.gpg | tar x
  rcup -v -d dot -d private

  if [ -f "$HOME/.exports" ]; then
    append_to_zshrc 'source "$HOME/.exports"'
  fi
}

install_emacs() {
  brew_install emacs --with-cocoa
  brew link emacs
  brew linkapps emacs
}

setup_emacs() {
  if [ ! -d "$HOME/.emacs.d" ]; then
    git_clone_or_pull 'https://github.com/purcell/emacs.d.git' "$HOME/.emacs.d" --depth 1
  fi
}

setup_vim() {
  if [ ! -d "$HOME/.vim" ]; then
    sh <(curl https://j.mp/spf13-vim3 -L)
  fi
}

install_omz_theme() {
  local repo=$1
  local name=${repo##*/}
  local themedir="$HOME/.oh-my-zsh/custom/themes"
  git_clone_or_pull "https://github.com/${repo}.git" "$themedir/$name" --depth 1
  local file
  for file in "$themedir/$name"/*.zsh-theme ; do
    ln -snf "$file" "$themedir/$(basename "$file")"
  done
}

use_omz_theme() {
  local theme=$1
  test -f "$HOME/.oh-my-zsh/custom/themes/${theme}.zsh-theme"
  replace_zshrc_variable ZSH_THEME "$theme"
}

use_zprezto_modules() {
  local zpreztorc="$HOME/.zpreztorc"
  if [ ! -w "$zpreztorc" ]; then
    return
  fi

  local new_modules=()
  for module in $@ ; do
    if ! grep -qs '^\s*'"'$module'"'\s*\\$' "$zpreztorc"; then
      new_modules+=($module)
    fi
  done

  if [ -n "$new_modules" ]; then
    sed "/^  'prompt'"'$/i\
'"$(printf "#(  '%s' )#"'\\\n' "${new_modules[@]}")"'
' "$zpreztorc" | sed 's/#(\(.*\))#$/\1\\/' > "${zpreztorc}.tmp"
    mv "${zpreztorc}.tmp" "$zpreztorc"
  fi
}

install_nodejs() {
  # nvm
  if [ ! -f ~/.nvm/nvm.sh ]; then
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.29.0/install.sh | bash
  fi
  . ~/.nvm/nvm.sh

  # node
  if ! nvm which node >/dev/null; then
    nvm install node
  fi
  nvm use node

  # cnpm
  if ! command -v cnpm >/dev/null; then
    npm install -g cnpm --registry=http://registry.npm.taobao.org
  fi
}

npm_install_global() {
  if cnpm ls -g "$1" &>/dev/null; then
    fancy_echo "%s is already installed. Upgrading ..." "$1"
    cnpm update -g "$@"
  else
    cnpm install -g "$@"
  fi
}

install_rust() {
  PATH=$PATH:$HOME/.cargo/bin
  if ! command -v cargo &>/dev/null; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    cargo install racer
  fi
}

# TODO: override this function in bootstrap.conf
customize() {
  true
}

excludes=()

commands=()

map() {
  local command=$1
  shift
  local exclude_pattern=" ${excludes[*]} "
  local item
  for item in $@ ; do
    if [[ "$exclude_pattern" =~ " $item " ]]; then
      fancy_echo 'Excluded package %s.' "$item"
    else
      $command $item
    fi
  done
}

brew_formulas=(
)

brew_tap_formulas=(
)

brew_casks=(
)

osx_brew_formulas=(
)

osx_brew_casks=(
)

global_node_modules=(
)

process_args() {
  local arg
  for arg in $@; do
    if [[ "$arg" =~ skip=.* ]]; then
      local function_name=${arg#skip=}
      eval "$function_name () {
        fancy_echo 'Skipping %s %s ...' $function_name \"\$*\"
      }"
    elif [[ "$arg" =~ exclude=.* ]]; then
      excludes+=("${arg#exclude=}")
    elif [[ "$arg" =~ run=.* ]]; then
      commands+=("${arg#run=}")
    fi
  done
}

run_commands() {
  if [ "$#" -eq 0 ]; then
    main
  else
    local cmd
    for cmd in $@; do
      fancy_echo 'Running: %s' "${cmd}"
      eval "${cmd}"
    done
  fi
}

main() {
  #install_omz
  install_prezto
  setup_zsh

  install_homebrew
  brew_update

  brew_tap caskroom/cask

  map brew_install ${brew_formulas[@]}
  map brew_tap_install ${brew_tap_formulas[@]}
  map brew_cask_install ${brew_casks[@]}

  if [[ "$OSTYPE" =~ darwin ]]; then
    map brew_install ${osx_brew_formulas[@]}
    map brew_tap_install ${osx_brew_tap_formulas[@]}
    map brew_cask_install ${osx_brew_casks[@]}
  elif [[ "$OSTYPE" =~ linux-gnu ]]; then
    true
  fi

  install_emacs
  setup_emacs
  setup_dotfiles
  setup_vim

  install_nodejs
  map npm_install_global ${global_node_modules[@]}

  install_rust

  customize
}

trap 'ret=$?; test $ret -ne 0 && printf "failed\n\n" >&2; exit $ret' EXIT

set -e

process_args $@

if [ -f "$(dirname $0)/bootstrap.conf" ]; then
  . "$(dirname $0)/bootstrap.conf"
fi

run_commands ${commands[@]}

fancy_echo 'all done.'

# vim:set et sw=2:
