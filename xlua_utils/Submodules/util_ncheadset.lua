--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
--[[ Table that contains the configuration Variables for the NC Headset module ]]
NCHeadset_Config_Vars = {
{"NCHEADSET"},
{"Automation",0},
{"HeadsetOn",0},
{"NoiseCancelLevel",0.5},
{"NoiseCancelLevelDelta",0.1},
{"MainTimerInterval",1},
{"FModCompliant",1},
}
--[[ List of Datarefs used by this module ]]
local Dref_List = {
"sim/operation/sound/engine_volume_ratio",
"sim/operation/sound/enviro_volume_ratio",
"sim/operation/sound/exterior_volume_ratio",
"sim/operation/sound/fan_volume_ratio",
"sim/fake/dataref",
"sim/operation/sound/interior_volume_ratio",
"sim/operation/sound/warning_volume_ratio",
"sim/operation/sound/weather_volume_ratio",
}
--[[ Fixed datarefs that need constant monitoring ]]
IsInside_fmod = find_dataref("sim/operation/sound/inside_any")
IsInside_old = find_dataref("sim/graphics/view/view_is_external")
IsBurningFuel = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel")
NumEngines = find_dataref("sim/aircraft/engine/acf_num_engines")
HeadSetStatus_Old = 0
--[[ Container Table for the Datarefs to be monitored. Datarefs are stored in subtables {dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
NCHeadset_Datarefs = {
"DATAREF",
}

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
        NCHeadset_Datarefs[i][3][1] = Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") * NCHeadset_Datarefs[i][4][1] -- Multiply default noise levels by noise cancellation factor
        Dataref_Write(NCHeadset_Datarefs,3,"All")
    end
end
--[[ Remove headset muffling ]]
function NCHeadset_Off()
    for i=2,#NCHeadset_Datarefs do
        Dataref_Write(NCHeadset_Datarefs,4,"All")
    end
end
--[[ ]]
function NCHeadset_MainTimer()
    -- Picks the dataref feeding the IsInside variable based on fmod compliance as determined by the user
    if Preferences_ValGet(NCHeadset_Config_Vars,"FModCompliant") == 1 then IsInside = IsInside_fmod else IsInside = IsInside_old end
    -- Headset automation control - Puts on headset when all engines are started
    if (Preferences_ValGet(NCHeadset_Config_Vars,"Automation") == 1 and AllEnginesRunning() == 1) and IsInside == 1 then Preferences_ValSet(NCHeadset_Config_Vars,"HeadsetOn",1) NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,2) end
    if (Preferences_ValGet(NCHeadset_Config_Vars,"Automation") == 1 and AllEnginesRunning() == 0) or IsInside == 0 then Preferences_ValSet(NCHeadset_Config_Vars,"HeadsetOn",0) NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,2) end
    -- Headset On/Off handling
    if Preferences_ValGet(NCHeadset_Config_Vars,"HeadsetOn") == 1 and HeadSetStatus_Old == 0 then
        NCHeadset_On()
        HeadSetStatus_Old = 1
        DebugLogOutput(NCHeadset_Config_Vars[1][1]..": On")
    end
    if Preferences_ValGet(NCHeadset_Config_Vars,"HeadsetOn") == 0 and HeadSetStatus_Old == 1 then
        NCHeadset_Off()
        HeadSetStatus_Old = 0
        DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Off")
    end
end
--[[

INITIALIZATION

]]
--[[ First start of the NCHeadset module ]]
function NCHeadset_FirstRun()
    Preferences_Write(NCHeadset_Config_Vars,Xlua_Utils_PrefsFile)
    Preferences_Read(Xlua_Utils_PrefsFile,NCHeadset_Config_Vars)
    DrefTable_Read(Dref_List,NCHeadset_Datarefs)
    NCHeadset_Menu_Init(XluaUtils_Menu_ID)
    LogOutput(NCHeadset_Config_Vars[1][1]..": First Run!")
end
--[[ Initializes NCHeadset at every startup ]]
function NCHeadset_Init()
    Preferences_Read(Xlua_Utils_PrefsFile,NCHeadset_Config_Vars)
    DrefTable_Read(Dref_List,NCHeadset_Datarefs)
    Dataref_Read(NCHeadset_Datarefs,4,"All") -- Populate dataref container with currrent values as defaults
    Dataref_Read(NCHeadset_Datarefs,3,"All") -- Populate dataref container with currrent values
    run_at_interval(NCHeadset_MainTimer,Preferences_ValGet(NCHeadset_Config_Vars,"MainTimerInterval"))
    LogOutput(NCHeadset_Config_Vars[1][1]..": Initialized!")
end
--[[ Reloads the Persistence configuration ]]
function NCHeadset_Reload()
    Preferences_Read(Xlua_Utils_PrefsFile,NCHeadset_Config_Vars)
    --NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,8)
    LogOutput(NCHeadset_Config_Vars[1][1]..": Reloaded!")
