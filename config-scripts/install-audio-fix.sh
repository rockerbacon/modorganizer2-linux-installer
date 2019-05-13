#!/bin/bash

if [ -d "$HOME/.steam/steam" ]; then
    STEAM_PREFIX="$HOME/.steam/steam/steamapps/compatdata/489830/pfx"
elif [ -d "$HOME/.local/share/Steam" ]; then
    STEAM_PREFIX="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx"
else
    echo "Could not find Steam"
    exit -1
fi

if [ "$AUDIOFIX_EXECUTABLE" == "" ]; then
    SOURCE_FILE_PATH=$(dirname "$0")
    AUDIOFIX_EXECUTABLE="$SOURCE_FILE_PATH/wine_setup_faudio.sh"
    echo "INFO: fAudio setup=\"$AUDIOFIX_EXECUTABLE\""
fi

WINEPREFIX="$STEAM_PREFIX" bash "$AUDIOFIX_EXECUTABLE"
