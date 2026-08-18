# tmux-dev-session

A small, portable tmux setup for starting a session-focused development layout.

## Install

```bash
git clone <your-repository-url> tmux-dev-session
cd tmux-dev-session
./install.sh
source ~/.bashrc # use ~/.zshrc when applicable
boop             # starts or attaches to the default `main` session
boop work ~/code/my-app
                 # starts or attaches to `work` for a specific project
```

`install.sh` creates symlinks for `~/.tmux.conf` and
`~/scripts/tmux-dev-setup.sh`, then sources the repository's aliases from your
shell configuration. Existing regular files are backed up under
`~/.tmux-dev-backup-<timestamp>`; an unrelated existing symlink is never
replaced automatically.

The installer checks for `tmux` (required) and `fzf`, `fd`, `rg`, and `bat`
(optional), and installs [TPM](https://github.com/tmux-plugins/tpm) when Git is
available. Inside tmux, press `Ctrl-b` then `I` to install plugins.

## Usage

```bash
boop [session] [project-dir]
boop              # attach/create the default `main` session in the current directory
boop work         # attach/create a named session in the current directory
boop work ~/code/my-app
                  # attach/create `work` for a specific project directory
bleh work         # kill a session by name
tdev              # alias for boop
```

The launcher creates or attaches to a named session with a persistent
3-pane `dev` layout for agent, workspace, and shell work. The first argument
is the session name; the second argument is optional and points at the project
directory to open in that session.

Useful bindings: `Ctrl-b` plus the arrow keys move between panes, `|` creates a
horizontal split, `-` a vertical split, and `Ctrl-b r` reloads the tmux
configuration.

## Remove

```bash
./uninstall.sh
```

This removes only links that point to this repository and the marked alias
block. TPM and tmux plugins are intentionally retained.
