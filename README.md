# eh_godot_projects_build_scripts
Some build scripts I use on my Godot project to expedite exporting projects. 

Do note that for them to work I expect a lot of things to be true:
- This files should be in a subfolder on the root of the project, but not scattered on the root on the repository (for this I usually add them as a submodule in a folder called "_00_utility" or "_00_build_scripts")
- You must add two string properties to the `application/config` category of your Project Settings, one named `version` and the other named `build_folder`
<img src="https://i.imgur.com/FHILdXz.png" alt="Project Settings Example">

- It also expects a configured `export_presets.cfg`
- It should have one export profile for each system/architecture you want to support, and they should be named as "SystemArch". For example:
  - Windows64
  - Linux32
  - OSX (Osx is an exception, as it exports a zip with both 32 and 64 bits)
  - HTML5 (This is also an exception, but I do expect any web export to be called just HTML5)
- The export should have only the executable filename in the field Export Path, and no folder paths at all. The scripts will read this filename and generate a export path in the format of: GameBuilds/build_folder/ReleaseOrDebug/ProjectNameExportProfileName
<img src="https://i.imgur.com/Yx7KYHR.png" alt="Export Profiles Example">

With all of that you also need to configure some variables in the `build_standalone_releases.sh` with the path to the godot binary you're using for that project and the project name. There are comments there with examples
