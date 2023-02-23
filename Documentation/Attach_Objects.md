## XLuaUtils Object Attachment Utility

This document contains information about XLuaUtils' object attachment utility.

[Back to Readme.md](../README.md) 

&nbsp;

<a name="toc"></a>
### Table of Contents
1. [Principles of Operation](#1)  
2. [Known Issues](#2)
3. [Menu](#3)
4. [Profile File](#4)   

&nbsp; 

<a name="1"></a>
### 1. Functionality

The object attachment utility reads object information, consisting of object file path, object coordinates and rotation information, visibility and atttachment information from a configuration file and places them in the 3D scene. For this, X-Plane's [object instancing system](https://developer.x-plane.com/sdk/XPLMInstance/) is being used.   
Each object's position is updated every frame.    
If the object is set to be attached to the user aircraft (e.g. passengers), the object's defined position relative to the aircraft's coordinate system  is [transformed into the OpenGL coordinate system](https://forums.x-plane.org/index.php?/forums/topic/276602-solution-aircraft-coordinates-to-world-coordinates/) to properly render it on screen.   
If the object is set to be attached to the ground (e.g. ground equipment), it will stick to the position relative to the aircraft that it initially spawns at or when it becomes visible.   
Hidden objects are moved underground at the North Pole to avoid having to reload their object files from disk, which may potentially cause stuttering.   
If the profile file or the aircraft is reloaded, all presently loaded object instances will be reloaded as well. 

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="2"></a>
### 2. Known issues

- (Presently) No support for animated objects
- Gimbal lock may occur at certain aircraft rotation angles, which may cause visual oddities. The issue could be eliminated by using quaternions, but I understand those enough to implement them.

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="3"></a>
### 3. Menu

[To be documented]

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="4"></a>
### 4. Profile File

[To be documented]

&nbsp;

[Back to table of contents](#toc)

&nbsp;