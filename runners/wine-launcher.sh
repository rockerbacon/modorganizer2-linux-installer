#!/bin/bash

script=$0

print_help() {
cat << EOF

Usage: $script [OPTIONS...] EXECUTABLE [EXECUTABLE_ARGS...]

Launch arbitrary executables inside a Steam game's Proton prefix
Remember to specify the wine prefix with the environment variable WINEPREFIX

APPID:			APPID for the Steam game
			visit https://steamdb.info to a game's APPID

EXECUTABLE:		path to the .exe file to execute

EXECUTABLE_ARGS:	arguments to pass to EXECUTABLE

OPTIONS:
	-e,--env	send custom environment variable to Proton

	--int-scaling	enable integer scaling

	--keep-pulse	do not restart pulseaudio (default)

	-n,--native	specify dlls which should prefer native versions
			should be a quoted space-separated list
			eg.: -n 'xaudio2_7 d3d9'

	--proton-wine	use a Wine version supplied by Proton
			causes '--winever' to match against Proton versions

	--restart-pulse	restart pulseaudio right before running EXECUTABLE

	--system-libs	prefer system libraries over
			libraries supplied by Steam

	--system-wine	use Wine installed on the system
			instead of versions supplied by Lutris

	-w,--workdir	specify working directory for the entire script
			the script switches to this directory
			right after parsing all arguments

	--winever	specify Wine version to use
			defaults to the latest lutris version available
			can be a Pearl regex
			if a regex, the latest matching version is used
			search is made in the directory
			\$HOME/.local/share/lutris/runners/wine

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
winever='*'
wine_extra_envs=()
wine_libdir="$steam_dir/steam"
restart_pulse=false
bin_supplier="lutris"
###    DEFAULTS    ###

###    PARSE NAMED ARGS    ###
parsing_args=true
while [ "$parsing_args" == "true" ]; do
	argname=$1
	case "$argname" in
		-e|--env)
			wine_extra_envs+=("$2"); shift 2
			;;

		--int-scaling)
			wine_extra_evs+=("WINE_FULLSCREEN_INTEGER_SCALING=1"); shift 1
			;;

		--keep-pulse)
			restart_pulse=false; shift 1
			;;

		-n|--native)
			dlls=$2; shift 2

			for dll in $dlls; do
				dll_overrides="$dll=n,b;$dll_overrides"
			done

			wine_extra_envs+=("WINEDLLOVERRIDES='$dll_overrides'")
			;;

		--proton-wine)
			bin_supplier="proton"; shift 1
			;;

		--restart-pulse)
			restart_pulse=true; shift 1
			;;

		--system-libs)
			bin_supplier="system"; shift 1
			;;

		--system-wine)
			force_system_wine=true; shift 1
			;;

		-w|--workdir)
			workdir=$2; shift 2
			;;

		--winever)
			winever=$2; shift 2
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

###    FIND WINE EXECUTABLE    ###
case "$bin_supplier" in
	lutris)
		if [ "$winever" == "*" ]; then
			version_match="/lutris-$winever"
		else
			version_match="$winever"
		fi

		wine_dir=$(find "$HOME/.local/share/lutris/runners/wine/" \
				-maxdepth 1 -path "*$version_match*" \
			|	sort -rV \
			|	head -n 1 \
		)
		if [ ! -d "$wine_dir" ]; then
			$errorbox "Could not find wine version matching '$winever' in directory '$HOME/.local/share/lutris/runners/wine/'"
			print_help >&2
			exit 1
		fi
		;;

	proton)
		steam_install_candidates=( \
			"$steam_dir" \
			"$HOME/.local/share/flatpak/app/com.valvesoftware.Steam" \
		)
		for steam_install in "${steam_install_candidates[@]}"; do
			echo "Searching for Steam in '$steam_install'"
			if [ -d "$steam_install" ]; then
				echo "Found Steam"
				break
			fi
		done
		if [ ! -d "$steam_install" ]; then
			msg="could not find Steam"
			echo "ERROR: $msg" >&2
			$errorbox "$msg"
			exit 1
		fi

		restore_ifs=$IFS
		IFS=$'\n'
			steam_libraries=("$steam_install/steam")
			steam_libraries+=($( \
				grep -oE '/[^"]+' "$steam_install/steam/steamapps/libraryfolders.vdf" \
			))
		IFS=$restore_ifs

		candidate_paths=()
		for libdir in "${steam_libraries[@]}"; do
			candidate_paths+=("$libdir/steamapps/common/")
		done
		candidate_paths+=( \
			"$steam_dir/compatibilitytools.d/" \
		)

		for search_path in "${candidate_paths[@]}"; do
			proton_dir=$(find "$search_path" \
					-maxdepth 1 -path "*Proton*$winever*" \
				|	sort -rV \
				|	head -n 1 \
			)

			if [ -d "$proton_dir" ]; then
				break
			fi
		done

		if [ ! -d "$proton_dir" ]; then
			$errorbox "Could not find Proton version matching '$winever'"
			print_help >&2
			exit 1
		fi

		wine_dir="$proton_dir/dist"
		;;

	system)
		wine_dir=$(realpath $(dirname $(readlink "/usr/bin/wine"))/..)
		if [ ! -d "$wine_dir" ]; then
			$errorbox "Could not locate Wine in your system"
			print_help >&2
			exit 1
		fi
		;;
esac
###    FIND WINE EXECUTABLE    ###

###    BUILD LD_LIBRARY_PATH    ###
library_path=$LD_LIBRARY_PATH
if [ -d "$steam_dir" ] && [ -z "$library_path" ]; then
	steam_rundir="$steam_dir/ubuntu12_32/steam-runtime"

	if [ "$bin_supplier" == "proton" ]; then
		proton_libs=("$proton_dir/dist/lib64" "$proton_dir/dist/lib")
	else
		proton_libs=()
	fi

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
			"${proton_libs[@]}" \
			"${steam_pinned_libs[@]}" \
			"${steam_supplementary_libs[@]}" \
		)
	else
		libs=( \
			"${proton_libs[@]}" \
			"${steam_pinned_libs[@]}" \
			"${system_libs[@]}" \
			"${steam_supplementary_libs[@]}" \
		)
	fi

	library_path=$(IFS=: ; echo "${libs[*]}")
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
run_wine="
	LD_LIBRARY_PATH='$library_path' \\
	${wine_extra_envs[*]} \\
	WINEPREFIX='$WINEPREFIX'
	\\
	'$wine_dir/bin/wine' '$executable' $([ -n "$1" ] && printf " '%s'" "$@")
"

echo -e "\n$run_wine\n"

bash -c "$run_wine"
###    RUN EXECUTABLE    ###

