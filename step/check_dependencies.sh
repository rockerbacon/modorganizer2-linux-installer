#!/usr/bin/env bash

missing_deps=()

if [ -z "$(command -v 7z)" ]; then
	missing_deps+=(7z)
fi

if [ -z "$(command -v curl)" ] && [ -z "$(command -v wget)" ]; then
	missing_deps+=("curl or wget")
fi

if [ ! $("$utils/protontricks.sh" get-release) ]; then
	missing_deps+=(protontricks)
fi

if [ -z "$(command -v zenity)" ]; then
	missing_deps+=(zenity)
fi

if [ -n "${missing_deps[*]}" ]; then
	log_error "missing dependencies ${missing_deps[@]}"
	"$dialog" errorbox \
		"Your system is missing the following programs:\n$(printf '* %s\n' "${missing_deps[@]}")\n\nThey should be available in your distro's package manager.\nInstall them and try again."
	exit 1
fi

if [ ! -f "$redirector/main.exe" ]; then
	log_error "redirector binaries not found"
	exit 1
fi

os_id=$("$utils/get_os_id.sh")

if [ "$os_id" == "steamos" ] && [ "$("$utils/protontricks.sh" get-release)" != "flatpak" ]; then
	log_error "Using non-flatpak Protontricks on SteamOS"
	"$dialog" errorbox \
		"Only Flatpak releases of Protontricks are supported on SteamOS.\nPlease install Protontricks through the Discover app and try again."
	exit 1
fi

log_info "all dependencies met"

