--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES


]]
local EngineDamage_Profile_File = "engine_profile.cfg"
local EngineDamage_HasProfile = 0 -- Used by util_enginedamage.lua
--[[ Table that contains the configuration Variables for the NC Headset module ]]
local EngineDamage_Config_Vars = {
{"ENGINEDAMAGE"},
{"MainTimerInterval",1},    -- Main timer interval, in seconds
{"Notify_Pin",1},           -- Display all notifications as long as condition persists
}
--[[ Table with engine profile information ]]
local EngineDamage_Profile = {
-- ID, Enabled, base parameter redline (-1 = use dataref val), unit, base redline scalar to calculate damage accumulation rate from, base limit damage tolerance (in seconds), damage tolerance at node calculated from base redline * scalar (in seconds), scalar for damage rate when damage is receding
{"DMG_CHT",0,-1,"°C",1.5,300,10,0.75},
{"DMG_EGT",0,-1,"°C",1.5,240,120,0.75},
{"DMG_ITT",0,-1,"°C",1.5,120,5,0.75},
{"DMG_MP",0,-1,"inHg",1.5,300,7.5,0.75},
{"DMG_N1",0,-1,"%",1.5,500,10,0.75},
{"DMG_N2",0,-1,"%",1.5,400,10,0.75},
{"DMG_TRQ",0,-1,"Nm",1.5,50,15,0.75},
{"RandomizeLimit",0.98,1.04},       -- Randomization range for limit values
{"RandomizeDamage",0.98,1.02},       -- Randomization range for incurred damage
{"FailureChance",0.0001,0.01},     -- Chance for failure per time unit at 0 and 100% stress
}
--[[ List of continuously monitored datarefs used by this module ]]
local Dref_List_Cont = {
{"Eng_CHT","sim/flightmodel2/engines/CHT_deg_C"}, -- deg C
{"Eng_EGT","sim/flightmodel2/engines/EGT_deg_C"}, -- deg C
{"Eng_ITT","sim/flightmodel2/engines/ITT_deg_C"}, -- deg C
{"Eng_MP","sim/flightmodel/engine/ENGN_MPR"}, -- inHG
{"Eng_N1","sim/flightmodel2/engines/N1_percent"}, -- %
{"Eng_N2","sim/flightmodel2/engines/N2_percent"}, -- %
{"Eng_TRQ","sim/flightmodel/engine/ENGN_driv_TRQ"}, -- Nm
{"Fail_CHT_1","sim/operation/failures/rel_engfir0"}, -- 0: Normal, 6: Failed
{"Fail_CHT_2","sim/operation/failures/rel_engfir1"}, -- 0: Normal, 6: Failed
{"Fail_CHT_3","sim/operation/failures/rel_engfir2"}, -- 0: Normal, 6: Failed
{"Fail_CHT_4","sim/operation/failures/rel_engfir3"}, -- 0: Normal, 6: Failed
{"Fail_CHT_5","sim/operation/failures/rel_engfir4"}, -- 0: Normal, 6: Failed
{"Fail_CHT_6","sim/operation/failures/rel_engfir5"}, -- 0: Normal, 6: Failed
{"Fail_CHT_7","sim/operation/failures/rel_engfir6"}, -- 0: Normal, 6: Failed
{"Fail_CHT_8","sim/operation/failures/rel_engfir7"}, -- 0: Normal, 6: Failed
{"Fail_EGT_1","sim/operation/failures/rel_engfir0"}, -- 0: Normal, 6: Failed
{"Fail_EGT_2","sim/operation/failures/rel_engfir1"}, -- 0: Normal, 6: Failed
{"Fail_EGT_3","sim/operation/failures/rel_engfir2"}, -- 0: Normal, 6: Failed
{"Fail_EGT_4","sim/operation/failures/rel_engfir3"}, -- 0: Normal, 6: Failed
{"Fail_EGT_5","sim/operation/failures/rel_engfir4"}, -- 0: Normal, 6: Failed
{"Fail_EGT_6","sim/operation/failures/rel_engfir5"}, -- 0: Normal, 6: Failed
{"Fail_EGT_7","sim/operation/failures/rel_engfir6"}, -- 0: Normal, 6: Failed
{"Fail_EGT_8","sim/operation/failures/rel_engfir7"}, -- 0: Normal, 6: Failed
{"Fail_ITT_1","sim/operation/failures/rel_engfir0"}, -- 0: Normal, 6: Failed
{"Fail_ITT_2","sim/operation/failures/rel_engfir1"}, -- 0: Normal, 6: Failed
{"Fail_ITT_3","sim/operation/failures/rel_engfir2"}, -- 0: Normal, 6: Failed
{"Fail_ITT_4","sim/operation/failures/rel_engfir3"}, -- 0: Normal, 6: Failed
{"Fail_ITT_5","sim/operation/failures/rel_engfir4"}, -- 0: Normal, 6: Failed
{"Fail_ITT_6","sim/operation/failures/rel_engfir5"}, -- 0: Normal, 6: Failed
{"Fail_ITT_7","sim/operation/failures/rel_engfir6"}, -- 0: Normal, 6: Failed
{"Fail_ITT_8","sim/operation/failures/rel_engfir7"}, -- 0: Normal, 6: Failed
{"Fail_N1_1","sim/operation/failures/rel_engfai0"}, -- 0: Normal, 6: Failed
{"Fail_N1_2","sim/operation/failures/rel_engfai1"}, -- 0: Normal, 6: Failed
{"Fail_N1_3","sim/operation/failures/rel_engfai2"}, -- 0: Normal, 6: Failed
{"Fail_N1_4","sim/operation/failures/rel_engfai3"}, -- 0: Normal, 6: Failed
{"Fail_N1_5","sim/operation/failures/rel_engfai4"}, -- 0: Normal, 6: Failed
{"Fail_N1_6","sim/operation/failures/rel_engfai5"}, -- 0: Normal, 6: Failed
{"Fail_N1_7","sim/operation/failures/rel_engfai6"}, -- 0: Normal, 6: Failed
{"Fail_N1_8","sim/operation/failures/rel_engfai7"}, -- 0: Normal, 6: Failed
{"Fail_N2_1","sim/operation/failures/rel_engfai0"}, -- 0: Normal, 6: Failed
{"Fail_N2_2","sim/operation/failures/rel_engfai1"}, -- 0: Normal, 6: Failed
{"Fail_N2_3","sim/operation/failures/rel_engfai2"}, -- 0: Normal, 6: Failed
{"Fail_N2_4","sim/operation/failures/rel_engfai3"}, -- 0: Normal, 6: Failed
{"Fail_N2_5","sim/operation/failures/rel_engfai4"}, -- 0: Normal, 6: Failed
{"Fail_N2_6","sim/operation/failures/rel_engfai5"}, -- 0: Normal, 6: Failed
{"Fail_N2_7","sim/operation/failures/rel_engfai6"}, -- 0: Normal, 6: Failed
{"Fail_N2_8","sim/operation/failures/rel_engfai7"}, -- 0: Normal, 6: Failed
{"Fail_TRQ_1","sim/operation/failures/rel_pshaft0"}, -- 0: Normal, 6: Failed
{"Fail_TRQ_2","sim/operation/failures/rel_pshaft1"}, -- 0: Normal, 6: Failed
{"Fail_TRQ_3","sim/operation/failures/rel_pshaft2"}, -- 0: Normal, 6: Failed
{"Fail_TRQ_4","sim/operation/failures/rel_pshaft3"}, -- 0: Normal, 6: Failed
{"Fail_TRQ_5","sim/operation/failures/rel_pshaft4"}, -- 0: Normal, 6: Failed
{"Fail_TRQ_6","sim/operation/failures/rel_pshaft5"}, -- 0: Normal, 6: Failed
{"Fail_TRQ_7","sim/operation/failures/rel_pshaft6"}, -- 0: Normal, 6: Failed
{"Fail_TRQ_8","sim/operation/failures/rel_pshaft7"}, -- 0: Normal, 6: Failed
}
--[[ List of one-shot updated datarefs used by this module ]]
local Dref_List_Once = {
{"Eng_Num","sim/aircraft/engine/acf_num_engines"}, -- Number of engines
{"Type_Eng","sim/aircraft/prop/acf_en_type"}, -- Engine type 0 = recip carb, 1 = recip injected, 3 = electric, 5 = single spool jet, 6 = rocket, 7 = multi spool jet, 9 = free turboprop, 10 = fixed turboprop
{"Type_Prop","sim/aircraft/prop/acf_prop_type"}, -- Propeller type, 0 = fixed pitch, 1 = variable pitch, 3 = main rotor, 5 = tail rotor, 9 == jet
{"Limit_CHT","sim/aircraft/engine/acf_max_CHT"},     -- Maximum CHT
{"Limit_EGT","sim/aircraft/engine/acf_max_EGT"},     -- Maximum EGT
{"Limit_ITT","sim/aircraft/engine/acf_max_ITT"},     -- Maximum ITT
{"Limit_MP","sim/aircraft/engine/acf_mpmax"},     -- Maximum manifold pressure
{"Limit_N1","sim/aircraft/limits/red_hi_N1"},     -- Maximum N1
{"Limit_N2","sim/aircraft/limits/red_hi_N2"},     -- Maximum N2
{"Limit_TRQ","sim/aircraft/limits/red_hi_TRQ"},     -- Maximum torque in Nm or %
{"Max_TRQ","sim/aircraft/controls/acf_trq_max_eng"},     -- Maximum torque in Nm
{"Unit_CHT_C","sim/aircraft/engine/acf_CHT_is_C"}, -- Unit for the CHT limit
{"Unit_EGT_C","sim/aircraft/engine/acf_EGT_is_C"}, -- Unit for the EGT limit
{"Unit_ITT_C","sim/aircraft/engine/acf_ITT_is_C"}, -- Unit for the ITT limit
}
--[[ Container table for continuously monitored datarefs, which are stored in subtables {alias,dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local EngineDamage_Drefs_Cont = {
"DREFS_CONT",
}
--[[ Container table for continuously monitored datarefs, which are stored in subtables {alias,dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local EngineDamage_Drefs_Once = {
"DREFS_ONCE",
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local EngineDamage_Menu_Items = {
"Engine Damage",            -- Menu title, index 1
"",                         -- Item index: 2
"Pin Messages",             -- Item index: 3
"[Separator]",              -- Item index: 4
"CHT",                      -- Item index: 5
"EGT",                      -- Item index: 6
"ITT",                      -- Item index: 7
"MP",                       -- Item index: 8
"N1",                       -- Item index: 9
"N2",                       -- Item index: 10
"TRQ",                      -- Item index: 11
"[Separator]",              -- Item index: 12
"Disable All",              -- Item index: 13
"Repair Engine(s)",         -- Item index: 14
}
--[[ Menu variables for FFI ]]
local EngineDamage_Menu_ID = nil
local EngineDamage_Menu_Pointer = ffi.new("const char")
--[[ Other variables ]]
local EngineData={} -- Engine data container
local Notifications_OldStatus={CHT=0,EGT=0,ITT=0,MP=0,N1=0,N2=0,TRQ=0,F_CHT={},F_EGT={},F_ITT={},F_MP={},F_N1={},F_N2={},F_TRQ={}} -- Helper to only display notifications upon changes
local Notification_ID = {Stress="",Fail=""}
--[[

DEBUG WINDOW

]]
--[[ Adds things to the debug window - HANDLED IN xluautils.lua!! ]]
function EngineDamage_DebugWindow_Init()
    Debug_Window_AddLine("ED_Spacer"," ")
    Debug_Window_AddLine("ED_Header","===== Engine Damage =====")
    --Debug_Window_AddLine("ED_MixtureMode") -- Reserving a line in the debug window only requires an ID.
    for i=1,Table_ValGet(EngineDamage_Drefs_Once,"Eng_Num",4,1) do
        Debug_Window_AddLine("ED_E"..i.."Head","Engine "..i..":")
        if Table_ValGet(EngineDamage_Profile,"DMG_CHT",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."CHT") end
        if Table_ValGet(EngineDamage_Profile,"DMG_EGT",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."EGT") end
        if Table_ValGet(EngineDamage_Profile,"DMG_ITT",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."ITT") end
        if Table_ValGet(EngineDamage_Profile,"DMG_MP",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."MP") end
        if Table_ValGet(EngineDamage_Profile,"DMG_N1",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."N1") end
        if Table_ValGet(EngineDamage_Profile,"DMG_N2",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."N2") end
        if Table_ValGet(EngineDamage_Profile,"DMG_TRQ",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."TRQ") end
    end
end
--[[ Updates the debug window ]]
function EngineDamage_DebugWindow_Update()
    --Debug_Window_ReplaceLine("ED_MixtureMode","Mixture Mode: "..Table_ValGet(EngineDamage_Config_Vars,"MixtureMode",nil,2)) -- Replaces a line by means of its ID. Use this within a timer to refresh the displayed values of variables.
    for i=1,Table_ValGet(EngineDamage_Drefs_Once,"Eng_Num",4,1) do
        -- Loop through engine data table and see if the parameters in its subtables can be populated
        for j=1,#EngineData[i] do
            if Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,2) == 1 then Debug_Window_ReplaceLine("ED_E"..i..EngineData[i][j][1],"  "..EngineData[i][j][1].." Stress: "..string.format("%.2f",Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8)).."/"..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5).." ("..string.format("%+.4f",Table_ValGet(EngineData[i],EngineData[i][j][1],nil,7)).." / "..Table_ValGet(EngineDamage_Config_Vars,"MainTimerInterval",nil,2).." s)") end
        end
    end
end
--[[

FUNCTIONS

]]
--[[ Randomizes a given input variable ]]
local function EngineDamage_Randomize(target,input)
    local output = math.random(Table_ValGet(EngineDamage_Profile,target,nil,2) * 10000,Table_ValGet(EngineDamage_Profile,target,nil,3) * 10000) / 10000 -- Generates a random number between lower and upper limit must be multiplied with 10000 because Lua's RNG only supplies integers as result
    output = input * output
    return output
end
--[[ Gathers information about the aircraft's engine type and auto-actiavtes suitable damage datarefs ]]
function EngineDamage_ProfileAircraft()
    -- Loop through available engines
    for i=1,Table_ValGet(EngineDamage_Drefs_Once,"Eng_Num",4,1) do
        EngineData[i] = {
            -- 1: ID,2: unit,3: base limit,4: base limit randomized,5: stress tolerance randomized,6: stress rate slope,7: stress rate,8: accumulated stress,9: stress recess rate randomized,10: Random lucky number
            {"CHT","°C",-1,-1,-1,-1,0,0,0,0},
            {"EGT","°C",-1,-1,-1,-1,0,0,0,0},
            {"ITT","°C",-1,-1,-1,-1,0,0,0,0},
            {"MP","inHg",-1,-1,-1,-1,0,0,0,0},
            {"N1","%",-1,-1,-1,-1,0,0,0,0},
            {"N2","%",-1,-1,-1,-1,0,0,0,0},
            {"TRQ","Nm",-1,-1,-1,-1,0,0,0,0},
        }
        -- Loop through engine data table and see if the parameters in its subtables can be populated
        for j=1,#EngineData[i] do
            -- Guess property unit if no override was set by user
            if Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,3) == -1 then
                if EngineData[i][j][1] == "CHT" and Table_ValGet(EngineDamage_Drefs_Once,"Unit_CHT_C",4,1) == 0 then Table_ValSet(EngineData[i],"CHT",nil,2,"°F") end
                if EngineData[i][j][1] == "EGT" and Table_ValGet(EngineDamage_Drefs_Once,"Unit_EGT_C",4,1) == 0 then Table_ValSet(EngineData[i],"EGT",nil,2,"°F") end
                if EngineData[i][j][1] == "ITT" and Table_ValGet(EngineDamage_Drefs_Once,"Unit_ITT_C",4,1) == 0 then Table_ValSet(EngineData[i],"ITT",nil,2,"°F") end
                if EngineData[i][j][1] == "TRQ" and Table_ValGet(EngineDamage_Drefs_Once,"Limit_TRQ",4,1) < 200 then Table_ValSet(EngineData[i],"TRQ",nil,2,"%") end
            end
            -- Fill EngineData table
            if Table_ValGet(EngineDamage_Drefs_Once,"Limit_"..EngineData[i][j][1],4,1) ~= nil or Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,3) > -1 then -- Check if dataref exists or has an override set
                if Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,3) > 0 then -- Check if there is a user override for the limit
                    -- Sanity check for units
                    local unit = Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,4)
                    if unit == "°C" or unit == "°F" or unit == "inHg" or unit == "%" or unit == "°C" or unit == "Nm" or unit == "lb-ft" then
                        Table_ValSet(EngineData[i],EngineData[i][j][1],nil,2,Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,4)) -- Assign the user override unit
                    end
                    Table_ValSet(EngineData[i],EngineData[i][j][1],nil,3,Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,3)) -- Assign the user override
                else
                    Table_ValSet(EngineData[i],EngineData[i][j][1],nil,3,Table_ValGet(EngineDamage_Drefs_Once,"Limit_"..EngineData[i][j][1],4,1)) -- Assign the dataref limit
                end
                -- Use value #6 as temporary storage for the randomized damage tolerance
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,6,math.floor(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,6))))
                -- 1. Randomize the base limit and store it as value #4 in EngineData, calculate the upper limit (base limit * scalar) and randomize
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,4,math.ceil(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineData[i],EngineData[i][j][1],nil,3))))
                local limit_high = math.floor(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineData[i],EngineData[i][j][1],nil,3) * Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,5)))
                -- 2. Randomize the stress tolerance at base limit (seconds) and store it in EngineData, randomize the stress tolerance at upper limit (seconds)
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,5,math.floor(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,6))))
                local tolerance_high = math.floor(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,7)))
                -- 3. Stress accumulation rate is always 1 at base limit, but needs to be calculated for upper limit. This will normalize the sustained stress to the value range at the base limit. From that, calculate the slope and store it in engine data.
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,6,math.abs(((Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5) / tolerance_high) - 1) / (limit_high - Table_ValGet(EngineData[i],EngineData[i][j][1],nil,4))))
                -- 4. Stress recess rate uses the damage type randomization
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,9,EngineDamage_Randomize("RandomizeDamage",Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,8)) * -1)
                -- 5. Assign a random lucky number to the engine
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,10,math.ceil(math.random()*10))
                LogOutput("Aircraft engine "..i.." "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,1).." tolerates stress at "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,4).." "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,2).." for "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5).." s and its stress rate increases by "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,6).." per "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,2).." above the limit every "..Table_ValGet(EngineDamage_Config_Vars,"MainTimerInterval",nil,2).." s and will decrease by "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,9).." per "..Table_ValGet(EngineDamage_Config_Vars,"MainTimerInterval",nil,2).." s")
            end

        end
    end
    -- Update menu
    for i=2,#EngineDamage_Menu_Items do
        EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,i)
    end
