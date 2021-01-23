# global version and russion version are different games on steam
newvegas_possible_appids=(22380 22490)

for newvegas_appid in "${newvegas_possible_appids[@]}"; do
	newvegas_library=$("$CACHE/utils/find-library-for-appid.sh" $newvegas_appid)
	if [ -d "$newvegas_library" ]; then
		steam_library="$newvegas_library"
		break
	fi
done

if [ "$newvegas_appid" == "22380" ]; then
	game_steam_subdirectory="Fallout New Vegas"
else
	game_steam_subdirectory="Fallout New Vegas enplczru"
fi
game_appid=$newvegas_appid
game_proton_options="--protonver 5.0"
game_wine_options=""
game_protontricks="d3dcompiler_43 d3dx9"
game_winetricks="d3dcompiler_43 d3dx9"
game_scriptextender_url="http://nvse.silverlock.org/download/nvse_5_1_beta4.7z"

