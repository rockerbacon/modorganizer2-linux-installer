#!/bin/bash

if [ -d "$HOME/.steam/steam" ]; then
    export STEAM_PREFIX="$HOME/.steam/steam/steamapps/compatdata/489830/pfx"
elif [ -d "$HOME/.local/share/Steam" ]; then
    export STEAM_PREFIX="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx"
else
    echo "Could not find Steam"
    exit -1

if [ "$AUDIOFIX_EXECUTABLE" == "" ] && [ "$GAMEDIR" != "" ]; then
    AUDIOFIX_EXECUTABLE="$GAMEDIR/audiofix/wine_setup_faudio.sh"
else
    echo "Need to specify the location for wine_setup_faudio.sh through the AUDIOFIX_EXECUTABLE environment variable"
fi

WINEPREFIX="$STEAM_PREFIX" bash "$AUDIOFIX_EXECUTABLE"
