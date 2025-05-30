jit.off()
--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
--[[ Table that contains the configuration variables for the NC Headset module ]]
local NCHeadset_Config_Vars = {
{"NCHEADSET"},
{"HeadsetState",0},
{"NoiseCancelLevel",0.5},
{"NoiseCancelLevelDelta",0.1},
{"MainTimerInterval",0.5},
{"FModCompliant",1},
{"NotifySuppress",0},
}
--[[ List of Datarefs used by this module ]]
local Dref_List = {
{"Dref[n]","sim/operation/sound/engine_volume_ratio"},
{"Dref[n]","sim/operation/sound/enviro_volume_ratio"},
{"Dref[n]","sim/operation/sound/exterior_volume_ratio"},
{"Dref[n]","sim/operation/sound/fan_volume_ratio"},
{"Dref[n]","sim/operation/sound/interior_volume_ratio"},
{"Dref[n]","sim/operation/sound/warning_volume_ratio"},
{"Dref[n]","sim/operation/sound/weather_volume_ratio"},
}
--[[ Fixed datarefs that need constant monitoring ]]
IsInside_fmod = find_dataref("sim/operation/sound/inside_any")
IsInside_old = find_dataref("sim/graphics/view/view_is_external")
IsBurningFuel = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel")
NumEngines = find_dataref("sim/aircraft/engine/acf_num_engines")
local HeadSetStatus_Old = 0
--[[ Container Table for the Datarefs to be monitored. Datarefs are stored in subtables {alias,dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local NCHeadset_Datarefs = {
"DATAREF",
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local NCHeadset_Menu_Items = {
"Headset",                  -- Menu title, index 1
"Headset Mode: ",                  -- Item index: 2
"Increment Noise Level (+ "..(Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta",nil,2) * 100).." %)",   -- Item index: 3
"Noise Level: "..(Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2) * 100).." %",       -- Item index: 4
"Decrement Noise Level (- "..(Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta",nil,2) * 100).." %)",   -- Item index: 5
"[Separator]",              -- Item index: 6
"Use FMod Sound Space",     -- Item index: 7
"Suppress Notifications",   -- Item index: 8
}
--[[ Menu variables for FFI ]]
local NCHeadset_Menu_ID = nil
local NCHeadset_Menu_Pointer = ffi.new("const char")
--[[

FUNCTIONS

]]
--[[ Determine number of engines running ]]
local function AllEnginesRunning()
    local j=0
    for i=0,(NumEngines-1) do if IsBurningFuel[i] == 1 then j = j + 1 end end
    if j == NumEngines then return 1 end
    if j < NumEngines then return 0 end
end
--[[ Apply headset muffling ]]
function NCHeadset_On()
    for i=2,#NCHeadset_Datarefs do
        NCHeadset_Datarefs[i][4][1] = Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2) * NCHeadset_Datarefs[i][5][1] -- Multiply default noise levels by noise cancellation factor
        Dataref_Write(NCHeadset_Datarefs,4,"All")
    end
end
--[[ Remove headset muffling ]]
function NCHeadset_Off()
    for i=2,#NCHeadset_Datarefs do
        Dataref_Write(NCHeadset_Datarefs,5,"All")
    end
end
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function NCHeadset_Menu_Callbacks(itemref)
    for i=2,#NCHeadset_Menu_Items do
        if itemref == NCHeadset_Menu_Items[i] then
            if i == 2 then
                Table_ValSet(NCHeadset_Config_Vars,"HeadsetState",nil,2,Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) + 1)
                if Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) > 2 then Table_ValSet(NCHeadset_Config_Vars,"HeadsetState",nil,2,0) end
                Preferences_Write(NCHeadset_Config_Vars,XLuaUtils_PrefsFile)
                if Table_ValGet(NCHeadset_Config_Vars,"NotifySuppress",nil,2) == 0 then
                    if Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 0 then DisplayNotification("Headset Mode: Off","Nominal",3) end
                    if Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 0 then DisplayNotification("Headset Mode: On","Nominal",3) end
                    if Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 2 then DisplayNotification("Headset Mode: Auto","Nominal",3) end
                end
            end
            if i == 3 then
                Table_ValSet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2,Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2) + Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta",nil,2))
                Preferences_Write(NCHeadset_Config_Vars,XLuaUtils_PrefsFile)
                if Table_ValGet(NCHeadset_Config_Vars,"HeadsetOn",nil,2) == 1 then NCHeadset_On() end
                DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Increased Noise Level to "..(Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2) * 100).." %.")
            end
            if i == 4 then
                Table_ValSet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2,Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2) - Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta",nil,2))
                Preferences_Write(NCHeadset_Config_Vars,XLuaUtils_PrefsFile)
                if Table_ValGet(NCHeadset_Config_Vars,"HeadsetOn",nil,2) == 1 then NCHeadset_On() end
                DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Decreased Noise Level to "..(Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2) * 100).." %.")
            end
            if i == 7 then
                if Table_ValGet(NCHeadset_Config_Vars,"FModCompliant",nil,2) == 0 then Table_ValSet(NCHeadset_Config_Vars,"FModCompliant",nil,2,1)
                elseif Table_ValGet(NCHeadset_Config_Vars,"FModCompliant",nil,2) == 1 then Table_ValSet(NCHeadset_Config_Vars,"FModCompliant",nil,2,0) end
                Preferences_Write(NCHeadset_Config_Vars,XLuaUtils_PrefsFile)
                DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Soundscape Triggering set to "..Table_ValGet(NCHeadset_Config_Vars,"FModCompliant",nil,2))
            end
            if i == 8 then
                if Table_ValGet(NCHeadset_Config_Vars,"NotifySuppress",nil,2) == 0 then Table_ValSet(NCHeadset_Config_Vars,"NotifySuppress",nil,2,1)
                elseif Table_ValGet(NCHeadset_Config_Vars,"NotifySuppress",nil,2) == 1 then Table_ValSet(NCHeadset_Config_Vars,"NotifySuppress",nil,2,0) end
                Preferences_Write(NCHeadset_Config_Vars,XLuaUtils_PrefsFile)
                DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Notification suppression set to "..Table_ValGet(NCHeadset_Config_Vars,"NotifySuppress",nil,2))
            end
            NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function NCHeadset_Menu_Watchdog(intable,index)
    if index == 2 then
        if Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 0 then Menu_ChangeItemSuffix(NCHeadset_Menu_ID,index,"Off ",intable)
        elseif Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 1 then Menu_ChangeItemSuffix(NCHeadset_Menu_ID,index,"On  ",intable)
        elseif Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 2 then
            if HeadSetStatus_Old == 1 then Menu_ChangeItemSuffix(NCHeadset_Menu_ID,index,"Auto [On]",intable) end
            if HeadSetStatus_Old == 0 then Menu_ChangeItemSuffix(NCHeadset_Menu_ID,index,"Auto [Off]",intable) end
        end
    end
    if index == 3 or index == 4 then
        if Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2) < 0 then Table_ValSet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2,0) end
        XPLM.XPLMSetMenuItemName(NCHeadset_Menu_ID,1,"Increment Noise Level (+ "..(Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta",nil,2) * 100).." %)",1)
        XPLM.XPLMSetMenuItemName(NCHeadset_Menu_ID,2,"Noise Level: "..(Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel",nil,2) * 100).." %",1)
        XPLM.XPLMSetMenuItemName(NCHeadset_Menu_ID,3,"Decrement Noise Level (- "..(Table_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta",nil,2) * 100).." %)",1)
    end
    if index == 7 then
        if Table_ValGet(NCHeadset_Config_Vars,"FModCompliant",nil,2) == 0 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[Off]",intable)
        elseif Table_ValGet(NCHeadset_Config_Vars,"FModCompliant",nil,2) == 1 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[On] ",intable) end
    end
    if index == 8 then
        if Table_ValGet(NCHeadset_Config_Vars,"NotifySuppress",nil,2) == 0 then Menu_CheckItem(NCHeadset_Menu_ID,index,"Deactivate")
        elseif Table_ValGet(NCHeadset_Config_Vars,"NotifySuppress",nil,2) == 1 then Menu_CheckItem(NCHeadset_Menu_ID,index,"Activate") end
    end
end
--[[ Registration routine for the menu ]]
function NCHeadset_Menu_Register()
    if XPLM ~= nil and NCHeadset_Menu_ID == nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(XLuaUtils_Menu_ID,NCHeadset_Menu_Items[1],ffi.cast("void *","None"),1)
        NCHeadset_Menu_ID = XPLM.XPLMCreateMenu(NCHeadset_Menu_Items[1],XLuaUtils_Menu_ID,Menu_Index,function(inMenuRef,inItemRef) NCHeadset_Menu_Callbacks(inItemRef) end,ffi.cast("void *",NCHeadset_Menu_Pointer))
        NCHeadset_Menu_Build()
        DebugLogOutput(NCHeadset_Config_Vars[1][1].." Menu registered!")
    end
end
--[[ Initialization routine for the menu ]]
function NCHeadset_Menu_Build()
    XPLM.XPLMClearAllMenuItems(NCHeadset_Menu_ID)
    local Menu_Indices = {}
    if XLuaUtils_HasConfig == 1 then
        for i=2,#NCHeadset_Menu_Items do Menu_Indices[i] = 0 end
        if NCHeadset_Menu_ID ~= nil then
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
            DebugLogOutput(NCHeadset_Config_Vars[1][1].." Menu built!")
        end
    end
end
--[[

RUNTIME CALLBACKS

]]
--[[ Module Main Timer ]]
function NCHeadset_MainTimer()
    -- Picks the dataref feeding the IsInside variable based on fmod compliance as determined by the user
    if Table_ValGet(NCHeadset_Config_Vars,"FModCompliant",nil,2) == 1 then IsInside = IsInside_fmod else IsInside = IsInside_old end
    -- Headset mode control. If in auto mode, puts on headset when all engines are started
    if (Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 1 or (Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 2 and AllEnginesRunning() == 1)) and IsInside == 1 and HeadSetStatus_Old == 0 then
        NCHeadset_On()
        HeadSetStatus_Old = 1
        DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Active")
        NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,2)
        if Table_ValGet(NCHeadset_Config_Vars,"NotifySuppress",nil,2) == 0 then DisplayNotification("Headset Put On","Nominal",3) end
    end

    if (Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 0 or (Table_ValGet(NCHeadset_Config_Vars,"HeadsetState",nil,2) == 2 and AllEnginesRunning() == 0) or IsInside == 0) and HeadSetStatus_Old == 1 then
        NCHeadset_Off()
        HeadSetStatus_Old = 0
        DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Inactive")
        NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,2)
        if Table_ValGet(NCHeadset_Config_Vars,"NotifySuppress",nil,2) == 0 then DisplayNotification("Headset Taken Off","Nominal",3) end
    end
end
--[[

INITIALIZATION

]]
--[[ Module is run for the very first time ]]
function NCHeadset_FirstRun()
    Preferences_Write(NCHeadset_Config_Vars,XLuaUtils_PrefsFile)
    DrefTable_Read(Dref_List,NCHeadset_Datarefs)
    LogOutput(NCHeadset_Config_Vars[1][1]..": First Run!")
end
--[[ Module initialization at every Xlua Utils start ]]
function NCHeadset_Init()
    Preferences_Read(XLuaUtils_PrefsFile,NCHeadset_Config_Vars)
    if XLuaUtils_HasConfig == 1 then
        DrefTable_Read(Dref_List,NCHeadset_Datarefs)
        Dataref_Read(NCHeadset_Datarefs,5,"All") -- Populate dataref container with current values as defaults
        Dataref_Read(NCHeadset_Datarefs,4,"All") -- Populate dataref container with current values
        run_at_interval(NCHeadset_MainTimer,Table_ValGet(NCHeadset_Config_Vars,"MainTimerInterval",nil,2))
        if is_timer_scheduled(NCHeadset_MainTimer) then DisplayNotification("Headset: Initialized","Nominal",5) end
        NCHeadset_Menu_Register()
    end
    LogOutput(NCHeadset_Config_Vars[1][1]..": Initialized!")
end
--[[ Module reload ]]
function NCHeadset_Reload()
    Preferences_Read(XLuaUtils_PrefsFile,NCHeadset_Config_Vars)
    NCHeadset_Menu_Build()
    LogOutput(NCHeadset_Config_Vars[1][1]..": Reloaded!")
end
