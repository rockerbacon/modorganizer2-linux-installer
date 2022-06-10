## Introduction

This project aims to make modding and playing Bethesda games on Linux as easy as possible. It does that by providing installers which automatically setup a working experience for the user.

While these installers may be available on Lutris.net, users are always recommended to use the latest stable release from this repository. The testers and maintainers of this project have little control over the content on Lutris and cannot assure that the installers available there are up to date nor that they haven't been incorrectly modified.

## Installing Mod Organizer 2

#### Requirements

You may need to manually install the following programs:

- _7z_
- _protontricks_

The following requirements should be available out-of-the-box in most systems:

- _bash_
- either _curl_ or _wget_
- _zenity_
- _protontricks-launcher_: should be available after installing `protontricks` already, if not see [this](https://github.com/Matoking/protontricks#desktop)

All requirements should be readily available in your distribution's package manager.

#### Installation steps

1. Install the game you want to play on Steam;
2. Download the the latest stable release [here](https://github.com/rockerbacon/modorganizer2-linux-installer/releases/download/4.3.0/mo2installer-4_3_0.tar.gz);
3. Extract the downloaded file;
4. Open the extracted folder in a terminal and execute `./install.sh`;
5. The installer will start and guide you through the rest of the process;
6. Run the game on Steam and Mod Organizer 2 should start;
7. Read the [post-install instructions](post-install.md) for recommended additional steps;

The installer will automatically configure game-specific workarounds and install the script extender for your game of choice. Java binaries are also made available at `C:\java` for running Proc Patchers.

**Avoid using ENBoost** with Skyrim: DXVK and Wine have their own better working memory patches, both properly enabled with this installer.

### Features

The following is a small overview of the current state of each supported game:

| GAME                   | GAMEPLAY      | SCRIPT EXTENDER           | ENB           |
| :--------------------- | :------------ | :------------------------ | :------------ |
| Fallout 3              | not tested    | not tested                | not tested    |
| Fallout 4              | working | [some plugins might not work](https://github.com/rockerbacon/lutris-skyrimse-installers/issues/32) | ENB v0.393 or older, disabling "EnablePostPassShader" might be necessary |
| Fallout New Vegas      | fullscreen only       | working | working    |
| Morrowind              | not tested    | not tested                | not tested    |
| Oblivion               | working    | [some plugins might require manual setup](https://github.com/rockerbacon/lutris-skyrimse-installers/issues/63#issuecomment-643690247)                 | not tested    |
| Skyrim                 | working       | working                   | working       |
| Skyrim Special Edition | working       | working                   | not tested |

For known bugs and necessary workarounds, please refer to the [issues page](https://github.com/rockerbacon/lutris-skyrimse-installers/issues?q=is:issue+is:open+label:bug+)

Please, help to keep this table up to date by [opening issues](https://github.com/rockerbacon/lutris-skyrimse-installers/issues/new/choose) on any successes or problems you have experienced.

## Updating Mod Organizer 2

It is highly recommended to backup your existing installation before updating.

#### From 4.0.0 and above

You can update by simply following the install instructions again.

#### From 3.1.0 and below

You can update by simply following the install instructions again.

If you have multiple instances installed, you'll need to update all of them for Nexus integration to work.

#### From 2.8.6 and below (old Lutris installer)

1. Go to where Mod Organizer was installed and rename the folder "ModOrganizer2" to "modorganizer2" (all lowercase);
2. Follow the install instructions in this readme;
3. If you have multiple instances installed, you'll need to update all of them for Nexus integration to work;

#### Notes

- The old Skyrim Special Edition and SKSE64 installers have been deprecated as the Mod Organizer 2 installer replaces both

## Installing Vortex

The Vortex installer was created before Wine had builtin support for Mod Organizer 2.

The Vortex installer does not apply any configurations to the games themselves. Make sure they are working, using Lutris or another method, before modding.

GAMES SHOULD NOT BE LAUNCHED FROM WITHIN VORTEX.

The Vortex installer is not under active development/maintenance at the moment.

To install Vortex, you first need the `vortex.yml` installer from the [latest release which included it](https://github.com/rockerbacon/modorganizer2-linux-installer/releases/tag/2.0).

You can run the installer in Lutris by clicking the 'Add Game' plus icon and selecting 'Install from a local install script' and selecting the `vortex.yml` file or with the following terminal command. Remember to change the path if the file was downloaded to another location:
```bash
lutris -i "$HOME/Downloads/vortex.yml"
```

Remember to follow all instructions during installation. If not installing the latest version of Vortex, manually disconnect from the internet when prompted during installation to prevent Vortex from trying to automatically update.

After installation, select the game you want to mod from the games tab in the app to begin managing it with Vortex. The `vortex-downloads-handler.desktop` can be used to download files directly to the mod manager and/or launch Vortex without starting Lutris. Further instructions for using the Vortex installer can be found on [older versions of this README](https://github.com/rockerbacon/lutris-skyrimse-installers/tree/0203cd1fdc9832152ae1d87c488c7492ea3ecc61).
