--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

XLUA MENU

]]
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
XluaUtils_Menu_Items = {
"XLua Utils",
"",
"Debug Output",
"Debug Window",
}
--[[ Menu variables for FFI ]]
XluaUtils_Menu_ID = nil     -- GLOBAL!
XluaUtils_Menu_Index = nil  --  GLOBAL!
local XluaUtils_Menu_Pointer = ffi.new("const char")
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function XluaUtils_Menu_Callbacks(itemref)
    for i=2,#XluaUtils_Menu_Items do
        if itemref == XluaUtils_Menu_Items[i] then
            if i == 2 then
                if XluaUtils_HasConfig == 0 then
                    Persistence_FirstRun() -- Generates config files for the persistence module
                    NCHeadset_FirstRun()   -- Generates/appends config file for the ncheadset module
                elseif XluaUtils_HasConfig == 1 then
                    Persistence_Reload() -- Reloads the persistence module
                    NCHeadset_Reload()  -- Reloads the ncheadset module
                    DebugWindow_Reload() -- Reloads the debug window module
                end
            end
            if i == 3 then
                if Preferences_ValGet(XluaUtils_Config_Vars,"DebugOutput") == 0 then Preferences_ValSet(XluaUtils_Config_Vars,"DebugOutput",1) else Preferences_ValSet(XluaUtils_Config_Vars,"DebugOutput",0) end
                Preferences_Write(XluaUtils_Config_Vars,Xlua_Utils_PrefsFile)
                DebugLogOutput("Set Xlua Utils Debug Output to "..Preferences_ValGet(XluaUtils_Config_Vars,"DebugOutput"))
            end
            if i == 4 then
                if Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindow") == 0 then Preferences_ValSet(XluaUtils_Config_Vars,"DebugWindow",1) else Preferences_ValSet(XluaUtils_Config_Vars,"DebugWindow",0) end
                DebugWindow_Toggle()
                Preferences_Write(XluaUtils_Config_Vars,Xlua_Utils_PrefsFile)
                DebugLogOutput("Set Xlua Utils Debug Window state to "..Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindow"))
            end
            XluaUtils_Menu_Watchdog(XluaUtils_Menu_Items,i)
        end
    end
end
--[[ Menu watchdog that is used to check an item or change its prefix ]]
function XluaUtils_Menu_Watchdog(intable,index)
    if index == 2 then
        if XluaUtils_HasConfig == 0 then Menu_ChangeItemPrefix(XluaUtils_Menu_ID,index,"Initialize Xlua",intable)
        elseif XluaUtils_HasConfig == 1 then Menu_ChangeItemPrefix(XluaUtils_Menu_ID,index,"Reload Xlua Preferences",intable) end
    end
    if index == 3 then
        if Preferences_ValGet(XluaUtils_Config_Vars,"DebugOutput") == 0 then Menu_CheckItem(XluaUtils_Menu_ID,index,"Deactivate") -- Menu_CheckItem must be "Activate" or "Deactivate"!
        elseif Preferences_ValGet(XluaUtils_Config_Vars,"DebugOutput") == 1 then Menu_CheckItem(XluaUtils_Menu_ID,index,"Activate") end
    end
    if index == 4 then
        if Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindow") == 0 then Menu_ChangeItemPrefix(XluaUtils_Menu_ID,index,"Open",intable)
        elseif Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindow") == 1 then Menu_ChangeItemPrefix(XluaUtils_Menu_ID,index,"Close",intable) end
    end
end
--[[ Menu initialization routine ]]
function XluaUtils_Menu_Init()
    local Menu_Indices = {}
    for i=2,#XluaUtils_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        XluaUtils_Menu_Index = XPLM.XPLMAppendMenuItem(XPLM.XPLMFindAircraftMenu(),XluaUtils_Menu_Items[1],ffi.cast("void *","None"),1)
        XluaUtils_Menu_ID = XPLM.XPLMCreateMenu(XluaUtils_Menu_Items[1],XPLM.XPLMFindAircraftMenu(),XluaUtils_Menu_Index, function(inMenuRef,inItemRef) XluaUtils_Menu_Callbacks(inItemRef) end,ffi.cast("void *",XluaUtils_Menu_Pointer))
        for i=2,#XluaUtils_Menu_Items do
            if XluaUtils_Menu_Items[i] ~= "[Separator]" then
                XluaUtils_Menu_Pointer = XluaUtils_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(XluaUtils_Menu_ID,XluaUtils_Menu_Items[i],ffi.cast("void *",XluaUtils_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(XluaUtils_Menu_ID)
            end
        end
        for i=2,#XluaUtils_Menu_Items do
            if XluaUtils_Menu_Items[i] ~= "[Separator]" then
                XluaUtils_Menu_Watchdog(XluaUtils_Menu_Items,i)
            end
        end
        LogOutput(XluaUtils_Menu_Items[1].." menu initialized!")
    end
end
