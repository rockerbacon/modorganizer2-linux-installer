#!/bin/bash

shared="$HOME/.local/share/modorganizer2"
mkdir -p "$shared"

mo2_tricks="vcrun2019"
mo2_options=""

cp "$launchers/proton-launcher.sh" "$shared/"
chmod +x "$launchers/proton-launcher.sh"

echo -e \
"#!/bin/bash\n\n'$shared/proton-launcher.sh' $mo2_options $game_proton_options \"\$@\" $game_appid '$install_dir/ModOrganizer2/ModOrganizer.exe'" \
> "$install_dir/run.sh"

echo -e \
"#!/bin/bash\n\n'$shared/proton-launcher.sh' $mo2_options $game_proton_options $game_appid '$install_dir/ModOrganizer2/nxmhandler.exe' \"\$1\"" \
> "$install_dir/download.sh"

