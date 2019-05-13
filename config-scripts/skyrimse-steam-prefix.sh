#!/bin/bash

if [ -d "$HOME/.steam/steam" ]; then
    export STEAM_PREFIX="$HOME/.steam/steam/steamapps/compatdata/489830/pfx"
elif [ -d "$HOME/.local/share/Steam" ]; then
    export STEAM_PREFIX="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx"
else
    echo "Could not find Steam"
    exit -1
