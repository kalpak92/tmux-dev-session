#!/usr/bin/env bash
# One-command setup for tmux-dev-session.
set -euo pipefail

REPO_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd -P)"
SCRIPTS_DIR="$HOME/scripts"
BACKUP_DIR="$HOME/.tmux-dev-backup-$(date +%s)"

backup_if_exists() {
  local target="$1"
  if [[ -e "$target" && ! -L "$target" ]]; then
    mkdir -p "$BACKUP_DIR"
    cp -a -- "$target" "$BACKUP_DIR/"
    printf '  Backed up %s to %s/\n' "$target" "$BACKUP_DIR"
  fi
}

create_symlink() {
  local source="$1" target="$2"
  if [[ -L "$target" ]]; then
    if [[ "$(readlink -f -- "$target")" == "$(readlink -f -- "$source")" ]]; then
      printf '  Already linked: %s\n' "$target"
      return
    fi
    printf 'Refusing to replace existing symlink: %s\n' "$target" >&2
    return 1
  fi
  backup_if_exists "$target"
  rm -f -- "$target"
  ln -s -- "$source" "$target"
  printf '  Linked %s -> %s\n' "$target" "$source"
}

detect_shell_rc() {
  if [[ "${SHELL:-}" == *zsh* ]]; then
    printf '%s\n' "${ZDOTDIR:-$HOME}/.zshrc"
  else
    printf '%s\n' "$HOME/.bashrc"
  fi
}

wire_aliases() {
  local shell_rc="$1"
  local start='# >>> tmux-dev-session >>>'
  local end='# <<< tmux-dev-session <<<'
  mkdir -p "$(dirname -- "$shell_rc")"
  touch "$shell_rc"
  if grep -qF -- "$start" "$shell_rc"; then
    printf '  Aliases already wired in %s\n' "$shell_rc"
    return
  fi
  {
    printf '\n%s\n' "$start"
    printf 'source %q\n' "$REPO_DIR/shell/aliases.sh"
    printf '%s\n' "$end"
  } >> "$shell_rc"
  printf '  Added aliases to %s\n' "$shell_rc"
}

install_tpm() {
  local tpm_dir="$HOME/.tmux/plugins/tpm"
  if [[ -d "$tpm_dir" ]]; then
    printf '  TPM already installed\n'
  elif command -v git >/dev/null 2>&1; then
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    printf '  Installed TPM\n'
  else
    printf '  git not found; skipped TPM installation\n' >&2
  fi
}

printf 'tmux-dev-session installer\n\n'
printf '%s\n' 'Linking config files:'
create_symlink "$REPO_DIR/config/.tmux.conf" "$HOME/.tmux.conf"
mkdir -p "$SCRIPTS_DIR"
create_symlink "$REPO_DIR/scripts/tmux-dev-setup.sh" "$SCRIPTS_DIR/tmux-dev-setup.sh"

printf '%s\n' 'Wiring shell aliases:'
SHELL_RC="$(detect_shell_rc)"
wire_aliases "$SHELL_RC"

printf '%s\n' 'Checking dependencies:'
"$REPO_DIR/scripts/tmux-dev-setup.sh" --deps-only

printf '%s\n' 'Installing Tmux Plugin Manager:'
install_tpm

printf '\nInstallation complete. Run: source %q && boop\n' "$SHELL_RC"
printf 'Then press prefix + I inside tmux to install configured plugins.\n'
