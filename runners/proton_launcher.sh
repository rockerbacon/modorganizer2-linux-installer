#!/bin/bash

SKYRIM_PROTON_BINARY="$HOME/.steam/steam/steamapps/common/Proton 4.11/proton"
SKYRIM_INSTALL_FOLDER="$HOME/.steam/steam/steamapps/common/Skyrim Special Edition"

script=$0

print_help() {
cat << EOF

Launch arbitrary executables inside a Steam game's Proton prefix

Usage: $script [OPTIONS...] APPID EXECUTABLE [EXECUTABLE_ARGS...]

APPID:			APPID for the Steam game
			visit https://steamdb.info to a game's APPID

EXECUTABLE:		path to the .exe file to execute

EXECUTABLE_ARGS:	arguments to pass to EXECUTABLE

OPTIONS:
	--d9vk		use DXVK instead of wined3d on DirectX9 apps
			obsolete on Proton 5.0 or newer

	--directx9	force EXECUTABLE to use DirectX9

	-e,--env	send custom environment variable to Proton

	--int-scaling	enable integer scaling

	-l,--libdir	specify Steam library where to look for the game
			default is \$HOME/.steam/steam

	-n,--native	specify dlls which should prefer native versions
			should be a quoted space-separated list
			eg.: -n 'xaudio2_7 d3d9'

	--noesync	run without esync

	--nofsync	run without fsync

	-p,--protonver	specify Proton version to use
			defaults to the latest installed version
			can be a Pearl regex
			if a regex, the latest matching version is used

	--proton-libdir	specify Steam library where to look for Proton
			default is \$HOME/.steam/steam

	--restart-pulse	restart pulseaudio right before running EXECUTABLE

	-w,--workdir	specify working directory for the entire script
			the script switches to this directory
			right after parsing all arguments

	--wined3d	use wined3d instead of DXVK

	-h,--help	print this help message and exit

EOF
}

###    DEFAULTS    ###
libdir="$HOME/.steam/steam"
protonver='.*'
proton_extra_envs=()
proton_libdir="$HOME/.steam/steam"
restart_pulse=false
###    DEFAULTS    ###

###    PARSE NAMED ARGS    ###
parsing_args=true
while [ "$parsing_args" == "true" ]; do
	argname=$1
	case "$argname" in
		--d9vk)
			proton_extra_envs+=("PROTON_USE_D9VK=1"); shift 1
			;;

		--directx9)
			proton_extra_envs+=("PROTON_NO_D3D10=1" "PROTON_NO_D3D11=1")
			shift 1
			;;

		-e|--env)
			proton_extra_envs+=("$2"); shift 2
			;;

		--int-scaling)
			proton_extra_evs+=("WINE_FULLSCREEN_INTEGER_SCALING=1"); shift 1
			;;

		-l|--libdir)
			libdir=$2; shift 2
			;;

		-n|--native)
			dlls=$2; shift 2

			for dll in $dlls; do
				dll_overrides="$dll=n,b;$dll_overrides"
			done

			proton_extra_envs+=("WINEDLLOVERRIDES='$dll_overrides'")
			;;

		--noesync)
			proton_extra_envs+=("PROTON_NO_ESYNC=1"); shift 1
			;;

		--nofsync)
			proton_extra_envs+=("PROTON_NO_FSYNC=1"); shift 1
			;;

		-p|--protonver)
			protonver=$2; shift 2
			;;

		--proton-libdir)
			proton_libdir=$2; shift 2
			;;

		--restart-pulse)
			restart_pulse=true; shift 1
			;;

		-w|--workdir)
			workdir=$2; shift 2
			;;

		--wined3d)
			proton_extra_envs+=("PROTON_USE_WINED3D=1"); shift 1
			;;

		-h|--help)
			print_help
			exit 0
			;;

		--)
			parsing_args=false; shift 1
			;;

		-*)
			echo "ERROR: unknown option '$option'" >&2
			print_help >&2
			exit 1
			;;

		*)
			parsing_args=false
			;;
	esac
done
###    PARSE NAMED ARGS    ###

###    PARSE POSITIONAL ARGS    ###
appid=$1; shift
if [ -z $appid ]; then
	echo "ERROR: please specify the APPID" >&2
	print_help >&2
	exit 1
fi

executable=$1; shift
if [ -z "$executable" ]; then
	echo "ERROR: please specify the EXECUTABLE" >&2
	print_help >&2
	exit 1
fi
###    PARSE POSITIONAL ARGS    ###

if [ -n "$workdir" ]; then
	cd "$workdir"
	echo "Changed working directory to '$workdir'"
fi

compat_data="$libdir/steamapps/compatdata/$appid"
if [ ! -d "$compat_data" ]; then
	echo "ERROR: could not find compatdata for game with APPID '$appid' in directory '$compat_data'" >&2
	print_help >&2
	exit 1
fi

proton_dir=$(find "$proton_libdir/steamapps/common/" \
		-maxdepth 1 -path "*/Proton $protonver" \
	|	sort -rV \
	|	head -n 1
)
if [ ! -d "$proton_dir" ]; then
	echo "ERROR: could not find proton version matching '$protonver' in directory '$proton_libdir/steamapps/common/'" >&2
	print_help >&2
	exit 1
fi

steam_dir=$(dirname "$proton_libdir")
steam32_dir=$(readlink "$steam_dir/bin32")/steam-runtime

if [ "$restart_pulse" == "true" ]; then
			pulseaudio --kill \
	&&	echo "Killed pulseaudio" \
	&&	pulseaudio --start \
	&&	echo "Started pulseaudio"
fi

echo "Executing 'STEAM_COMPAT_DATA_PATH=\"$compat_data\" ${proton_extra_envs[@]} \"$proton_dir/proton\" run \"$executable\" $@'"

PATH="$steam32_dir/amd64/usr/bin:$steam32_dir/usr/bin:$PATH" \
LD_LIBRARY_PATH="$proton_dir/dist/lib64:$proton_dir/dist/lib:$steam32_dir/pinned_libs_32:$steam32_dir/pinned_libs_64" \
STEAM_COMPAT_DATA_PATH="$compat_data" \
SteamGameId=$appid \
${proton_extra_envs[@]}\
\
"$proton_dir/proton" run "$executable" $@

