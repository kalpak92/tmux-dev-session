#!/usr/bin/env bash
# Create or attach to a persistent 3-pane tmux session.
set -euo pipefail

check_dependencies() {
  local missing=0 tool
  tool=tmux
  if command -v "$tool" >/dev/null 2>&1; then
    printf '  found %s: %s\n' "$tool" "$(command -v "$tool")"
  else
    printf '  missing required tool: %s\n' "$tool" >&2
    missing=1
  fi
  for tool in fzf fd rg bat; do
    if command -v "$tool" >/dev/null 2>&1; then
      printf '  found optional tool: %s\n' "$tool"
    else
      printf '  optional tool not found: %s\n' "$tool"
    fi
  done
  return "$missing"
}

if [[ "${1:-}" == '--deps-only' ]]; then
  check_dependencies
  exit $?
fi

if ! command -v tmux >/dev/null 2>&1; then
  printf '%s\n' 'tmux is required. Install it with your system package manager.' >&2
  exit 1
fi

session_name="${1:-main}"
session_name="${session_name//[^[:alnum:]_-]/_}"
project_dir="${2:-$PWD}"
if [[ ! -d "$project_dir" ]]; then
  printf 'Not a directory: %s\n' "$project_dir" >&2
  exit 1
fi
project_dir="$(cd -- "$project_dir" && pwd -P)"

if tmux has-session -t "$session_name" 2>/dev/null; then
  if [[ -n "${TMUX:-}" ]]; then
    tmux switch-client -t "$session_name"
  else
    exec tmux attach-session -t "$session_name"
  fi
fi

tmux new-session -d -s "$session_name" -n dev -c "$project_dir"
tmux split-window -h -t "$session_name:dev" -c "$project_dir"
tmux split-window -v -t "$session_name:dev.1" -c "$project_dir"
tmux select-pane -t "$session_name:dev.0"
tmux display-message -t "$session_name" 'dev session ready: agent | workspace | shell'

if [[ -n "${TMUX:-}" ]]; then
  tmux switch-client -t "$session_name"
else
  exec tmux attach-session -t "$session_name"
fi
