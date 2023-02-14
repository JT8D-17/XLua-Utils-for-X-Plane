## Xlua Utils automixture utility

This document contains information about Xlua Utils' automixture utility.

[Back to Readme.md](../README.md) 

&nbsp;

<a name="toc"></a>
### Table of Contents
1. [Functionality/Caveats/Known Issues](#1)  
2. [Profile File](#2)   
3. [Usage](#3)   

&nbsp; 

### 1. Functionality/Caveats/Known Issues

The  "Auto Rich" and "Auto Lean" modes basically adjust the mixture until a given target air-fuel-ratio (AFR) is obtained. Since X-Plane does not calculate said air-fuel-ratio by default, a custom calculation method based on a [MSc. Thesis by E. Fantenberg](http://liu.diva-portal.org/smash/get/diva2:1259188/FULLTEXT01.pdf) for air mass flow estimation in combustion engines had to be implemented.
To obtain the FAR for each of of the aircraft's engines, air mass flow is calculated from inlet pressure (MAP), displacement, RPM, the gas constant of air and air temperature and divided by fuel flow obtained from X-Plane.    
With the current AFR continuously determined from fuel flow, X-Plane's mixture datarefs are then adjusted within a given permissible value range (to avoid accidental engine cutoff) to attempt to match the current to the target AFR.
While this method is not the most accurate one as it is very simplified and has to work within a timer loop trying to minimize the required CPU cycles while providing an accurate result, it is efficient and was easy to code (see the "Automix_MainTimer()" function in _util_automixture.lua_).   

Known Issues ...

&nbsp;

[Back to table of contents](#toc)

&nbsp;

### 2. Profile File

[To be documented]

Example _"automixture_profile.cfg"_ files for some add-on aircraft can be found in _"xlua_utils/Config Files/Automixture"_. These may be used as a starting point or template. Contributions are welcome.

&nbsp;

[Back to table of contents](#toc)

&nbsp;

### 3. Usage

[To be documented]

&nbsp;

[Back to table of contents](#toc)

&nbsp;