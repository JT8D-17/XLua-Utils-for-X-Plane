## XLuaUtils Miscellaneous Utilities

This document contains information about XLuaUtil's collection of miscellaneous small utilities.

[Back to Readme.md](../README.md) 

&nbsp;

<a name="toc"></a>
### Table of Contents
1. [Menu/Functionality](#1)   
2. [General Configuration](#2)   
3. [Power Monitor](#3)   

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
Power Monitor|Outputs engine power data to the notification window 

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="2"></a>
### 2. General Configuration

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

<a name="3"></a>
### 3. Power Monitor

The Power Monitor is very much inspired by the one in [SimCoders' Reality Expansion Packs](https://www.simcoders.com/reality-expansion-pack/overview/). it offers a possibility to monitor relevant engine parameters without having to enable XP's data outputs or looking at the instruments.  

&nbsp;

#### 3.1 Features

Power Monitor offers the following outputs, per engine:

- Engine power as a percentage
- Optional: Scaled engine power (in case it is required)
- Engine horsepower
- Engine RPM
- Engine manifold pressure
- Cylinder head temperature (CHT)
- Fuel flow in various units (see below), but always per hour

&nbsp;

#### 3.2 Limitations

- At the moment, Power Monitor is only configured for reciprocating engines
- Guessing the temperature units from the ACF file, while possible, is not something I wish to implement (at the moment), so both units (°C/°F) are displayed at any time, with the user required to figure out which one X-Plane uses (hint open the aircraft in PlaneMaker and then look in the "Standard" --> "Systems" --> "Limits 1/2" menu).

&nbsp;

#### 3.3 Usage

Toggle Power Monitor on/off with the _"Power Monitor"_ menu item.

Power Monitor will check X-Plane's main throttle, mixture and prop lever input datarefs for changes and then display the engine parameters listed above for each running engine in a notification window. If no change from these levers has been determined for 5 seconds or if the engine produces negative power during deceleration, the notification window will close itself again.   
However, it is also possible to have it open permanently as long as the engine produces positive power (see below).


&nbsp;
 
#### 3.3 Configuration

Power Monitor can only be configured in _"plugins/xlua/scripts/xluautils/preferences.cfg"_. Relevant lines:

```
MISC_UTILS,PowerMonitor:string,1:number
MISC_UTILS,PowerMonitorDisplayTime:string,5:number
MISC_UTILS,PowerMonitorScalar:string,1.0:number
MISC_UTILS,PowerMonitorInputChange:string,0.005:number
MISC_UTILS,PowerMonitorFuelUnit:string,kg:string
```

Parameter|Value Range|Description
-|-|-
PowerMonitor|0 or 1|1: Power Monitor is enabled.
PowerMonitorDisplayTime|<1 or >1|>1: The Power Monitor notification will stay visible for this amount of time after no throttle, mixture or prop change has been detected.<br><1: The Power Monitor notification is permanently open as long as the engine produces positive power.  
PowerMonitorScalar|<1.0 or >1.0|Enables a scaled output of the engine power percentage when smaller or greater than 1.0. May be useful in some scenarios.
PowerMonitorInputChange|0 to 1|The delta that the throttle, mixture or power lever must move in order to trigger the Power Monitor notification.
PowerMonitorFuelUnit|kg<br>lbs<br>gal_avgas<br>gal_jet-a<br>l_avgas<br>l_jet-a|Outputs the fuel flow in the specified format.<br>Fuel flow is always [unit] per hour.<br>Conversion factors: 2.20462 lbs/kg, Avgas: 5.87 lbs/gal (per X-Plane) and 0.719 kg/l, Jet-A: 6.66 lbs/gal and 0.796 kg/l.

&nbsp;

Changed parameters can be reloaded in X-Plane from the "XLuaUtils" menu with _"Reload XLuaUtils Preferences"_.

&nbsp;

[Back to table of contents](#toc)

&nbsp;