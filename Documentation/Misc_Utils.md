## XLuaUtils Miscellaneous Utilities

This document contains information about XLuaUtil's collection of miscellaneous small utilities.

[Back to Readme.md](../README.md) 

&nbsp;

<a name="toc"></a>
### Table of Contents
1. [Menu/Functionality](#1)   
2. [Configuration via Preferences.cfg](#2)   

&nbsp;
 
 <a name="1"></a>
### 1. Menu/Functionality

![XLuaUtils Misc Menu](Images/XLuaUtils_Misc.jpg  "XLuaUtils Misc Menu")

Menu Item|Function
-|-
Repair All Damage|This resets the value of all X-Plane's failure datarefs (>500) to zero (from a value of six, indicating a failure). Aircraft must be standing still on the ground with all engines off in order to use this. If the aircraft can not be repaired, the menu entry will read _"[Can Not Repair]"_.
Synchronize Baros|When enabled, synchronizes the pilot's, co-pilot's and standby altimeter when any of them are changed
Next Livery|Switches to the next livery for the current aircraft
Previous Livery|Switches to the previous livery for the current aircraft
Synchronize Date|Synchronizes X-Plane's day and month to the system's day and month. Does not consider the year!
Synchronize Time|Synchronizes X-Plane's local time to the system's local time

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="2"></a>
### 2. Configuration

The miscellaneous utilities can be configured in _"plugins/xlua/scripts/xluautils/preferences.cfg"_. Relevant lines:

```
MISC_UTILS,MainTimerInterval:string,1:number
MISC_UTILS,SyncBaros:string,1:number
```

Parameter|Value Range|Description
-|-|-
MainTimerInterval|> 0|Sets the refresh interval, in seconds, for the main timer used by misc utilities. Should be greater than zero.
SyncBaros|0 or 1|1: Barometer synchronization (see "Menu" above) is enabled

&nbsp;

[Back to table of contents](#toc)

&nbsp;