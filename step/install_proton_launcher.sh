#!/bin/bash

shared="$HOME/.local/share/modorganizer2"
mkdir -p "$shared"

cp "$launchers/proton-launcher.sh" "$shared/"
chmod +x "$launchers/proton-launcher.sh"

echo -e \
"#!/bin/bash\n\n'$shared/proton-launcher.sh' --protonver '$game_protonver' $game_proton_options \"\$@\" $game_appid '$install_dir/ModOrganizer2/ModOrganizer.exe'" \
> "$install_dir/run.sh"

echo -e \
"#!/bin/bash\n\n'$shared/proton-launcher.sh' --protonver '$game_protonver' $game_proton_options $game_appid '$install_dir/ModOrganizer2/nxmhandler.exe' \"\$1\"" \
> "$install_dir/download.sh"

