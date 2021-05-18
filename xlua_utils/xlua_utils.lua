--[[

Main File for xlua utils
Licensed under the EUPL v1.2: https://eupl.eu/

BK, xxyyzzzz
]]
ScriptName = "Xlua Utils"
LogFileName = "z_xlua_utils_log.txt"

ACF_Folder = "" -- KEEP EMPTY
ACF_Filename = "" -- KEEP EMPTY
--[[

SUBMODULES

]]
ffi = require ("ffi") -- LuaJIT FFI module
dofile("Submodules/xlua_utils_init.lua")  -- DO NOT CHANGE ORDER
dofile("Submodules/xlua_utils_menu.lua")  -- DO NOT CHANGE ORDER

--[[

MENU TEST

]]
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name.]]
MenuItems = {
"Xlua Utils Test",  -- Menu title
" Test 1",          -- Item index: 2
"[Separator]",      -- Item index: 3
"Test 2",           -- Item index: 4
}
--[[ Test variable table for the menu items ]]
MenuVarTest = {0,true}
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function MenuCallbacks(index)
    if index == 2 then 
        if MenuVarTest[1] == 0 then MenuVarTest[1] = 1 else MenuVarTest[1] = 0 end 
    end
    if index == 4 then 
        if MenuVarTest[2] == false then MenuVarTest[2] = true else MenuVarTest[2] = false end 
    end
end

--[[ Menu watchdog that is used to check an item or change its prefix ]]
function MenuWatchdog(intable,index)
    if index == 2 then
        if MenuVarTest[1] == 0 then Menu_ChangeItemPrefix(intable,index,"Enable")
        elseif MenuVarTest[1] == 1 then Menu_ChangeItemPrefix(intable,index,"Disable") end
    end
    if index == 4 then
        if MenuVarTest[2] == false then Menu_CheckItem(index,"Deactivate") -- Menu_CheckItem must be "Activate" or "Deactivate"!
        elseif MenuVarTest[2] == true then Menu_CheckItem(index,"Activate") end
    end
end
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
    DeleteLogFile()
    LogOutput("ACF Folder: "..ACF_Folder)
    LogOutput("ACF File: "..ACF_Filename)
    Menu_Init(MenuItems)
end
-- 3: Flight crash
--[[function flight_crash() 
end]]
-- 4: Before physics
--[[function before_physics() 
end]]
-- 5: After physics
function after_physics()
    
end


PrintToConsole("Successful parse of xlua_utils.lua")
