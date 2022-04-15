#!/bin/bash

# Evolved from the thoughtbot laptop script.

append_to_zshrc() {
  local text="$1" zshrc
  local skip_new_line="${2:-0}"

  if [ -n "$3" ]; then
    zshrc="$3"
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

setup_zsh() {
  # Setup configuration (creates .zshrc) before switching to zsh.
  if [ "$MY_ZSH_CONFIG" = 'omz' ]; then
    install_omz
  elif [ "$MY_ZSH_CONFIG" = 'zprezto' ]; then
    install_prezto
  fi

  case "$SHELL" in
    */zsh) : ;;
    *)
      fancy_echo "Changing your shell to zsh ..."
        chsh -s "$(which zsh)"
      ;;
  esac
}

install_omz() {
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    curl -L https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
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

use_zprezto_theme() {
  local zpreztorc="$HOME/.zpreztorc"
  if [ ! -w "$zpreztorc" ]; then
    return
  fi
  local theme="$1"
  if [ -n "$theme" ]; then
    sed "s/^\\(zstyle ':prezto:module:prompt' theme\\) '.*'$/\\1 '${theme}'/" \
    "$zpreztorc" > "${zpreztorc}.tmp"
    mv "${zpreztorc}.tmp" "$zpreztorc"
  fi
}

use_zprezto_modules() {
  local zpreztorc="$HOME/.zpreztorc"
  if [ ! -w "$zpreztorc" ]; then
    return
  fi

  local new_modules=()
  for module in "$@" ; do
    if ! grep -qs '^\s*'"'$module'"'\s*\\$' "$zpreztorc"; then
      new_modules+=("$module")
    fi
  done

  if [ ${#new_modules[@]} -ne 0 ]; then
    sed "/^  'prompt'\$/i\\
$(printf "#(  '%s' )#"'\\\n' "${new_modules[@]}" | sed '$s/\\$//')
" "$zpreztorc" | sed 's/#(\(.*\))#/\1\\/' > "${zpreztorc}.tmp"
    mv "${zpreztorc}.tmp" "$zpreztorc"
  fi
}
