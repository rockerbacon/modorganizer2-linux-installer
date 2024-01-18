#!/bin/bash

organizer="$game_prefix/users/steamuser/AppData/Local/ModOrganizer/"
overwrite="$organizer/overwrite/SKSE"

mkdir -p "$overwrite"

cat << EOT >> "$overwrite/SKSE.ini"
[Loader]
RuntimeName=_SkyrimVR.exe
EOT