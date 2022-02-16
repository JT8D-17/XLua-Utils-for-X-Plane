--[[

Main File for xlua utils
Licensed under the EUPL v1.2: https://eupl.eu/

BK, xxyyzzzz
]]
--[[

GLOBAL VARIABLES

]]
ScriptName = "Xlua Utils"
LogFileName = "z_xlua_utils_log.txt"

ACF_Folder = "" -- KEEP EMPTY
ACF_Filename = "" -- KEEP EMPTY
Xlua_Utils_Path = "" -- KEEP EMPTY
Xlua_Utils_PrefsFile = "" -- KEEP EMPTY 

XluaUtils_HasConfig = 0     -- Used by this script
XluaPersist_HasDrefFile = 0 -- Used by xlua_persistence.lua

XluaUtils_DebugWinID = nil -- ID of the debug window
XluaUtils_NotifyWinID = nil -- ID of the notification window
--[[

SUBMODULES

]]
ffi = require ("ffi") -- LuaJIT FFI module
dofile("Submodules/xlua_utils_init.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_preferences.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_menu.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_datarefs.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_notifications.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_debugwindow.lua")  -- CORE COMPONENT; DO NOT CHANGE ORDER
dofile("Submodules/util_persistence.lua")  -- UTILITY
dofile("Submodules/util_ncheadset.lua")  -- UTILITY
dofile("Submodules/util_misc.lua")  -- UTILITY
--dofile("aircraft_specific/config.lua")  -- Airplane-specific script
dofile("Examples/DebugWindow.lua")  -- Example script for the debug window
--[[

VARIABLES

]]
--[[ Table that contains the configuration Variables for Xlua Utils ]]
XluaUtils_Config_Vars = {
{"XLUAUTILS"},
{"DebugOutput",0},
{"DebugWindow",0},
{"DebugWindowPos",200,600,600,200}, -- left, top, right, bottom
}
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
    if Preferences_ValGet(Persistence_Config_Vars,"SaveOnExit") == 1 then Persistence_Save() end -- Check persistence save on exit status and load if necessary
    NCHeadset_Off()
    LogOutput("AIRCRAFT UNLOAD")
    Preferences_Write(XluaUtils_Config_Vars,Xlua_Utils_PrefsFile)
    Window_Destroy(XluaUtils_DebugWinID)
    Window_Destroy(XluaUtils_NotifyWinID)
    Menu_CleanUp()
end
-- 2: Flight start
function flight_start()
    ACF_Folder, ACF_Filename = GetAircraftFolder() -- ALWAYS THE FIRST ITEM!
    Xlua_Utils_Path = ACF_Folder.."plugins/xlua/scripts/xlua_utils/"
    Xlua_Utils_PrefsFile = Xlua_Utils_Path.."preferences.cfg"
    DeleteLogFile()
    Preferences_Read(Xlua_Utils_PrefsFile,XluaUtils_Config_Vars)
    LogOutput("FLIGHT START")
    LogOutput("ACF Folder: "..ACF_Folder)
    LogOutput("ACF File: "..ACF_Filename)
    LogOutput("Xlua Utils Path: "..Xlua_Utils_Path)
    NotificationWindow_Init()
    DebugWindow_Init()
    Persistence_Init() -- Initialize persistence module
    NCHeadset_Init() -- Initialize headset module
    MiscUtils_Init() -- Initialize repair module
    XluaUtils_Menu_Init()   -- Xlua Menu
    if XluaUtils_HasConfig == 1 then 
        Persistence_Menu_Init(XluaUtils_Menu_ID) -- Persistence menu
        if Preferences_ValGet(Persistence_Config_Vars,"Autoload") == 1 then run_after_time(Persistence_Load,Preferences_ValGet(Persistence_Config_Vars,"AutoloadDelay")) DisplayNotification("Waiting "..Preferences_ValGet(Persistence_Config_Vars,"AutoloadDelay").." seconds before loading persistence data..","Caution",-99) end -- Check persistence automation status and load if necessary
        Persistence_AutosaveTimerCtrl()
        NCHeadset_Menu_Init(XluaUtils_Menu_ID)
    end
    MiscUtils_Menu_Init(XluaUtils_Menu_ID)
    --run_at_interval(Main_Timer,1)
end
-- 3: Flight crash
--[[function flight_crash() 
end]]
-- 4: Before physics
--[[function before_physics() 
end]]
-- 5: After physics
--[[function after_physics()
    --XluaUtils_Menu_Watchdog(XluaUtils_Menu_Items,2)
end]]
