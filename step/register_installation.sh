#!/usr/bin/env bash

mkdir -p "$HOME/.config/modorganizer2/instances"
rm -f "$HOME/.config/modorganizer2/instances/$game_nexusid"
ln -s "$install_dir" "$HOME/.config/modorganizer2/instances/$game_nexusid"

