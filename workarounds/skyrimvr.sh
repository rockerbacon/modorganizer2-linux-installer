#!/usr/bin/env bash

skse_config_dir="$game_installation/Data/SKSE"

mkdir -p "$skse_config_dir"

cat << EOT >> "$skse_config_dir/SKSE.ini"
[Loader]
RuntimeName=_SkyrimVR.exe
EOT