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

utils=$(realpath "../utils")
dialog="$utils/dialog.sh"
gamesinfo=$(realpath "../gamesinfo")

nexus_game_id=$(source select_game.sh)
echo "INFO: selected game '$nexus_game_id'"

runner=$(source select_runner.sh)
echo "INFO: selected runner '$runner'"

install_dir=$(source select_install_dir.sh)
echo "INFO: selected install directory '$install_dir'"

source load_gameinfo.sh
# source download_files.sh

case "$runner" in
	proton)
		source install_proton_launcher.sh
	;;
	wine)
		echo "ERROR: wine installation not yet implemented" >&2
		exit 1
	;;
esac

echo "ERROR: no implementation beyond this" >&2
exit 1

