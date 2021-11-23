#!/bin/bash

# CONSTANTS AND VARIABLES DEFINITIONS -------------------------------------------------------------------------------------

# Imports
ORIGINAL_DIRECTORY=$(pwd)
cd "$(dirname "$0")" || exit
# shellcheck disable=SC1091
source _config.sh
change_directory "$ORIGINAL_DIRECTORY"


# END CONSTANTS AND VARIABLES DEFINITIONS ---------------------------------------------------------------------------------


# FUNCTION DEFINITIONS ----------------------------------------------------------------------------------------------------

function show_help() {
	echo "possible commansd are:"
	echo "all --------------------- publish on itch to all platforms"
	echo "linux | lin ------------- publish on itch to linux"
	echo "windows | win ----------- publish on itch to windows"
	echo "max | osx --------------- publish on itch to mac"
	echo "html | web -------------- publish on itch for web"
	echo "pc ---------------------- publich on itch for windows/osx/linux"
	echo "help -------------------- shows this help menu"
}

# In the future, maybe try to use the same folder structure you use for steam, but add some ignores to separate the versions
# for OSX you can just send the zip directly
function push_linux {
	echo -e "\nPushing $GREEN$ITCH_GAME_ADDRESS$RESET for Linux" 
	./butler push --userversion="$GAME_VERSION" "$BASE_RELEASE_PATH/$PROJECT_NAME""Linux32" "$ITCH_GAME_ADDRESS:linux32"
	./butler push --userversion="$GAME_VERSION" "$BASE_RELEASE_PATH/$PROJECT_NAME""Linux64" "$ITCH_GAME_ADDRESS:linux64"
}

function push_windows {
	echo -e "\nPushing $GREEN$ITCH_GAME_ADDRESS$RESET for Windows" 
	echo "$ITCH_GAME_ADDRESS:linux32"
	./butler push --userversion="$GAME_VERSION" "$BASE_RELEASE_PATH/$PROJECT_NAME""Windows32" "$ITCH_GAME_ADDRESS:windows32"
	./butler push --userversion="$GAME_VERSION" "$BASE_RELEASE_PATH/$PROJECT_NAME""Windows64" "$ITCH_GAME_ADDRESS:windows64"
}

function push_osx {
	echo -e "\nPushing $GREEN$ITCH_GAME_ADDRESS$RESET for OSX" 
	./butler push --userversion="$GAME_VERSION" "$BASE_RELEASE_PATH/$PROJECT_NAME""OSX" "$ITCH_GAME_ADDRESS:osx-universal"
}

function push_html {
	echo -e "\nPushing $GREEN$ITCH_GAME_ADDRESS$RESET for HTML5" 
	./butler push --userversion="$GAME_VERSION" "$BASE_RELEASE_PATH/$PROJECT_NAME""HTML5" "$ITCH_GAME_ADDRESS:html"
}

# END OF FUNCTION DEFINITIONS ---------------------------------------------------------------------------------------------


# SCRIPT EXECUTION --------------------------------------------------------------------------------------------------------

builds_to_push=$1

case $builds_to_push in
	"all")
		builds_to_push="all"
		;;
	"pc" | "PC" | "Pc")
		builds_to_push="pc"
		;;
	"linux" | "lin")
		builds_to_push="linux"
		;;
	"win" | "windows")
		builds_to_push="win"
		;;
	"mac" | "osx")
		builds_to_push="osx"
		;;
	"html" | "web")
		builds_to_push="html"
		;;
	"-h" | "help" | "--help")
		show_help
		exit 0
		;;
	*)
		echo -e "$RED""ERROR$RESET | Unrecognized option for builds_to_push: $builds_to_push"
		show_help
		exit 1
		;;
esac

if [[ "$(has_folder butler)" == "false" ]]
then
	echo -e "$YELLOW""Itch.io's Butler was not found$RESET, will start downloading and installing it now."
	# shellcheck disable=SC1091
	source download_itchio_butler.sh
fi

change_directory "butler"

case $builds_to_push in
	"linux")
		push_linux
		;;
	"win")
		push_windows
		;;
	"osx")
		push_osx
		;;
	"html")
		push_html
		;;
	"pc")
		push_windows
		push_linux
		push_osx
		;;
	*)
		push_windows
		push_linux
		push_osx
		push_html
		;;
esac

# END OF SCRIPT EXECUTION -------------------------------------------------------------------------------------------------