--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

Inspired by the portable oxygen script for FlyWithLua by eddk24
https://forums.x-plane.org/index.php?/files/file/54217-portable-oxygen-for-ga-aircrafts-lua-script/

]]
--[[ Table that contains the configuration variables for the oxygen system module ]]
local OxygenSystem_Config_Vars = {
{"OXYGENSYSTEM"},
{"MainTimerInterval",1},
{"Automation",0},
{"AutoAltitude",12500},
{"BottleCapacityLiters",400},
{"BottleRemainingLiters",400},
{"FlowSetting",2},
{"MasksOn",0},
{"Users",1},
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local OxygenSystem_Menu_Items = {
"Oxygen System",            -- Menu title, index 1
"Mask(s)",                  -- Item index: 2
"Automation",               -- Item index: 3
"[Separator]",              -- Item index: 4
"Users +1 ["..Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2).."]",                  -- Item index: 5
"Users -1 ["..Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2).."]",                  -- Item index: 6
"[Separator]",              -- Item index: 7
"Flow Setting +1 ["..Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2).."]",          -- Item index: 8
"Flow Setting -1 ["..Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2).."]",          -- Item index: 9
"[Separator]",              -- Item index: 10
"[Can not Refill]",         -- Item Index: 11
"[Separator]",              -- Item index: 12
"[Remain]",                 -- Item Index: 13
}
--[[ Menu variables for FFI ]]
local OxygenSystem_Menu_ID = nil
local OxygenSystem_Menu_Pointer = ffi.new("const char")
--
local Pilot_Hypoxia_Stage = {0,"Fine"}
local Hypoxia_Stages_Alt = {11500,14000,15000} -- Onset, Impact, Blacked Out
local Hypoxia_Stage = 0 -- For locking the notification
--[[

DATAREFS

]]
DRef_OnGround = find_dataref("sim/flightmodel/failures/onground_any")
DRef_Oxy_Capacity = find_dataref("sim/aircraft/overflow/acf_o2_bottle_cap_liters")
DRef_Oxy_FlowSetting = find_dataref("sim/cockpit2/oxygen/actuators/demand_flow_setting")
DRef_Oxy_NumUsers = find_dataref("sim/cockpit2/oxygen/actuators/num_plugged_in_o2")
DRef_Oxy_Remain = find_dataref("sim/cockpit2/oxygen/indicators/o2_bottle_rem_liter")
DRef_Oxy_ValvePos = find_dataref("sim/cockpit2/oxygen/actuators/o2_valve_on")
DRef_PilotAlt = find_dataref("sim/cockpit2/oxygen/indicators/pilot_felt_altitude_ft")
--[[

FUNCTIONS

]]

--[[ Apply oxygen system ]]
function OxygenSystem_On()
    DRef_Oxy_ValvePos = 1
    Table_ValSet(OxygenSystem_Config_Vars,"MasksOn",nil,2,1)
    DisplayNotification("Oxygen System: On ("..DRef_Oxy_NumUsers.." Users, Flow "..DRef_Oxy_FlowSetting..")","Nominal",10)
end
--[[ Remove oxygen system ]]
function OxygenSystem_Off()
    DRef_Oxy_ValvePos = 0
    Table_ValSet(OxygenSystem_Config_Vars,"MasksOn",nil,2,0)
    DisplayNotification("Oxygen System: Off","Nominal",10)
end

--[[ Gets old dataref values ]]
function OxygenSystem_WriteSaved()
    if Table_ValGet(OxygenSystem_Config_Vars,"BottleCapacityLiters",nil,2) > DRef_Oxy_Capacity then DRef_Oxy_Capacity = Table_ValGet(OxygenSystem_Config_Vars,"BottleCapacityLiters",nil,2) end
    DRef_Oxy_Remain = Table_ValGet(OxygenSystem_Config_Vars,"BottleRemainingLiters",nil,2)
    DRef_Oxy_FlowSetting = Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2)
    DRef_Oxy_NumUsers = Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2)
    if Table_ValGet(OxygenSystem_Config_Vars,"MasksOn",nil,2) == 1 then OxygenSystem_On() end
end

