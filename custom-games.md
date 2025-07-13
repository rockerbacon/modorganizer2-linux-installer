# Custom Games

Games that aren't officially supported by this project may be installed using the custom game installer.

_Note that no support will be offered for these games outside of issues with the installer itself._

In order to enable the custom game installer, run `install.sh -c` and select the **Custom Game** option. 

## Options
- **Executable** [required]: The name of the game's main executable, including the file extension.

- **App ID** [required]: The Steam App ID. 

    If you don't know what this is, it can easily be obtained by visiting the game's store page and looking at the URL. For example, **Stardew Valley**'s URL is `https://store.steampowered.com/app/413150/Stardew_Valley/`, and thus the **App ID** is `413150`.

- **Nexus ID**: The game's ID on Nexus Mods.

    If you don't know what this is, it can easily be obtained by visiting the game's mod page and looking at the URL. For example, **Stardew Valley**'s URL is `https://www.nexusmods.com/games/stardewvalley`, and thus the **Nexus ID** is `stardewvalley`.

- **Protontricks Args**: A list of system libraries to install in the game's Proton prefix, separated by spaces.

    A good place to find these is [Lutris' website](https://lutris.net) in the install scripts. Look for a section like:
    ```yaml
    installer:
    - task:
        app: arial vcrun2010 vcrun2012 vcrun2013
        name: winetricks
    ```
    and use the list from `app`; `arial vcrun2010 vcrun2012 vcrun2013`.

- **Script Extender URL**: A URL from which to download a script extender. You may have better luck installing this manually, depending on how the extender works.

- **Script Extender Files**: A list of specific files to install from the script extender, separated by spaces; _or_ `*` to install all files.