end
--[[ Calculates a random number from a range of values, whose upper limit is calculated from a probability gradient ]]
local function EngineDamage_RandomIntfromRange(engineindex,paramindex)
    local randomnumber
    -- (((1 / probability_2) - (1 / probability_1)) / range) * (stress / max_stress * 100) + (1 / probability_1)
    randomnumber = math.random(0,math.ceil((((1 / Table_ValGet(EngineDamage_Profile,"FailureChance",nil,3)) - (1 / Table_ValGet(EngineDamage_Profile,"FailureChance",nil,2))) / 100) * (Table_ValGet(EngineData[engineindex],EngineData[engineindex][paramindex][1],nil,8) / Table_ValGet(EngineData[engineindex],EngineData[engineindex][paramindex][1],nil,5) * 100) + (1 / Table_ValGet(EngineDamage_Profile,"FailureChance",nil,2))))
    return randomnumber
end
--[[ Unit converter ]]
local function EngineDamage_UnitConverter(in_value,in_unit,out_unit)
    local out_value = 0
    if in_unit == "°C" and out_unit == "°F" then out_value = (in_value * 1.8) + 32 end
    if in_unit == "°F" and out_unit == "°C" then out_value = (in_value - 32) / 1.8 end
    if in_unit == "lb-ft" and out_unit == "Nm" then out_value = in_value * 1.35582 end
    if in_unit == "Nm" and out_unit == "lb-ft" then out_value = in_value / 1.35582 end
    if in_unit == out_unit then out_value = in_value end
    return out_value
