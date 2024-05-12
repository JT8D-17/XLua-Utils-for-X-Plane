--[[

Main File for xlua utils
Licensed under the EUPL v1.2: https://eupl.eu/

BK, 2022
]]
--[[

GLOBAL VARIABLES

]]
ScriptName = "XLuaUtils"
LogFileName = "z_xluautils_log.txt"

ACF_Folder = "" -- KEEP EMPTY, GLOBAL
ACF_Filename = "" -- KEEP EMPTY, GLOBAL
XLuaUtils_Path = "" -- KEEP EMPTY, GLOBAL
XLuaUtils_PrefsFile = "" -- KEEP EMPTY, GLOBAL
XLuaUtils_LogFile = "" -- KEEP EMPTY, GLOBAL
XP_Folder = "" -- KEEP EMPTY, GLOBAL

XLuaUtils_HasConfig = 0     -- Used by this script

--[[

SUBMODULES

]]
ffi = require("ffi") -- LuaJIT FFI module
dofile("Submodules/xluautils_core_ffi.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xluautils_core_common.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xluautils_core_mainmenu.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xluautils_core_debugging.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xluautils_core_datarefs.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xluautils_core_notifications.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/util_automixture.lua")  -- UTILITY
dofile("Submodules/util_enginedamage.lua")  -- UTILITY
dofile("Submodules/util_misc.lua")  -- UTILITY
dofile("Submodules/util_ncheadset.lua")  -- UTILITY
dofile("Submodules/util_persistence.lua")  -- UTILITY
dofile("Submodules/util_attachobjects.lua")  -- UTILITY
dofile("Submodules/util_oxygensystem.lua")  -- UTILITY
dofile("Submodules/util_sticktrim.lua")  -- UTILITY
dofile("Examples/DebugWindow.lua")  -- Example script for the debug window
--[[

TIMERS

]]
--run_after_time(Startup_Timer_Once,2) --Runs func once after delay seconds, then timer stops. 
--run_at_interval(func, interval) -- Runs func every interval seconds, starting interval seconds from the call.
--run_timer(func,10,5) -- Runs func after delay seconds, then every interval seconds after that.
--stop_timer(func) -- This ensures that func does not run again until you re­schedule it; any scheduled runs from previous calls are canceled.
--is_timer_scheduled(func) -- This returns true if the timer function will run at any time in the future. It returns false if the timer isn’t scheduled or if func has never been used as a timer. 
--[[

MODULE/UTILITY CALLBACKS

]]
--[[ Modules/Utilities are run for the very first time - called from xluautils_core_mainmenu.lua ]]
function Modules_FirstRun()
    MiscUtils_FirstRun()
    NCHeadset_FirstRun()
    OxygenSystem_FirstRun()
end
--[[ Modules/Utilities are initialized - called from xluautils_core_mainmenu.lua or below ]]
function Modules_Init()
    Main_Menu_Init()        -- Only triggers the menu watchdog
    AttachObject_Init()     -- Initialize the Attach Object module, see util_attachobjects.lua
    Automix_Init()          -- Initialize the Automixture module, see util_automixture.lua
    EngineDamage_Init()     -- Initialize the Engine Damage module, see util_enginedamage.lua
    MiscUtils_Init()        -- Initialize the Misc Utilities module, see util_misc.lua
    NCHeadset_Init()        -- Initialize the Noise-Cancelling Headset module, see util_ncheadset.lua
    OxygenSystem_Init()     -- Initialize the Oxygen System module, see util_oxygensystem.lua
    StickTrim_Init()        -- Initialize then Stick Trim module, see util_sticktrim.lua
    Persistence_Init()      -- Initialize the Persistence module, see util_persistence.lua
end
--[[ Modules/Utilities are reloaded - called from xluautils_core_mainmenu.lua ]]
function Modules_Reload()
    NCHeadset_Reload()  -- Reloads the ncheadset module
    MiscUtils_Reload()  -- Reloads the misc utilities module
    OxygenSystem_Reload() -- Reloads the oxygen system module
    Debug_Window_Reload() -- Reloads the debug window module
