--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

Credit: POM57 for HeliTrim for SASL https://github.com/POM57/HeliTrim

]]
--[[

VARIABLES

]]
--[[ Table that contains the configuration variables for the Stick Trim module ]]
local StrickTrim_Config_Vars = {
{"STICKTRIM"},
{"MainTimerInterval",0.1},  -- Main timer interval, in seconds
{"Stick",1},                -- Monitor stick trim
{"Pedals",1},               -- Monitor predal trim
{"Push_For_Reset",0.25},    -- Command press time for reset
{"Reset_Rate",1},           -- Rate at which the trim resets
{"Notifications",1},        -- Display Notifications?
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local StickTrim_Menu_Items = {
"Stick Trim",               -- Menu title, index 1
"Notifications",            -- Item index: 2
"[Separator]",              -- Item index: 3
"Monitor Stick",            -- Item index: 4
"Monitor Pedals",           -- Item index: 5
}

local Trim_Offset = {P=0,R=0,Y=0}
local Control_Deflection = {P=0,R=0,Y=0}
local Reset_Commanded = {S=0,P=0} -- Trim reset commanded for stick and pedals
--[[

DATAREFS

]]
simDR_IsHelicopter = find_dataref("sim/aircraft2/metadata/is_helicopter")
simDR_JoyMappedAxis = find_dataref("sim/joystick/joy_mapped_axis_value") -- 1 = pitch, 2 = roll, 3 = yaw
simDR_Override_Joy_P = find_dataref("sim/operation/override/override_joystick_pitch")
simDR_Override_Joy_R = find_dataref("sim/operation/override/override_joystick_roll")
simDR_Override_Joy_H = find_dataref("sim/operation/override/override_joystick_heading")
simDR_Yoke_P = find_dataref("sim/joystick/yoke_pitch_ratio")
simDR_Yoke_R = find_dataref("sim/joystick/yoke_roll_ratio")
simDR_Yoke_H = find_dataref("sim/joystick/yoke_heading_ratio")
simDR_Total_Time = find_dataref("sim/time/total_running_time_sec")
simDR_Trim_E = find_dataref("sim/cockpit2/controls/elevator_trim")
simDR_Trim_A = find_dataref("sim/cockpit2/controls/aileron_trim")
simDR_Trim_R = find_dataref("sim/cockpit2/controls/rudder_trim")
--[[

FUNCTIONS

]]
function Callback_Stick_Trim(phase,duration)
    if phase == 0 then -- Begin
        if Table_ValGet(StrickTrim_Config_Vars,"Stick",nil,2) == 1 then
            Control_Deflection.P = simDR_JoyMappedAxis[1] -- Pitch
            Control_Deflection.R = simDR_JoyMappedAxis[2] -- Roll
        end
        if Table_ValGet(StrickTrim_Config_Vars,"Pedals",nil,2) == 1 then
            Control_Deflection.Y = simDR_JoyMappedAxis[3] -- Yaw
        end
    end
    if phase == 1 and duration > Table_ValGet(StrickTrim_Config_Vars,"Push_For_Reset",nil,2) then

    end
    if phase == 2 then -- Release
        if duration < Table_ValGet(StrickTrim_Config_Vars,"Push_For_Reset",nil,2) then
            if Table_ValGet(StrickTrim_Config_Vars,"Stick",nil,2) == 1 and Reset_Commanded.S == 0 then Reset_Commanded.S = 1 end
            if Table_ValGet(StrickTrim_Config_Vars,"Pedals",nil,2) == 1 and Reset_Commanded.P == 0 then Reset_Commanded.P = 1 end
        else
            if Table_ValGet(StrickTrim_Config_Vars,"Stick",nil,2) == 1 then
                Trim_Offset.P = Control_Deflection.P - simDR_JoyMappedAxis[1]
                Trim_Offset.R = Control_Deflection.R - simDR_JoyMappedAxis[2]
                simDR_Trim_E = Trim_Offset.P
                simDR_Trim_A = Trim_Offset.R
            end
            if Table_ValGet(StrickTrim_Config_Vars,"Pedals",nil,2) == 1 then
                Trim_Offset.Y = Control_Deflection.Y - simDR_JoyMappedAxis[3]
                simDR_Trim_R = Trim_Offset.Y
            end
            if Table_ValGet(StrickTrim_Config_Vars,"Notifications",nil,2) == 1 then DisplayNotification("Stick Trim: Trimmed","Nominal",2) end
        end
    end
end
--[[ Increment/decrement to target value ]]
function Delta_To_Target(anim,target,rate)
    if math.abs(target-anim) < rate * Table_ValGet(StrickTrim_Config_Vars,"MainTimerInterval",nil,2) then
        anim = target
    elseif target > anim then
        anim = anim + rate * Table_ValGet(StrickTrim_Config_Vars,"MainTimerInterval",nil,2)
    else
        anim = anim - rate * Table_ValGet(StrickTrim_Config_Vars,"MainTimerInterval",nil,2)
    end
    return anim
end
--[[

CUSTOM COMMANDS

]]
create_command("xluautils/stick_trim","XluaUtils Stick Trim",Callback_Stick_Trim)
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function StickTrim_Menu_Callbacks(itemref)
    for i=2,#StickTrim_Menu_Items do
        if itemref == StickTrim_Menu_Items[i] then
            if i == 2 then
                if Table_ValGet(StrickTrim_Config_Vars,"Notifications",nil,2) == 0 then Table_ValSet(StrickTrim_Config_Vars,"Notifications",nil,2,1) else Table_ValSet(StrickTrim_Config_Vars,"Notifications",nil,2,0) end
            end
            if i == 4 then
                if Table_ValGet(StrickTrim_Config_Vars,"Stick",nil,2) == 0 then Table_ValSet(StrickTrim_Config_Vars,"Stick",nil,2,1) else Table_ValSet(StrickTrim_Config_Vars,"Stick",nil,2,0) end
            end
            if i == 5 then
                if Table_ValGet(StrickTrim_Config_Vars,"Pedals",nil,2) == 0 then Table_ValSet(StrickTrim_Config_Vars,"Pedals",nil,2,1) else Table_ValSet(StrickTrim_Config_Vars,"Pedals",nil,2,0) end
            end
        end
        Preferences_Write(StrickTrim_Config_Vars,XLuaUtils_PrefsFile)
        StickTrim_Menu_Watchdog(StickTrim_Menu_Items,i)
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function StickTrim_Menu_Watchdog(intable,index)
    if index == 2 then
        if Table_ValGet(StrickTrim_Config_Vars,"Notifications",nil,2) == 1 then Menu_CheckItem(StickTrim_Menu_ID,index,"Activate") else Menu_CheckItem(StickTrim_Menu_ID,index,"Deactivate") end
    end
    if index == 4 then
        if Table_ValGet(StrickTrim_Config_Vars,"Stick",nil,2) == 1 then Menu_CheckItem(StickTrim_Menu_ID,index,"Activate") else Menu_CheckItem(StickTrim_Menu_ID,index,"Deactivate") end
    end
    if index == 5 then
        if Table_ValGet(StrickTrim_Config_Vars,"Pedals",nil,2) == 1 then Menu_CheckItem(StickTrim_Menu_ID,index,"Activate") else Menu_CheckItem(StickTrim_Menu_ID,index,"Deactivate") end
    end
end
--[[ Registration routine for the menu ]]
function StickTrim_Menu_Register()
    if XPLM ~= nil and StickTrim_Menu_ID == nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(XLuaUtils_Menu_ID,StickTrim_Menu_Items[1],ffi.cast("void *","None"),1)
        StickTrim_Menu_ID = XPLM.XPLMCreateMenu(StickTrim_Menu_Items[1],XLuaUtils_Menu_ID,Menu_Index,function(inMenuRef,inItemRef) StickTrim_Menu_Callbacks(inItemRef) end,ffi.cast("void *",StickTrim_Menu_Pointer))
        StickTrim_Menu_Build()
        DebugLogOutput(StrickTrim_Config_Vars[1][1].." Menu registered!")
    end
end
--[[ Initialization routine for the menu ]]
function StickTrim_Menu_Build()
    XPLM.XPLMClearAllMenuItems(StickTrim_Menu_ID)
    local Menu_Indices = {}
    local endindex = 2
    for i=2,#StickTrim_Menu_Items do Menu_Indices[i] = 0 end
    if StickTrim_Menu_ID ~= nil then
        for i=2,#StickTrim_Menu_Items do
            if StickTrim_Menu_Items[i] ~= "[Separator]" then
                StickTrim_Menu_Pointer = StickTrim_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(StickTrim_Menu_ID,StickTrim_Menu_Items[i],ffi.cast("void *",StickTrim_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(StickTrim_Menu_ID)
            end
        end
        for i=2,#StickTrim_Menu_Items do
            if StickTrim_Menu_Items[i] ~= "[Separator]" then
                StickTrim_Menu_Watchdog(StickTrim_Menu_Items,i)
            end
        end
        DebugLogOutput(StrickTrim_Config_Vars[1][1].." Menu built!")
    end
end
--[[

RUNTIME CALLBACKS

]]
--[[ Module Main Timer ]]
function StickTrim_MainTimer()
    if Table_ValGet(StrickTrim_Config_Vars,"Stick",nil,2) == 1 and Reset_Commanded.S == 1 then -- Reset pitch and roll
        simDR_Trim_E = Delta_To_Target(simDR_Trim_E,0,Table_ValGet(StrickTrim_Config_Vars,"Reset_Rate",nil,2))
        simDR_Trim_A = Delta_To_Target(simDR_Trim_A,0,Table_ValGet(StrickTrim_Config_Vars,"Reset_Rate",nil,2))
        Trim_Offset.P = simDR_Trim_E
        Trim_Offset.R = simDR_Trim_A
        if simDR_Trim_E == 0 and simDR_Trim_A == 0 then -- Check if stick has been reset
            Reset_Commanded.S = 0
            if Table_ValGet(StrickTrim_Config_Vars,"Notifications",nil,2) == 1 then DisplayNotification("Stick Trim: Stick Reset","Nominal",2) end
        end
    end
    if Table_ValGet(StrickTrim_Config_Vars,"Pedals",nil,2) == 1 and Reset_Commanded.P == 1 then -- Reset yaw
        simDR_Trim_R = Delta_To_Target(simDR_Trim_R,0,Table_ValGet(StrickTrim_Config_Vars,"Reset_Rate",nil,2))
        Trim_Offset.Y = simDR_Trim_R
        if simDR_Trim_R == 0 then -- Check if stick has been reset
            Reset_Commanded.P = 0
            if Table_ValGet(StrickTrim_Config_Vars,"Notifications",nil,2) == 1 then DisplayNotification("Stick Trim: Pedals Reset","Nominal",2) end
        end
    end
end
--[[

INITIALIZATION

]]
--[[ Module is run for the very first time ]]
function StickTrim_FirstRun()
    Preferences_Write(StrickTrim_Config_Vars,XLuaUtils_PrefsFile)
    LogOutput(StrickTrim_Config_Vars[1][1]..": First Run!")
end
--[[ Module initialization at every Xlua Utils start ]]
function StickTrim_Init()
    Preferences_Read(XLuaUtils_PrefsFile,StrickTrim_Config_Vars)
    if XLuaUtils_HasConfig == 1 then
        run_at_interval(StickTrim_MainTimer,Table_ValGet(StrickTrim_Config_Vars,"MainTimerInterval",nil,2))
        if is_timer_scheduled(StickTrim_MainTimer) then DisplayNotification("Stick Trim: Initialized","Nominal",5) end
        StickTrim_Menu_Register()
    end
    LogOutput(StrickTrim_Config_Vars[1][1]..": Initialized!")
end
--[[ Module reload ]]
function StickTrim_Reload()
    Preferences_Read(XLuaUtils_PrefsFile,StrickTrim_Config_Vars)
    StickTrim_Menu_Build()
    LogOutput(StrickTrim_Config_Vars[1][1]..": Reloaded!")
end
