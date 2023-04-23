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
UtilPersist_HasDrefFile = 0 -- Used by util_persistence.lua

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

X-PLANE WRAPPERS

]]
-- 1: Aircraft loading
--[[function aircraft_load()
end]]
function aircraft_unload()
    Persistence_Unload()
    NCHeadset_Off()
    LogOutput("AIRCRAFT UNLOAD")
    Debug_Unload()
    Notify_Window_Unload()
    Main_Menu_Unload()
    AttachObject_Unload()
    Automix_Unload()
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
    Main_Menu_Build() -- Build main XLua Utils menu
    Debug_Init() -- Initialize debug module
    Notify_Window_Build() -- Build notification window
    Debug_Window_Build() -- Build debug window
    Persistence_Init() -- Initialize persistence module
    NCHeadset_Init() -- Initialize headset module
    MiscUtils_Init() -- Initialize misc utilities
    Automix_Init() -- Initialize automixture
    EngineDamage_Init() -- Initialize engine damage
    AttachObject_Init() -- Initialize object attachments
    Debug_Menu_Build(XLuaUtils_Menu_ID)
    if XLuaUtils_HasConfig == 1 then
        Main_Menu_Init() -- Only triggers the menu watchdog
        Persistence_Menu_Build(XLuaUtils_Menu_ID) -- Persistence menu
        Persistence_Autoload()
        Persistence_AutosaveTimerCtrl()
        NCHeadset_Menu_Build(XLuaUtils_Menu_ID)
        Automix_Menu_Register(XLuaUtils_Menu_ID) -- Registers the automixture menu
        EngineDamage_Menu_Build(XLuaUtils_Menu_ID)
        AttachObject_Menu_Build(XLuaUtils_Menu_ID)
    end
    MiscUtils_Menu_Build(XLuaUtils_Menu_ID)
    if DebugIsEnabled() == 1 then Debug_Start() end
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
    Example_DebugWindow_Init()
    Automix_DebugWindow_Init()
    EngineDamage_DebugWindow_Init()
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