#!/usr/bin/env bash

screen_text=$( \
cat << EOF
Welcome to the Mod Organizer 2 installer!

This installer only allows Mod Organizer 2 to manage a single game.
Install one instance of Mod Organizer 2 for each game you want to manage.

Which game would you like to manage with this installation?
EOF
)

selected_game=$( \
	"$dialog" \
		radio \
		450 "$screen_text" \
		"enderal" "Enderal: Forgotten Stories" \
		"enderal_se" "Enderal: Forgotten Stories (Special Edition)" \
		"fallout3" "Fallout 3" \
		"fallout3_goty" "Fallout 3 - Game of the Year Edition" \
		"fallout4" "Fallout 4" \
		"newvegas" "Fallout: New Vegas" \
		"newvegas_ru" "Fallout: New Vegas RU" \
		"morrowind" "Morrowind" \
		"oblivion" "Oblivion" \
		"skyrim" "Skyrim" \
		"skyrimspecialedition" "Skyrim Special Edition" \
)

if [ -z "$selected_game" ]; then
	log_error "no game selected"
	exit 1
fi

echo "$selected_game"

