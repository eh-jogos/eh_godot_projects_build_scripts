#!/bin/bash

# CONSTANTS AND VARIABLES DEFINITIONS -------------------------------------------------------------------------------------

version=$1
profile=$2
filename=$3
include_debug=$4

# Imports
ORIGINAL_DIRECTORY=$(pwd)
cd "$(dirname "$0")" || exit
# shellcheck disable=SC1091
source _config.sh

STEAM_BINARIES_FOLDER=$PROJECT_FOLDER/.binaries/steam_sdk/redistributable_bin

steam_app_id=$PROJECT_FOLDER/steam_appid.txt
steam_linux_32_lib=$(get_absolute_path "$STEAM_BINARIES_FOLDER/linux32/libsteam_api.so")
steam_linux_64_lib=$(get_absolute_path "$STEAM_BINARIES_FOLDER/linux64/libsteam_api.so")
steam_windows_32_folder=$(get_absolute_path "$STEAM_BINARIES_FOLDER")
steam_windows_64_folder=$(get_absolute_path "$STEAM_BINARIES_FOLDER/win64")

final_path_release=$BASE_BUILDS_PATH/Steam/Release/
final_path_debug=$BASE_BUILDS_PATH/Steam/Debug/

# END CONSTANTS AND VARIABLES DEFINITIONS ---------------------------------------------------------------------------------


# FUNCTION DEFINITIONS ----------------------------------------------------------------------------------------------------

function update_final_paths_based_on_profile() {
	profile=$1
	if [[ -z $profile ]]
	then
		echo -e "$RED""ERROR | profile can't be empty. Aborting$RESET"
		exit 1
	fi
	
	if [[ $profile == *"32"* ]]
	then
		if [[ $profile == *"demo"* ]]
		then
			final_path_release=$BASE_BUILDS_PATH/Steam/Demo/Release/32bits/
			final_path_debug=$BASE_BUILDS_PATH/Steam/Demo/Debug/32bits/
		else
			final_path_release=$BASE_BUILDS_PATH/Steam/Release/32bits/
			final_path_debug=$BASE_BUILDS_PATH/Steam/Debug/32bits/
		fi
	elif [[ $profile == *"demo"* ]]
	then
		final_path_release=$BASE_BUILDS_PATH/Steam/Demo/Release/
		final_path_debug=$BASE_BUILDS_PATH/Steam/Demo/Debug/
	fi
}


function export_project() {
	profile=$1
	path=$2
	if [[ -z $profile || -z $path ]]
	then
		echo -e "$RED""ERROR | Neither profile nor path can be empty.\n profile=$profile path=$path\n Aborting$RESET"
		exit 1
	fi
	
	echo -e "Exporting $CYAN$profile$RESET to $GREEN$path$RESET\n"
	mkdir -p "$final_path_release"
	$GODOT_PATH --path "$PROJECT_FOLDER" --no-window --export "$profile" "$path$filename"
}


function copy_steam_files() {
	profile=$1
	path_from=$2
	if [[ -z $profile || -z $path_from ]]
	then
		echo -e "$RED""ERROR | Neither profile nor path_from can be empty.$RESET"
		echo -e "profile=$profile \npath_from=$path_from $RED\nAborting$RESET"
		exit 1
	fi
	
	echo -e  "\nCopying Related Steam Files from $path_from \n"
	cp "$path_from" "$final_path_release"
	if [[ $include_debug = "true" ]]
	then
		cp "$path_from" $final_path_debug
	fi
}

# END OF FUNCTION DEFINITIONS ---------------------------------------------------------------------------------------------


# SCRIPT EXECUTION --------------------------------------------------------------------------------------------------------

change_directory "$PROJECT_FOLDER"

if [[ $profile == *"OSX"* ]]
then
	echo "Exporting to OSX for steam is unsupported for now. Skipping OSX"
	exit 0
fi

echo -e "\nBuilding Steam release for: $CYAN$profile$RESET"
echo -e "Game Version is: $GREEN$version$RESET"
echo -e "###########################################################\n"

unquoted_profile=$(sed -e 's/^"//' -e 's/"$//' <<< $profile)

update_final_paths_based_on_profile "$unquoted_profile"

export_project "$unquoted_profile" "$final_path_release"
cp "$steam_app_id" "$final_path_release"

if [[ $include_debug = "true" ]]
then
	export_project "$unquoted_profile" "$final_path_debug"
	cp "$steam_app_id" "$final_path_debug"
fi


case $profile in
	*"Windows64"*)
		copy_steam_files "$unquoted_profile" "$steam_windows_64_folder/steam_api64.dll"
		copy_steam_files "$unquoted_profile" "$steam_windows_64_folder/steam_api64.lib"
		;;
	*"Windows32"*)
		copy_steam_files "$unquoted_profile" "$steam_windows_32_folder/steam_api.dll"
		copy_steam_files "$unquoted_profile" "$steam_windows_32_folder/steam_api.lib"
		;;
	*"Linux64"*)
		copy_steam_files "$unquoted_profile" "$steam_linux_64_lib"
		;;
	*"Linux32"*)
		copy_steam_files "$unquoted_profile" "$steam_linux_32_lib"
		;;
	*)
		echo -e "$RED\nUnsupported Profile: $profile \n$RESET"
		exit 1
		;;
esac

echo -e "\nExporting $unquoted_profile Finished"
echo -e  "###########################################################\n"