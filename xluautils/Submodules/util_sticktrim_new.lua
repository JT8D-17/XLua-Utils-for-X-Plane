jit.off()
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
{"Notifications",1},        -- Display Notifications?
{"Channel_P",1},            -- Monitor the pitch channel
{"Channel_R",1},            -- Monitor the roll channel
{"Channel_Y",1},            -- Monitor the yaw channel
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local StickTrim_Menu_Items = {
"Stick Trim",               -- Menu title, index 1
"Notifications",            -- Item index: 2
"[Separator]",              -- Item index: 3
"Pitch Channel",            -- Item index: 4
"Roll Channel",             -- Item index: 5
"Yaw Channel",              -- Item index: 6
}

local Control_Offset = {P=0,R=0,Y=0,Acquire=0,Reset=0}
--[[

DATAREFS

]]
simDR_Joystick_P = find_dataref("sim/joystick/joy_mapped_axis_value[1]") -- 1 = pitch, 2 = roll, 3 = yaw
simDR_Joystick_R = find_dataref("sim/joystick/joy_mapped_axis_value[2]") -- 1 = pitch, 2 = roll, 3 = yaw
simDR_Joystick_Y = find_dataref("sim/joystick/joy_mapped_axis_value[3]") -- 1 = pitch, 2 = roll, 3 = yaw
simDR_Override_Joy_P = find_dataref("sim/operation/override/override_joystick_pitch")
simDR_Override_Joy_R = find_dataref("sim/operation/override/override_joystick_roll")
simDR_Override_Joy_H = find_dataref("sim/operation/override/override_joystick_heading")
simDR_Yoke_P = find_dataref("sim/cockpit2/controls/yoke_pitch_ratio")
simDR_Yoke_R = find_dataref("sim/cockpit2/controls/yoke_roll_ratio")
simDR_Yoke_H = find_dataref("sim/cockpit2/controls/yoke_heading_ratio")
--[[

CUSTOM DATAREFS

]]
function fake_handler() end -- Makes custom datarefs writable
Dref_Yoke_NewCtr_P = create_dataref("sim/xluautils/yoke_pitch_offset","number",fake_handler)
Dref_Yoke_NewCtr_R = create_dataref("sim/xluautils/yoke_roll_offset","number",fake_handler)
Dref_Yoke_NewCtr_Y = create_dataref("sim/xluautils/yoke_yaw_offset","number",fake_handler)
--[[

FUNCTIONS

]]
local reset = 0
--[[ Clamps a value ]]
function Clamp(value,min,max)
    if value < min then return min
    elseif value > max then return max
    else return value end
end
--[[ The callback for the custom stick trim command ]]
function Callback_Stick_Trim(phase,duration)
    if phase == 0 then -- Begin
        Control_Offset.Acquire = 1
        if Table_ValGet(StrickTrim_Config_Vars,"Notifications",nil,2) == 1 then DisplayNotification("Stick Trim: Acquiring new center. Release the stick, then the button!","Nominal",-199) end
        Control_Offset.P = simDR_Yoke_P
        Control_Offset.R = simDR_Yoke_R
        Control_Offset.Y = simDR_Yoke_Y
        if simDR_Joystick_P > -0.01 and simDR_Joystick_P < 0.01 and simDR_Joystick_R > -0.01 and simDR_Joystick_R < 0.01 then Control_Offset.Reset = 1 end
    end
    if phase == 1 then -- Hold

    end
    if phase == 2 then -- Release
        Control_Offset.Acquire = 0
        if Control_Offset.Reset == 0 then
            Dref_Yoke_NewCtr_P = simDR_Yoke_P
            Dref_Yoke_NewCtr_R = simDR_Yoke_R
            Dref_Yoke_NewCtr_Y = simDR_Yoke_Y
        else
            Dref_Yoke_NewCtr_P = 0
            Dref_Yoke_NewCtr_R = 0
            Dref_Yoke_NewCtr_Y = 0
            Control_Offset.Reset = 0
        end
        RemoveNotification(-199)
    end
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
                if Table_ValGet(StrickTrim_Config_Vars,"Channel_P",nil,2) == 0 then Table_ValSet(StrickTrim_Config_Vars,"Channel_P",nil,2,1) else Table_ValSet(StrickTrim_Config_Vars,"Channel_P",nil,2,0) end
            end
            if i == 5 then
                if Table_ValGet(StrickTrim_Config_Vars,"Channel_R",nil,2) == 0 then Table_ValSet(StrickTrim_Config_Vars,"Channel_R",nil,2,1) else Table_ValSet(StrickTrim_Config_Vars,"Channel_R",nil,2,0) end
            end
            if i == 6 then
                if Table_ValGet(StrickTrim_Config_Vars,"Channel_Y",nil,2) == 0 then Table_ValSet(StrickTrim_Config_Vars,"Channel_Y",nil,2,1) else Table_ValSet(StrickTrim_Config_Vars,"Channel_Y",nil,2,0) end
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
        if Table_ValGet(StrickTrim_Config_Vars,"Channel_P",nil,2) == 1 then Menu_CheckItem(StickTrim_Menu_ID,index,"Activate") else Menu_CheckItem(StickTrim_Menu_ID,index,"Deactivate") end
    end
    if index == 5 then
        if Table_ValGet(StrickTrim_Config_Vars,"Channel_R",nil,2) == 1 then Menu_CheckItem(StickTrim_Menu_ID,index,"Activate") else Menu_CheckItem(StickTrim_Menu_ID,index,"Deactivate") end
    end
    if index == 6 then
        if Table_ValGet(StrickTrim_Config_Vars,"Channel_Y",nil,2) == 1 then Menu_CheckItem(StickTrim_Menu_ID,index,"Activate") else Menu_CheckItem(StickTrim_Menu_ID,index,"Deactivate") end
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

--[[ Runs before each frame's physics calculation ]]
function before_physics()
    simDR_Override_Joy_P = 1
    simDR_Override_Joy_R = 1
    simDR_Override_Joy_Y = 1
    if Control_Offset.Acquire == 0 then
        simDR_Yoke_P = Clamp(simDR_Joystick_P + Dref_Yoke_NewCtr_P,-1,1)
        simDR_Yoke_R = Clamp(simDR_Joystick_R + Dref_Yoke_NewCtr_R,-1,1)
        simDR_Yoke_Y = Clamp(simDR_Joystick_Y + Dref_Yoke_NewCtr_Y,-1,1)
    else
        simDR_Yoke_P = Control_Offset.P
        simDR_Yoke_R = Control_Offset.R
        simDR_Yoke_Y = Control_Offset.Y
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
