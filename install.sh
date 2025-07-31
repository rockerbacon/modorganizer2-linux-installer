#!/usr/bin/env bash

cache_enabled="${CACHE:-1}"

set -eu
set -o pipefail

script_root=$(realpath "$(dirname "${BASH_SOURCE[0]}")")
: > "$script_root/install.log"
exec > >(tee -a "$script_root/install.log") 2>&1

utils="$script_root/utils"
dialog="$utils/dialog.sh"
pluginsinfo="$script_root/pluginsinfo.json"
gamesinfo="$script_root/gamesinfo"
handlers="$script_root/handlers"
launchers="$script_root/launchers"
redirector="$script_root/steam-redirector"
step="$script_root/step"
workarounds="$script_root/workarounds"
downloads_cache=/tmp/mo2-linux-installer-downloads-cache
shared="$HOME/.local/share/modorganizer2"

custom_game_enabled=0
started_download_step=0
expect_exit=0

mkdir -p "$downloads_cache"
mkdir -p "$shared"

function handle_error() {
	if [ "$expect_exit" != "1" ]; then
		if [ "$started_download_step" == "1" ]; then
			purge_downloads_cache
		fi

		"$dialog" \
			errorbox \
			"Operation canceled. Check the terminal for details"
	fi
}

function log_info() {
	echo "INFO:" "$@" >&2
}

function log_warn() {
	echo "WARN:" "$@" >&2
}

function log_error() {
	echo "ERROR:" "$@" >&2
}

trap handle_error EXIT

if [ "$UID" == "0" ]; then
	log_error "Attempted to run as root"
	log_error "Please follow the install instructions provided at https://github.com/rockerbacon/modorganizer2-linux-installer"
	exit 1
fi

source "$step/update_check.sh"

expect_exit=1

source "$step/check_dependencies.sh"

# Parse options; implemented as a loop in case there are additional uses for it later.
while getopts c launch_options; do
	case "${launch_options}" in
		c) custom_game_enabled=1 ;;
	esac
done

selected_game=$(source "$step/select_game.sh")
log_info "selected game '$selected_game'"

source "$step/load_gameinfo.sh"
if [ "$hasScriptExtender" == true ]; then
	install_extras=$(source "$step/prompt_optional.sh")
	log_info "Installing optional components: '$install_extras'"
else
	install_extras=false
	log_info "No script extender provided for '$selected_game'."
fi

selected_plugins=$(source "$step/select_plugins.sh")
log_info "selected plugins '$selected_plugins'"
source "$step/load_plugininfo.sh"

source "$step/clean_game_prefix.sh"

install_dir=$(source "$step/select_install_dir.sh")
log_info "selected install directory '$install_dir'"

expect_exit=0

source "$step/download_external_resources.sh"
source "$step/install_external_resources.sh"
source "$step/install_nxm_handler.sh"
source "$step/configure_steam_wineprefix.sh"
source "$step/install_steam_redirector.sh"
source "$step/register_installation.sh"

source "$step/apply_workarounds.sh"

log_info "installation completed successfully"
expect_exit=1
"$dialog" infobox "Installation successful!\n\Launch the game on Steam to use Mod Organizer 2"