end
--[[ Checks an engine component for being above a limit and accumulates stress on the engine ]]
local function EngineDamage_CheckStress()
    for i=1,#EngineData do -- Loop through all engines
        for j=1,#EngineData[i] do -- Loop through all engine parameters
            Notification_ID.Stress = tonumber("-990"..i..j) -- Assign a unique ID for a notification based on engine number and parameter
            Notification_ID.Fail = tonumber("-991"..i..j) -- Assign a unique ID for a notification based on engine number and parameter
            if Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,2) == 1 and EngineData[i][j][3] > -1 then -- Check if parameter is enabled and has a limit set
                --print(i.." "..EngineData[i][j][1]..": "..Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i))
                -- If component has not failed:
                if Table_ValGet(EngineDamage_Drefs_Cont,"Fail_"..EngineData[i][j][1].."_"..i,4,1) ~= 6 then
                    local datarefval = 0
                    -- Handle CHT dataref temperature unit and engine profile unit
                    if EngineData[i][j][1] == "CHT" then
                        if Table_ValGet(EngineDamage_Drefs_Once,"Unit_CHT_C",4,1) == 0 then datarefval = EngineDamage_UnitConverter(Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i),"°F",EngineData[i][j][2])
                        else datarefval = EngineDamage_UnitConverter(Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i),"°C",EngineData[i][j][2]) end
                    end
                    -- Handle EGT dataref temperature unit and engine profile unit
                    if EngineData[i][j][1] == "EGT" then
                        if Table_ValGet(EngineDamage_Drefs_Once,"Unit_EGT_C",4,1) == 0 then datarefval = EngineDamage_UnitConverter(Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i),"°F",EngineData[i][j][2])
                        else datarefval = EngineDamage_UnitConverter(Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i),"°C",EngineData[i][j][2]) end
                    end
                    -- Handle ITT dataref temperature unit and engine profile unit
                    if EngineData[i][j][1] == "ITT" then
                        if Table_ValGet(EngineDamage_Drefs_Once,"Unit_ITT_C",4,1) == 0 then datarefval = EngineDamage_UnitConverter(Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i),"°F",EngineData[i][j][2])
                        else datarefval = EngineDamage_UnitConverter(Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i),"°C",EngineData[i][j][2]) end
                    end
                    -- Handle TRQ dataref unit and engine profile unit
                    if EngineData[i][j][1] == "TRQ" then
                        if Table_ValGet(EngineDamage_Drefs_Once,"Limit_TRQ",4,1) < 200 and EngineData[i][j][2] == "%" then datarefval = Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i) / Table_ValGet(EngineDamage_Drefs_Once,"Max_TRQ",4,1) * 100 end
                        if Table_ValGet(EngineDamage_Drefs_Once,"Limit_TRQ",4,1) > 200 and EngineData[i][j][2] == "Nm" then datarefval = Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i) end
                        if Table_ValGet(EngineDamage_Drefs_Once,"Limit_TRQ",4,1) > 200 and EngineData[i][j][2] == "lb-ft" then datarefval = EngineDamage_UnitConverter(Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i),"Nm","lb-ft") end
                    end
                    -- Calculate the stress rate
                    if datarefval > EngineData[i][j][3] then
                        -- Display notification
                        if not CheckNotification(Notification_ID.Stress) then
                            DisplayNotification("Engine "..i.." is accumulating stress from "..EngineData[i][j][1].."! ("..string.format("%.2f",(Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8) / Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5)) * 100).." %)","Warning",Notification_ID.Stress)
                        else
                            UpdateNotification("Engine "..i.." is accumulating stress from "..EngineData[i][j][1].."! ("..string.format("%.2f",(Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8) / Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5)) * 100).." %)","Warning",Notification_ID.Stress)
                        end
                        --
                        if Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8) < Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5) then
                            Table_ValSet(EngineData[i],EngineData[i][j][1],nil,7,(datarefval - EngineData[i][j][3]) * Table_ValGet(EngineData[i],EngineData[i][j][1],nil,6))
                        else
                            Table_ValSet(EngineData[i],EngineData[i][j][1],nil,7,0)
                        end
                    else
                        -- Remove notification
                        if CheckNotification(Notification_ID.Stress) then RemoveNotification(Notification_ID.Stress) end
                        --
                        if Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8) > 0 then
                            Table_ValSet(EngineData[i],EngineData[i][j][1],nil,7,Table_ValGet(EngineData[i],EngineData[i][j][1],nil,9))
                        else
                            Table_ValSet(EngineData[i],EngineData[i][j][1],nil,7,0)
                        end
                    end
                    -- Calculate the accumulated stress
                    if Table_ValGet(EngineData[i],EngineData[i][j][1],nil,7) ~= 0 then
                        Table_ValSet(EngineData[i],EngineData[i][j][1],nil,8,Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8) + Table_ValGet(EngineData[i],EngineData[i][j][1],nil,7))
                        -- Clamp stress level
                        if Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8) > Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5) then Table_ValSet(EngineData[i],EngineData[i][j][1],nil,8,Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5)) end
                        if Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8) < 0 then Table_ValSet(EngineData[i],EngineData[i][j][1],nil,8,0) end
                    end
                    -- Probability of failure
                    if Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8) > 0 and Table_ValGet(EngineDamage_Drefs_Cont,"Fail_"..EngineData[i][j][1].."_"..i,4,1) ~= 6 then
                        if Table_ValGet(EngineData[i],EngineData[i][j][1],nil,10) == EngineDamage_RandomIntfromRange(i,j) then
                            Table_ValSet(EngineData[i],EngineData[i][j][1],nil,7,0)
                            Table_ValSet(EngineDamage_Drefs_Cont,"Fail_"..EngineData[i][j][1].."_"..i,4,1,6)
                            Dataref_Write(EngineDamage_Drefs_Cont,4,"Fail_"..EngineData[i][j][1].."_"..i)
                        end
                    end
                -- Fail component if overstressed
                --if Table_ValGet(EngineData[i],EngineData[i][j][1],nil,8) >= Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5) and Table_ValGet(EngineDamage_Drefs_Cont,"Fail_"..EngineData[i][j][1].."_"..i,4,1) ~= 6 then
                --    Table_ValSet(EngineDamage_Drefs_Cont,"Fail_"..EngineData[i][j][1].."_"..i,4,1,6)
                --    Dataref_Write(EngineDamage_Drefs_Cont,4,"Fail_"..EngineData[i][j][1].."_"..i)
                --end
                else
                    if Table_ValGet(EngineDamage_Config_Vars,"Notify_Pin",nil,2) == 1 then
                        if not CheckNotification(Notification_ID.Fail) then DisplayNotification("Engine "..i.." has failed due to excessive "..EngineData[i][j][1].."!","Warning",Notification_ID.Fail) end
                    else
                        if Notifications_OldStatus["F_"..EngineData[i][j][1]][i] ~= i then
                            DisplayNotification("Engine "..i.." has failed due to excessive "..EngineData[i][j][1].."!","Warning",60)
                            Notifications_OldStatus["F_"..EngineData[i][j][1]][i] = i
                        end
                    end
                    if CheckNotification(Notification_ID.Stress) then RemoveNotification(Notification_ID.Stress) end
                end
            end
        end
    end
