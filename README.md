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

All requirements should be readily available in your distribution's package manager.

#### Installation steps

1. Install the game you want to play. Prefer to get your games directly from Steam as that is the most tested use case;
2. Download the source code of the latest stable release [here](https://github.com/rockerbacon/lutris-skyrimse-installers/releases);
3. Extract the downloaded file;
4. Open the extracted folder in a terminal and execute `./install.sh`;
5. The installer will start and guide you through the rest of the process;

The installer will automatically configure game-specific workarounds and install the script extender for your game of choice. Java binaries are also made available at `C:\java` for running Proc Patchers.

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

You can update by simply following the install instructions again. It is recommended to backup your existing installation before updating.

## Installing Vortex

The Vortex installer was created before Wine had builtin support for Mod Organizer 2. It should only be used for games which Mod Organizer 2 does not support.

The Vortex installer does not apply any configurations to the games themselves. Make sure they are working, using Lutris or another method, before modding. GAMES SHOULD NOT BE LAUNCHED FROM WITHIN VORTEX.

The Vortex installer is not under active development/maintenance at the moment.

To install Vortex, you first need the `vortex.yml` installer from the [latest release which included it](https://github.com/rockerbacon/lutris-skyrimse-installers/releases/tag/1.9.3).

You can use the installer with the following terminal command, remember to change the path if the file was downloaded to another location:
```bash
lutris -i "$HOME/Downloads/vortex.yml"
```

Remember to follow all instructions during installation, some manual steps are required for Vortex to work properly.

After installing Vortex and following all instructions, manually add the game you want to mod.

#### Notes

- The old Skyrim Special Edition and SKSE64 installers have been deprecated as the Mod Organizer 2 installer replaces both
- Advanced instructions for using Vortex can be found on [older versions of this README](https://github.com/rockerbacon/lutris-skyrimse-installers/tree/0203cd1fdc9832152ae1d87c488c7492ea3ecc61). They were removed since they are only applicable to games supported by the Mod Organizer 2 installer
