#!/bin/bash

# enters the folder this script is in
cd "$(dirname "$0")"
# go to previous folder, which is expected to be the godot project folder
cd ..

version=$1
profile=$2
filename=$3
include_debug=$4

# Fill the path to Godot binary you're using for this project, 
# or the command you use to open godot from terminal
godot_path="/mnt/24847D5F847D3500/Daniel/00_Resources/_softwares/Godot/33x/Godot_v3.3.2-stable_x11.64"

# Fill in your project name, the same way you want the exported folder to be named. 
# The folder name will be project name folowed by profile name. ex. CoolProjectWindows64
project_name="Muto"


echo
echo "Building Standalone release for: $profile"
echo "Game Version is: $version"

project_path=$(pwd)
base_builds_path="$(dirname $project_path)/GameBuilds"

echo "###########################################################"
unquoted_profile=$(sed -e 's/^"//' -e 's/"$//' <<< $profile)
final_path_release=$base_builds_path/$version/Release/$project_name$unquoted_profile/
final_path_debug=$base_builds_path/$version/Debug/$project_name$unquoted_profile/

echo "Exporting $unquoted_profile Release to $final_path_release"
mkdir -p $final_path_release
$godot_path --export $unquoted_profile $final_path_release$filename

if [[ $include_debug = "true" ]]
then
	echo "Exporting $unquoted_profile Debug to $final_path_debug"
	mkdir -p $final_path_debug
	$godot_path --export-debug $unquoted_profile $final_path_debug$filename
fi

echo "Exporting $unquoted_profile Finished"
echo "###########################################################"
echo