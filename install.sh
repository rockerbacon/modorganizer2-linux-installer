#!/bin/bash

set -e

function treat_error() {
	"../utils/dialog.sh" \
		errorbox \
		"Unexpected error occurred, check the terminal for details"
}

trap treat_error EXIT

script_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

cd "$script_root/installer" || exit 1

source check_dependencies.sh

root_dir=$(realpath "..")
utils="$root_dir/utils"
dialog="$utils/dialog.sh"
gamesinfo="$root_dir/gamesinfo"
handlers="$root_dir/handlers"
launchers="$root_dir/launchers"

nexus_game_id=$(source select_game.sh)
echo "INFO: selected game '$nexus_game_id'"

runner=$(source select_runner.sh)
echo "INFO: selected runner '$runner'"

install_dir=$(source select_install_dir.sh)
echo "INFO: selected install directory '$install_dir'"

source load_gameinfo.sh
source download_external_resources.sh
source install_external_resources.sh
source install_nxm_handler.sh

case "$runner" in
	proton)
		source install_proton_launcher.sh
		source configure_steam_wineprefix.sh
	;;
	wine)
		source install_wine_launcher.sh
	;;
esac

source register_installation.sh

echo "INFO: installation completed successfully"

