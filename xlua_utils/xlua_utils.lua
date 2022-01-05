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
--[[

SUBMODULES

]]
ffi = require ("ffi") -- LuaJIT FFI module
dofile("Submodules/xlua_utils_init.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_preferences.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_menu.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_datarefs.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_persistence.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_ncheadset.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_window.lua")  -- DO NOT CHANGE ORDER
--dofile("VSL_C47_Enhancements.lua")  -- DO NOT CHANGE ORDER
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
    DebugWindow_Destroy()
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
    DebugWindow_Init()
    Persistence_Init() -- Initialize persistence module
    NCHeadset_Init() -- Initialize headset module
    C47_Init() -- Initialize C-47 module
    XluaUtils_Menu_Init()   -- Xlua Menu
    if XluaUtils_HasConfig == 1 then 
        Persistence_Menu_Init(XluaUtils_Menu_ID) -- Persistence menu
        if Preferences_ValGet(Persistence_Config_Vars,"Autoload") == 1 then run_after_time(Persistence_Load,Preferences_ValGet(Persistence_Config_Vars,"AutoloadDelay")) end -- Check persistence automation status and load if necessary
        Persistence_AutosaveTimerCtrl()
        NCHeadset_Menu_Init(XluaUtils_Menu_ID)
    end
    C47_Menu_Init(XluaUtils_Menu_ID)
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
