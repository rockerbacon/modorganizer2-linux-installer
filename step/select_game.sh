#!/usr/bin/env bash

screen_text=$( \
cat << EOF
Welcome to the Mod Organizer 2 installer!

This installer only allows Mod Organizer 2 to manage a single game.
Install one instance of Mod Organizer 2 for each game you want to manage.

Which game would you like to manage with this installation?
EOF
)

game_list=()
for game in $(ls -1 $gamesinfo); do
	source "$gamesinfo/$game"
	[[ -n "${game_full_name:-}" ]] && game_name="$game_full_name" \
		|| game_name="$game_steam_subdirectory"
	game_list+=("$(basename "$game" '.sh')" "$game_name")
	unset game_full_name game_steam_subdirectory game_protontricks \
		game_nexusid game_appid game_executable \
		game_scriptextender_url game_scriptextender_files
done


selected_game=$( \
	"$dialog" \
		radio \
		450 "$screen_text" \
		"${game_list[@]}"
)

if [ -z "$selected_game" ]; then
	log_error "no game selected"
	exit 1
fi

echo "$selected_game"

