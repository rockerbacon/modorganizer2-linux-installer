# lutris-skyrimse-installers
Installers to make Skyrim Special Edition plug and play on Lutris

## Installing

These installers are not available on Lutris.net. In order to used them you have to download the .yml file for the app you want from the [latest stable release](https://github.com/rockerbacon/lutris-skyrimse-installers/releases) and install it with the command:
```
lutris -i /path/to/downloaded/file.yml
```
IMPORTANT: If Lutris is already open the path to the file must be absolute, since the working directory for Lutris will not be the same as the terminal's. If in doubt just make sure Lutris is not running before executing the install command.

## Vortex

Plug and play installation, everything configured out of the box for games installed for Steam Play or Lutris Winesteam (see the "WORKING GAMES" section).

Support for other games can be added through a few edits to the installer (see the "ADD SUPPORT FOR GAMES" section).

### WORKING GAMES:
- TESV: Skyrim Special Edition
- TESV: Skyrim
- TESIV: Oblivion (Untested)
- Fallout 4
- Fallout 3 - Game of the Year Edition (Bugfix deployed, awaiting new tests)
- Fallout 3 (Untested)
- Fallout New Vegas
- Morrowind (Untested)

### CONFIRMED WORKING EXTERNAL APPLICATIONS:
- Fores New Idles in Skyrim (FNIS)
- SSEEdit
- LOOT
- Bodyslide and Outfit Studio

Other applications may work as well, but they have not been tested.

### KNOWN BUGS/LIMITATIONS:
- The game cannot be launched from within the application;
- If a new game is installed after Vortex, it'll be unable to manage mods for that game untill the symlinks are rebuild (see the section "REBUILDING SYMLINKS" for instructions);
- Games installed outside of _$HOME/.steam/steam_, _$HOME/.local/share/Steam_ or _$HOME/.local/share/lutris/runners/winesteam_ require manual configuration. (see the section "NON-DEFAULT INSTALL LOCATIONS" for instructions)

### NON-DEFAULT INSTALL LOCATIONS
By default, the symlink build script will look for installed games in the following folders:
- _$HOME/.steam/steam_: default Steam instal location;
- _$HOME/.local/share/Steam_: there are a few reports on the internet of Steam using this folder as its default install location;
- _$HOME/.local/share/lutris/runners/winesteam_: Lutris default location for games using the Wine Steam runner

If you have your games installed on a non-standard Steam library you will need to:

1. Install Vortex on the same drive you installed your games on;
2. Manually edit the Vortex symlink build script;
3. Rebuild the symlinks in order for your games to be detected.

The instructions for editing the script are as follows:

1. Determine your custom Steam library location. This can be done by opening Steam > Settings > Downloads > Steam Library Folders;
2. Open the Vortex symlink build script in _$HOME/Games/vortex-mod-manager/config_scripts/vortex-symlinks.sh_;
3. Find the block "PATH CANDIDATES", there you should see the following:
```
STEAM_PROTON1_PATH="$HOME/.steam/steam"
STEAM_PROTON2_PATH="$HOME/.local/share/Steam"
WINESTEAM_PATH="$HOME/.local/share/lutris/runners/winesteam"
```
4. Pick any of the locations and replace it with your custom library location from step 1. Remember that once replaced, the script will no longer look in the old location so you want to replace a location you do not use;
5. Rebuild the symlinks by executing the script. (see section "REBUILDING SYMLINKS")

### ADD SUPPORT FOR GAMES
#### Game Requirements
- Game must store its configurations inside the folder _users/\<user\>/My Documents/My Games/_
- Game must store its load order data inside the folder _users/\<user\>/Local Settings/Application Data/_
All Bethesda games should fulfill these requirements.
#### Editing config-scripts/vortex-symlinks.sh
This edit is needed to configure the symlink builder, which helps Vortex know where your game's configurations and plugins data are. This step cannot be skipped.
1. Go to steamdb.info, search for the game you want to add support;
2. Write down its APPID, we'll be needing it later;
3. Click on the APPID to open the game's page;
4. Click on "Information" on the left side menu;
5. Write down its gamedir;
6. Open _config-scripts/vortex-symlinks.sh_ and look for the section starting with "GAMES INFO";
7. Inside that section write the following lines:
```
VSL_GAME_NAME_GAMEDIR="gamedir from step 5"
VSL_GAME_NAME_APPID="APPID from step 2"
```
8. If the game saves its data under a different name from gamedir inside _My Games_ or _Application Data_ then these edits are also necessary:
```
VSL_GAME_NAME_OVERRIDE_MYGAMES="folder name inside My Games"
VSL_GAME_NAME_OVERRIDE_APPDATA="folder name inside Application Data"
```
9. Save the file and close it.
Note: GAME_NAME can be anything which identifies the game but can only contain characters, numbers and underscores.

#### Editing installers/vortex.yml
This edit is needed for adding registry keys to the Vortex Wine prefix, which tell Vortex where to look for game installations. If this step is skipped, Vortex will still be able to manage the game, but the game discovery will have to be done manually within Vortex.
1. Open _installers/vortex.yml_ and look for the section starting with "REGEDITS";
2. There you will have subsections with games names. Copy and paste one of them so that we won't have to re-write everything, we'll only be changing a few things;
3. Change the game name between the "#" characters, it can be anything that identifies the game;
4. Now look for the subsection starting with "# Developer install path". Here we will tell Vortex where to look for game installations;
5. Look for the line:
```
path: HKEY_LOCAL_MACHINE\Software\Wow6432Node\some developer name\some gamedir
```
6. Change "some developer name" with the appropriate developer name. In case you do not know the correct one, see sections for other games from the same developer, if there are none you can try searching for the game at www.regfiles.net;
7. Change "some gamedir" with the gamedir from step 5 from the previous edit;
8. We're done with this line, now look for this one:
```
value: c:\\program files (x86)\\steam\\steamapps\\common\\some gamedir
```
9. Change "some gamedir" with the gamedir from step 5 from the previous edit;
10. This subsection is done, now we'll be doing the subsection "# Steam install path". This is a redundancy registry, although Vortex can find the game installation with just the previous registry key, it will raise an error upon startup if it doesn't also find a Steam registry;
11. Look for the line:
```
path: HKEY_LOCAL_MACHINE\Software\Wow6432Node\Valve\Steam\Apps\some APPID
```
12. Change "same APPID" with the APPID from step 2 from the previous edit;
13. Now we look for the line:
```
value: c:\\program files (x86)\\steam\\steamapps\\common\\some gamedir
```
14. This one should be the same as the one we got from step 9. Change "some gamedir" with the gamedir from step 5 from the previous edit;
15. Save the file and close it.
After all this, the installer will properly handle the games almost as if it was a native Windows installation (see the "KNOWN BUGS/LIMITATIONS" section).

### REBUILDING SYMLINKS
We use symlinks in order to trick Vortex into thinking all your game files reside on a single Windows installation, when in actuality they were installed accross multiple Wine prefixes.

The upside of this approach is that you don't need Vortex installed on the same prefix as your game, which makes Wine configuration easier to manage and allows for tools such as Lutris to work well. The downside is that symlinks need a physical folder to point to and before the game is installed this folder does not exist.

Rebuilding the symlinks is very easy, there's a script included with the Vortex installation for that:
1. Open Lutris' Vortex installation folder on a terminal (usually _$HOME/Games/vortex-mod-manager_);
2. Execute the following command:
```
bash config_scripts/vortex-symlinks.sh
```

## SKSE64

For a copy of Skyrim Special Edition installed for Steam Play only. See known bugs and limitations before using the installer.

Lauching SKSE64 from within Lutris will run the default game launcher. In order to play the game using SKSE64 the game must be run from Steam (or Lutris, which launches Steam).

### KNOWN BUGS/LIMITATIONS
- Launching SKSE64 from within Lutris allows the user to launch Skyrim's default launcher but starting the game from within this launcher will not load SKSE. This is the default SKSE behavior;
- After installation is complete Steam might run first time setup again, which will cause fAudio to be overriden and game settings to be reset. See section [Skyrim Special Edition](#skyrim-special-edition) for instructions on getting fAudio again;

## SKYRIM SPECIAL EDITION

Plug and play.

### KNOWN BUGS/LIMITATIONS

- Steam might decide to rerun first time setup under some circumstances, which will uninstall fAudio and result in silent music and dialogue. To reinstall fAudio run the commands:
```
cd $HOME/.steam/steam/steamapps/common/Skyrim\ Special\ Edition/audiofix
bash ./install-audio-fix.sh
```
