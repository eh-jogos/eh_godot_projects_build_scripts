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

# END CONSTANTS AND VARIABLES DEFINITIONS ---------------------------------------------------------------------------------


# FUNCTION DEFINITIONS ----------------------------------------------------------------------------------------------------

# END OF FUNCTION DEFINITIONS ---------------------------------------------------------------------------------------------


# SCRIPT EXECUTION --------------------------------------------------------------------------------------------------------

change_directory "$PROJECT_FOLDER"

echo -e "\nBuilding Standalone release for: $CYAN$profile$RESET"
echo -e "Game Version is: $GREEN$version$RESET"

echo -e "###########################################################\n"
unquoted_profile=$(sed -e 's/^"//' -e 's/"$//' <<< $profile)
final_path_release=$BASE_BUILDS_PATH/$BUILD_FOLDER/Release/$PROJECT_NAME$unquoted_profile/
final_path_debug=$BASE_BUILDS_PATH/$BUILD_FOLDER/Debug/$PROJECT_NAME$unquoted_profile/

echo -e "Exporting $CYAN$unquoted_profile$RESET Release to $GREEN$final_path_release$RESET\n"
mkdir -p "$final_path_release"
$GODOT_PATH --no-window --export "$unquoted_profile" "$final_path_release$filename"

if [[ $include_debug = "true" ]]
then
	echo -e "\nExporting $CYAN$unquoted_profile$RESET Debug version to $GREEN$final_path_debug$RESET\n"
	mkdir -p "$final_path_debug"
	$GODOT_PATH --no-window --export-debug "$unquoted_profile" "$final_path_debug$filename"
fi

echo -e "\nExporting $CYAN$unquoted_profile$RESET Finished"
echo -e "###########################################################\n"

# END OF SCRIPT EXECUTION -------------------------------------------------------------------------------------------------
