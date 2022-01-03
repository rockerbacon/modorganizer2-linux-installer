#!/bin/bash

set -eu

script_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")

utils="$script_root/utils"
dialog="$utils/dialog.sh"
gamesinfo="$script_root/gamesinfo"
handlers="$script_root/handlers"
launchers="$script_root/launchers"
step="$script_root/step"

function handle_error() {
	"$dialog" \
		errorbox \
		"Operation canceled. Check the terminal for details"
}

function log_info() {
	echo "INFO: $1"
}

function log_warn() {
	echo "WARN: $1" >&2
}

function log_error() {
	echo "ERROR: $1" >&2
}

trap handle_error EXIT

source "$step/check_dependencies.sh"

nexus_game_id=$(source "$step/select_game.sh")
log_info "selected game '$nexus_game_id'"

runner=$(source "$step/select_runner.sh")
log_info "selected runner '$runner'"

install_dir=$(source "$step/select_install_dir.sh")
log_info "selected install directory '$install_dir'"

source "$step/load_gameinfo.sh"
source "$step/download_external_resources.sh"
source "$step/install_external_resources.sh"
source "$step/install_nxm_handler.sh"

case "$runner" in
	proton)
		source "$step/install_proton_launcher.sh"
		source "$step/configure_steam_wineprefix.sh"
	;;
	wine)
		source "$step/install_wine_launcher.sh"
	;;
esac

source "$step/register_installation.sh"

log_info "installation completed successfully"

