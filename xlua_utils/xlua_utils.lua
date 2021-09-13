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

XluaPersist_HasConfig = 0
XluaPersist_HasDrefFile = 0

--[[

SUBMODULES

]]
ffi = require ("ffi") -- LuaJIT FFI module
dofile("Submodules/xlua_utils_init.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_preferences.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_menu.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_datarefs.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_persistence.lua")  -- DO NOT CHANGE ORDER
--dofile("Submodules/Persistence_Menu.lua")  -- DO NOT CHANGE ORDER

local function timer_test()
     LogOutput(os.clock())
end
--run_timer(timer_test,10,5)
--[[ 

X-PLANE WRAPPERS

]]
-- 1: Aircraft loading
--[[function aircraft_load()
end]]
function aircraft_unload()
    PrintToConsole("Status: UNLOADING")
    Menu_CleanUp()
end
-- 2: Flight start
function flight_start()
    ACF_Folder, ACF_Filename = GetAircraftFolder() -- ALWAYS THE FIRST ITEM!
    Xlua_Utils_Path = ACF_Folder.."plugins/xlua/scripts/xlua_utils/"
    Xlua_Utils_PrefsFile = Xlua_Utils_Path.."preferences.cfg"
    DeleteLogFile()
    LogOutput("ACF Folder: "..ACF_Folder)
    LogOutput("ACF File: "..ACF_Filename)
    LogOutput("Xlua Utils Path: "..Xlua_Utils_Path)
    Preferences_Read(Xlua_Utils_PrefsFile,Persistence_Config_Vars)
    Persistence_DrefFile_Read(Xlua_Utils_Path.."datarefs.cfg")
    XluaUtils_Menu_Init()
    if XluaPersist_HasConfig == 1 then Persistence_Menu_Init(XluaUtils_Menu_ID) end
    Dataref_Read("All")
end
-- 3: Flight crash
--[[function flight_crash() 
end]]
-- 4: Before physics
--[[function before_physics() 
end]]
-- 5: After physics
function after_physics()
    --XluaUtils_Menu_Watchdog(XluaUtils_Menu_Items,2)
end


PrintToConsole("Successful parse of xlua_utils.lua")
