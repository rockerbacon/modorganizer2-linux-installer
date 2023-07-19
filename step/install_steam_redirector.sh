#!/usr/bin/env bash

mkdir -p "$game_installation/modorganizer2"

installdir_windowspath="Z:$(tr '/' '\\' <<< "$install_dir")"
mo2_executable_windowspath="$installdir_windowspath\\modorganizer2\\ModOrganizer.exe"

mo2_executable_path_config="$game_installation/modorganizer2/instance_path.txt"

log_info "configuring mo2 executable path '$mo2_executable_windowspath' in '$mo2_executable_path_config'"
echo "$mo2_executable_windowspath" > "$mo2_executable_path_config"

original_game_executable="$game_installation/_$game_executable"

full_game_executable_path="$game_installation/$game_executable"
if [ ! -f "$original_game_executable" ]; then
	log_info "backing up original executable '$full_game_executable_path' in '$original_game_executable'"
	mv "$full_game_executable_path" "$original_game_executable"
fi

log_info "setting up redirector in '$full_game_executable_path'"
cp -f "$redirector/main.exe" "$full_game_executable_path"

