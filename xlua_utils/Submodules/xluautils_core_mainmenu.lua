--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
XluaUtils_Menu_Index = nil  --  GLOBAL!
XluaUtils_Menu_ID = nil     -- GLOBAL!
local XluaUtils_Menu_Pointer = ffi.new("const char")
--[[ Table for main menu items ]]
local Main_Menu_Items = {
"XLua Utils",
"",
}
--[[ Main Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function Main_Menu_Callbacks(itemref)
    for i=2,#Main_Menu_Items do
        if itemref == Main_Menu_Items[i] then
            if i == 2 then
                if XluaUtils_HasConfig == 0 then
                    LogOutput("FIRST TIME INITIALIZATION START")
                    Persistence_FirstRun() -- Generates config files for the persistence module
                    NCHeadset_FirstRun()   -- Generates/appends config file for the ncheadset module
                    EngineDamage_FirstRun() -- Generates/appends config file for the engine damage module
                    LogOutput("FIRST TIME INITIALIZATION END")
                elseif XluaUtils_HasConfig == 1 then
                    LogOutput("SUBMODULE RELOAD START")
                    Persistence_Reload() -- Reloads the persistence module
                    NCHeadset_Reload()  -- Reloads the ncheadset module
                    EngineDamage_Reload() -- Reloads the engine damage module
                    Debug_Window_Reload() -- Reloads the debug window module
                    LogOutput("SUBMODULE RELOAD END")
                end
            end
            Main_Menu_Watchdog(Main_Menu_Items,i)
        end
    end
end
--[[ Menu watchdog that is used to check an item or change its prefix ]]
function Main_Menu_Watchdog(intable,index)
    if index == 2 then
        if XluaUtils_HasConfig == 0 then Menu_ChangeItemPrefix(XluaUtils_Menu_ID,index,"Initialize XLua Utils",intable)
        elseif XluaUtils_HasConfig == 1 then Menu_ChangeItemPrefix(XluaUtils_Menu_ID,index,"Reload XLua Utils Preferences",intable) end
    end
end
--[[ Build logic for the main menu ]]
function Main_Menu_Build()
    local Menu_Indices = {}
    for i=2,#Main_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        XluaUtils_Menu_Index = XPLM.XPLMAppendMenuItem(XPLM.XPLMFindAircraftMenu(),Main_Menu_Items[1],ffi.cast("void *","None"),1)
        XluaUtils_Menu_ID = XPLM.XPLMCreateMenu(Main_Menu_Items[1],XPLM.XPLMFindAircraftMenu(),XluaUtils_Menu_Index,function(inMenuRef,inItemRef) Main_Menu_Callbacks(inItemRef) end,ffi.cast("void *",XluaUtils_Menu_Pointer))
        for i=2,#Main_Menu_Items do
            if Main_Menu_Items[i] ~= "[Separator]" then
                XluaUtils_Menu_Pointer = Main_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(XluaUtils_Menu_ID,Main_Menu_Items[i],ffi.cast("void *",XluaUtils_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(XluaUtils_Menu_ID)
            end
        end
        for i=2,#Main_Menu_Items do
            if Main_Menu_Items[i] ~= "[Separator]" then
                Main_Menu_Watchdog(Main_Menu_Items,i)
            end
        end
        LogOutput("Xlua Utils main menu initialized!")
    end
end
--[[

INITIALIZATION

]]
--[[ Initializes the debug module at every startup ]]
function Main_Menu_Init()
    Main_Menu_Watchdog(Main_Menu_Items,2)
end
--[[ Unload logic for the main menu ]]
function Main_Menu_Unload()
    Menu_CleanUp(XluaUtils_Menu_ID,XluaUtils_Menu_Index)
    --Preferences_Write(XluaUtils_Menu_Vars,Xlua_Utils_PrefsFile)
end
