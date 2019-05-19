#!/bin/bash

EXECUTABLE="SkyrimSELauncher.exe"
SKYRIM_COMPAT_DATA="$HOME/.steam/steam/steamapps/compatdata/489830"

if [ "$SKYRIM_PROTON_BINARY" == "" ]; then
    SOURCE_FILE_PATH=$(dirname "$0")
	SKSE_INSTALL_PATH=$(realpath "$SOURCE_FILE_PATH/..")
    SKYRIM_PROTON_BINARY="$SKSE_INSTALL_PATH/proton_patch/skyrim-proton/proton"
fi

SKYRIM_INSTALL_FOLDER="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition"


if [ "$EXECUTABLE" != "" ]; then
    echo "Launching $EXECUTABLE"
    export STEAM_COMPAT_DATA_PATH=$SKYRIM_COMPAT_DATA
    $SKYRIM_PROTON_BINARY run "$EXECUTABLE"
fi
