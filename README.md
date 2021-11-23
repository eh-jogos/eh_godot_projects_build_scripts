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
- You actually can have other names in the export presets, the build script will ask if you want to export or not for each of 
them and as long as they have the "System" name in some form or another it **should** (hopefully) work. 
- But the itch.io publishing script has some hardcoded presets for now, and will only look for exports with the "SystemArch" name
and ignore all others.
<img src="https://i.imgur.com/Yx7KYHR.png" alt="Export Profiles Example">

With all of that you also need to duplicate the `_config_template.sh` file and rename it `_config.sh`.
Inside it there are some variables that need to be configured by project, and some that are local to you only,
like the path to Godot's executable file. Just follow the comments and configure them as you want!
