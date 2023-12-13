#!/bin/env bash
create ~/bin
mkdir -p ~/bin

# download and extract just to ~/bin/just
curl --proto '=https' --tlsv1.2 -sSf https://just.systems/install.sh | bash -s -- --to ~/bin

# add `~/bin` to the paths that your shell searches for executables
# this line should be added to your shells initialization file,
# e.g. `~/.bashrc` or `~/.zshrc`
#export PATH="$PATH:$HOME/bin"
# shellcheck disable=SC2016
echo 'export PATH="$PATH:$HOME/bin"' >>"$HOME"/.zprofile
# shellcheck disable=SC2016
echo 'export PATH="$PATH:$HOME/bin"' >>"$HOME"/.profile
