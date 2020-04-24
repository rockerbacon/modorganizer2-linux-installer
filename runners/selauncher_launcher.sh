#!/bin/bash

EXECUTABLE="SkyrimSELauncher.exe"
SKYRIM_COMPAT_DATA="$HOME/.steam/steam/steamapps/compatdata/489830"
SKYRIM_PROTON_BINARY="$HOME/.steam/steam/steamapps/common/Proton 4.11/proton"
SKYRIM_INSTALL_FOLDER="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition"

if [ "$EXECUTABLE" != "" ]; then
    echo "Launching $EXECUTABLE"
    export STEAM_COMPAT_DATA_PATH=$SKYRIM_COMPAT_DATA
    "$SKYRIM_PROTON_BINARY" run "$EXECUTABLE"
fi
