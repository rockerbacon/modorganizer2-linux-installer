#!/usr/env/bin bash

log_info "installing nxm link broker in '$shared'"
cp "$handlers/modorganizer2-nxm-broker.sh" "$shared"
chmod +x "$shared/modorganizer2-nxm-broker.sh"

log_info "installing nxm link handler in '$HOME/.local/share/applications/'"
cp "$handlers/modorganizer2-nxm-handler.desktop" "$HOME/.local/share/applications/"

echo "$game_appid" > "$install_dir/appid.txt"

xdg-mime default modorganizer2-nxm-handler.desktop x-scheme-handler/nxm