end
--[[

MENU

]]
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
NCHeadset_Menu_Items = {
"Headset",                  -- Menu title, index 1
"Headset",                  -- Item index: 2
"Automation",               -- Item index: 3
"[Separator]",              -- Item index: 4
"Increment Noise Level (+ "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",   -- Item index: 5
"Noise Level: "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") * 100).." %",       -- Item index: 6
"Decrement Noise Level (- "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",   -- Item index: 7
"[Separator]",              -- Item index: 8
"Use FMod Sound Space",     -- Item index: 9
}
--[[ Menu variables for FFI ]]
NCHeadset_Menu_ID = nil
NCHeadset_Menu_Pointer = ffi.new("const char")
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function NCHeadset_Menu_Callbacks(itemref)
    for i=2,#NCHeadset_Menu_Items do
        if itemref == NCHeadset_Menu_Items[i] then
            if i == 2 then
                if Preferences_ValGet(NCHeadset_Config_Vars,"HeadsetOn") == 0 then Preferences_ValSet(NCHeadset_Config_Vars,"HeadsetOn",1)
                elseif Preferences_ValGet(NCHeadset_Config_Vars,"HeadsetOn") == 1 then if Preferences_ValGet(NCHeadset_Config_Vars,"Automation") == 1 then Preferences_ValSet(NCHeadset_Config_Vars,"Automation",0) end Preferences_ValSet(NCHeadset_Config_Vars,"HeadsetOn",0) end
            end
            if i == 3 then
                if Preferences_ValGet(NCHeadset_Config_Vars,"Automation") == 0 then Preferences_ValSet(NCHeadset_Config_Vars,"Automation",1) else Preferences_ValSet(NCHeadset_Config_Vars,"Automation",0) end
                Preferences_Write(NCHeadset_Config_Vars,Xlua_Utils_PrefsFile)
                DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Set Automation to "..Preferences_ValGet(NCHeadset_Config_Vars,"Automation"))
            end
            if i == 5 then
                Preferences_ValSet(NCHeadset_Config_Vars,"NoiseCancelLevel",Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") + Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta"))
                Preferences_Write(NCHeadset_Config_Vars,Xlua_Utils_PrefsFile)
                if Preferences_ValGet(NCHeadset_Config_Vars,"HeadsetOn") == 1 then NCHeadset_On() end
                DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Increased Noise Level to "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") * 100).." %.")
            end
            if i == 7 then
                Preferences_ValSet(NCHeadset_Config_Vars,"NoiseCancelLevel",Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") - Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta"))
                Preferences_Write(NCHeadset_Config_Vars,Xlua_Utils_PrefsFile)
                if Preferences_ValGet(NCHeadset_Config_Vars,"HeadsetOn") == 1 then NCHeadset_On() end
                DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Decreased Noise Level to "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") * 100).." %.")
            end
            if i == 9 then
                if Preferences_ValGet(NCHeadset_Config_Vars,"FModCompliant") == 0 then Preferences_ValSet(NCHeadset_Config_Vars,"FModCompliant",1)
                elseif Preferences_ValGet(NCHeadset_Config_Vars,"FModCompliant") == 1 then Preferences_ValSet(NCHeadset_Config_Vars,"FModCompliant",0) end
                Preferences_Write(NCHeadset_Config_Vars,Xlua_Utils_PrefsFile)
                DebugLogOutput(NCHeadset_Config_Vars[1][1]..": Soundscape Triggering set to "..Preferences_ValGet(NCHeadset_Config_Vars,"FModCompliant"))
            end
            NCHeadset_Menu_Watchdog(NCHeadset_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function NCHeadset_Menu_Watchdog(intable,index)
    if index == 2 then
        if Preferences_ValGet(NCHeadset_Config_Vars,"HeadsetOn") == 0 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[Off]",intable)
        elseif Preferences_ValGet(NCHeadset_Config_Vars,"HeadsetOn") == 1 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[On] ",intable) end
    end
    if index == 3 then
        if Preferences_ValGet(NCHeadset_Config_Vars,"Automation") == 0 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[Off]",intable)
        elseif Preferences_ValGet(NCHeadset_Config_Vars,"Automation") == 1 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[On] ",intable) end
    end
    if index == 5 or index == 7 then
        if Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") < 0 then Preferences_ValSet(NCHeadset_Config_Vars,"NoiseCancelLevel",0) end       
        XPLM.XPLMSetMenuItemName(NCHeadset_Menu_ID,3,"Increment Noise Level (+ "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",1)
        XPLM.XPLMSetMenuItemName(NCHeadset_Menu_ID,4,"Noise Level: "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevel") * 100).." %",1)
        XPLM.XPLMSetMenuItemName(NCHeadset_Menu_ID,5,"Decrement Noise Level (- "..(Preferences_ValGet(NCHeadset_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",1)
    end
    if index == 9 then
        if Preferences_ValGet(NCHeadset_Config_Vars,"FModCompliant") == 0 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[Off]",intable)
        elseif Preferences_ValGet(NCHeadset_Config_Vars,"FModCompliant") == 1 then Menu_ChangeItemPrefix(NCHeadset_Menu_ID,index,"[On] ",intable) end
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
        LogOutput(NCHeadset_Config_Vars[1][1].." Menu initialized!")
    end
end
