#!/bin/bash

declare -A gamesmap

register_handler_for() {
	gamesmap[${1}_dir]=$dir
	gamesmap[${1}_appid]=$appid
	gamesmap[${1}_launcher_opts]=$launcher_opts
}

########################

###    SKYRIM    ###
dir="Skyrim"
appid=72850
launcher_opts="--restart-pulse --native d3dx9_42 --protonver 5.*"
register_handler_for "skyrim"
###    SKYRIM    ###

###    FALLOUT NEW VEGAS    ###
dir="Fallout New Vegas"
appid=22380
launcher_opts="--restart-pulse --native d3dx9_42 --protonver 5.*"
register_handler_for "newvegas"
###    FALLOUT NEW VEGAS    ###

###    SKYRIM SPECIAL EDITION    ###
dir="Skyrim Special Edition"
appid=489830
launcher_opts="--restart-pulse --native 'xaudio2_7' --protonver 5.*"
register_handler_for "skyrimspecialedition"
###    SKYRIM SPECIAL EDITION    ###

########################

steam_libraries_list_file="$HOME/.steam/steam/steamapps/libraryfolders.vdf"

xtermbox() {
	action_on_exit=$1
	msg=$2
	xterm -e bash -c "
		echo '$msg'
		echo
		echo Press enter to $action_on_exit
		read
	"
}

if [ -n "$(command -v zenity)" ]; then
	errorbox="zenity --ellipsize --error --text"
elif [ -n "$(command -v xmessage)" ]; then
	errorbox="xmessage -buttons exit:0"
elif [ -n "$(command -v xterm)" ]; then
	errorbox="xtermbox exit"
else
	errorbox="echo"
fi

###    PARSE POSITIONAL ARGS    ###
nxm_link=$1; shift

if [ -z "$nxm_link" ]; then
	echo "ERROR: please specify a NXM Link to download"
	exit 1
fi

game=$(echo $nxm_link | grep -oE 'nxm://[^/]+' | sed 's/nxm:\/\///')
relative_game_dir=${gamesmap[${game}_dir]}
appid=${gamesmap[${game}_appid]}
launcher_opts=${gamesmap[${game}_launcher_opts]}

if [ -z "$relative_game_dir" ]; then
	$errorbox "Could not download file because '$game' is not a supported game"
	exit 1
fi
###    PARSE POSITIONAL ARGS    ###

###    FIND GAME LIBRARY    ###
steam_libraries=$( \
	grep -oE '/[^"]+' "$HOME/.steam/steam/steamapps/libraryfolders.vdf" \
)
steam_libraries=$(echo -e "$HOME/.steam/steam\n$steam_libraries")

for libdir in $steam_libraries; do
	echo "Searching for game in library '$libdir'"
	game_dir="$libdir/steamapps/common/$relative_game_dir"
	echo "$relative_game_dir"
	mo2_dir="$game_dir/ModOrganizer2"
	if [ -d "$mo2_dir" ]; then
		echo "Found game"
		break
	fi
done

if [ ! -d "$mo2_dir" ]; then
	$errorbox "Could not find a Mod Organizer 2 installation for '$game'"
	exit 1
fi
###    FIND GAME LIBRARY    ###

cd "$game_dir"

bash -c "
	STEAM_LIBRARY=$libdir \\
	'$game_dir/proton_launcher.sh' $launcher_opts $appid '$mo2_dir/nxmhandler.exe' '$nxm_link'
"

