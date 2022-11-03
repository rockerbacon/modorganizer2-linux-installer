#!/usr/bin/env bash

game_workarounds="$workarounds/$selected_game.sh"

if [ -f "$game_workarounds" ]; then
	log_info "applying workarounds in '$game_workarounds'"
	source "$game_workarounds"
fi

