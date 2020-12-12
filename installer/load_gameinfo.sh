#!/bin/bash

if [ ! -f "$gamesinfo/$nexus_game_id.sh" ]; then
		"$dialog" errorbox \
				"Could not find gameinfo for '$nexus_game_id'"
		exit 1
fi

source "$gamesinfo/$nexus_game_id.sh"

if [ -z "$game_appid" ]; then
		echo "ERROR: empty game_appid" >&2
		exit 1
elif [ -z "$game_steam_subdirectory" ]; then
		echo "ERROR: empty steam_subdirectory" >&2
		exit 1
fi

