# Post install instructions

This document provides information on additional steps you may want to take after installing Mod Organizer 2.

## General Advice
Remember, when adding anything to your Launch Options, include the `%command%` argument. If it's part of the game (i.e. `--skip-launcher`) then it goes after, otherwise it goes before. Other than that, ordering doesn't really matter. For example:
```
STEAM_COMPAT_MOUNTS=/folder1/:/folder2/ %command% --skip-launcher
```

## 'gamemoderun' Issue
Usually, `gamemoderun` to a proton game's Launch Options within Steam can give a significant improvement in performance.
</br>
However, in my testing, it appears that having this option in a game that's been modified by this script will prevent MO2 from launching, rendering the game unplayable.

## MO2 outside of $HOME
If you've installed MO2 outside of your $HOME directory, you may find you cannot launch. You can try adding `STEAM_COMPAT_MOUNTS=/path/to/folder %command%` to your Launch Options:
</br>
For example, I install my instances on a secondary drive mounted at /nvme2/, under a folder called modding, so the argument for me would be `STEAM_COMPAT_MOUNTS=/nvme2/modding/`

## Game Specific Adjustments

### Cyberpunk 2077
**IMPORTANT:** Add `WINEDLLOVERRIDES="winmm,version=n,b" %command%` to the game's Launch Options within Steam:</br>

## Using alternative proton versions

**IMPORTANT:** Proton 9.0 is the most extensively tested version. The author of this document provides no guarantees that alternative versions will work well.

1. Close the game and Mod Organizer 2 if you have them open;
2. Select the Proton version you'd like to use on Steam and wait for it to execute any validations and updates;
3. Purge your existing game prefix to ensure a clean version transition:
	1. Open a file explorer or terminal of your choice;
	2. Navigate to "\<your steam library\>/steamapps/compatdata";
	3. Delete the folder named after the appid of the game - you can find all appids [here](gamesinfo);
4. Launch the game on Steam and let it run the first time setup;
5. (Optional\*) Run the installer again, select no when asked to update Mod Organizer 2;

\*Step 5 is for re-applying protontricks on the newly created prefix. Whether or not that is helpful depends on how well the Proton version you selected works out-of-the-box.

## Launching Mod Organizer 2 outside of Steam

**IMPORTANT:** the author of this document highly advises against this. Steam runs Proton within its own special environment and Mod Organizer 2 may not properly utilize this environment when executed from outside of Steam. You can read [this reddit comment](https://www.reddit.com/r/linux_gaming/comments/k2kyjt/is_it_a_good_idea_to_use_proton_for_non_steam/gdxz70m/) where GloriousEggroll talks about this in more detail.

You can launch non-Steam applications with Proton using `protontricks-launch`.

An example of a shell command for running a Skyrim SE instance would be:

```bash
WINEESYNC=1 WINEFSYNC=1 protontricks-launch --appid 489830 "$HOME/.config/modorganizer2/instances/skyrimspecialedition/modorganizer2/ModOrganizer.exe"
```

You can find the proper appid for the game you want [here](gamesinfo).

## Launching a modded game without opening Mod Organizer 2

You can pass a single parameter to Mod Organizer 2 through the game's launch options on Steam. This allows you to tell Mod Organizer 2 to skip its UI and directly launch an executable.

1. Open Steam;
2. Right click the game you want to launch directly and click on "Properties";
3. Scroll down to "Launch Options" within the "General" tab;
4. Write `'moshortcut://"executable name"'` in the launch options textbox. eg.:
   - `'moshortcut://"Fallout Launcher"'` will launch the original Fallout New Vegas launcher
   - `'moshortcut://"SKSE"'` will directly launch Skyrim and Skyrim SE, with SKSE enabled

![steam launch options](screenshots/steam_launch_options.png?raw=true "Steam launch options")

5. Close the properties window and launch the game;

**IMPORTANT:** pay attention to the usage of single and double quotes in the examples above, as they ensure executable names including spaces will still work. The entire launch option should be wrapped in single quotes and the executable name should be wrapped in double quotes.
