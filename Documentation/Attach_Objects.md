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

The object attachment utility reads object information, consisting of object file path, object coordinates and rotation information, visibility and attachment information from a configuration file and places them in the 3D scene. For this, X-Plane's [object instancing system](https://developer.x-plane.com/sdk/XPLMInstance/) is being used.   
Each object's position is updated every frame.    
If the object is set to be attached to the user aircraft (e.g. external loads), the object's defined position relative to the aircraft's coordinate system  is [transformed into the OpenGL coordinate system](https://forums.x-plane.org/index.php?/forums/topic/276602-solution-aircraft-coordinates-to-world-coordinates/) to properly render it on screen.   
If the object is set to be attached to the ground (e.g. ground equipment), it will stick to the position relative to the aircraft that it initially spawns at or when it becomes visible.   
Hidden objects are moved underground at the North Pole to avoid having to reload their object files from disk, which may potentially cause stuttering.   
If the profile file or the aircraft is reloaded, all presently loaded object instances will be reloaded as well. 

&nbsp;

[Back to table of contents](#toc)

&nbsp;

<a name="2"></a>
### 2. Caveats/Drawbacks

- There is (presently) no support for object animations via datarefs.
- There is no possibility to set the shading for instance objects to "internal", so **any object placed inside an aircraft will not be lit correctly**! Therefore, only use "Attach Objects" for **external objects** if you wish to minimize visual glitches.
- Using asynchronous loading via XPLMLoadObjectAsync, I did not manage to reliably return an object reference (XPLMObjectRef), which is required to place and move the object instance. Therefore, I'm using XPLMLoadObject instead, which momentarily takes control of X-Plane and thus *may* cause short stuttering and hanging when a large amount of objects is loaded from a slow disk drive. However, this will occur during aircraft (re)load and should not impact flying.
- Gimbal lock may occur at certain aircraft rotation angles, which may cause visual oddities. The issue could be eliminated by using quaternions, but I do not understand those enough to implement them.

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

#### 3.1 File Information

An attached objects profile file is stored in _"[Aircraft folder]/plugins/xlua/scripts/xluautils/Submodules/attached_objs.cfg"_.   
This file is generated when "Attached Objects" is initialized and its file header contains information regarding line structuring and more.

&nbsp;

#### 3.2 Parameter Lines 

Each object requires its own line. Depending on some parameters, these lines can become quite long. Line values are explained in the _attached_objs.cfg_ header or in the table below:


	GPU_Obj,XP_Folder,Resources/default scenery/airport scenery/Dynamic_Vehicles/GPU.obj,8,0,5,0,240,0,sim/cockpit/electrical/gpu_on,skip,eq,1,1


|Value Index|Value|Description|
|-|-|-|
|1|[anything]|Object alias. Can be anything, but should be short and to the point, unique and not use spaces or any special signs|
|2|ACF_Folder or XP_Folder|The parent folder of this object. "ACF_Folder" will use the aircraft folder, "XP_Folder" will use X-Plane's root folder.
|3|[path]|The path to the object file from its parent folder|
|4|[numerical]|X (lateral) axis position relative to the aircraft's origin. Positive value: Direction of the right wing|
|5|[numerical]|Y (vertical) axis position relative to the aircraft's origin. Positive value: Up|
|6|[numerical]|Z (longitudinal) axis position relative to the aircraft's origin.    Positive value: Aft (toward tail)|
|7|[numerical]|X (lateral) axis rotation relative to the aircraft's origin. Positive value: Toward tail, when seen from the side|
|8|[numerical]|Y (vertical) axis rotation relative to the aircraft's origin. Positive value: Clockwise, when seen from top|
|9|[numerical]|Z (longitudinal) axis rotation relative to the aircraft's origin. Positive value: Right, when seen from the tail|
|10|[dataref]|The dataref that is used for controlling this object's visibility. Find it with [DataRefTool](https://datareftool.com/) or in [X-Plane folder]/Resources/plugins/datarefs.txt|
|11|[numerical] or "skip"|If the dataref is an array type (has more than 1 member), provide the index of the dataref's member here. E.g. when trying to use "sim/flightmodel2/engines/engine_is_burning_fuel[2]", this value here would be "2". Use "skip" if the dataref is not an array|
|12|"gt" or "lt" or "eq"|Comparison operator for the dataref. "gt" = "greater than", "lt" = "lower than", "eq" = equal|
|13|[numerical]|Value the dataref is compared against. In the provided example, the GPU object is displayed when "sim/cockpit/electrical/gpu_on" equals 1|
|14|0 or 1|Flag that determines if the object is to stick to the ground. Objects that stick to the ground will *not* move with the airplane! 1 = Stick to ground|

&nbsp;

[Back to table of contents](#toc)

&nbsp;