#!/bin/bash

############### GAMES INFO ############################

VSL_SKYRIMSE_FOLDER="Syrim Special Edition"
VSL_SKYRIMSE_STEAM_ID="489830"

VSL_SKYRIM_FOLDER="Skyrim"
VSL_SKYRIM_STEAM_ID="72850"

#######################################################

############### PATH CANDIDATES #######################

STEAM_PROTON1_PATH="$HOME/.steam/steam"
STEAM_PROTON2_PATH="$HOME/.local/share/Steam"
WINESTEAM_PATH="$HOME/.local/share/lutris/runners/winesteam"

#######################################################

############### VORTEX PREFIX #########################
if [ "$VORTEX_PREFIX" == "" ]; then
	VORTEX_PREFIX=$(dirname $BASH_SOURCE)
fi
if [ ! -d "$VORTEX_PREFIX" ]; then
    echo "ERROR: Invalid Vortex prefix \"$VORTEX_PREFIX\""
    exit -1
fi
#######################################################

############## FUNCTIONS DECLARATIONS #################

find_current_game_folders () {

    if [ -d "$STEAM_PROTON1_PATH/steamapps/compatdata/$CURRENT_GAME_STEAM_ID/pfx" ]; then
        CURRENT_INSTALL="$STEAM_PROTON1_PATH/steamapps/common/$CURRENT_GAME_FOLDER"
        CURRENT_PREFIX="$STEAM_PROTON1_PATH/steamapps/compatdata/$CURRENT_GAME_FOLDER/pfx"
        CURRENT_GAME_USER="steamuser"

    elif [ -d "$STEAM_PROTON2_PATH/steamapps/compatdata/$CURRENT_GAME_STEAM_ID/pfx" ]; then
        CURRENT_INSTALL="$STEAM_PROTON2_PATH/steamapps/common/$CURRENT_GAME_FOLDER"
        CURRENT_PREFIX="$STEAM_PROTON2_PATH/steamapps/compatdata/$CURRENT_GAME_FOLDER/pfx"
        CURRENT_GAME_USER="steamuser"

    elif [ -d "$WINESTEAM_PATH/prefix64/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAME_FOLDER" ]; then
        CURRENT_INSTALL="$WINESTEAM_PATH/prefix64/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAME_FOLDER"
        CURRENT_PREFIX="$WINESTEAM_PATH/prefix64"
        CURRENT_GAME_USER=$USER

    fi

    if [ ! -d "$CURRENT_INSTALL" ]; then
        echo "WARN: Could not find $CURRENT_GAME_FOLDER installation"
    fi
    if [ ! -d "$CURRENT_PREFIX" ]; then
        echo "WARN: Could not find $CURRENT_GAME_FOLDER prefix"
    fi

}

create_current_game_symlinks () {
    if [ -d "$CURRENT_INSTALL" ] && [ -d "$CURRENT_PREFIX" ]; then

        mkdir -p "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/My Documents/My Games/$CURRENT_GAME_FOLDER"
        mkdir -p "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/Local Settings/Application Data/$CURRENT_GAME_FOLDER"

        rm -rf "$VORTEX_PREFIX/drive_c/users/$USER/My Documents/My Games/$CURRENT_GAME_FOLDER"
        rm -rf "$VORTEX_PREFIX/drive_c/users/$USER/Local Settings/Application Data/$CURRENT_GAME_FOLDER"
        rm -rf "$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAME_FOLDER"

        ln -s "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/My Documents/My Games/$CURRENT_GAME_FOLDER" "$VORTEX_PREFIX/drive_c/users/$USER/My Documents/My Games/$CURRENT_GAME_FOLDER"
        ln -s "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/Local Settings/Application Data/$CURRENT_GAME_FOLDER" "$VORTEX_PREFIX/drive_c/users/$USER/Local Settings/Application Data/$CURRENT_GAME_FOLDER"
        ln -s "$CURRENT_INSTALL" "$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAME_FOLDER"

    fi
}

#######################################################

########## CREATE NECESSARY VORTEX FOLDERS ############
mkdir -p "$VORTEX_PREFIX/drive_c/users/$USER/My Documents/My Games"
mkdir -p "$VORTEX_PREFIX/drive_c/users/$USER/Local Settings/Application Data"
mkdir -p "$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common"
#######################################################

################ CREATE SYMLINKS ######################
for CURRENT_GAME in $(printenv | grep -o -e 'VSL_\w*_FOLDER' | sed 's/_FOLDER//')
do

    CURRENT_GAME_FOLDER=$(printenv "${CURRENT_GAME}_FOLDER")
    CURRENT_GAME_STEAM_ID=$(printenv "${CURRENT_GAME}_STEAM_ID")

    find_current_game_folders
    create_current_game_symlinks

done
#######################################################
