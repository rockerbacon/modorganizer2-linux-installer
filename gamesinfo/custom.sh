screen_text=$( \
cat << EOF
Specify the game details:
(Note: Fields marked with an asterisk are required.)
EOF
)

IFS=',' read -ra submitted_data <<< "$( \
	"$dialog" \
		form \
		"$screen_text" \
		"Executable*" \
		"App ID*" \
		"Steam Subdirectory*" \
		"Nexus ID" \
		"Protontricks Args" \
		"Script Extender URL" \
		"Script Extender Files" \
)"

if [ -z "${submitted_data[0]}" ]; then
	log_error "no game executable specified"
	exit 1
fi
game_executable="${submitted_data[0]}"

if [ -z "${submitted_data[1]}" ]; then
	log_error "no app id specified"
	exit 1
fi
game_appid="${submitted_data[1]}"

game_steam_subdirectory=$(
	[ -z "${submitted_data[2]+x}" ] && echo '' || echo "${submitted_data[2]}"
)

game_nexusid=$(
	[ -z "${submitted_data[3]+x}" ] && echo '' || echo "${submitted_data[3]}"
)


if [ -z "${submitted_data[4]+x}" ]; then
	game_protontricks=''
else
	IFS=' ' read -ra game_protontricks <<< "${submitted_data[4]}"
fi

game_scriptextender_url=$(
	[ -z "${submitted_data[5]+x}" ] && echo '' || echo "${submitted_data[5]}"
)

if [ -z "${submitted_data[6]+x}" ]; then
	game_scriptextender_files=''
else
	IFS=' ' read -ra game_scriptextender_files <<< "${submitted_data[6]}"
fi
