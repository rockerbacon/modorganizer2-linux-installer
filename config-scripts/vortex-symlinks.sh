#!/bin/bash

#### determine Skyrim prefix and Steam folder
if [ "$SKYRIM_PREFIX" == "" ]; then
	if [ -d "$HOME/.steam/steam/steamapps/compatdata/489830/pfx" ]; then
		STEAM_FOLDER="$HOME/.steam/steam"
		SKYRIM_PREFIX="$HOME/.steam/steam/steamapps/compatdata/489830/pfx"
	elif [ -d "$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx" ]; then
		STEAM_FOLDER="$HOME/.local/share/Steam"
		SKYRIM_PREFIX="$HOME/.local/share/Steam/steamapps/compatdata/489830/pfx"
	elif [ -d "$HOME/.local/share/lutris/runners/winesteam/prefix64/drive_c/Program Files (x86)/Steam/steamapps/common/Skyrim Special Edition" ]; then
        STEAM_FOLDER="$HOME/.local/share/lutris/runners/winesteam/prefix64/drive_c/Program Files (x86)/Steam"
        SKYRIM_PREFIX="$HOME/.local/share/lutris/runners/winesteam/prefix64"
    fi

	if [ ! -d "$SKYRIM_PREFIX" ]; then
		echo "Could not find prefix Skyrim Special Edition"
		exit -1
	fi
fi

#### determine Vortex prefix
if [ "$VORTEX_PREFIX" == "" ]; then
	VORTEX_PREFIX=$(dirname $BASH_SOURCE)
fi

#### ensure required directories exist and are ready to receive the symlinks
SKYRIM_MY_GAMES="$SKYRIM_PREFIX/drive_c/users/steamuser/My Documents/My Games"
mkdir -p "$SKYRIM_MY_GAMES/Skyrim Special Edition"
SKYRIM_APP_DATA="$SKYRIM_PREFIX/drive_c/users/steamuser/Local Settings/Application Data"
mkdir -p "$SKYRIM_APP_DATA/Skyrim Special Edition"

VORTEX_MY_GAMES="$VORTEX_PREFIX/drive_c/users/$USER/My Documents/My Games"
rm -rf "$VORTEX_MY_GAMES/Skyrim Special Edition"
mkdir -p "$VORTEX_MY_GAMES"
VORTEX_APP_DATA="$VORTEX_PREFIX/drive_c/users/$USER/Local Settings/Application Data"
rm -rf "$VORTEX_APP_DATA/Skyrim Special Edition"
mkdir -p "$VORTEX_APP_DATA"
if [ "$STEAM_FOLDER" != "" ]; then
    VORTEX_PROGRAM_FILES="$VORTEX_PREFIX/drive_c/Program Files (x86)"
    rm -rf "$VORTEX_PROGRAM_FILES/Steam"
    mkdir -p "$VORTEX_PROGRAM_FILES"
fi

#### add symlikns between Skyrim's prefix and vortex's
ln -s "$SKYRIM_MY_GAMES/Skyrim Special Edition" "$VORTEX_MY_GAMES/Skyrim Special Edition"
ln -s "$SKYRIM_APP_DATA/Skyrim Special Edition" "$VORTEX_APP_DATA/Skyrim Special Edition"
if [ "$STEAM_FOLDER" != "" ]; then
    ln -s "$STEAM_FOLDER" "$VORTEX_PROGRAM_FILES/Steam"
fi