end
--[[ Repairs any engine damage ]]
function EngineDamage_RepairAll()
    for i=1,#EngineData do -- Loop through all engines
        for j=1,#EngineData[i] do -- Loop through all engine parameters
            if Table_ValGet(EngineDamage_Drefs_Cont,"Fail_"..EngineData[i][j][1].."_"..i,4,1) == 6 then
                Table_ValSet(EngineDamage_Drefs_Cont,"Fail_"..EngineData[i][j][1].."_"..i,4,1,0)
                Dataref_Write(EngineDamage_Drefs_Cont,4,"Fail_"..EngineData[i][j][1].."_"..i)
                DebugLogOutput(EngineDamage_Config_Vars[1][1]..": Repaired engine damage ("..EngineData[i][j][1].."_"..i..")")
                DisplayNotification("Repaired engine "..i.." from "..EngineData[i][j][1].." damage.","Success",10)
            end
        end
    end
    --DisplayNotification("All engine damage has been repaired!","Success",10)
end
--[[ Engine profile read ]]
function EngineDamage_Profile_Read(inputfile)
    local file = io.open(inputfile, "r") -- Check if file exists
    if file then
        EngineDamage_HasProfile = 1
        LogOutput("FILE READ START: Engine Profile")
        local temptable = {}
        local counter = 0
        --local drefline = { }
        for line in file:lines() do
            if string.match(line,"^[^#]") then
                counter = counter + 1
                local splitline = SplitString(line,"([^,]+)")
                --splitline[1] = TrimEndWhitespace(splitline[1]) -- Trims the end whitespace from a string
                for i=1,#EngineDamage_Profile do
                    if EngineDamage_Profile[i][1] == splitline[1] then
                        for j=2,#splitline do
                            if j == 4 then -- Check for known strings
                                EngineDamage_Profile[i][j] = tostring(splitline[j])
                            else
                                EngineDamage_Profile[i][j] = tonumber(splitline[j])
                            end
                        end
                        --print(table.concat(EngineDamage_Profile[i],","))
                    end
                end
            end
        end
        file:close()
        if counter > 1 then LogOutput("FILE READ SUCCESS: "..inputfile) else LogOutput("FILE READ ERROR: "..inputfile) end
    else
        LogOutput("FILE NOT FOUND: Engine Profile")
    end
