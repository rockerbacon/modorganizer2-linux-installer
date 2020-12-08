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

shared="$HOME/.local/share/modorganizer2"
mkdir -p "$shared"

mo2_tricks="vcrun2019"
mo2_options=""

if [ -z "$steam_library" ]; then
		steam_library=$("$utils/find-library-for-appid.sh" $game_appid)
fi

if [ ! -d "$steam_library" ]; then
		"$dialog" errorbox \
				"Could not find '$game_steam_subdirectory' in your Steam library"
		exit 1
fi

game_prefix="$steam_library/steamapps/compatdata/$game_appid/pfx"
game_installation="$steam_library/steamapps/common/$game_steam_subdirectory"
game_tricks="$game_protontricks"

echo -e \
"#!/bin/bash\n\n'$shared/proton-launcher.sh' $mo2_options $game_proton_options \"\$@\" $game_appid '$install_dir/ModOrganizer2/ModOrganizer.exe'" \
> "$install_dir/run.sh"

echo -e \
"#!/bin/bash\n\n'$shared/proton-launcher.sh' $mo2_options $game_proton_options $game_appid '$install_dir/ModOrganizer2/nxmhandler.exe' \"\$1\"" \
> "$install_dir/download.sh"
