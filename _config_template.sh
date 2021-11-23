#!/bin/bash

# CONSTANTS AND VARIABLES DEFINITIONS -------------------------------------------------------------------------------------

# Format helpers
RESET="\e[0m"
UNDERLINE="\e[4m"
RED="\e[91m"
GREEN="\e[92m"
YELLOW="\e[93m"
CYAN="\e[96m"

BUILD_SCRIPTS_FOLDER=$(dirname "$0")
PROJECT_FOLDER="$BUILD_SCRIPTS_FOLDER/.."

# Project Configurations

# Fill the path to Godot binary you're using for this project, 
# or the command you use to open godot from terminal
GODOT_PATH="../.binaries/godot/godot_steam_windows_64.exe"

# Fill in your project name, the same way you want the exported folder to be named. 
# The folder name will be project name folowed by profile name. ex. CoolProjectWindows64
PROJECT_NAME="MonsterOutbreak"

# The base name for the executable file of the game. Platform specific extensions will be added later
# Defaults to the same as the PROJECT_NAME but can be changed to whatever you want.
# ex: "CoolGame" will become "CoolGame.exe" on windows
GAME_FILENAME="$PROJECT_NAME"

# Fill in the itch game address as in "user/game"
# ex: game url "https://eh-jogos.itch.io/cosmicabyss" -> game addres "eh-jogos/cosmicabyss"
ITCH_GAME_ADDRESS="gamemuncher/monster-outbreak"

# This is the path in your disk where the scripts should export the games
# This folder will be used as a base folder and the script wil create other folders in it, based
# on the version and platform you're exporting to.
# By default it will try to find a folder called "GameBuilds" beside the godot source, but you can 
# change it to whatever path you want.
BASE_BUILDS_PATH="$PROJECT_FOLDER/../GameBuilds"

# END CONSTANTS AND VARIABLES DEFINITIONS ---------------------------------------------------------------------------------


# FUNCTION DEFINITIONS ----------------------------------------------------------------------------------------------------

function change_directory(){
	cd "$1" || ( echo -e "$RED""Error!$RESET Invalid directory $YELLOW$1$RESET. Aborting" && exit 1 )
}


function get_absolute_path(){
	echo -e "$(realpath "$1")"
}


function has_folder(){
	if [[ -d $1 ]]
	then
		echo "true"
	else
		echo "false"
	fi
}


function get_config {
	prop_key=$1
	path_to_config_file=$2
	
	prop_value=$(grep "$prop_key" "$path_to_config_file" | cut -d'=' -f2 | tr -d \" | tr -d ' ')
	echo "$prop_value"
}


function get_project_property {
	prop_key=$1
	path_to_project_settings=$2
	if [[ -z $path_to_project_settings ]]
	then
		path_to_project_settings="$PROJECT_FOLDER/project.godot"
	fi
	echo $(get_config "$prop_key" "$path_to_project_settings")
}


function get_export_property {
	prop_key=$1
	path_to_export_settings=$2
	if [[ -z $path_to_export_settings ]]
	then
		path_to_export_settings="$PROJECT_FOLDER/export_presets.cfg"
	fi
	echo $(get_config "$prop_key" "$path_to_export_settings")
}


function get_executable_name {
	profile_name=$1
	is_64=$2
	case $profile_name in
		*"Windows"* | *"windows"*)
			echo "$GAME_FILENAME.exe"
			;;
		*"Linux"* | *"linux"*)
			if [[ $is_64 = "true" ]]
			then
				echo "$GAME_FILENAME.x86_64"
			else
				echo "$GAME_FILENAME.x86"
			fi
			;;
		*"OSX"* | *"osx"* | *"MAC"* | *"Mac"* | *"mac"*)
			echo "$GAME_FILENAME.zip"
			;;
		*"HTML5"*)
			echo "$GAME_FILENAME.html"
			;;
		*)
			echo -e "$RED""ERROR | Could not find a match for $RESET$profile_name"
			exit 1
			;;
	esac
}


function remove_quotes(){
	echo $(sed -e 's/^"//' -e 's/"$//' <<< $1)
}

# END OF FUNCTION DEFINITIONS ---------------------------------------------------------------------------------------------


# SCRIPT EXECUTION --------------------------------------------------------------------------------------------------------

# Convert all paths to absolute paths
BUILD_SCRIPTS_FOLDER=$(get_absolute_path "$BUILD_SCRIPTS_FOLDER")
PROJECT_FOLDER=$(get_absolute_path "$BUILD_SCRIPTS_FOLDER/..")
GODOT_PATH=$(get_absolute_path "$GODOT_PATH")

if [[ "$(has_folder "$BASE_BUILDS_PATH")" == "false" ]]
then
	mkdir -p "$BASE_BUILDS_PATH"
fi
BASE_BUILDS_PATH=$(get_absolute_path "$BASE_BUILDS_PATH")

BUILD_FOLDER=$(get_project_property "^config/build_folder")
BUILD_FOLDER=$(remove_quotes "$BUILD_FOLDER")
GAME_VERSION=$(get_project_property "^config/version")
GAME_VERSION=$(remove_quotes "$GAME_VERSION")

BASE_RELEASE_PATH="$BASE_BUILDS_PATH/$BUILD_FOLDER/Release"
if [[ "$(has_folder "$BASE_RELEASE_PATH")" == "false" ]]
then
	mkdir -p "$BASE_RELEASE_PATH"
fi
BASE_RELEASE_PATH=$(get_absolute_path "$BASE_RELEASE_PATH")

if [[ -z $GODOT_PATH ]]
then
	echo -e "$RED""ERROR | $RESET""GODOT_PATH$RED must be set in _config.sh for this scripts to work.$RESET "
	exit 1
elif [[ -z $PROJECT_NAME ]]
then 
	echo -e "$RED""ERROR | $RESET""PROJECT_NAME$RED must be set in _config.sh for this scripts to work.$RESET "
	exit 1
elif [[ -z $GAME_FILENAME ]]
then 
	echo -e "$RED""ERROR | $RESET""GAME_FILENAME$RED must be set in _config.sh for this scripts to work.$RESET "
	exit 1
elif [[ -z $ITCH_GAME_ADDRESS ]]
then 
	echo -e "$RED""ERROR | $RESET""ITCH_GAME_ADDRESS$RED must be set in _config.sh for this scripts to work.$RESET "
	exit 1
elif [[ -z $GAME_VERSION ]]
then 
	msg="$RED""ERROR | Could not find 'config/version' in the project.settings.$RESET"
	msg+="$YELLOW Did you add in the Godot Projet Settings? $RESET"
	echo -e msg
	exit 1
elif [[ -z $BUILD_FOLDER ]]
then 
	msg="$RED""ERROR | Could not find 'config/build_folder' in the project.settings.$RESET"
	msg+="$YELLOW Did you add in the Godot Projet Settings? $RESET"
	echo -e msg
	exit 1
fi

# echo "$GODOT_PATH"
# echo "$PROJECT_FOLDER"
# echo "$BUILD_FOLDER"
# echo "$GAME_VERSION"
# echo "$BASE_BUILDS_PATH"
# echo "$BASE_RELEASE_PATH"

# END OF SCRIPT EXECUTION -------------------------------------------------------------------------------------------------