end
--[[ Engine profile write ]]
function EngineDamage_Profile_Write(outputfile)
    LogOutput("FILE WRITE START: Engine Profile")
    local file = io.open(outputfile, "w")
    file:write("# XLua Utils engine profile generated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# This file contains engine parameter data for XLua Util's engine damage module.\n")
    file:write("# The initial values were determined from the default datarefs, i.e. the aircraft's ACF file.\n")
    file:write("# You can override the default values with custom ones here and enable/disable single parameters.\n")
    file:write("# The new values will then be used after reloading the file from the \"Engine Damage\" menu in XLua Utils.\n")
    file:write("#\n")
    file:write("# Format for the damage-related parameters:\n")
    file:write("# ID, Enabled, base parameter redline (-1 = use dataref val), unit, base redline scalar to calculate damage accumulation rate from, base limit damage tolerance (in seconds), damage tolerance at node calculated from base redline * scalar (in seconds), scalar for damage rate when damage is receding.\n")
    file:write("#\n")
    for i=1,#EngineDamage_Profile do
        file:write(table.concat(EngineDamage_Profile[i],",").."\n")
    end
    if file:seek("end") > 0 then LogOutput("FILE WRITE SUCCESS: Engine Profile") else LogOutput("FILE WRITE ERROR: Engine Profile") end
    file:close()
