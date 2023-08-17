#!/usr/bin/env bash

load_gameinfo="$gamesinfo/$selected_game.sh"

if [ ! -f "$load_gameinfo" ]; then
	log_error "no gameinfo for '$selected_game'"
	"$dialog" errorbox \
		"Could not find information on '$selected_game'"
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

steam_library=$("$utils/find-library-for-file.sh" "$game_steam_subdirectory/$game_executable")

if [ ! -d "$steam_library" ]; then
	log_error "could not find any Steam library containing a game with appid '$game_appid'. If you known exactly where the library is, you can specify it using the environment variable STEAM_LIBRARY"
	"$dialog" errorbox \
		"Could not find '$game_steam_subdirectory' in any of your Steam libraries\nMake sure the game is installed and that you've run it at least once"
	exit 1
fi

game_prefix=$("$utils/protontricks.sh" get-prefix "$game_appid")
game_compatdata=$(dirname "$game_prefix")
game_installation="$steam_library/steamapps/common/$game_steam_subdirectory"

