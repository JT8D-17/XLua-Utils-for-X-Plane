# XLuaUtils for X-Plane 12 (and maybe still 11)

XLuaUtils is a collection of scripts for X-Plane's [XLua plugin](https://github.com/X-Plane/XLua) that can be installed and used in any aircraft for X-Plane 12 (and maybe still 11).    
End-users get a collection of handy utilities that facilitate or enhance the operation of aircraft in X-Plane, such as persistence, oxygen, headset and engine damage systems (plus various smaller items).    
Developers get a collection of wrappers and an API to add their own utilities to the XLuaUtils environment.    
As XLuaUtils makes heavy use of [LuaJIT](https://luajit.org/)'s [Foreign Function Interface](https://luajit.org/ext_ffi.html) (FFI) to access X-Plane's SDK library (written in C), it also serves as a demonstration for acessing C code from xlua.

&nbsp;

<a name="toc"></a>
## Table of Contents
1. [Features](#1.0)
1. [Requirements](#2.0)
1. [Installation](#3.0)
1. [Uninstallation](#4.0)
1. [License](#5.0)

&nbsp;

<a name="1.0"></a>
## 1 - Features

XLuaUtils brings a variety of features for both developers and end-users. Consult the manual (_xluautils_manual.odt/pdf_).

&nbsp;

### 1.1 For end users
- A persistence utility that can be used to save the aircraft's state across X-Plane sessions.
- An engine damage utility will add consequences to exceeding operational limitations.
- An oxygen system that does not require editing the aircraft's _.acf_ file in Plane Maker or that can override a present system. Also provides warnings about pilot hypoxia.
- A noise-cancelling headset utility that decreases the levels of all sounds but those that are relevant to communication (as a real headset would). It can be automated to only be on in interior views with the engines running.
- Various smaller utilities like instant damage repair, snychronization between pilot, copilot and standby barometers, livery changing, date and time synchronization and a power monitor. 

See the chapter "Utilities" in the manual.

&nbsp;

### 1.2 For developers

- Expanded logging capabilities.
- Utility configuration tables.
- A centralized preferences management system.
- A custom window with multi-page support that handles utility nofifications or text.
- A centralized window to serve as parent for utilities.
- Custom handlers for datarefs stored in lists.

See the chapter "XLuaUtils Developer Reference" in the manual.

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="2.0"></a>
## 2 - Requirements

- [X-Plane](https://www.x-plane.com/)  (preferably version 12, I can not guarantee that XLuaUtils still works in X-Plane 11)
- [XLua](https://github.com/X-Plane/XLua) (1.0 or higher)

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="3.0"></a>
## 3 - Installation

### 3.1 Aircraft without an XLua plugin

- Download the latest [xlua release](https://github.com/X-Plane/XLua/releases), unzip the archive and copy the *"xlua"* folder into the _"plugins"_ folder of the aircraft that you wish to use XLuaUtils to.
- Delete all subfolders from the _"[Aircraft's main folder]/plugins/xlua/scripts"_ folder.
- Copy the _"xluautils"_ folder into _"[Aircraft's main folder]/plugins/xlua/scripts"._

&nbsp;

### 3.2 Aircraft with an XLua plugin

- Copy the _"xluautils"_ folder into _"[Aircraft's main folder]/plugins/xlua/scripts"._

&nbsp;

### 3.3 Post-installation

XLuaUtils is working correctly if X-Plane's main menu bar contains a menu with the aircraft's name and an _"XLuaUtils"_ submenu. See the chapter "Initialization / Main Menu" in the manual.

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="4.0"></a>
## 4 - Uninstallation

Delete the _"xluautils"_ folder from _"[Aircraft's main folder]/plugins/xlua/scripts/"_

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="5.0"></a>
## 5 - License

XLuaUtils is licensed under the European Union Public License v1.2 (see _EUPL-1.2-license.txt_). Compatible licenses (e.g. GPLv3) are listed  in the section "Appendix" in the license file.

[Back to table of contents](#toc)
