--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ Table that contains the configuration Variables for the C-47 module ]]
C47_Config_Vars = {
{"VSL_C47"},
{"MainTimerInterval",1},
}
--[[ List of Datarefs used by this module ]]
local Dref_List = {
"sim/operation/failures/rel_engfir0",
"sim/operation/failures/rel_engfir1",
"sim/flightmodel/failures/over_vne",
"sim/operation/failures/rel_collapse2",
"sim/operation/failures/rel_collapse3",
"sim/operation/sound/interior_volume_ratio",
"sim/operation/failures/rel_engsep0",
"sim/operation/failures/rel_engsep1",
"sim/operation/failures/rel_seize_0",
"sim/operation/failures/rel_seize_1",
"sim/operation/failures/rel_vstb2",
"sim/operation/failures/rel_smoke_cpit",
"sim/operation/failures/rel_oilpmp0",
"sim/operation/failures/rel_oilpmp1",
"sim/operation/failures/rel_fuelfl0",
"sim/operation/failures/rel_fuelfl1",
--"sim/operation/failures/rel_xpndr",
--"sim/operation/failures/rel_ss_dgy",
--"sim/operation/failures/rel_cop_dgy",
--"sim/operation/failures/rel_ss_tsi",
--"sim/operation/failures/rel_cop_tsi",
--"sim/operation/failures/rel_magLFT0",
--"sim/operation/failures/rel_magRGT0",
--"sim/operation/failures/rel_magLFT1",
--"sim/operation/failures/rel_magRGT1",
"sim/operation/failures/rel_gear_act",
"sim/operation/failures/rel_flap_act",
"sim/operation/failures/rel_fc_L_flp",
"sim/operation/failures/rel_fc_R_flp",
--"sim/operation/failures/rel_auto_servos",
}
--[[ Fixed datarefs that need constant monitoring ]]
OnGround = find_dataref("sim/flightmodel/failures/onground_any")
GroundSpeed = find_dataref("sim/flightmodel2/position/groundspeed")
--IsBurningFuel = find_dataref("sim/flightmodel2/engines/engine_is_burning_fuel") -- Inherited from xlua_ncheadset.lua
--NumEngines = find_dataref("sim/aircraft/engine/acf_num_engines") -- Inherited from xlua_ncheadset.lua
--[[ Container Table for the Datarefs to be monitored. Datarefs are stored in subtables {dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
C47_Datarefs = {
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
--[[ Main timer ]]
function C47_MainTimer()
    C47_Menu_Watchdog(C47_Menu_Items,2)
end
--[[

INITIALIZATION

]]
--[[ First start of the C47 module ]]
function C47_FirstRun()
    Preferences_Write(C47_Config_Vars,Xlua_Utils_PrefsFile)
    Preferences_Read(Xlua_Utils_PrefsFile,C47_Config_Vars)
    DrefTable_Read(Dref_List,C47_Datarefs)
    C47_Menu_Init(XluaUtils_Menu_ID)
    LogOutput(C47_Config_Vars[1][1]..": First Run!")
end
--[[ Initializes C47 at every startup ]]
function C47_Init()
    --Preferences_Read(Xlua_Utils_PrefsFile,C47_Config_Vars)
    DrefTable_Read(Dref_List,C47_Datarefs)
    --Dataref_Read(C47_Datarefs,4,"All") -- Populate dataref container with currrent values as defaults
    Dataref_Read(C47_Datarefs,3,"All") -- Populate dataref container with currrent values
    for i=2,#C47_Datarefs do C47_Datarefs[i][3][1] = 0 end -- Zero all datarefs
    run_at_interval(C47_MainTimer,Preferences_ValGet(C47_Config_Vars,"MainTimerInterval"))
    LogOutput(C47_Config_Vars[1][1]..": Initialized!")
end
--[[

MENU

]]
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
C47_Menu_Items = {
"C-47 Enhancements",             -- Menu title, index 1
" ",        -- Item index: 2
-- "Decrement Noise Level (- "..(Preferences_ValGet(C47_Config_Vars,"NoiseCancelLevelDelta") * 100).." %)",   -- Item index: 7
}
--[[ Menu variables for FFI ]]
C47_Menu_ID = nil
C47_Menu_Pointer = ffi.new("const char")
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function C47_Menu_Callbacks(itemref)
    for i=2,#C47_Menu_Items do
        if itemref == C47_Menu_Items[i] then
            if i == 2 then
                if OnGround == 1 and GroundSpeed < 0.1 and AllEnginesRunning() == 0 then Dataref_Write(C47_Datarefs,3,"All") end
            end    
            C47_Menu_Watchdog(C47_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function C47_Menu_Watchdog(intable,index)
    if index == 2 then
        if OnGround == 1 and GroundSpeed < 0.1 and AllEnginesRunning() == 0 then Menu_ChangeItemPrefix(C47_Menu_ID,index,"Repair All Damage",intable)
        else Menu_ChangeItemPrefix(C47_Menu_ID,index,"[Can Not Repair]",intable) end
    end
end

--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function C47_Menu_Init(ParentMenuID)
    local Menu_Indices = {}
    for i=2,#C47_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,C47_Menu_Items[1],ffi.cast("void *","None"),1)
        C47_Menu_ID = XPLM.XPLMCreateMenu(C47_Menu_Items[1],ParentMenuID,Menu_Index,function(inMenuRef,inItemRef) C47_Menu_Callbacks(inItemRef) end,ffi.cast("void *",C47_Menu_Pointer))
        for i=2,#C47_Menu_Items do
            if C47_Menu_Items[i] ~= "[Separator]" then
                C47_Menu_Pointer = C47_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(C47_Menu_ID,C47_Menu_Items[i],ffi.cast("void *",C47_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(C47_Menu_ID)
            end
        end
        for i=2,#C47_Menu_Items do
            if C47_Menu_Items[i] ~= "[Separator]" then
                C47_Menu_Watchdog(C47_Menu_Items,i)
            end
        end
        LogOutput(C47_Config_Vars[1][1].." Menu initialized!")
    end
end
