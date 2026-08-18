# Source this file from .bashrc or .zshrc. It intentionally does not alter PATH.

boop() {
  "$HOME/scripts/tmux-dev-setup.sh" "$@"
}

bleh() {
  tmux kill-session -t "${1:?usage: bleh <name>}"
}

alias tdev='boop'
