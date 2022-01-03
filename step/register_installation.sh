#!/bin/bash

mkdir -p "$HOME/.config/modorganizer2/instances"
rm -f "$HOME/.config/modorganizer2/instances/$nexus_game_id"
ln -s "$install_dir" "$HOME/.config/modorganizer2/instances/$nexus_game_id"