--[[ Main timer for the oxygen system logic ]]
function OxygenSystem_MainTimer()
    -- Handle automatic donning and undonning of oxygen masks
    if Table_ValGet(OxygenSystem_Config_Vars,"Automation",nil,2) == 1 then
        if DRef_PilotAlt > Table_ValGet(OxygenSystem_Config_Vars,"AutoAltitude",nil,2) and DRef_Oxy_ValvePos == 0 then OxygenSystem_On() end
        if DRef_PilotAlt < Table_ValGet(OxygenSystem_Config_Vars,"AutoAltitude",nil,2) and DRef_Oxy_ValvePos == 1 then OxygenSystem_Off() end
    end
    -- Determine pilot pilot condition
    if DRef_PilotAlt < Hypoxia_Stages_Alt[1] and Hypoxia_Stage ~= 0 then
        Hypoxia_Stage = 0
        DisplayNotification("Oxygen System: Pilot Is Fine!","Nominal",5)
    elseif DRef_PilotAlt > Hypoxia_Stages_Alt[2] and DRef_PilotAlt < Hypoxia_Stages_Alt[3] and Hypoxia_Stage ~= 1 then
        Hypoxia_Stage = 1
        DisplayNotification("Oxygen System: Pilot Feels Hypoxia!","Caution",5)
    elseif DRef_PilotAlt > Hypoxia_Stages_Alt[3] and Hypoxia_Stage ~= 2 then
        Hypoxia_Stage = 2
        DisplayNotification("Oxygen System: Pilot Impaired From Hypoxia!","Warning",5)
    end
    -- Write remainning oxygen in bottle to persistence table
    if DRef_Oxy_ValvePos == 1 then Table_ValSet(OxygenSystem_Config_Vars,"BottleRemainingLiters",nil,2,DRef_Oxy_Remain) end
    -- Refresh menu entries
    for i=2,#OxygenSystem_Menu_Items do
        OxygenSystem_Menu_Watchdog(OxygenSystem_Menu_Items,i)
    end
