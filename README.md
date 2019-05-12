# lutris-skyrimse-installers
Installers to make Skyrim Special Edition plug and play on Lutris

## Vortex

Plug and play installation, everything configured out of the box for games installed for Steam Play or Lutris Winesteam (see the "WORKING GAMES" section).

Support for other games can be added through a few edits to the installer (see the "ADD SUPPORT FOR GAMES" section).

Can also be used on custom Wine installations with a few manual steps (see the "CUSTOM WINE INSTALLATION" section).

### WORKING GAMES:
- TESV: Skyrim Special Edition
- TESV: Skyrim (Untested)
- TESIV: Oblivion (Untested)
- Fallout 4 (Untested)
- Fallout 3 - Game of the Year Edition (Untested)
- Fallout 3 (Untested)
- Fallout New Vegas (Untested)

### KNOWN BUGS/LIMITATIONS:
- You cannot safely launch apps from within Vortex as its prefix is not configured to run other apps;
- Although profiles work for plugins and configs they will not work for saves;
- If a new game is installed after Vortex, it'll be unable to manage mods for that game untill the symlinks are rebuild (see the section "REBUILDING SYMLINKS" for instructions).

### ADD SUPPORT FOR GAMES
#### Game Requirements
- Game must store its configurations inside the folder _users/\<user\>/My Documents/My Games/\<Game Title\>_
- Game must store its load order data inside the folder _users/\<user\>/Local Settings/Application Data/\<Game Title\>_
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
8. Save the file and close it.
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
value: c:\\program files (x86)\\steam\\steamapps\\common\\same gamedir
```
14. This one should be the same as the one we got from step 9. Change "some gamedir" with the gamedir from step 5 from the previous edit;
15. Save the file and close it.
After all this, the installer will properly handle the games almost as if it was a native Windows installation (see the "KNOWN BUGS/LIMITATIONS" section).

### REBUILDING SYMLINKS
We use symlinks in order to trick Vortex into thinking all your game files reside on a single Windows installation, when in actuality they were installed accross multiple Wine prefixes.

The upside of this approach is that you don't need Vortex installed on the same prefix as your game, which makes Wine configuration easier to manage and allows for tools such as Lutris to work well. The downside is that symlinks need a physical folder to point to and before the game is installed this folder does not exist.

Rebuilding the symlinks is very easy, there's a script included with the Vortex installation for that:
1. Open Lutris' Vortex installation folder on a terminal (usually _/home/\<user\>/Games/vortex-mod-manager_);
2. Execute the following command:
```
bash ./vortex-symlinks.sh
```

### CUSTOM WINE INSTALLATION (Currently unavailable):
First install Vortex normally through Lutris and close it after installation is finished. Then move on to the custom configuration:

We need to configure symlinks so that Vortex will be able to edit the files your game uses. Luckly for you, I've wrote a simple script which takes care of that for us:
1. Open Lutris' Vortex installation folder on a terminal (usually _/home/\<user\>/Games/vortex-mod-manager_);
2. Execute the following commands:
```
export SKYRIM_PREFIX="<custom wine installation prefix directory path>"
bash ./vortex-symlinks.sh
```
Now Vortex is already able to manage the game, but it still does not know which game that is. For that we need to allow Vortex to see where the game is installed:
1. Launch Vortex;
2. Go to _Settings > Games > Add Search Directory_;
3. Navigate to your Skyrim Special Edition installation folder;
4. Go to _Games > Scan > Scan: Full_;
5. Now you should be able to use the manager with no problems.