end
--[[ Handles notifications ]]
function EngineDamage_Notifications()
    if Table_ValGet(EngineDamage_Profile,"DMG_CHT",nil,2) > Notifications_OldStatus.CHT then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by CHT: On") DisplayNotification("Engine damage by CHT: On","Caution",5)  Notifications_OldStatus.CHT = Table_ValGet(EngineDamage_Profile,"DMG_CHT",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_CHT",nil,2) < Notifications_OldStatus.CHT then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by CHT: Off") DisplayNotification("Engine damage by CHT: Off","Nominal",5)  Notifications_OldStatus.CHT = Table_ValGet(EngineDamage_Profile,"DMG_CHT",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_EGT",nil,2) > Notifications_OldStatus.EGT then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by EGT: On") DisplayNotification("Engine damage by EGT: On","Caution",5)  Notifications_OldStatus.EGT = Table_ValGet(EngineDamage_Profile,"DMG_EGT",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_EGT",nil,2) < Notifications_OldStatus.EGT then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by EGT: Off") DisplayNotification("Engine damage by EGT: Off","Nominal",5)  Notifications_OldStatus.EGT = Table_ValGet(EngineDamage_Profile,"DMG_EGT",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_ITT",nil,2) > Notifications_OldStatus.ITT then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by ITT: On") DisplayNotification("Engine damage by ITT: On","Caution",5)  Notifications_OldStatus.ITT = Table_ValGet(EngineDamage_Profile,"DMG_ITT",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_ITT",nil,2) < Notifications_OldStatus.ITT then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by ITT: Off") DisplayNotification("Engine damage by ITT: Off","Nominal",5)  Notifications_OldStatus.ITT = Table_ValGet(EngineDamage_Profile,"DMG_ITT",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_MP",nil,2) > Notifications_OldStatus.MP then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by MP: On") DisplayNotification("Engine damage by MP: On","Caution",5)  Notifications_OldStatus.MP = Table_ValGet(EngineDamage_Profile,"DMG_MP",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_MP",nil,2) < Notifications_OldStatus.MP then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by MP: Off") DisplayNotification("Engine damage by MP: On","Caution",5)  Notifications_OldStatus.MP = Table_ValGet(EngineDamage_Profile,"DMG_MP",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_N1",nil,2) > Notifications_OldStatus.N1 then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by N1: On") DisplayNotification("Engine damage by N1: On","Caution",5)  Notifications_OldStatus.N1 = Table_ValGet(EngineDamage_Profile,"DMG_N1",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_N1",nil,2) < Notifications_OldStatus.N1 then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by N1: Off") DisplayNotification("Engine damage by N1: Off","Nominal",5)  Notifications_OldStatus.N1 = Table_ValGet(EngineDamage_Profile,"DMG_N1",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_N2",nil,2) > Notifications_OldStatus.N2 then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by N2: On") DisplayNotification("Engine damage by N2: On","Caution",5)  Notifications_OldStatus.N2 = Table_ValGet(EngineDamage_Profile,"DMG_N2",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_N2",nil,2) < Notifications_OldStatus.N2 then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by N2: Off") DisplayNotification("Engine damage by N2: Off","Nominal",5)  Notifications_OldStatus.N2 = Table_ValGet(EngineDamage_Profile,"DMG_N2",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_TRQ",nil,2) > Notifications_OldStatus.TRQ then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by TRQ: On") DisplayNotification("Engine damage by TRQ: On","Caution",5)  Notifications_OldStatus.TRQ = Table_ValGet(EngineDamage_Profile,"DMG_TRQ",nil,2) end
    if Table_ValGet(EngineDamage_Profile,"DMG_TRQ",nil,2) < Notifications_OldStatus.TRQ then DebugLogOutput(EngineDamage_Profile[1][1]..": Engine damage by TRQ: Off") DisplayNotification("Engine damage by TRQ: Off","Nominal",5)  Notifications_OldStatus.TRQ = Table_ValGet(EngineDamage_Profile,"DMG_TRQ",nil,2) end
