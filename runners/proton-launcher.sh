#!/bin/bash

script=$0

print_help() {
cat << EOF

Usage: $script [OPTIONS...] APPID EXECUTABLE [EXECUTABLE_ARGS...]

Launch arbitrary executables inside a Steam game's Proton prefix

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

	--system-libs	prefer system libraries over
			libraries supplied by Steam

	-w,--workdir	specify working directory for the entire script
			the script switches to this directory
			right after parsing all arguments

	--wined3d	use wined3d instead of DXVK

	-h,--help	print this help message and exit

EOF
}

xtermbox() {
	action_on_exit=$1
	msg=$2
	xterm -e bash -c "
		echo '$msg'
		echo
		echo Press enter to $action_on_exit
		read
	"
}

if [ -n "$(command -v zenity)" ]; then
	infobox="zenity --ok-label=Continue --ellipsize --info --text"
	errorbox="zenity --ok-label=Exit --ellipsize --error --text"
elif [ -n "$(command -v xmessage)" ]; then
	infobox="xmessage -buttons continue:0"
	errorbox="xmessage -buttons exit:0"
elif [ -n "$(command -v xterm)" ]; then
	infobox="xtermbox continue"
	errorbox="xtermbox exit"
else
	infobox="echo"
	errorbox="echo"
fi

###    DEFAULTS    ###
protonver='*'
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

		--system-libs)
			prefer_system_libs=true; shift 1
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
			echo "ERROR: unknown option '$argname'" >&2
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
if [ -z "$appid" ]; then
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

###    ASSERT PATHS    ###
if [ -n "$workdir" ]; then
	cd "$workdir"
	echo "Changed working directory to '$workdir'"
fi

if [ ! -f "$executable" ]; then
	echo "ERROR: could not find executable '$executable'" >&2
	print_help >&2
	exit 1
fi
###    ASSERT PATHS    ###

###    ASSERT STEAM RUNNING    ###
if [ -z "$(pidof steam)" ]; then
	$infobox "Steam must be running before continuing. Please start Steam"

	if [ -z "$(pidof steam)" ]; then
		$errorbox "Steam was not started, aborting"
		echo "ERROR: Steam not running" >&2
		exit 1
	fi
fi
###    ASSERT STEAM RUNNING    ###

###    FIND GAME LIBRARY    ####
if [ -n "$STEAM_LIBRARY" ]; then
	compat_data="$STEAM_LIBRARY/steamapps/compatdata/$appid"
else
	steam_libraries=$( \
		grep -oE '/[^"]+' "$HOME/.steam/steam/steamapps/libraryfolders.vdf" \
	)
	steam_libraries=$(echo -e "$HOME/.steam/steam\n$steam_libraries")

	for libdir in $steam_libraries; do
		echo "Searching for game in library '$libdir'"
		compat_data="$libdir/steamapps/compatdata/$appid"
		if [ -d "$compat_data" ]; then
			echo "Found game"
			break
		fi
	done
fi

if [ ! -d "$compat_data" ]; then
	$errorbox "Could not find a game with APPID '$appid'"
	print_help >&2
	exit 1
fi
###    FIND GAME LIBRARY    ####

###    FIND PROTON EXECUTABLE    ###
proton_dir=$(find "$proton_libdir/steamapps/common/" \
		-maxdepth 1 -path "*/Proton $protonver" \
	|	sort -rV \
	|	head -n 1
)
if [ ! -d "$proton_dir" ]; then
	$errorbox "Could not find proton version matching '$protonver' in directory '$proton_libdir/steamapps/common/'"
	print_help >&2
	exit 1
fi
###    FIND PROTON EXECUTABLE    ###

###    BUILD LD_LIBRARY_PATH    ###
steam_dir=$(dirname "$proton_libdir")
steam_rundir=$(readlink "$steam_dir/bin32")/steam-runtime

steam_pinned_libs="$steam_rundir/pinned_libs_32:$steam_rundir/pinned_libs_64"

system_libs=$( \
			ldconfig -N -v 2>/dev/null \
		|	grep -oE '^/[^:]+' \
		| tr '\n' ':' \
		| sed 's/:$//' \
)

steam_32libs="$steam_rundir/i386/lib/i368-linux-gnu:$steam_rundir/i386/lib:$steam_rundir/i386/usr/lib/i386-linux-gnu:$steam_rundir/i386/usr/lib"
steam_64libs="$steam_rundir/amd64/lib/x86_64-linux-gnu:$steam_rundir/amd64/lib:$steam_rundir/amd64/usr/lib/x86_64-linux-gnu:$steam_rundir/amd64/usr/lib"

if [ "$prefer_system_libs" == "true" ]; then
	library_path="$system_libs:$steam_pinned_libs:$steam_32libs:$steam_64libs"
else
	library_path="$steam_pinned_libs:$system_libs:$steam_32libs:$steam_64libs"
fi
###    BUILD LD_LIBRARY_PATH    ###

###    RESET PULSEAUDIO    ###
if [ "$restart_pulse" == "true" ]; then
			pulseaudio --kill \
	&&	echo "Killed pulseaudio" \
	&&	pulseaudio --start \
	&&	echo "Started pulseaudio"
fi
###    RESET PULSEAUDIO    ###

###    RUN EXECUTABLE    ###
echo; set -x

PATH="$steam_rundir/amd64/usr/bin:$steam_rundir/usr/bin:$PATH" \
LD_LIBRARY_PATH="$library_path" \
STEAM_COMPAT_DATA_PATH="$compat_data" \
SteamGameId=$appid \
SteamAppId=$appid \
${proton_extra_envs[*]} \
\
"$proton_dir/proton" run "$executable" $@

set +x; echo
###    RUN EXECUTABLE    ###

