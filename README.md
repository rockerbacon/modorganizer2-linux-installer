# lutris-skyrimse-installers
Installers to make Skyrim Special Edition plug and play on Lutris

## Vortex

Plug and play installation, everything configured out of the box for usage with Skyrim Special Edition from Steam Play or Lutris Winesteam. Can also be used on a custom Wine Skyrim Special Edition installation with a few manual steps (see technical notes on lutris.net)

### KNOWN BUGS/LIMITATIONS:
- You cannot safely launch apps from within Vortex as its prefix is not configured to run other apps;
- Although profiles work for plugins and configs they will not work for saves;
- It was written to work with Winesteam but only Steam Play was tested. Please notify any problems.

### CUSTOM WINE INSTALLATION:
1. Install normally with Lutris;
2. Close Vortex;
3. Open Lutris' Vortex installation folder on a terminal (usually _/home/\<user\>/Games/vortex-mod-manager_);
4. Execute the following commands:
```
export SKYRIM_PREFIX="<custom wine installation prefix directory path>"
bash ./setup-symlinks.sh
```
5. Launch Vortex;
6. Go to _Settings > Games > Add Search Directory_;
7. Navigate to your Skyrim Special Edition installation folder;
8. Go to _Games > Scan > Scan: Full_;
9. Now you should be able to use the manager with no problems.
