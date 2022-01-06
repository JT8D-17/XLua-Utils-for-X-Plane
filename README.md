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
4.2 [Paths](#4.2)   
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
### 4.2 Paths

...

&nbsp;

<a name="4.3"></a>
### 4.3 Logging

...

&nbsp;

<a name="4.4"></a>
### 4.4 Preferences

...

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

...

&nbsp;

<a name="5.2"></a>
### 5.2 Persistence

...

&nbsp;

<a name="5.3"></a>
### 5.3 Noise-Cancelling Headset

...

&nbsp;

[Back to table of contents](#toc)

&nbsp;



<a name="6.0"></a>
## 6 - License

XLua Utils is licensed under the European Union Public License v1.2 (see _EUPL-1.2-license.txt_). Compatible licenses (e.g. GPLv3) are listed  in the section "Appendix" in the license file.

[Back to table of contents](#toc)