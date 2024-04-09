#!/usr/bin/env bash

# Install SMAPI
if [ -d "$extracted_scriptextender" ]; then
		log_info "installing SMAPI in '$game_installation'"

        # This command is ugly, but necessary 
        # Needs to run through wineconsole in order to work with .NET's System.Console

        "$utils/protontricks.sh" run-command "$game_appid" "wineconsole '${extracted_scriptextender}/SMAPI ${game_smapi_version} installer/internal/windows/SMAPI.Installer.exe' --install --no-prompt --game-path 'Z:\mnt\lingames\SteamLibrary\steamapps\common\Stardew Valley'" \
		    | "$dialog" loading "Installing SMAPI\nThis may take a while"

	if [ "$?" != "0" ]; then
		"$dialog" errorbox \
			"Error while installing SMAPI, check the terminal for more details"
		exit 1
	fi

fi