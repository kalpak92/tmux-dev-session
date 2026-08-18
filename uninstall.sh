#!/usr/bin/env bash
# Remove only links and shell blocks installed by this repository.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"

remove_own_link() {
  local target="$1" source="$2"
  if [[ -L "$target" ]] && [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
    rm -- "$target"
    printf '  Removed %s\n' "$target"
  fi
}

remove_alias_block() {
  local rc="$1"
  [[ -f "$rc" ]] || return 0
  local temp
  temp="$(mktemp "${TMPDIR:-/tmp}/tmux-dev-session.XXXXXX")"
  awk '/^# >>> tmux-dev-session >>>$/ { skipping=1; next } /^# <<< tmux-dev-session <<</ { skipping=0; next } !skipping { print }' "$rc" > "$temp"
  mv -- "$temp" "$rc"
  printf '  Cleaned aliases from %s\n' "$rc"
}

printf '%s\n' 'Removing tmux-dev-session:'
remove_own_link "$HOME/.tmux.conf" "$REPO_DIR/config/.tmux.conf"
remove_own_link "$HOME/scripts/tmux-dev-setup.sh" "$REPO_DIR/scripts/tmux-dev-setup.sh"
remove_alias_block "${ZDOTDIR:-$HOME}/.zshrc"
remove_alias_block "$HOME/.bashrc"
printf '%s\n' 'Done. TPM and installed tmux plugins were left untouched.'
