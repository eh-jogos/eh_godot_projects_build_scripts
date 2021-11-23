#!/bin/bash

# CONSTANTS AND VARIABLES DEFINITIONS -------------------------------------------------------------------------------------

project_settings="../project.godot"
include_debug=$1
export_output=$2

# Imports
ORIGINAL_DIRECTORY=$(pwd)
cd "$(dirname "$0")" || exit
# shellcheck disable=SC1091
source _config.sh

# END CONSTANTS AND VARIABLES DEFINITIONS ---------------------------------------------------------------------------------


# FUNCTION DEFINITIONS ----------------------------------------------------------------------------------------------------

# END OF FUNCTION DEFINITIONS ---------------------------------------------------------------------------------------------


# SCRIPT EXECUTION --------------------------------------------------------------------------------------------------------

if [[ -z $include_debug || $include_debug = "false" ]]
then
	include_debug=false
elif [[ $include_debug = "true" ]]
then
	include_debug=true
else
	echo -e "$YELLOW""Unrecognized option for include_debug: $include_debug | changing to false$RESET"
	include_debug=false
fi


echo -e "\nExporting $CYAN$GAME_VERSION$RESET with debug turned: $CYAN$include_debug$RESET"

export_profiles=($(get_export_property "^name"))
export_architectures=($(get_export_property "^binary_format/64_bits"))
export_tags=( $(get_export_property "^custom_features") )
echo -e "Found the following profiles: $GREEN${export_profiles[@]}$RESET\n"
yes_to_all=false

confirmed_profiles=""
confirmed_architectures=""
confirmed_tags=""

# This is a hack so that I can skip OSX which does not have a 32/64 option in the export presets config file
architecture_offset=0
length=${#export_profiles[@]}
for ((i = 0; i < $length; i++));
do
	
	profile=${export_profiles[i]}
	custom_features=${export_tags[i]}
	
	if [[ $profile = *"OSX"* || $profile = *"HTML"* ]]
	then
		((architecture_offset--))
		is_64="null"
	else
		is_64=${export_architectures[i+$architecture_offset]}
	fi
	
	asking_input="false"
	if [[ -n $export_output ]]
	then
		if [[ "$custom_features" = *"$export_output"* ]]
		then
			confirmed_profiles+="$profile "
			confirmed_architectures+="$is_64 "
			confirmed_tags+="$custom_features "
			echo -e "$GREEN""Adding $profile to build list.$RESET"
		fi
	else
		asking_input="true"
	fi
	
	while $asking_input
	do
		answer="invalid"
		if [ $yes_to_all = "true" ]
		then
			answer="yes"
			echo -e "Building $GREEN$profile$RESET"
		else
			prompt="$CYAN\nBuild profile $profile?$RESET "
			prompt+="(""$GREEN$UNDERLINE""y""$RESET""es/"
			prompt+="yes to ""$GREEN$UNDERLINE""all$RESET/"
			prompt+="$YELLOW$UNDERLINE""s""$RESET""kip/"
			prompt+="$RED$UNDERLINE""a""$RESET""bort) "
			echo -e "$prompt"
			read answer
		fi
		
		case $answer in
			"all" | "All" | "ALL" )
				yes_to_all="true"
				;&
			"yes" | "y" | "Y" | "Yes" | "YES" )
				confirmed_profiles+="$profile "
				confirmed_architectures+="$is_64 "
				confirmed_tags+="$custom_features "
				echo -e "$GREEN""Adding $profile to build list.$RESET"
				asking_input=false
				;;
			"skip" | "s" | "S" | "Skip" | "SKIP" )
				echo -e "$YELLOW""Skipping $profile""$RESET"
				asking_input=false
				;;
			"abort" | "a" | "A" | "Abort" | "ABORT" )
				echo -e "$RED""Aborting script""$RESET"
				asking_input=false
				exit 1
				;;
			*)
				echo -e "$RED""ERROR $RESET| Invalid Input $answer"
				prompt="Valid Inputs are "
				prompt+="(""$GREEN$UNDERLINE""y""$RESET""es/"
				prompt+="yes to ""$GREEN$UNDERLINE""all"$RESET"/"
				prompt+="$YELLOW$UNDERLINE""s""$RESET""kip/"
				prompt+="$RED$UNDERLINE""a""$RESET""bort) "
				echo -e "$prompt"
				;;
		esac
	done
done

profiles=( $confirmed_profiles )
architectures=( $confirmed_architectures )
features=( $confirmed_tags )
length=${#profiles[@]}
for ((i = 0; i < $length; i++));
do	
	profile=${profiles[i]}
	is_64=${architectures[i]}
	custom_features=${features[i]}
	filename=$(get_executable_name "$profile" "$is_64")
	# This is to accept other modifiers in case you want
	# to have separate scripts for building steam releases or export in other
	# configurations then each export profile having its own folder.
	# (See the "project/cosmic_abyss" branch for an example)
	# Just add these other options as cases below:
	case $custom_features in
		*"steam"*)
			./build_steam_releases.sh "$GAME_VERSION" "$profile" "$filename" "$include_debug"
			;;
		*)
			./build_standalone_releases.sh "$GAME_VERSION" "$profile" "$filename" "$include_debug"
			;;
	esac
done

# END OF SCRIPT EXECUTION -------------------------------------------------------------------------------------------------