end
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function OxygenSystem_Menu_Callbacks(itemref)
    for i=2,#OxygenSystem_Menu_Items do
        if itemref == OxygenSystem_Menu_Items[i] then
            if i == 2 then
                if Table_ValGet(OxygenSystem_Config_Vars,"MasksOn",nil,2) == 0 then OxygenSystem_On()
                elseif Table_ValGet(OxygenSystem_Config_Vars,"MasksOn",nil,2) == 1 then if Table_ValGet(OxygenSystem_Config_Vars,"Automation",nil,2) == 1 then Table_ValSet(OxygenSystem_Config_Vars,"Automation",nil,2,0) end OxygenSystem_Off() end
                Preferences_Write(OxygenSystem_Config_Vars,XLuaUtils_PrefsFile)
            end
            if i == 3 then
                if Table_ValGet(OxygenSystem_Config_Vars,"Automation",nil,2) == 0 then Table_ValSet(OxygenSystem_Config_Vars,"Automation",nil,2,1) else Table_ValSet(OxygenSystem_Config_Vars,"Automation",nil,2,0) end
                Preferences_Write(OxygenSystem_Config_Vars,XLuaUtils_PrefsFile)
                DebugLogOutput(OxygenSystem_Config_Vars[1][1]..": Set Automation to "..Table_ValGet(OxygenSystem_Config_Vars,"Automation",nil,2))
            end
            if i == 5 then
                Table_ValSet(OxygenSystem_Config_Vars,"Users",nil,2,Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2) + 1)
                Preferences_Write(OxygenSystem_Config_Vars,XLuaUtils_PrefsFile)
                DRef_Oxy_NumUsers = Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2)
                DebugLogOutput(OxygenSystem_Config_Vars[1][1]..": Increased Users to "..Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2)..".")
            end
            if i == 6 then
                Table_ValSet(OxygenSystem_Config_Vars,"Users",nil,2,Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2) - 1)
                Preferences_Write(OxygenSystem_Config_Vars,XLuaUtils_PrefsFile)
                DRef_Oxy_NumUsers = Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2)
                DebugLogOutput(OxygenSystem_Config_Vars[1][1]..": Decreased Users to "..Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2)..".")
            end
            if i == 8 then
                Table_ValSet(OxygenSystem_Config_Vars,"FlowSetting",nil,2,Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2) + 1)
                Preferences_Write(OxygenSystem_Config_Vars,XLuaUtils_PrefsFile)
                DRef_Oxy_FlowSetting = Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2)
                DebugLogOutput(OxygenSystem_Config_Vars[1][1]..": Increased Flow Setting to "..Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2)..".")
            end
            if i == 9 then
                Table_ValSet(OxygenSystem_Config_Vars,"FlowSetting",nil,2,Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2) - 1)
                Preferences_Write(OxygenSystem_Config_Vars,XLuaUtils_PrefsFile)
                DRef_Oxy_FlowSetting = Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2)
                DebugLogOutput(OxygenSystem_Config_Vars[1][1]..": Decreased Flow Setting to "..Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2)..".")
            end
            if i == 11 then
                if DRef_OnGround == 1 then DRef_Oxy_Remain = DRef_Oxy_Capacity DisplayNotification("Oxygen System: Bottle Refilled ("..DRef_Oxy_Capacity.." l)","Nominal",5) end
            end
            OxygenSystem_Menu_Watchdog(OxygenSystem_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function OxygenSystem_Menu_Watchdog(intable,index)
    if index == 2 then
        if Table_ValGet(OxygenSystem_Config_Vars,"MasksOn",nil,2) == 0 then Menu_ChangeItemPrefix(OxygenSystem_Menu_ID,index,"[Off]",intable)
        elseif Table_ValGet(OxygenSystem_Config_Vars,"MasksOn",nil,2) == 1 then Menu_ChangeItemPrefix(OxygenSystem_Menu_ID,index,"[On] ",intable) end
    end
    if index == 3 then
        if Table_ValGet(OxygenSystem_Config_Vars,"Automation",nil,2) == 0 then Menu_ChangeItemPrefix(OxygenSystem_Menu_ID,index,"[Off]",intable)
        elseif Table_ValGet(OxygenSystem_Config_Vars,"Automation",nil,2) == 1 then Menu_ChangeItemPrefix(OxygenSystem_Menu_ID,index,"[On] ",intable) end
    end
    if index == 5 or index == 6 then
        if Table_ValGet(OxygenSystem_Config_Vars,"Users",nil,2) < 1 then Table_ValSet(OxygenSystem_Config_Vars,"Users",nil,2,1) DRef_Oxy_NumUsers = 1 end
        XPLM.XPLMSetMenuItemName(OxygenSystem_Menu_ID,3,"Users +1 ["..DRef_Oxy_NumUsers.."]",1)
        XPLM.XPLMSetMenuItemName(OxygenSystem_Menu_ID,4,"Users -1 ["..DRef_Oxy_NumUsers.."]",1)
    end
    if index == 8 or index == 9 then
        if Table_ValGet(OxygenSystem_Config_Vars,"FlowSetting",nil,2) < 0 then Table_ValSet(OxygenSystem_Config_Vars,"FlowSetting",nil,2,0) DRef_Oxy_FlowSetting = 0 end
        XPLM.XPLMSetMenuItemName(OxygenSystem_Menu_ID,6,"Flow Setting +1 ["..DRef_Oxy_FlowSetting.."]",1)
        XPLM.XPLMSetMenuItemName(OxygenSystem_Menu_ID,7,"Flow Setting -1 ["..DRef_Oxy_FlowSetting.."]",1)
    end
    if index == 11 then
        if DRef_OnGround == 1 or DebugIsEnabled() == 1 then XPLM.XPLMSetMenuItemName(OxygenSystem_Menu_ID,9,"Refill Bottle",1)
        else XPLM.XPLMSetMenuItemName(OxygenSystem_Menu_ID,9,"[Can Not Refill]",1) end
    end
    if index == 13 then
        XPLM.XPLMSetMenuItemName(OxygenSystem_Menu_ID,11,"Remaining: "..string.format("%.1f",DRef_Oxy_Remain).."/"..string.format("%.1f",DRef_Oxy_Capacity).." l",1)
    end
end
--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function OxygenSystem_Menu_Build(ParentMenuID)
    local Menu_Indices = {}
    for i=2,#OxygenSystem_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,OxygenSystem_Menu_Items[1],ffi.cast("void *","None"),1)
        OxygenSystem_Menu_ID = XPLM.XPLMCreateMenu(OxygenSystem_Menu_Items[1],ParentMenuID,Menu_Index,function(inMenuRef,inItemRef) OxygenSystem_Menu_Callbacks(inItemRef) end,ffi.cast("void *",OxygenSystem_Menu_Pointer))
        for i=2,#OxygenSystem_Menu_Items do
            if OxygenSystem_Menu_Items[i] ~= "[Separator]" then
                OxygenSystem_Menu_Pointer = OxygenSystem_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(OxygenSystem_Menu_ID,OxygenSystem_Menu_Items[i],ffi.cast("void *",OxygenSystem_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(OxygenSystem_Menu_ID)
            end
        end
        for i=2,#OxygenSystem_Menu_Items do
            if OxygenSystem_Menu_Items[i] ~= "[Separator]" then
                OxygenSystem_Menu_Watchdog(OxygenSystem_Menu_Items,i)
            end
        end
        LogOutput(OxygenSystem_Config_Vars[1][1].." Menu initialized!")
    end
end

--[[

INITIALIZATION

]]
--[[ First start of the OxygenSystem module ]]
function OxygenSystem_FirstRun()
    Preferences_Write(OxygenSystem_Config_Vars,XLuaUtils_PrefsFile)
    Preferences_Read(XLuaUtils_PrefsFile,OxygenSystem_Config_Vars)
    OxygenSystem_Menu_Build(XLuaUtils_Menu_ID)
    LogOutput(OxygenSystem_Config_Vars[1][1]..": First Run!")
end
--[[ Initializes OxygenSystem at every startup ]]
function OxygenSystem_Init()
    Preferences_Read(XLuaUtils_PrefsFile,OxygenSystem_Config_Vars)
    OxygenSystem_WriteSaved()
    run_at_interval(OxygenSystem_MainTimer,Table_ValGet(OxygenSystem_Config_Vars,"MainTimerInterval",nil,2))
    LogOutput(OxygenSystem_Config_Vars[1][1]..": Initialized!")
end
--[[ Reloads the Oxygen System configuration ]]
function OxygenSystem_Reload()
    Preferences_Read(XLuaUtils_PrefsFile,OxygenSystem_Config_Vars)
    --OxygenSystem_Menu_Watchdog(OxygenSystem_Menu_Items,8)
    LogOutput(OxygenSystem_Config_Vars[1][1]..": Reloaded!")
end