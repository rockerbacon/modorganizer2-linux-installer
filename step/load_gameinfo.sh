#!/bin/bash

load_gameinfo="$gamesinfo/$nexus_game_id.sh"

if [ ! -f "$load_gameinfo" ]; then
	log_error "no gameinfo for '$nexus_game_id'"
	"$dialog" errorbox \
		"Could not find information on '$nexus_game_id'"
	exit 1
fi

source "$load_gameinfo"

if [ -z "$game_appid" ]; then
	log_error "empty game_appid"
	exit 1
elif [ -z "$game_steam_subdirectory" ]; then
	log_error "empty steam_subdirectory"
	exit 1
fi

