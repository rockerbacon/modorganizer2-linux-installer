#!/usr/bin/env bash

log_info "installing nxm link broker in '$shared'"
cp "$handlers/modorganizer2-nxm-broker.sh" "$shared"
chmod +x "$shared/modorganizer2-nxm-broker.sh"

app_dir="$HOME/.local/share/applications"
log_info "installing nxm link handler in '$app_dir/'"
mkdir -p "$app_dir"
cp "$handlers/modorganizer2-nxm-handler.desktop" "$app_dir/"

echo "$game_appid" > "$install_dir/appid.txt"

if [ -n "$(command -v xdg-mime)" ]; then
	xdg-mime default modorganizer2-nxm-handler.desktop x-scheme-handler/nxm
else
	log_warn "xdg-mime not found, cannot register mimetype"
fi

