--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
--[[ Table that contains the configuration Variables for the NC Headset module ]]
NCHeadset_Config_Vars = {
{"NCHeadset"},
{"Automation",0},
{"HeadsetOn",0},
{"NoiseCancelLevel",0.5},
{"NoiseCancelLevelDelta",0.1},
}
--[[ List of Datarefs used by this module ]]
local Dref_List = {
"sim/operation/sound/inside_any",
"sim/operation/sound/engine_volume_ratio",
"sim/operation/sound/enviro_volume_ratio",
"sim/operation/sound/exterior_volume_ratio",
"sim/operation/sound/fan_volume_ratio",
"sim/operation/sound/interior_volume_ratio",
"sim/operation/sound/warning_volume_ratio",
"sim/operation/sound/weather_volume_ratio",
}
--[[ Container Table for the Datarefs to be monitored. Datarefs are stored in subtables {dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
NCHeadset_Datarefs = {
"DATAREF",
}
--[[

FUNCTIONS

]]
--[[

INITIALIZATION

]]
--[[ First start of the NCHeadset module ]]
function NCHeadset_FirstRun()
    Preferences_Write(NCHeadset_Config_Vars,Xlua_Utils_PrefsFile)
    Preferences_Read(Xlua_Utils_PrefsFile,NCHeadset_Config_Vars)
    NCHeadset_Menu_Init(XluaUtils_Menu_ID)
end
--[[ Initializes NCHeadset at every startup ]]
function NCHeadset_Init()
    Preferences_Read(Xlua_Utils_PrefsFile,NCHeadset_Config_Vars)
    --Dataref_Read("All")
end
--[[ Reloads the Persistence configuration ]]
function NCHeadset_Reload()
    NCHeadset_Init()
    NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,8)
    --NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,12)
end
--[[ Autoloads the saved NCHeadset values ]]
--function Persistence_Load()
--    Persistence_SaveFile_Read(Xlua_Utils_Path..Persistence_SaveFile,Persistence_Datarefs)
--    Dataref_Write("All")
--    LogOutput("Loaded Persistence Data at "..os.date("%X").." h")
--end
--[[ Autosaves the curent NCHeadset values ]]
--function Persistence_Save()
    --Dataref_Read("All")
    --Persistence_SaveFile_Write(Xlua_Utils_Path..Persistence_SaveFile,Persistence_Datarefs)
    --LogOutput("Saved Persistence Data at "..os.date("%X").." h")
--end
--[[

MENU

]]
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
NCHeadset_Menu_Items = {
"NC Headset",               -- Menu title, index 1
"Headset",                  -- Item index: 2
"Automation",               -- Item index: 3
"[Separator]",              -- Item index: 4
"Increment Muffling (+ "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",   -- Item index: 5
"Noise Level: "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") * 100).." %",       -- Item index: 6
"Decrement Muffling (- "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",   -- Item index: 7
}
--[[ Menu variables for FFI ]]
NCHeadset_Menu_ID = nil
NCHeadset_Menu_Pointer = ffi.new("const char")
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function NCHeadset_Menu_Callbacks(itemref)
    for i=2,#NCHeadset_Menu_Items do
        if itemref == NCHeadset_Menu_Items[i] then
            if i == 2 then
                
            end
            if i == 3 then
                if Preferences_ValGet(NCHeadset_Config_Vars,"Automation") == 0 then Preferences_ValSet(NCHeadset_Config_Vars,"Automation",1) else Preferences_ValSet(NCHeadset_Config_Vars,"Automation",0) end
                Preferences_Write(NCHeadset_Config_Vars,Xlua_Utils_PrefsFile)
                LogOutput("Set NC Headset Automation to "..Preferences_ValGet(NCHeadset_Config_Vars,"Automation"))
            end
            if i == 5 then
                Preferences_ValSet(NCHeadset_Config_Vars,"NoiseCancelLevel",Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") + Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta"))
                Preferences_Write(NCHeadset_Config_Vars,Xlua_Utils_PrefsFile)
                LogOutput("Increased Headset Noise Cancellation Level to "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") * 100).." %.")
            end
            if i == 7 then
                Preferences_ValSet(NCHeadset_Config_Vars,"NoiseCancelLevel",Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") - Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta"))
                Preferences_Write(NCHeadset_Config_Vars,Xlua_Utils_PrefsFile)
                LogOutput("Decreased Headset Noise Cancellation Level to "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") * 100).." %.")
            end        
            NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function NCHeadset_Menu_Watchdog(intable,index)
    if index == 2 then
        if Preferences_ValGet(NCHeadset_Config_Vars,"Headset") == 0 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[Off] Put On",intable)
        elseif Preferences_ValGet(NCHeadset_Config_Vars,"Headset") == 1 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[On] Take Off",intable) end
    end
    if index == 3 then
        if Preferences_ValGet(NCHeadset_Config_Vars,"Automation") == 0 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[Off] Enable",intable)
        elseif Preferences_ValGet(NCHeadset_Config_Vars,"Automation") == 1 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[On] Disable",intable) end
    end
    if index == 5 or index == 7 then
        if Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") < 0 then Preferences_ValSet(NCHeadset_Config_Vars,"NoiseCancelLevel",0) end       
        XPLM.XPLMSetMenuItemName(NCHeadset_Menu_ID,3,"Increment Muffling (+ "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",1)
        XPLM.XPLMSetMenuItemName(NCHeadset_Menu_ID,4,"Noise Cancellation Level: "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") * 100).." %",1)
        XPLM.XPLMSetMenuItemName(NCHeadset_Menu_ID,5,"Decrement Muffling (- "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",1)
    end
end

--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function NCHeadset_Menu_Init(ParentMenuID)
    local Menu_Indices = {}
    for i=2,#NCHeadset_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,NCHeadset_Menu_Items[1],ffi.cast("void *","None"),1)
        NCHeadset_Menu_ID = XPLM.XPLMCreateMenu(NCHeadset_Menu_Items[1],ParentMenuID,Menu_Index,function(inMenuRef,inItemRef) NCHeadset_Menu_Callbacks(inItemRef) end,ffi.cast("void *",NCHeadset_Menu_Pointer))
        for i=2,#NCHeadset_Menu_Items do
            if NCHeadset_Menu_Items[i] ~= "[Separator]" then
                NCHeadset_Menu_Pointer = NCHeadset_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(NCHeadset_Menu_ID,NCHeadset_Menu_Items[i],ffi.cast("void *",NCHeadset_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(NCHeadset_Menu_ID)
            end
        end
        for i=2,#NCHeadset_Menu_Items do
            if NCHeadset_Menu_Items[i] ~= "[Separator]" then
                NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,i)
            end
        end
        LogOutput(NCHeadset_Menu_Items[1].." menu initialized!")
    end
end

LogOutput("NCHeadset initialized")
