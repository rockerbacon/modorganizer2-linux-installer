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
	--customver	specify a custom version of proton to use
			specified version must be a path within
			\$HOME/.steam/root/compatibilitytools.d

	--d9vk		use DXVK instead of wined3d on DirectX9 apps
			obsolete on Proton 5.0 or newer

	--directx9	force EXECUTABLE to use DirectX9

	-e,--env	send custom environment variable to Proton

	--int-scaling	enable integer scaling

	--keep-pulse	do not restart pulseaudio (default)

	-n,--native	specify dlls which should prefer native versions
			should be a quoted space-separated list
			eg.: -n 'xaudio2_7 d3d9'

	--noesync	run without esync

	--nofsync	run without fsync

	-p,--protonver	specify Proton version to use
			defaults to the latest installed version
			can be a Pearl regex
			if a regex, the latest matching version is used

	--proton-libdir	this argument does nothing
			it's kept solely for compatibility purposes

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
steam_dir=$(readlink -f "$HOME/.steam/root")
protonver='*'
proton_extra_envs=()
proton_libdir="$steam_dir/steam"
restart_pulse=false
customver=""
###    DEFAULTS    ###

###    PARSE NAMED ARGS    ###
parsing_args=true
while [ "$parsing_args" == "true" ]; do
	argname=$1
	case "$argname" in
		--customver)
			customver="$2"; shift 2
			;;

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

		--keep-pulse)
			restart_pulse=false; shift 1
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
			msg="unknown option '$argname'"
			echo "ERROR: $msg" >&2
			$errorbox "$msg"
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
	msg="please specify the APPID"
	echo "ERROR: $msg" >&2
	$errorbox "$msg"
	print_help >&2
	exit 1
fi

executable=$1; shift
if [ -z "$executable" ]; then
	msg="please specify the EXECUTABLE"
	echo "ERROR: $msg" >&2
	$errorbox "$msg"
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
	msg="could not find executable '$executable'"
	echo "ERROR: $msg" >&2
	$errorbox "$msg"
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

###    LIST STEAM LIBRARIES    ###
steam_dir=$(readlink -f "$HOME/.steam/root")
steam_libraries=()

steam_install_candidates=( \
	"$steam_dir" \
	"$HOME/.var/app/com.valvesoftware.Steam/.local/share/Steam" \
)
for steam_install in "${steam_install_candidates[@]}"; do
	echo "Searching for Steam in '$steam_install'"
	if [ -d "$steam_install" ]; then
		echo "Found Steam"

		restore_ifs=$IFS
		IFS=$'\n'
			main_library="$steam_install"
			if [ ! -d "$main_library/steamapps" ]; then
				main_library="$steam_install/steam"
			fi

			steam_libraries+=("$main_library")
			steam_libraries+=($( \
				grep -oE '/[^"]+' "$main_library/steamapps/libraryfolders.vdf" \
			))
		IFS=$restore_ifs
	fi
done
if [ -z "$steam_libraries" ]; then
	msg="could not find a single Steam library"
	echo "ERROR: $msg" >&2
	$errorbox "$msg"
	exit 1
fi
###    LIST STEAM LIBRARIES    ###

###    FIND GAME LIBRARY    ####
if [ -n "$STEAM_LIBRARY" ]; then
	compat_data="$STEAM_LIBRARY/steamapps/compatdata/$appid"
else
	for libdir in "${steam_libraries[@]}"; do
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
match_proton() {
	echo $(find "$1" \
			-maxdepth 1 -path "*/$2" \
		|	sort -rV \
		|	head -n 1
	)
}

if [ -n "$customver" ]; then
	echo "Searching for '$customver' in '$steam_dir/compatibilitytools.d/'"
	proton_dir=$(match_proton "$steam_dir/compatibilitytools.d/" "$customver")
else
	for libdir in "${steam_libraries[@]}"; do
		echo "Searching for 'Proton $protonver' in library '$libdir'"
		proton_dir=$(match_proton "$libdir/steamapps/common/" "Proton $protonver")
		if [ -d "$proton_dir" ]; then
			echo "Found Proton"
			break
		fi
	done
fi

if [ ! -d "$proton_dir" ]; then
	$errorbox "Could not find Proton. Check terminal output for details"
	print_help >&2
	exit 1
fi
###    FIND PROTON EXECUTABLE    ###

###    BUILD LD_LIBRARY_PATH    ###
steam_rundir="$steam_dir/ubuntu12_32/steam-runtime"

library_path=$LD_LIBRARY_PATH
if [ -d "$steam_rundir" ] && [ -z "$library_path" ]; then
	# these will be added by proton, no need to specify them manually
	# proton_libs=("$proton_dir/dist/lib64" "$proton_dir/dist/lib")

	steam_pinned_libs=("$steam_rundir/pinned_libs_32" "$steam_rundir/pinned_libs_64")

	steam_supplementary_libs=( \
		"$steam_rundir/lib/i368-linux-gnu" \
		"$steam_rundir/usr/lib/i386-linux-gnu" \
		"$steam_rundir/lib/x86_64-linux-gnu" \
		"$steam_rundir/usr/lib/x86_64-linux-gnu" \
		"$steam_rundir/lib" \
		"$steam_rundir/usr/lib" \
	)

	system_libs=($( \
		ldconfig -N -v 2>/dev/null | grep -oE '^/[^:]+' \
	))

	if [ "$prefer_system_libs" == "true" ]; then
		libs=( \
			"${system_libs[@]}" \
			"${steam_pinned_libs[@]}" \
			"${steam_supplementary_libs[@]}" \
		)
	else
		libs=( \
			"${steam_pinned_libs[@]}" \
			"${system_libs[@]}" \
			"${steam_supplementary_libs[@]}" \
		)
	fi

	library_path=$(IFS=: ; echo "${libs[*]}")
else
	echo "WARN: could not find Steam runtime, you might experience problems" >&2
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
run_proton="
	PATH='$steam_rundir/amd64/usr/bin:$steam_rundir/usr/bin:$PATH' \\
	LD_LIBRARY_PATH='$library_path' \\
	STEAM_COMPAT_DATA_PATH='$compat_data' \\
	STEAM_COMPAT_CLIENT_INSTALL_PATH='$steam_dir' \\
	SteamGameId=$appid \\
	SteamAppId=$appid \\
	${proton_extra_envs[*]} \\
	\\
	'$proton_dir/proton' runinprefix '$executable' $([ -n "$1" ] && printf " '%s'" "$@")
"

echo -e "\n$run_proton\n"

bash -c "$run_proton"
###    RUN EXECUTABLE    ###