end
--[[ Modules/Utilities are unloaded - called from aircraft_unload() below ]]
function Modules_Unload()
    Persistence_Unload()
    NCHeadset_Off()
    Debug_Unload()
    Notify_Window_Unload()
    Main_Menu_Unload()
    AttachObject_Unload()
    Automix_Unload()
end
--[[

CUSTOM COMMANDS

]]
--[[ Custom commands from modules MUST sadly(!) be initialized here instead of in the module ]]
-- From util_persistence.lua
function CMD_Handler_Persistence_Load(phase,duration) if phase == 0 then Persistence_Load() end end
CMD_Persistence_Load = create_command("xlua/xluautils/persistence_load","XLuaUtils: Loads aircraft persistence",CMD_Handler_Persistence_Load)
function CMD_Handler_Persistence_Save(phase,duration) if phase == 0 then Persistence_Save() end end
CMD_Persistence_Save = create_command("xlua/xluautils/persistence_save","XLuaUtils: Saves aircraft persistence",CMD_Handler_Persistence_Save)
--[[ 

X-PLANE CALLBACKS

]]
-- 1: Aircraft loading
--[[function aircraft_load()
end]]
function aircraft_unload()
    LogOutput("AIRCRAFT UNLOAD DETECTED")
    Modules_Unload()
    LogOutput("SUBMODULES UNLOADED")
end
-- 2: Flight start
function flight_start()
    ACF_Folder, ACF_Filename = GetAircraftFolder() -- ALWAYS THE FIRST ITEM!
    XP_Folder = GetXPlaneFolder()
    XLuaUtils_Path = ACF_Folder.."plugins/xlua/scripts/xluautils/"
    XLuaUtils_PrefsFile = XLuaUtils_Path.."preferences.cfg"
    XLuaUtils_LogFile = XLuaUtils_Path..LogFileName
    DeleteLogFile(XLuaUtils_LogFile)
    FFI_CheckInit()
    LogOutput("FLIGHT START")
    LogOutput("ACF Folder: "..ACF_Folder)
    LogOutput("ACF File: "..ACF_Filename)
    LogOutput("XLuaUtils Path: "..XLuaUtils_Path)
    Main_Menu_Build()                   -- Build main XLua Utils menu, see xluautils_core_mainmenu.lua
    Debug_Init()                        -- Initialize debug module, see xluautils_core_debugging.lua
    Debug_Menu_Build(XLuaUtils_Menu_ID) -- Build debugging menu, see xluautils_core_debugging.lua
    Notify_Window_Build()               -- Build notification window, see xluautils_core_notifications.lua
    Debug_Window_Build()                -- Build debugging window, see xluautils_core_debugging.lua
    Modules_Init()                      -- Initialize modules, see above
    if DebugIsEnabled() == 1 then Debug_Start() end -- Starts debugging, see below
end
-- 3: Flight crash
--[[function flight_crash() 
end]]
-- 4: Before physics
--[[function before_physics() 
end]]
-- 5: After physics
--[[function after_physics()
    --XLuaUtils_Menu_Watchdog(XLuaUtils_Menu_Items,2)
end]]
--[[

DEBUGGING

]]
-- Register the items that need to be done when debugging is turned on
function Debug_Start()
    Example_DebugWindow_Init()      -- Debug test strings, see Examples/DebugWindow.lua
    Automix_DebugWindow_Init()      -- Debug strings for the Automixture module, see util_automixture.lua
    EngineDamage_DebugWindow_Init() -- Debug strings for the Engine Damage module, see util_enginedamage.lua
end
-- Register the items that need to be done when debugging is turned off
function Debug_Stop()
    Debug_Window_ClearAll()
end
-- Register the items that need to be done when debugging is restarted
function Debug_Reload()
    Debug_Stop()
    Debug_Start()
end
