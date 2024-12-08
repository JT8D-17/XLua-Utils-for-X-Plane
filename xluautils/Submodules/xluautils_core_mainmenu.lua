--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
XLuaUtils_Menu_Index = nil  --  GLOBAL!
XLuaUtils_Menu_ID = nil     -- GLOBAL!
local XLuaUtils_Menu_Pointer = ffi.new("const char")
--[[ Table for main menu items ]]
local Main_Menu_Items = {
"XLuaUtils",
"",
}
--[[ Main Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function Main_Menu_Callbacks(itemref)
    for i=2,#Main_Menu_Items do
        if itemref == Main_Menu_Items[i] then
            if i == 2 then
                if XLuaUtils_HasConfig == 0 then
                    DebugLogOutput("FIRST TIME INITIALIZATION START")
                    Modules_FirstRun()
                    if FileExists(XLuaUtils_PrefsFile) then XLuaUtils_HasConfig = 1 end
                    Modules_Init()
                    DisplayNotification("XLuaUtils Initialization Complete","Nominal",5)
                    DebugLogOutput("FIRST TIME INITIALIZATION END")
                elseif XLuaUtils_HasConfig == 1 then
                    DebugLogOutput("SUBMODULES RELOAD START")
                    Modules_Reload()
                    DisplayNotification("XLuaUtils Submodules Reloaded","Nominal",5)
                    DebugLogOutput("SUBMODULES RELOAD END")
                end
            end
            Main_Menu_Watchdog(Main_Menu_Items,i)
        end
    end
end
--[[ Menu watchdog that is used to check an item or change its prefix ]]
function Main_Menu_Watchdog(intable,index)
    if index == 2 then
        if XLuaUtils_HasConfig == 0 then Menu_ChangeItemPrefix(XLuaUtils_Menu_ID,index,"Initialize XLuaUtils",intable)
        elseif XLuaUtils_HasConfig == 1 then Menu_ChangeItemPrefix(XLuaUtils_Menu_ID,index,"Reload XLuaUtils Preferences",intable) end
    end
end
--[[ Build logic for the main menu ]]
function Main_Menu_Build()
    local Menu_Indices = {}
    for i=2,#Main_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        XLuaUtils_Menu_Index = XPLM.XPLMAppendMenuItem(XPLM.XPLMFindAircraftMenu(),Main_Menu_Items[1],ffi.cast("void *","None"),1)
        XLuaUtils_Menu_ID = XPLM.XPLMCreateMenu(Main_Menu_Items[1],XPLM.XPLMFindAircraftMenu(),XLuaUtils_Menu_Index,function(inMenuRef,inItemRef) Main_Menu_Callbacks(inItemRef) end,ffi.cast("void *",XLuaUtils_Menu_Pointer))
        for i=2,#Main_Menu_Items do
            if Main_Menu_Items[i] ~= "[Separator]" then
                XLuaUtils_Menu_Pointer = Main_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(XLuaUtils_Menu_ID,Main_Menu_Items[i],ffi.cast("void *",XLuaUtils_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(XLuaUtils_Menu_ID)
            end
        end
        for i=2,#Main_Menu_Items do
            if Main_Menu_Items[i] ~= "[Separator]" then
                Main_Menu_Watchdog(Main_Menu_Items,i)
            end
        end
        DebugLogOutput("XLua Utils main menu initialized!")
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
    Menu_CleanUp(XLuaUtils_Menu_ID,XLuaUtils_Menu_Index)
    --Preferences_Write(XLuaUtils_Menu_Vars,XLuaUtils_PrefsFile)
end
