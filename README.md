# OARC with angel ore support

Based on http://github.com/Oarcinae/FactorioScenarioMultiplayerSpawn

## Differences from original

Embedded mods removed. You have to install RSO, BPS, ets as mods now. You don't have to modify mods, so they could be updated.

Solo spawn provide coal + 6 angel ores. Oil is not provided. Circle size is bigger.

This scenario provide no starting items (some mods in modpack may provide them). 

RSO may generate resources inside spawn. There is high chance of getting aliens inside solo spawn. 

It is intended for coop from main base.

Silo is 500 chunks away (default is 250).

Simpler installation.


## Instructions

### STEP 1

Download the zip. 

Place it in your Factorio/scenarios/... folder.

It should look something like this (for my windows steam install location):

C:\Users\user\AppData\Roaming\Factorio\scenarios\OARCwithANGEL\control.lua

### STEP 2

Go into config.lua and edit the strings to add your own server messages and other settings.



## Configuration

Look in config.lua for some controls over the different modules.  

Not all configurations have been fully tested so modify at your own risk.

If you want to change the RSO config, you should do it in rso mod.


## TODO (not sure if will ever happened)

Cleanup code.

Conver to mod (if possible).

Cleanups solo starting areas from aliens.

Add option to select other spawn after death.


## Credit

original oarc aka FactorioScenarioMultiplayer done by https://github.com/Oarcinae

RSO is not my own creation. It was done by Orzelek. I requested permission to include it in my scenario.  https://mods.factorio.com/mods/orzelek/rso-mod

Several other portions of the code (tags, frontier style rocket silo) have also been adapted from other scenario code.

Credit to 3Ra as well: https://github.com/3RaGaming/3Ra-Enhanced-Vanilla