# could be either Fallout 3 or Fallout 3 Game of The Year Edition
fo3_possible_appids=(22300 22370)

for fo3_appid in "${fo3_possible_appids[@]}"; do
	fo3_library=$("$CACHE/utils/find-library-for-appid.sh" $fo3_appid)
	if [ -d "$fo3_library" ]; then
		steam_library="$fo3_library"
		break
	fi
done

if [ "$fo3_appid" == "22300" ]; then
	game_steam_subdirectory="Fallout 3"
else
	game_steam_subdirectory="Fallout 3 goty"
fi
game_appid=$fo3_appid
game_proton_options="--protonver 5.0"
game_wine_options=""
game_protontricks="d3dcompiler_43 d3dx9"
game_winetricks="d3dcompiler_43 d3dx9"
game_scriptextender_url="https://www.fose.silverlock.org/download/fose_v1_2_beta2.7z"
game_scriptextender_files="*"

