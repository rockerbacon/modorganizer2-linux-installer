#!/bin/bash

############### GAMES INFO ############################

VSL_SKYRIMSE_GAMEDIR="Skyrim Special Edition"
VSL_SKYRIMSE_APPID="489830"

VSL_SKYRIM_GAMEDIR="Skyrim"
VSL_SKYRIM_APPID="72850"

#######################################################

############### PATH CANDIDATES #######################

STEAM_PROTON1_PATH="$HOME/.steam/steam"
STEAM_PROTON2_PATH="$HOME/.local/share/Steam"
WINESTEAM_PATH="$HOME/.local/share/lutris/runners/winesteam"

#######################################################

############### VORTEX PREFIX #########################
if [ "$VORTEX_PREFIX" == "" ]; then
    CURRENT_DIRECTORY=$(dirname $BASH_SOURCE)
	VORTEX_PREFIX="$CURRENT_DIRECTORY/.."
fi
if [ ! -d "$VORTEX_PREFIX" ]; then
    echo "ERROR: Invalid Vortex prefix \"$VORTEX_PREFIX\""
    exit -1
else
    echo "INFO: Using Vortex prefix at \"$VORTEX_PREFIX\""
fi
#######################################################

############## FUNCTIONS DECLARATIONS #################

find_current_game_paths () {

    CURRENT_INSTALL=""
    CURRENT_PREFIX=""

    if [ -d "$STEAM_PROTON1_PATH/steamapps/compatdata/$CURRENT_APPID/pfx" ]; then
        CURRENT_INSTALL="$STEAM_PROTON1_PATH/steamapps/common/$CURRENT_GAMEDIR"
        CURRENT_PREFIX="$STEAM_PROTON1_PATH/steamapps/compatdata/$CURRENT_APPID/pfx"
        CURRENT_GAME_USER="steamuser"

    elif [ -d "$STEAM_PROTON2_PATH/steamapps/compatdata/$CURRENT_APPID/pfx" ]; then
        CURRENT_INSTALL="$STEAM_PROTON2_PATH/steamapps/common/$CURRENT_GAMEDIR"
        CURRENT_PREFIX="$STEAM_PROTON2_PATH/steamapps/compatdata/$CURRENT_APPID/pfx"
        CURRENT_GAME_USER="steamuser"

    elif [ -d "$WINESTEAM_PATH/prefix64/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAMEDIR" ]; then
        CURRENT_INSTALL="$WINESTEAM_PATH/prefix64/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAMEDIR"
        CURRENT_PREFIX="$WINESTEAM_PATH/prefix64"
        CURRENT_GAME_USER=$USER

    fi

    if [ ! -d "$CURRENT_INSTALL" ]; then
        echo "WARN: Could not find $CURRENT_GAME installation"
    else
        echo "INFO: Found installation for $CURRENT_GAME in \"$CURRENT_INSTALL\""
    fi
    if [ ! -d "$CURRENT_PREFIX" ]; then
        echo "WARN: Could not find $CURRENT_GAME prefix"
    else
        echo "INFO: Found prefix for $CURRENT_GAME in \"$CURRENT_PREFIX\""
    fi

}

create_current_game_symlinks () {
    if [ -d "$CURRENT_INSTALL" ] && [ -d "$CURRENT_PREFIX" ]; then

        mkdir -p "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/My Documents/My Games/$CURRENT_GAMEDIR"
        mkdir -p "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/Local Settings/Application Data/$CURRENT_GAMEDIR"

        rm -rf "$VORTEX_PREFIX/drive_c/users/$USER/My Documents/My Games/$CURRENT_GAMEDIR"
        rm -rf "$VORTEX_PREFIX/drive_c/users/$USER/Local Settings/Application Data/$CURRENT_GAMEDIR"
        rm -rf "$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAMEDIR"

        ln -s "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/My Documents/My Games/$CURRENT_GAMEDIR" "$VORTEX_PREFIX/drive_c/users/$USER/My Documents/My Games/$CURRENT_GAMEDIR"
        ln -s "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/Local Settings/Application Data/$CURRENT_GAMEDIR" "$VORTEX_PREFIX/drive_c/users/$USER/Local Settings/Application Data/$CURRENT_GAMEDIR"
        ln -s "$CURRENT_INSTALL" "$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAMEDIR"

    fi
}

#######################################################

########## CREATE NECESSARY VORTEX FOLDERS ############
mkdir -p "$VORTEX_PREFIX/drive_c/users/$USER/My Documents/My Games"
mkdir -p "$VORTEX_PREFIX/drive_c/users/$USER/Local Settings/Application Data"
mkdir -p "$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common"
#######################################################

################ CREATE SYMLINKS ######################
GAMES=$(set -o posix; set | grep -o -e 'VSL_\w*_GAMEDIR' | sed 's/_GAMEDIR//')
echo "INFO: Found games:"
echo $GAMES
for CURRENT_GAME in $GAMES
do

    echo "INFO: Building symlinks for $CURRENT_GAME"

    CURRENT_GAMEDIR=$(set -o posix; set | grep "${CURRENT_GAME}_GAMEDIR=" | sed "s/${CURRENT_GAME}_GAMEDIR=//; s/^'//; s/'$//")
    CURRENT_APPID=$(set -o posix; set | grep "${CURRENT_GAME}_APPID=" | sed "s/${CURRENT_GAME}_APPID=//")

    echo "INFO: gamedir=\"$CURRENT_GAMEDIR\" APPID=\"$CURRENT_APPID\""

    find_current_game_paths
    create_current_game_symlinks

done
#######################################################
