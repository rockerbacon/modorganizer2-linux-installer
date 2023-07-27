#!/usr/bin/env bash

confirm_cleaning_text=$( \
cat << EOF
It is highly recommended to clean your current game prefix
before starting the installation process.

Would you like to delete your current game prefix and
create a new one?
EOF
)

create_clean_prefix_text=$( \
cat << EOF
Your existing prefix was deleted. Now you need to create a clean one:

1. On Steam: right click the game > Properties > Compatibility
2. Check the option "Force the use of a specific Steam Play compatibility tool"
3. Select the Proton version you would like to use
	* Proton 8.0 is the currently supported and recommended version
4. Launch the game and wait for Steam to finish its setup
5. Close the game. It must remain stopped through the entire install process
EOF
)

function delete_existing_prefix() {
	if [ -d "$game_compatdata" ]; then
		log_info "deleting '$game_compatdata'"
		rm -rf "$game_compatdata"
	else
		log_info "not deleting prefix, '$game_compatdata' is not a directory"
	fi
}

function clean_game_prefix() {
	delete_existing_prefix

	confirmation=$( \
		"$dialog" \
			radio \
			425 "$create_clean_prefix_text" \
			"1" "Cancel the installation" \
			"0" "All done. Let's continue" \
	)

	echo "$confirmation"
}

confirm_cleaning=$("$dialog" question "$confirm_cleaning_text")
if [ "$confirm_cleaning" == "0" ]; then
	cleaning_status=$(clean_game_prefix)
	if [ "$cleaning_status" != "0" ]; then
		log_error "installation cancelled by the user"
		exit 1
	fi

	log_info "user confirmed prefix setup"
else
	log_info "proceeding with existing prefix"
fi

if [ ! -d "$game_prefix" ]; then
	"$dialog" \
		errorbox \
		"A prefix for the selected game could not be found.\nMake sure you have followed the instructions\non cleaning your prefix"
	exit 1
fi

