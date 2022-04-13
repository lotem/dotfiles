#!/bin/bash

# No holy war over text editors. I use all of the following.

setup_emacs() {
  if [ ! -d "$HOME/.emacs.d" ]; then
    if [ "$MY_EMACS_CONFIG" = 'centaur' ]; then
      git_clone_or_pull 'https://github.com/seagle0128/.emacs.d.git' "$HOME/.emacs.d" --depth 1
    elif [ "$MY_EMACS_CONFIG" = 'prelude' ]; then
      curl -L https://git.io/epre | sh
    elif [ "$MY_EMACS_CONFIG" = 'purcell' ]; then
      git_clone_or_pull 'https://github.com/purcell/emacs.d.git' "$HOME/.emacs.d" --depth 1
    fi
  fi
  if [[ "$OSTYPE" =~ darwin ]]; then
    fancy_echo "TODO: brew services start emacs"
  else
    fancy_echo "TODO: systemctl --user enable --now emacs"
  fi
}

setup_vim() {
  if [ ! -d "$HOME/.vim" ]; then
    sh <(curl https://j.mp/spf13-vim3 -L)
  fi
}

setup_nano() {
  git_clone_or_pull 'https://github.com/scopatz/nanorc.git' "$HOME/.nano" --depth 1
  if [ ! -f "$HOME/.nanorc" ]; then
    cat "$HOME/.nano/nanorc" > "$HOME/.nanorc"
  fi

  if [[ "$OSTYPE" =~ darwin ]] &&
      [ "$(command -v nano)" != "$(brew --prefix)/bin/nano" ]; then
    fancy_echo "Please install the latest version of nano"
  fi
}
