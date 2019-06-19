# lutris-skyrimse-installers
Installers to make Skyrim Special Edition plug and play on Lutris

## Vortex

Plug and play installation, everything configured out of the box for games installed for Steam Play or Lutris Winesteam (see the "WORKING GAMES" section).

Support for other games can be added through a few edits to the installer (see the "ADD SUPPORT FOR GAMES" section).

### WORKING GAMES:
- TESV: Skyrim Special Edition
- TESV: Skyrim (Untested)
- TESIV: Oblivion (Untested)
- Fallout 4 (Untested)
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
- After Vortex update 0.18.7, having the dashlets "Announcements", "News" and "Latest Mods" enabled in "Settings" can cause Vortex to go on a crash loop after a game is added.

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

For a copy of Skyrim Special Edition installed for Steam Play only.

Currently mostly plug and play. As of 1.6, a few manual steps are required and game reconfiguration may be needed. See known bugs and limitations before using the installer.

Lauching SKSE64 from within Lutris will run the default game launcher. In order to play the game using SKSE64 the game must be run from Steam (or Lutris, which launches Steam).

### KNOWN BUGS/LIMITATIONS
- Launching SKSE64 from within Lutris allows the user to launch Skyrim's default launcher but starting the game from within this launcher will not load SKSE. This is the default SKSE behavior;
- Manual steps are required in order for SKSE to run using Skyrim's custom proton prefix, which can only be done from within Steam. The installer will inform the needed steps;
- After installation is complete Steam may run first time setup again, which will cause fAudio to be overriden and game settings to be erased;

## SKYRIM SPECIAL EDITION

As of 1.6 installs the game for Steam Play and saves the files needed for the audio fix inside the game's folder. It does not install the audio fix automatically yet.

The audio fix can be installed by running the commands:
```
cd $HOME/.steam/steam/steamapps/common/Skyrim\ Special\ Edition/audiofix
bash ./install-audio-fix.sh
```

Every time Steam runs first time setup the audio fix must be installed again.
