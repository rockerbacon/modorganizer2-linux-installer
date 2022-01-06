#!/bin/bash

mkdir -p "$game_installation/modorganizer2"

installdir_windowspath="Z:$(tr '/' '\\' <<< "$install_dir")"

echo "$installdir_windowspath\\modorganizer2\\ModOrganizer.exe" > "$game_installation/modorganizer2/instance_path.txt"

original_game_executable="$game_installation/_$game_executable"

if [ ! -f "$original_game_executable" ]; then
	mv "$game_installation/$game_executable" "$original_game_executable"
fi

cp -f "$redirector/main.exe" "$game_installation/$game_executable"

