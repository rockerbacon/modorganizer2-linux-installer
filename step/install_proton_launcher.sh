#!/bin/bash

log_info "installing proton launcher in '$shared'"

cp "$utils/dialog.sh" "$shared/"
chmod +x "$shared/dialog.sh"

cp "$utils/list-steam-libraries.sh" "$shared/"
chmod +x "$shared/list-steam-libraries.sh"

cp "$utils/find-library-for-appid.sh" "$shared/"
chmod +x "$shared/find-library-for-appid.sh"

cp "$utils/find-proton-dir.sh" "$shared/"
chmod +x "$shared/find-proton-dir.sh"

cp "$launchers/proton-launcher.sh" "$shared/"
chmod +x "$shared/proton-launcher.sh"

log_info "generating '$install_dir/run.sh'"
echo -e \
"#!/bin/bash\n\n'$shared/proton-launcher.sh' --protonver '$game_protonver' $game_proton_options \"\$@\" $game_appid '$install_dir/modorganizer2/ModOrganizer.exe'" \
> "$install_dir/run.sh"
chmod +x "$install_dir/run.sh"

log_info "generating '$install_dir/download.sh'"
echo -e \
"#!/bin/bash\n\n'$shared/proton-launcher.sh' --protonver '$game_protonver' $game_proton_options $game_appid '$install_dir/modorganizer2/nxmhandler.exe' \"\$1\"" \
> "$install_dir/download.sh"
chmod +x "$install_dir/download.sh"

