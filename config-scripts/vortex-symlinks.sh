#!/bin/bash

############### GAMES INFO ############################

VSL_SKYRIMSE_GAMEDIR="Skyrim Special Edition"
VSL_SKYRIMSE_APPID="489830"

VSL_SKYRIM_GAMEDIR="Skyrim"
VSL_SKYRIM_APPID="72850"

VSL_OBLIVION_GAMEDIR="Oblivion"
VSL_OBLIVION_APPID="22330"

VSL_FALLOUT4_GAMEDIR="Fallout 4"
VSL_FALLOUT4_APPID="377160"
VSL_FALLOUT4_OVERRIDE_MYGAMES="Fallout4"
VSL_FALLOUT4_OVERRIDE_APPDATA="Fallout4"

VSL_FALLOUT3_GOTY_GAMEDIR="Fallout 3 goty"
VSL_FALLOUT3_GOTY_APPID="22370"
VSL_FALLOUT3_GOTY_OVERRIDE_MYGAMES="Fallout3"
VSL_FALLOUT3_GOTY_OVERRIDE_APPDATA="Fallout3"

VSL_FALLOUT3_GAMEDIR="Fallout 3"
VSL_FALLOUT3_APPID="22300"

VSL_FALLOUT_NEWVEGAS_GAMEDIR="Fallout New Vegas"
VSL_FALLOUT_NEWVEGAS_APPID="22380"
VSL_FALLOUT_NEWVEGAS_OVERRIDE_MYGAMES="FalloutNV"
VSL_FALLOUT_NEWVEGAS_OVERRIDE_APPDATA="FalloutNV"

VSL_MORROWIND_GAMEDIR="Morrowind"
VSL_MORROWIND_APPID="22320"

#######################################################

############### PATH ARG CHECKS #######################

if ! [ -z $STEAM_CUSTOM_PATHS ]; then
	for path in $STEAM_CUSTOM_PATHS; do
		if ! [ -d "$path" ]; then
			echo "ERROR: Custom path $path does not exist"
			exit -1
		else
			echo "INFO: Custom path $path found"
		fi
	done
else
	STEAM_CUSTOM_PATHS=""
fi

#######################################################

############### PATH CANDIDATES #######################

STEAM_PROTON_PATH="$HOME/.steam/steam $HOME/.local/share/Steam $STEAM_CUSTOM_PATHS"
WINESTEAM_PATH="$HOME/.local/share/lutris/runners/winesteam"

#######################################################

############### VORTEX PREFIX #########################
if [ "$VORTEX_PREFIX" == "" ]; then
    SOURCE_FILE_PATH=$(dirname "$0")
	VORTEX_PREFIX=$(realpath "$SOURCE_FILE_PATH/..")
fi
if [ ! -d "$VORTEX_PREFIX" ]; then
    echo "ERROR: Invalid Vortex prefix \"$VORTEX_PREFIX\""
    exit -1
else
    echo "INFO: Using Vortex prefix at \"$VORTEX_PREFIX\""
fi
#######################################################

############## FUNCTIONS DECLARATIONS #################
game_attribute () {
     echo $(set | grep "${CURRENT_GAME}_${1}=" | sed "s/${CURRENT_GAME}_${1}=//; s/^'//; s/'$//")
}

find_current_game_paths () {

    CURRENT_INSTALL=""
    CURRENT_PREFIX=""

    if [ -d "$WINESTEAM_PATH/prefix64/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAMEDIR" ]; then
        CURRENT_INSTALL="$WINESTEAM_PATH/prefix64/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAMEDIR"
        CURRENT_PREFIX="$WINESTEAM_PATH/prefix64"
        CURRENT_GAME_USER=$USER

    else
		for steam_path in $STEAM_PROTON_PATHS; do
    		if [ -d "$steam_path/steamapps/compatdata/$CURRENT_APPID/pfx" ]; then
        		CURRENT_INSTALL="$steam_park/steamapps/common/$CURRENT_GAMEDIR"
	        	CURRENT_PREFIX="$steam_path/steamapps/compatdata/$CURRENT_APPID/pfx"
		        CURRENT_GAME_USER="steamuser"
			fi
		done
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

        OVERRIDE_MYGAMES=$(game_attribute "OVERRIDE_MYGAMES")
        OVERRIDE_APPDATA=$(game_attribute "OVERRIDE_APPDATA")

        if [ "$OVERRIDE_MYGAMES" == "" ]; then
            MYGAMES=$CURRENT_GAMEDIR
        else
            MYGAMES=$OVERRIDE_MYGAMES
        fi

        if [ "$OVERRIDE_APPDATA" == "" ]; then
            APPDATA=$CURRENT_GAMEDIR
        else
            APPDATA=$OVERRIDE_APPDATA
        fi

        mkdir -p "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/My Documents/My Games/$MYGAMES"
        mkdir -p "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/Local Settings/Application Data/$APPDATA"

        rm -rf "$VORTEX_PREFIX/drive_c/users/$USER/My Documents/My Games/$MYGAMES"
        rm -rf "$VORTEX_PREFIX/drive_c/users/$USER/Local Settings/Application Data/$APPDATA"
        rm -rf "$VORTEX_PREFIX/drive_c/Program Files (x86)/Steam/steamapps/common/$CURRENT_GAMEDIR"

        ln -s "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/My Documents/My Games/$MYGAMES" "$VORTEX_PREFIX/drive_c/users/$USER/My Documents/My Games/$MYGAMES"
        ln -s "$CURRENT_PREFIX/drive_c/users/$CURRENT_GAME_USER/Local Settings/Application Data/$APPDATA" "$VORTEX_PREFIX/drive_c/users/$USER/Local Settings/Application Data/$APPDATA"
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
set -o posix
GAMES=$(set | grep -o -e 'VSL_\w*_GAMEDIR' | sed 's/_GAMEDIR//')
echo "INFO: Found games:"
echo $GAMES
for CURRENT_GAME in $GAMES
do

    echo "INFO: Building symlinks for $CURRENT_GAME"

    CURRENT_GAMEDIR=$(game_attribute "GAMEDIR")
    CURRENT_APPID=$(game_attribute "APPID")

    echo "INFO: gamedir=\"$CURRENT_GAMEDIR\" APPID=\"$CURRENT_APPID\""

    find_current_game_paths
    create_current_game_symlinks

done
#######################################################

######### LINK DOWNLOADS HANDLER SHORTCUT #############
echo "INFO: Linking Nexus Mods downloads to Vortex"
ESCAPED_VORTEX_PREFIX=$(echo $VORTEX_PREFIX | sed 's/\//\\\//g')
ESCAPED_HOME=$(echo $HOME | sed 's/\//\\\//g')
sed -i "s/<VORTEX_PREFIX>/$ESCAPED_VORTEX_PREFIX/g; s/<HOME>/$ESCAPED_HOME/g" "$HOME/.local/share/applications/vortex-downloads-handler.desktop"
xdg-mime default vortex-downloads-handler.desktop x-scheme-handler/nxm
xdg-mime default vortex-downloads-handler.desktop x-scheme-handler/nxm-protocol
#######################################################
