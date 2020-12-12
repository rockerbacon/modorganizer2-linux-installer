#!/bin/bash

cp "$handlers/modorganizer2-nxm-broker.sh" "$HOME/.local/share/modorganizer2/"
chmod +x "$HOME/.local/share/modorganizer2/modorganizer2-nxm-broker.sh"

cp "$handlers/modorganizer2-nxm-handler.desktop" "$HOME/.local/share/applications/"

xdg-mime default modorganizer2-nxm-handler.desktop x-scheme-handler/nxm