end
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function EngineDamage_Menu_Callbacks(itemref)
    for i=2,#EngineDamage_Menu_Items do
        if itemref == EngineDamage_Menu_Items[i] then
            if i == 2 then
                if EngineDamage_HasProfile == 0 then EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File) EngineDamage_Profile_Read(XLuaUtils_Path..EngineDamage_Profile_File) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,2) end
                if EngineDamage_HasProfile == 1 then EngineDamage_Reload() end
            end
            if i == 3 then
                if Table_ValGet(EngineDamage_Config_Vars,"Notify_Pin",nil,2) == 0 then Table_ValSet(EngineDamage_Config_Vars,"Notify_Pin",nil,2,1) else Table_ValSet(EngineDamage_Config_Vars,"Notify_Pin",nil,2,0) end
            end
            if i == 5 then
                if Table_ValGet(EngineDamage_Profile,"DMG_CHT",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_CHT",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_CHT",nil,2,0) end
                EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File)
            end
            if i == 6 then
                if Table_ValGet(EngineDamage_Profile,"DMG_EGT",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_EGT",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_EGT",nil,2,0) end
                EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File)
            end
            if i == 7 then
                if Table_ValGet(EngineDamage_Profile,"DMG_ITT",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_ITT",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_ITT",nil,2,0) end
                EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File)
            end
            if i == 8 then
                if Table_ValGet(EngineDamage_Profile,"DMG_MP",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_MP",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_MP",nil,2,0) end
                EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File)
            end
            if i == 9 then
                if Table_ValGet(EngineDamage_Profile,"DMG_N1",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_N1",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_N1",nil,2,0) end
                EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File)
            end
            if i == 10 then
                if Table_ValGet(EngineDamage_Profile,"DMG_N2",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_N2",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_N2",nil,2,0) end
                EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File)
            end
            if i == 11 then
                if Table_ValGet(EngineDamage_Profile,"DMG_TRQ",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_TRQ",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_TRQ",nil,2,0) end
                EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File)
            end
            if i == 13 then
                Table_ValSet(EngineDamage_Profile,"DMG_CHT",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,5)
                Table_ValSet(EngineDamage_Profile,"DMG_EGT",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,6)
                Table_ValSet(EngineDamage_Profile,"DMG_ITT",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,7)
                Table_ValSet(EngineDamage_Profile,"DMG_MP",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,8)
                Table_ValSet(EngineDamage_Profile,"DMG_N1",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,9)
                Table_ValSet(EngineDamage_Profile,"DMG_N2",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,10)
                Table_ValSet(EngineDamage_Profile,"DMG_TRQ",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,11)
                EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File)
                DebugLogOutput(EngineDamage_Config_Vars[1][1]..": Disabled all engine damage sources")
                DisplayNotification("All engine damage sources have been disabled!","Nominal",10)
            end
            if i == 14 then
                EngineDamage_RepairAll()
            end
            Preferences_Write(EngineDamage_Config_Vars,XLuaUtils_PrefsFile)
            EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,i)
            EngineDamage_Notifications()
            if DebugIsEnabled() == 1 then Debug_Reload() end
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function EngineDamage_Menu_Watchdog(intable,index)
    if index == 2 then
        if EngineDamage_HasProfile == 0 then Menu_ChangeItemPrefix(EngineDamage_Menu_ID,index,"Generate Engine Profile",intable)
        elseif EngineDamage_HasProfile == 1 then Menu_ChangeItemPrefix(EngineDamage_Menu_ID,index,"Reload Engine Profile",intable) end
    end
    if index == 3 then
        if Table_ValGet(EngineDamage_Config_Vars,"Notify_Pin",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate") else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
    end
    if index == 5 then
        if Table_ValGet(EngineDamage_Profile,"DMG_CHT",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        if Table_ValGet(EngineData[1],"CHT",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%d",Table_ValGet(EngineData[1],"CHT",nil,3)).." "..Table_ValGet(EngineData[1],"CHT",nil,2)..")",intable) end
    end
    if index == 6 then
        if Table_ValGet(EngineDamage_Profile,"DMG_EGT",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        if Table_ValGet(EngineData[1],"EGT",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%d",Table_ValGet(EngineData[1],"EGT",nil,3)).." "..Table_ValGet(EngineData[1],"EGT",nil,2)..")",intable) end
    end
    if index == 7 then
        if Table_ValGet(EngineDamage_Profile,"DMG_ITT",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        if Table_ValGet(EngineData[1],"ITT",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%d",Table_ValGet(EngineData[1],"ITT",nil,3)).." "..Table_ValGet(EngineData[1],"ITT",nil,2)..")",intable) end
    end
    if index == 8 then
        if Table_ValGet(EngineDamage_Profile,"DMG_MP",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        if Table_ValGet(EngineData[1],"MP",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%.2f",Table_ValGet(EngineData[1],"MP",nil,3)).." "..Table_ValGet(EngineData[1],"MP",nil,2)..")",intable) end
    end
    if index == 9 then
        if Table_ValGet(EngineDamage_Profile,"DMG_N1",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        if Table_ValGet(EngineData[1],"N1",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%d",Table_ValGet(EngineData[1],"N1",nil,3)).." "..Table_ValGet(EngineData[1],"N1",nil,2)..")",intable) end
    end
    if index == 10 then
        if Table_ValGet(EngineDamage_Profile,"DMG_N2",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        if Table_ValGet(EngineData[1],"N2",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%d",Table_ValGet(EngineData[1],"N2",nil,3)).." "..Table_ValGet(EngineData[1],"N2",nil,2)..")",intable) end
    end
    if index == 11 then
        if Table_ValGet(EngineDamage_Profile,"DMG_TRQ",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        --print(Table_ValGet(EngineData[1],"TRQ",nil,3))
        if Table_ValGet(EngineData[1],"TRQ",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%d",Table_ValGet(EngineData[1],"TRQ",nil,3)).." "..Table_ValGet(EngineData[1],"TRQ",nil,2)..")",intable) end
    end
    --print(index)
end
--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function EngineDamage_Menu_Build(ParentMenuID)
    local Menu_Indices = {}
    for i=2,#EngineDamage_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,EngineDamage_Menu_Items[1],ffi.cast("void *","None"),1)
        EngineDamage_Menu_ID = XPLM.XPLMCreateMenu(EngineDamage_Menu_Items[1],ParentMenuID,Menu_Index,function(inMenuRef,inItemRef) EngineDamage_Menu_Callbacks(inItemRef) end,ffi.cast("void *",EngineDamage_Menu_Pointer))
        for i=2,#EngineDamage_Menu_Items do
            if EngineDamage_Menu_Items[i] ~= "[Separator]" then
                EngineDamage_Menu_Pointer = EngineDamage_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(EngineDamage_Menu_ID,EngineDamage_Menu_Items[i],ffi.cast("void *",EngineDamage_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(EngineDamage_Menu_ID)
            end
        end
        for i=2,#EngineDamage_Menu_Items do
            if EngineDamage_Menu_Items[i] ~= "[Separator]" then
                EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,i)
            end
        end
        LogOutput(EngineDamage_Config_Vars[1][1].." Menu initialized!")
    end
end
--[[

RUNTIME FUNCTIONS

]]
--[[ Main timer for the engine damage logic ]]
function EngineDamage_MainTimer()
    if DebugIsEnabled() == 1 then EngineDamage_DebugWindow_Update() end
    Dataref_Read(EngineDamage_Drefs_Cont,4,"All") -- Populate dataref container with current values
    EngineDamage_CheckStress()
end
--[[

INITIALIZATION

]]
--[[ First start of the engine damage module ]]
function EngineDamage_FirstRun()
    Preferences_Write(EngineDamage_Config_Vars,XLuaUtils_PrefsFile)
    --[[if FileExists(XLuaUtils_Path..EngineDamage_Profile_File) then
        LogOutput(EngineDamage_Config_Vars[1][1]..": Existing engine profile found, skipping creation of a new one!")
    else
        EngineDamage_Profile_Write(XLuaUtils_Path..EngineDamage_Profile_File)
    end]]
    Preferences_Read(XLuaUtils_PrefsFile,EngineDamage_Config_Vars)
    DrefTable_Read(Dref_List_Once,EngineDamage_Drefs_Once)
    DrefTable_Read(Dref_List_Cont,EngineDamage_Drefs_Cont)
    EngineDamage_Menu_Build(XLuaUtils_Menu_ID)
    LogOutput(EngineDamage_Config_Vars[1][1]..": First Run!")
end
--[[ Initializes engine damage at every startup ]]
function EngineDamage_Init()
    math.randomseed(os.time()) -- Generate random seed for random number generator
    Preferences_Read(XLuaUtils_PrefsFile,EngineDamage_Config_Vars)
    DrefTable_Read(Dref_List_Once,EngineDamage_Drefs_Once)
    DrefTable_Read(Dref_List_Cont,EngineDamage_Drefs_Cont)
    Dataref_Read(EngineDamage_Drefs_Once,4,"All") -- Populate dataref container with current values
    Dataref_Read(EngineDamage_Drefs_Cont,4,"All") -- Populate dataref container with current values
    EngineDamage_Profile_Read(XLuaUtils_Path..EngineDamage_Profile_File)
    EngineDamage_Notifications()
    EngineDamage_ProfileAircraft()
    run_at_interval(EngineDamage_MainTimer,Table_ValGet(EngineDamage_Config_Vars,"MainTimerInterval",nil,2))
    LogOutput(EngineDamage_Config_Vars[1][1]..": Initialized!")
end
--[[ Reloads the engine damage configuration ]]
function EngineDamage_Reload()
    Preferences_Read(XLuaUtils_PrefsFile,EngineDamage_Config_Vars)
    EngineDamage_Profile_Read(XLuaUtils_Path..EngineDamage_Profile_File)
    EngineDamage_ProfileAircraft()
    EngineDamage_Notifications()
    LogOutput(EngineDamage_Config_Vars[1][1]..": Reloaded!")
end
