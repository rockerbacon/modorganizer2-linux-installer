# Uninstalling Mod Organizer 2

Removal of Mod Organizer 2 is a simple process.

1. Delete your Mod Organizer 2 instance from wherever you chose to install it. 
2. In the game's folder (`{SteamLibrary}/steamapps/common/{game}`), delete the `modorganizer2` folder.<br/>
   Remove the underscore from the game launcher and overwrite (i.e. rename `_Fallout4Launcher.exe` to `Fallout4Launcher.exe`)<br/>
   Additionally, remove any additional script extender files that were installed.
3. Move to the `steamapps` folder, and open `compatdata`.<br/>
   Find the folder that matches the App ID of the game you're removing Mod Organizer from.<br/>
   Either:<br/>
   - Delete the folder.
   - Restore the archived folder from when you installed (`{AppID}.{DateTime}`)
4. Remove the `$HOME/.local/share/modorganizer2` folder
5. Remove `modorganizer2-nxm-handler.desktop` from `$HOME/.local/share/applications`

### Methods to find the App ID of your game:
- In Steam, right click the game and choose 'Properties', then choose the 'Updates' tab. The App ID will be listed at the bottom.
- Open `protontricks`. The App ID will be listed after the name of your game.
- Go to the game's Steam store page. The App ID will be in the URL.