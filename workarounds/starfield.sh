#!/usr/bin/env bash

sfse_config_dir="$game_installation/Data/SFSE"

mkdir -p "$sfse_config_dir"

cat << EOT >> "$sfse_config_dir/SFSE.ini"
[Loader]
RuntimeName=_Starfield.exe
EOT
