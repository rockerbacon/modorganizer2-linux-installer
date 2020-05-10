# could be either Fallout 3 or Fallout 3 Game of The Year Edition
fo3_possible_appids=(22300 22370)

for fo3_appid in "${fo3_possible_appids[@]}"; do
	fo3_library=$("$CACHE/utils/find-library-for-appid.sh" $fo3_appid)
	if [ -d "$fo3_library" ]; then
		break
	fi
done

if [ "$fo3_appid" == "22300" ]; then
	game_steam_subdirectory="Fallout 3"
else
	game_steam_subdirectory="Fallout 3 goty"
fi
game_appid=$fo3_appid
game_launcher_options="--restart-pulse --protonver 5.*"
game_protontricks="d3dcompiler_43 d3dx9"

