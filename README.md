# XLuaUtils for X-Plane 11

This is a collection of scripts and utilities for X-Plane's [XLua plugin](https://github.com/X-Plane/XLua), implemented as a cohesive companion utility. XLuaUtils extend XLua's capabiltities to demonstrate interaction with X-Plane's C API by means of [LuaJIT](https://luajit.org/)'s [Foreign Function Interface](https://luajit.org/ext_ffi.html) (FFI).   
It can be installed and used in any X-Plane 11 aircraft

It implements wrappers for 

&nbsp;

<a name="toc"></a>
## Table of Contents
1. [Requirements](#1.0)
2. [Installation](#2.0)
3. [Uninstallation](#3.0)
4. [Development Reference](#4.0)    
4.1 [Limitations](#4.1)   
4.2 [Global Variables and Paths](#4.2)   
4.3 [Logging](#4.3)   
4.4 [Preferences](#4.4)   
4.5 [Menus](#4.5)   
4.6 [Notifications](#4.6)   
4.7 [Paths](#4.7)   
4.8 [Dataref Handlers](#4.7)   
5. [End-User Utilities](#5.0)   
5.1 [Initialization](#5.1)   
5.2 [Persistence](#5.2)   
5.3 [Noise-Cancelling Headset](#5.3)   
5.4 [Miscellaneous Utilities](#5.4)   
6. [License](#6.0)




&nbsp;

<a name="1.0"></a>
## 1 - Requirements

- [X-Plane 11](https://www.x-plane.com/) (version 11 or higher)
- [XLua](https://github.com/X-Plane/XLua) (only works locally on aircraftl)


&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="2.0"></a>
## 2 - Installation

###2.1 Aircraft without an xlua plugin

- Copy the *"xlua"* folder from, e.g. _"X-Plane 11/Aircraft/Laminar Research/Cessna 172SP/plugins"_ into the _"plugins"_ folder of the aircraft that you wish to use XLuaUtils with.
- Delete all subfolders from the _"[Aircraft's main folder]/plugins/xlua/scripts"_ folder.
- Copy the _"xlua_utils"_ folder into _"[Aircraft's main folder]/plugins/xlua/scripts"_

###2.2 Aircraft with an xlua plugin

- Copy the _"xlua_utils"_ folder into _"[Aircraft's main folder]/plugins/xlua/scripts"_

###2.3 Post-Installation

XLuaUtils is working correctly if X-Plane's main menu bar contains a menu with the aircraft's name and an _"XLua Utils"_ submenu.

If you have no intention of using XLuaUtils for development purposes, consult [chapter 5](#5.0) of this readme to learn about the end-user oriented tools.
A quick read of [chapter 4](#4.0) is recommended nonetheless as a few bits of information may come in handy at some point.


&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="3.0"></a>
## 3 - Uninstallation

Delete the _"xlua_utils"_ folder from _"[Aircraft's main folder]/plugins/xlua/scripts/"_

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="4.0"></a>
## 4 - Development Reference

XLua Utils provides a range of useful functions to help debug code. This chapter states the core functionalities.

&nbsp;

<a name="4.1"></a>
### 4.1 Limitations

- As XLua namespaces are completely local, reading variables from other scripts is not possible.   
If you want to use any of XLuaUtils' functions in airplane related scripts, add them as a submodule at the end of the "submodules" section in `xlua_utils.lua`.

- As of now, XLuaUtils' capabilities do not encompass the full extent of X-Plane's API.

&nbsp;

<a name="4.2"></a>
### 4.2 Global Variables and Paths

XLua Utils will populate the following variables at script startup:

- `ACF_Folder`: Complete path of the folder that the .acf file of the user aircraft is located in.
- `ACF_Filename`: Name of the user aircraft's .acf file.
- `Xlua_Utils_Path`: Complete path of the XLua Utils root folder.
- `Xlua_Utils_PrefsFile`: Complete path to the XLua Utils preferences file, including filename.

These variables are available in all of XLua Utils' submodules.

&nbsp;

<a name="4.3"></a>
### 4.3 Printing and Logging

#### 4.3.1 Printing

Printing to X-Plane's developer console (and stdout) is done with     `PrintToConsole(inputstring)`, with _"inputstring"_ being the string that's to be printed.


#### 4.3.2 Logging

Xlua Utils possesses logging capabilities outside of X-Plane's _"Log.txt"_. By default, log output is written to _"xlua_utils/z_xlua_utils_log.txt"_. This file is recreated at every plugin start of xlua. All log entries are timestamped.

Writing to XLua Util's log file is achieved by `WriteToLogFile(inputstring)`, with _"inputstring"_ being the string that's to be written to the log file.

Combined printing to the developer console and writing to the log file at the same time is done with `LogOutput(inputstring)`.

#### 4.3.3 Debug-Level Logging

Infdrmation that is not necessary for day-to-day usage can be printed to the developer console and logged in XLua Util's log file with `DebugLogOutput(inputstring)`. This will only output an input string if _"Debug Output"_ has been activated in the _"XLua Utils"_ menu or the preferences file. 

&nbsp;

<a name="4.4"></a>
### 4.4 Preferences

XLua Utils can store configuration data for itself and any utility implemented as a submodule in a preferences file. This file is located in the _"xlua_utils"_ folder by default and named _"preferences.cfg"_.   
Configuring a module to use the preferences handling system and interacting with a preferences file and table is explained below.

#### 4.4.1 Preferences Table Format

Preferences information for XLua Utils or any of its submodules is stored in specifically structured Lua tables. Any submodule wishing to use the preferences system must use a table configured as per the following example:

	MyConfigTable = {
	{"EXAMPLE"}, -- A unique identifier string indicating the owner of values stored in the perferences file.
	{"MyParameter",12}, -- A subtable with a setting parameter. The first value of this table must always be a unique string identifying the parameter.
	{"MyOtherParameter",50,20,"Yes"}, -- Parameter subtables support numbers and strings, but no further subtables.
	}

#### 4.4.2 Reading/Writing From/To The Preferences File

Reading from the preferences file is done with `Preferences_Read(inputfile,outputtable)`, where _"inputfile"_ is the path to the target file (usually the `Xlua_Utils_PrefsFile` variable) and _"outputtable"_ the name of the table that parsed data is output to.   
Only lines matching the unique identifier string of _"outputtable"_ are read, the rest is ignored.

Writing to the preferences file is done with `Preferences_Write(inputtable,outputfile)`, where _"inputtable"_ the name of the table that data is read from and _"outputfile"_ is the path to the target file (usually the `Xlua_Utils_PrefsFile` variable).   
The writing process is selective, i.e. any data present in _"outputfile"_ that is not part of _"inputtable"_ is retained.


#### 4.4.3 Preference Table Interaction

Reading a value from a preferences table is done with `Preferences_ValGet(inputtable,item,subitem)`, where _"inputtable"_ is the table that preferences data is stored in, _"item"_ is the identifier string of a subtable and _"subitem"_ is the index of a value in the subtable.   
_"Subitem"_ may be omitted, which will pick the value after the identifier string (index 2).   
Using the example table above,  `Preferences_ValGet(MyConfigTable,"MyOtherParameter",4)` would return `"Yes"`.

Writing a value to a preferences table is done with `Preferences_ValSet(inputtable,item,newvalue,subitem)`, where _"inputtable"_ is the table that preferences data is stored in, _"item"_ is the identifier string of a subtable, _"newvalue"_ is the value to be written and _"subitem"_ is the index of a value in the subtable.   
Using the example table above,  `Preferences_ValSet(MyConfigTable,"MyOtherParameter","No",4)` would set the  `"Yes"` at index 4 to `"No"`.

&nbsp;

<a name="4.5"></a>
### 4.5 Menus

...

&nbsp;

<a name="4.6"></a>
### 4.6 Notifications

Notifications are handled by means of a message stack table. This table is refreshed regularly, and time-limited notifications are automatically purged from the message stack table. If the message stack table's length is zero, the notification window will close.   
Use the functions below to interact with the stack.

- `DisplayNotification(inputstring,colorkey,displaytime)`   
inputstring: An input string, e.g. "Hello"   
colorkey: Can be "Nominal" (white) or "Success" (green) or "Caution" (orange) or "Warning" (red)   
displaytime: **Positive numbers define the amount of time in seconds that a notification will display, any negative number produces a pinned notification. Each pinned notification must have a unique, numerical ID!**

- `CheckNotification(inID)`   
Returns "true" if a notification was found in the stack by its ID

- `RemoveNotification(inID)`   
Removes a notification from the stack by its ID

- `UpdateNotification(inputstring,colorkey,inID)`   
Will remove a notification from and then re-add it to the stack. Use this to refresh a notification with input string that contains a variable.

Reference: `xlua_utils/Submodules/xlua_utils_notifications.lua`

&nbsp;

<a name="4.7"></a>
### 4.7 Debug Window

...

Reference: `xlua_utils/Submodules/xlua_utils_debugwindow.lua`

&nbsp;

<a name="4.8"></a>
### 4.8 Dataref Handlers

...

Reference: `xlua_utils/Submodules/xlua_utils_datarefs.lua`

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="5.0"></a>
## 5 - End-User Utilities

<a name="5.1"></a>
### 5.1 Initialization

After a successful installation, the main X-Plane menu bar contains a menu with the aircraft's name. This menu has a submenu named _"XLua Utils"_.



&nbsp;

<a name="5.2"></a>
### 5.2 Persistence

The _"Persistence"_ submenu is available when there is a _"

...

&nbsp;

<a name="5.3"></a>
### 5.3 Noise-Cancelling Headset

...

&nbsp;

<a name="5.4"></a>
### 5.4 Miscellaneous Utilities

This menu item is always available.

- _"Repair All Damage"_ resets all 500+ of X-Plane's failure datarefs to a value of zero (from a value of six, indicating a failure). Aircraft must be standing still on the ground with all engines off in order to use this.
- _"Synchronize Baros"_, when enabled, will synchronize the pilot, co-pilot and standby barometers when either of these are adjusted.

&nbsp;

[Back to table of contents](#toc)

&nbsp;



<a name="6.0"></a>
## 6 - License

XLua Utils is licensed under the European Union Public License v1.2 (see _EUPL-1.2-license.txt_). Compatible licenses (e.g. GPLv3) are listed  in the section "Appendix" in the license file.

[Back to table of contents](#toc)