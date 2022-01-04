#!/bin/bash

log_info "installing nxm link broker in '$shared'"
cp "$handlers/modorganizer2-nxm-broker.sh" "$shared"
chmod +x "$shared/modorganizer2-nxm-broker.sh"

log_info "installing nxm link handler in '$HOME/.local/share/applications/'"
cp "$handlers/modorganizer2-nxm-handler.desktop" "$HOME/.local/share/applications/"

xdg-mime default modorganizer2-nxm-handler.desktop x-scheme-handler/nxm

