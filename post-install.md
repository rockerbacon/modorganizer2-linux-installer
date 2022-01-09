## Post install instructions

This document provides information on additional steps you may want to take after installing Mod Organizer 2

### Running the original game launcher

1. Open Mod Organizer 2;
2. Click on the cogwheel in the top bar to configure executables;
![topbar executables config](screenshots/topbar_executables_config.png?raw=true "Executables Configuration")
3. Click on the launcher in the list to the left;
4. In the "Binary" text box, add an underscore before the name of the .exe file;
	- eg.: "Z:\\home\\joe\\Games\\steam-library\\steamapps\\common\\Skyrim Special Edition\\\_SkyrimSELauncher.exe"
![executables list](screenshots/executables_config_leftside_list.png?raw=true "Executables List")
5. Now you should be able to run the launcher by selecting it in the executables dropdown;
![executables dropdown](screenshots/executables_dropdown.png?raw=true "Executables Dropdown")

### Using alternative proton versions

**IMPORTANT:** Proton 6.3 is the most extensively tested version. The author of this document provides no guarantees that alternative versions will work well.

1. Close the game and Mod Organizer 2 if you have them open;
2. Select the Proton version you'd like to use on Steam and wait for it to execute any validations and updates;
3. Purge your existing game prefix to ensure a clean version transition:
	1. Open a file explorer or terminal of your choice;
	2. Navigate to "<your steam library>/steamapps/compatdata";
	3. Delete the folder named after the appid of the game - you can find all appids [here](gamesinfo);
4. Launch the game on Steam and let it run the first time setup;
5. (Optional\*) Run the installer again, select no when asked to update Mod Organizer 2;

\*Step 5 is for re-applying protontricks on the newly created prefix. Whether or not that is helpful depends on how well the Proton version you selected works out-of-the-box.

### Launching Mod Organizer 2 outside of Steam

**IMPORTANT:** the author of this document highly advises against this. Steam runs Proton within its own special environment and Mod Organizer 2 may not properly utilize this environment when executed from outside of Steam. You can read [this reddit comment][https://www.reddit.com/r/linux_gaming/comments/k2kyjt/is_it_a_good_idea_to_use_proton_for_non_steam/gdxz70m/] where GloriousEggroll talks about this in more detail.

You can launch non-Steam applications with Proton using `protontricks-launch`.

An example of a shell command for running a Skyrim SE instance would be:

```bash
WINEESYNC=1 WINEFSYNC=1 protontricks-launch --appid 489830 "$HOME/.config/modorganizer2/instances/skyrimspecialedition/modorganizer2/ModOrganizer.exe"
```

You can find the proper appid for the game you want [here](gamesinfo).

