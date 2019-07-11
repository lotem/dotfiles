#!/bin/bash

# Evolved from the thoughtbot laptop script.

fancy_echo() {
  local fmt="$1"; shift

  # shellcheck disable=SC2059
  printf "\n$fmt\n" "$@"
}

git_clone_or_pull() {
  local repo_src=$1
  shift
  local local_repo=$1
  shift
  local local_repo_vc_dir=$local_repo/.git
  if [ ! -d "$local_repo_vc_dir" ]; then
    git clone --recursive "$repo_src" "$local_repo" "$@"
  else
    pushd "$local_repo"
    git pull "$repo_src" && git submodule update --init --recursive
    popd
  fi
}

import_module() {
  local module=$1
  local script_path="$(dirname $0)/modules/${module}.sh"
  if [ -f "${script_path}" ]; then
    source "${script_path}"
  else
    fancy_echo "Error: module '%s' not found at %s" "${module}" "${script_path}"
    return 1
  fi
}

map() {
  local command=$1
  shift
  local exclude_pattern=" ${excludes[*]} "
  local item
  for item in "$@" ; do
    if [[ "$exclude_pattern" =~ " $item " ]]; then
      fancy_echo 'Excluded package %s.' "$item"
    else
      $command "$item"
    fi
  done
}

load_config() {
  local config_file=$1
  if [ -f "$(dirname $0)/${config_file}" ]; then
    source "$(dirname $0)/${config_file}"
  fi
}

process_args() {
  local arg
  for arg in "$@"; do
    if [[ "$arg" =~ skip=.* ]]; then
      local function_name="${arg#skip=}"
      eval "$function_name () {
        fancy_echo 'Skipping %s %s ...' $function_name \"\$*\"
      }"

    elif [[ "$arg" =~ exclude=.* ]]; then
      excludes+=("${arg#exclude=}")

    elif [[ "$arg" =~ run=.* ]]; then
      commands+=("${arg#run=}")

    elif [[ "$arg" == '--liveusb' ]]; then
      liveusb=1
    fi
  done
}

run_commands() {
  if [ "$#" -eq 0 ]; then
    main
  else
    local cmd
    for cmd in "$@"; do
      fancy_echo 'Running: %s' "${cmd}"
      eval "${cmd}"
    done
  fi
}

setup_dotfiles() {
  if ! command -v rcup >/dev/null; then
    fancy_echo 'rcm is required. Installing ...'
    import_module 'rcm'
    install_rcm
  fi

  pushd "$(dirname $0)"
  setup_private_config
  rcup -v -d dot -d private
  popd

  if [ -f "$HOME/.exports" ]; then
    append_to_zshrc 'source "$HOME/.exports"'
  fi
}

setup_private_config() {
  if [ -d private ]; then
    return
  fi
  if [ -f private.gpg ]; then
    gpg --decrypt private.gpg | tar x
  else
    git submodule update --init private
  fi
}
