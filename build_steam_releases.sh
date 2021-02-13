#!/bin/zsh

# enters the folder this script is in
cd "$(dirname "$0")"
# go to previous folder, which is expected to be the godot project folder
cd ..

version=$1
profile=$2
filename=$3
include_debug=$4

if [[ $profile == *"OSX"* ]]
then
	echo "Exporting to OSX for steam is unsupported for now. Skipping OSX"
	exit 0
fi

echo
echo "Building Steam release for: $profile"
echo "Game Version is: $version"

godot_version="32-steam"
project_path=$(pwd)
base_builds_path="$(dirname $project_path)/GameBuilds"
project_name="CosmicAbyss"

prefix_os_absolute_path=""
if [[ "$OSTYPE" == "linux-gnu"* ]]
then
	prefix_os_absolute_path="/mnt/24847D5F847D3500"
elif [[ "$OSTYPE" == "msys" ]]
then
	prefix_os_absolute_path="/d"
else
	echo "Unsuported OS $OSTYPE | Exiting"
	exit 1
fi
echo "OS PREFIX: $prefix_os_absolute_path"

steam_app_id=$prefix_os_absolute_path/Daniel/ProjetosGames/CursoUdemy/EscapeFromTheCosmicAbyss/GameSteam/steam_appid.txt
steam_linux_32_lib=$prefix_os_absolute_path/Daniel/00_Resources/HybridStrategies/Steam/sdk/redistributable_bin/linux32/libsteam_api.so
steam_linux_64_lib=$prefix_os_absolute_path/Daniel/00_Resources/HybridStrategies/Steam/sdk/redistributable_bin/linux64/libsteam_api.so
steam_windows_32_folder=$prefix_os_absolute_path/Daniel/00_Resources/HybridStrategies/Steam/sdk/redistributable_bin
steam_windows_64_folder=$prefix_os_absolute_path/Daniel/00_Resources/HybridStrategies/Steam/sdk/redistributable_bin/win64

fpath=( ~/.zfunc "${fpath[@]}" )
autoload -Uz godot

echo "###########################################################"

unquoted_profile=$(sed -e 's/^"//' -e 's/"$//' <<< $profile)

final_path_release=$base_builds_path/$version/Steam/Release/
final_path_debug=$base_builds_path/$version/Steam/Debug/
if [[ $profile == *"32"* ]]
then
	echo $profile
	if [[ $profile == *"demo_compatibility"* ]]
	then
		final_path_release=$base_builds_path/$version/Steam/Compatibility/Demo/Release/32bits/
		final_path_debug=$base_builds_path/$version/Steam/Compatibility/Demo/Debug/32bits/
	elif [[ $profile == *"compatibility"* ]]
	then
		final_path_release=$base_builds_path/$version/Steam/Compatibility/Release/32bits/
		final_path_debug=$base_builds_path/$version/Steam/Compatibility/Debug/32bits/
	elif [[ $profile == *"demo"* ]]
	then
		final_path_release=$base_builds_path/$version/Steam/Demo/Release/32bits/
		final_path_debug=$base_builds_path/$version/Steam/Demo/Debug/32bits/
	else
		final_path_release=$base_builds_path/$version/Steam/Release/32bits/
		final_path_debug=$base_builds_path/$version/Steam/Debug/32bits/
	fi
elif [[ $profile == *"demo_compatibility"* ]]
then
	final_path_release=$base_builds_path/$version/Steam/Compatibility/Demo/Release/
	final_path_debug=$base_builds_path/$version/Steam/Compatibility/Demo/Debug/
elif [[ $profile == *"compatibility"* ]]
then
	final_path_release=$base_builds_path/$version/Steam/Compatibility/Release/
	final_path_debug=$base_builds_path/$version/Steam/Compatibility/Debug/
elif [[ $profile == *"demo"* ]]
then
	final_path_release=$base_builds_path/$version/Steam/Demo/Release/
	final_path_debug=$base_builds_path/$version/Steam/Demo/Debug/
fi

echo "Exporting $unquoted_profile Release to $final_path_release \n"
mkdir -p $final_path_release
godot $godot_version --path $project_path --export $unquoted_profile $final_path_release$filename

if [[ $include_debug = "true" ]]
then
	echo "\nExporting $unquoted_profile Debug to $final_path_debug \n"
	mkdir -p $final_path_debug
	godot $godot_version --path $project_path --export-debug $unquoted_profile $final_path_debug$filename
fi

cp $steam_app_id $final_path_release
cp $steam_app_id $final_path_debug

if [[ $profile == *"Windows64"* ]]
then
	echo "\nCopying Related Steam Files from $steam_windows_64_folder \n"
	cp $steam_windows_64_folder/* $final_path_release
	if [[ $include_debug = "true" ]]
	then
		cp $steam_windows_64_folder/* $final_path_debug
	fi
elif [[ $profile == *"Windows32"* ]]
then
	echo "\nCopying Related Steam Files from $steam_windows_32_folder \n"
	cp $steam_windows_32_folder/* $final_path_release
	if [[ $include_debug = "true" ]]
	then
		cp $steam_windows_32_folder/* $final_path_debug
	fi
elif [[ $profile == *"Linux64"* ]]
then
	echo "\nCopying Related Steam Files from $steam_linux_64_lib \n"
	cp $steam_linux_64_lib $final_path_release
	if [[ $include_debug = "true" ]]
	then
		cp $steam_linux_64_lib $final_path_debug
	fi
elif [[ $profile == *"Linux32"* ]]
then
	echo "\nCopying Related Steam Files from $steam_linux_32_lib \n"
	cp $steam_linux_32_lib $final_path_release
	if [[ $include_debug = "true" ]]
	then
		cp $steam_linux_32_lib $final_path_debug
	fi
else
	echo "\nUnsupported Profile: $profile \n"
fi

echo "\nExporting $unquoted_profile Finished"
echo "###########################################################"
echo