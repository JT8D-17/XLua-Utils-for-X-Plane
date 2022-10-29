--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
--[[ Table that contains the configuration Variables for the NC Headset module ]]
local MyModule_Config_Vars = {
{"MyModule"},
{"MainTimerInterval",1},    -- Main timer interval, in seconds
}
--[[ List of continuously monitored datarefs used by this module ]]
local Dref_List_Cont = {
--{"Eng_CHT","sim/flightmodel2/engines/CHT_deg_C"}, -- deg C
}
--[[ List of one-shot updated datarefs used by this module ]]
local Dref_List_Once = {
}
--[[ Container table for continuously monitored datarefs, which are stored in subtables {alias,dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local MyModule_Drefs_Cont = {
"DREFS_CONT",
}
--[[ Container table for continuously monitored datarefs, which are stored in subtables {alias,dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local MyModule_Drefs_Once = {
"DREFS_ONCE",
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local MyModule_Menu_Items = {
"MyModule",           -- Menu title, index 1
"Reload Config",            -- Item index: 2
}
--[[ Menu variables for FFI ]]
local MyModule_Menu_ID = nil
local MyModule_Menu_Pointer = ffi.new("const char")
--[[ Other variables ]]

--[[

DEBUG WINDOW

]]
--[[ Adds things to the debug window ]]
function MyModule_DebugWindow_Init()

end
--[[ Updates the debug window ]]
function MyModule_DebugWindow_Update()

end
--[[

FUNCTIONS

]]
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function MyModule_Menu_Callbacks(itemref)
    for i=2,#MyModule_Menu_Items do
        if itemref == MyModule_Menu_Items[i] then
            if i == 2 then
                MyModule_Reload()
            end
            --Preferences_Write(MyModule_Config_Vars,Xlua_Utils_PrefsFile)
            MyModule_Menu_Watchdog(MyModule_Menu_Items,i)
            if DebugIsEnabled() == 1 then Debug_Reload() end
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function MyModule_Menu_Watchdog(intable,index)

end
--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function MyModule_Menu_Build(ParentMenuID)
    local Menu_Indices = {}
    for i=2,#MyModule_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,MyModule_Menu_Items[1],ffi.cast("void *","None"),1)
        MyModule_Menu_ID = XPLM.XPLMCreateMenu(MyModule_Menu_Items[1],ParentMenuID,Menu_Index,function(inMenuRef,inItemRef) MyModule_Menu_Callbacks(inItemRef) end,ffi.cast("void *",MyModule_Menu_Pointer))
        for i=2,#MyModule_Menu_Items do
            if MyModule_Menu_Items[i] ~= "[Separator]" then
                MyModule_Menu_Pointer = MyModule_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(MyModule_Menu_ID,MyModule_Menu_Items[i],ffi.cast("void *",MyModule_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(MyModule_Menu_ID)
            end
        end
        for i=2,#MyModule_Menu_Items do
            if MyModule_Menu_Items[i] ~= "[Separator]" then
                MyModule_Menu_Watchdog(MyModule_Menu_Items,i)
            end
        end
        LogOutput(MyModule_Config_Vars[1][1].." Menu initialized!")
    end
end
--[[

RUNTIME FUNCTIONS

]]
--[[ Main timer for the engine damage logic ]]
function MyModule_MainTimer()
    --if DebugIsEnabled() == 1 then MyModule_DebugWindow_Update() end
end
--[[

INITIALIZATION

]]
--[[ First start of the engine damage module ]]
function MyModule_FirstRun()
    --Preferences_Write(MyModule_Config_Vars,Xlua_Utils_PrefsFile)
    --Preferences_Read(Xlua_Utils_PrefsFile,MyModule_Config_Vars)
    --DrefTable_Read(Dref_List_Once,MyModule_Drefs_Once)
    --DrefTable_Read(Dref_List_Cont,MyModule_Drefs_Cont)
    --MyModule_Menu_Build(XluaUtils_Menu_ID)
    LogOutput(MyModule_Config_Vars[1][1]..": First Run!")
end
--[[ Initializes engine damage at every startup ]]
function MyModule_Init()
    --math.randomseed(os.time()) -- Generate random seed for random number generator
    --Preferences_Read(Xlua_Utils_PrefsFile,MyModule_Config_Vars)
    --DrefTable_Read(Dref_List_Once,MyModule_Drefs_Once)
    --DrefTable_Read(Dref_List_Cont,MyModule_Drefs_Cont)
    --Dataref_Read(MyModule_Drefs_Once,4,"All") -- Populate dataref container with currrent values
    --Dataref_Read(MyModule_Drefs_Cont,4,"All") -- Populate dataref container with currrent values
    --run_at_interval(MyModule_MainTimer,Table_ValGet(MyModule_Config_Vars,"MainTimerInterval",nil,2))
    LogOutput(MyModule_Config_Vars[1][1]..": Initialized!")
end
--[[ Reloads the Persistence configuration ]]
function MyModule_Reload()
    --Preferences_Read(Xlua_Utils_PrefsFile,MyModule_Config_Vars)
    LogOutput(MyModule_Config_Vars[1][1]..": Reloaded!")
end
