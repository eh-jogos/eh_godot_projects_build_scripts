#!/bin/bash

project_settings="../project.godot"
export_configs="../export_presets.cfg"
include_debug=$1
export_output=$2


if [[ -z $include_debug || $include_debug = "false" ]]
then
	include_debug=false
elif [[ $include_debug = "true" ]]
then
	include_debug=true
else
	echo "Unrecognized option for include_debug: $include_debug | changing to false"
	include_debug=false
fi


game_version=$(cat $project_settings | grep "^config/build_folder" | cut -d'=' -f2)
game_version=$(sed -e 's/^"//' -e 's/"$//' <<< $game_version)
echo "Exporting $game_version with debug turned: $include_debug"


function getProperty {
   	prop_key=$1
   	prop_value=$(cat $export_configs | grep $prop_key | cut -d'=' -f2)
   	echo $prop_value
}

export_profiles=($(getProperty "^name"))
echo "Going to Export the following profiles: ${export_profiles[@]}"
export_paths=($(getProperty "^export_path"))
yes_to_all=false

length=${#export_profiles[@]}
for ((i = 0; i < $length; i++));
do
	profile=${export_profiles[i]}
	filename=$(sed -e 's/^"//' -e 's/"$//' <<< ${export_paths[i]})
	
	asking_input=true
	while $asking_input
	do
		answer="invalid"
		if [ $yes_to_all = "true" ]
		then
			answer="yes"
			echo "Building $profile"
		else
			prompt="Build profile $profile? (\e[4my\e[0mes/yes to \e[4mall\e[0m/\e[4ms\e[0mkip/\e[4ma\e[0mbort) "
			echo -e $prompt
			read answer
		fi
		
		case $answer in
			"all" | "All" | "ALL" )
				yes_to_all="true"
				;&
			"yes" | "y" | "Y" | "Yes" | "YES" )
				# This is to accept other modifiers in case you want
				# to have separate scripts for building steam releases or export in other
				# configurations then each export profile having its own folder.
				# (See the "project/cosmic_abyss" branch for an example)
				# Just add these other options as cases below:
				case $export_output in
					*)
						./build_standalone_releases.sh $game_version $profile $filename $include_debug
						;;
				esac
				asking_input=false
				;;
			"skip" | "s" | "S" | "Skip" | "SKIP" )
				echo "Skipping $profile"
				asking_input=false
				;;
			"abort" | "a" | "A" | "Abort" | "ABORT" )
				echo "Aborting script"
				asking_input=false
				exit 1
				;;
			*)
				echo "Invalid Input $answer"
				echo "Valid Inputs are "
				;;
		esac
	done
done