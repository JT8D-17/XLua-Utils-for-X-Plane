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
-- ID, Enabled, base parameter redline (-1 = use dataref val), base redline scalar to calculate damage accumulation rate from, base limit damage tolerance (in seconds), damage tolerance at node calculated from base redline * scalar (in seconds), scalar for damage rate when damage is receding
{"DMG_CHT",0,-1,1.5,300,10,0.75},
{"DMG_EGT",0,-1,1.5,240,120,0.75},
{"DMG_ITT",0,-1,1.5,120,5,0.75},
{"DMG_N1",0,-1,1.5,500,10,0.75},
{"DMG_N2",0,-1,1.5,400,10,0.75},
{"DMG_TRQ",0,-1,1.5,50,15,0.75},
{"RandomizeLimit",0.98,1.04},       -- Randomization range for limit values
{"RandomizeDamage",0.98,1.02},       -- Randomization range for incurred damage
}
--[[ List of continuously monitored datarefs used by this module ]]
local Dref_List_Cont = {
{"Eng_CHT","sim/flightmodel2/engines/CHT_deg_C"}, -- deg C
{"Eng_EGT","sim/flightmodel2/engines/EGT_deg_C"}, -- deg C
{"Eng_ITT","sim/flightmodel2/engines/ITT_deg_C"}, -- deg C
{"Eng_N1","sim/flightmodel2/engines/N1_percent"}, -- %
{"Eng_N2","sim/flightmodel2/engines/N2_percent"}, -- %
{"Eng_TRQ","sim/flightmodel/engine/POINT_driv_TRQ"}, -- Nm
}
--[[ List of one-shot updated datarefs used by this module ]]
local Dref_List_Once = {
{"Eng_Num","sim/aircraft/engine/acf_num_engines"}, -- Number of engines
{"Type_Eng","sim/aircraft/prop/acf_en_type"}, -- Engine type 0 = recip carb, 1 = recip injected, 3 = electric, 5 = single spool jet, 6 = rocket, 7 = multi spool jet, 9 = free turboprop, 10 = fixed turboprop
{"Type_Prop","sim/aircraft/prop/acf_prop_type"}, -- Propeller type, 0 = fixed pitch, 1 = variable pitch, 3 = main rotor, 5 = tail rotor, 9 == jet
{"Limit_CHT","sim/aircraft/engine/acf_max_CHT"},     -- Maximum CHT
{"Limit_EGT","sim/aircraft/engine/acf_max_EGT"},     -- Maximum EGT
{"Limit_ITT","sim/aircraft/engine/acf_max_ITT"},     -- Maximum ITT
{"Limit_N1","sim/aircraft/limits/red_hi_N1"},     -- Maximum N1
{"Limit_N2","sim/aircraft/limits/red_hi_N2"},     -- Maximum N2
{"Limit_TRQ","sim/flightmodel/engine/POINT_max_TRQ"}, -- Maximum torque
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
"N1",                       -- Item index: 8
"N2",                       -- Item index: 9
"TRQ",                      -- Item index: 10
"[Separator]",              -- Item index: 11
"All Off & Repair",         -- Item index: 12
}
--[[ Menu variables for FFI ]]
local EngineDamage_Menu_ID = nil
local EngineDamage_Menu_Pointer = ffi.new("const char")
--[[ Other variables ]]
local EngineData={} -- Engine data container
local Notifications_OldStatus={CHT=0,EGT=0,ITT=0,N1=0,N2=0,TRQ=0} -- Helper to only display notifications upon changes
--[[

DEBUG WINDOW

]]
--[[ Adds things to the debug window ]]
function EngineDamage_DebugWindow_Init()
    Debug_Window_AddLine("ED_Spacer"," ")
    Debug_Window_AddLine("ED_Header","===== Engine Damage =====")
    --Debug_Window_AddLine("ED_MixtureMode") -- Reserving a line in the debug window only requires an ID.
    for i=1,Table_ValGet(EngineDamage_Drefs_Once,"Eng_Num",4,1) do
        Debug_Window_AddLine("ED_E"..i.."Head","Engine "..i..":")
        if Table_ValGet(EngineDamage_Profile,"DMG_CHT",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."CHT") end
        if Table_ValGet(EngineDamage_Profile,"DMG_EGT",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."EGT") end
        if Table_ValGet(EngineDamage_Profile,"DMG_ITT",nil,2) == 1 then Debug_Window_AddLine("ED_E"..i.."ITT") end
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
            if Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,2) == 1 then Debug_Window_ReplaceLine("ED_E"..i..EngineData[i][j][1],"  "..EngineData[i][j][1].." Stress: "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,7).."/"..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5).." (+/-".." nnn / "..Table_ValGet(EngineDamage_Config_Vars,"MainTimerInterval",nil,2).." s)") end
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
--[[ Calculates the slope between two set points ]]
function EngineDamage_CalculateSlope(x1,x2,y1,y2)
    local dy = y2-y1
    local dx = x2-x1
    local slope = dy/dx

end
--[[ Gathers information about the aircraft's engine type and auto-actiavtes suitable damage datarefs ]]
function EngineDamage_ProfileAircraft()
    -- Loop through available engines
    for i=1,Table_ValGet(EngineDamage_Drefs_Once,"Eng_Num",4,1) do
        EngineData[i] = {
            -- ID, unit, base limit, base limit randomized, stress tolerance randomized, stress rate slope, stress accumulated
            {"CHT","°C",-1,-1,-1,-1,0},
            {"EGT","°C",-1,-1,-1,-1,0},
            {"ITT","°C",-1,-1,-1,-1,0},
            {"N1","%",-1,-1,-1,-1,0},
            {"N2","%",-1,-1,-1,-1,0},
            {"TRQ","Nm",-1,-1,-1,-1,0},
        }
        -- Loop through engine data table and see if the parameters in its subtables can be populated
        for j=1,#EngineData[i] do
            -- Adjust property unit if it's not Celsius
            if Table_ValGet(EngineData[i],"CHT",nil,1) == "CHT" and Table_ValGet(EngineDamage_Drefs_Once,"Unit_CHT_C",4,1) == 0 then Table_ValSet(EngineData[i],"CHT",nil,2,"°F") end
            if Table_ValGet(EngineData[i],"EGT",nil,1) == "EGT" and Table_ValGet(EngineDamage_Drefs_Once,"Unit_EGT_C",4,1) == 0 then Table_ValSet(EngineData[i],"EGT",nil,2,"°F") end
            if Table_ValGet(EngineData[i],"ITT",nil,1) == "ITT" and Table_ValGet(EngineDamage_Drefs_Once,"Unit_ITT_C",4,1) == 0 then Table_ValSet(EngineData[i],"ITT",nil,2,"°F") end
            --
            if Table_ValGet(EngineDamage_Drefs_Once,"Limit_"..EngineData[i][j][1],4,1) > 100 or Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,3) > -1 then
                if Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,3) > -1 then -- Check if there is a user override for the limit
                    Table_ValSet(EngineData[i],EngineData[i][j][1],nil,3,Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,3)) -- Assign the user override
                else
                    Table_ValSet(EngineData[i],EngineData[i][j][1],nil,3,Table_ValGet(EngineDamage_Drefs_Once,"Limit_"..EngineData[i][j][1],4,1)) -- Assign the dataref limit
                end
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,6,math.floor(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,5)))) -- Randomize damage tolerance a bit
                -- 1. Randomize the base limit and store it in EngineData, calculate the upper limit (base limit * scalar) and randomize
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,4,math.ceil(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineData[i],EngineData[i][j][1],nil,3))))
                local limit_high = math.floor(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineData[i],EngineData[i][j][1],nil,3) * Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,4)))
                -- 2. Randomize the stress tolerance at base limit (seconds) and store it in EngineData, randomize the stress tolerance at upper limit (seconds)
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,5,math.floor(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,5))))
                local tolerance_high = math.floor(EngineDamage_Randomize("RandomizeLimit",Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,6)))
                -- 3. Stress accumulation rate is always 1 at base limit, but needs to be calculated for upper limit. This will normalize the sustained stress to the value range at the base limit. From that, calculate the slope and store it in engine data.
                Table_ValSet(EngineData[i],EngineData[i][j][1],nil,6,math.abs(((Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5) / tolerance_high) - 1) / (limit_high - Table_ValGet(EngineData[i],EngineData[i][j][1],nil,4))))
                LogOutput("Aircraft engine "..i.." "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,1).." tolerates stress at "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,4).." "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,2).." for "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,5).." s and its stress rate increases by "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,6).." per "..Table_ValGet(EngineData[i],EngineData[i][j][1],nil,2).." above the limit.")
            end
        end
    end
end
--[[ ]]
local function EngineDamage_CheckStress()
    Dataref_Read(EngineDamage_Drefs_Cont,4,"All") -- Populate dataref container with currrent values
    for i=1,#EngineData do -- Loop through all engines
        for j=1,#EngineData[i] do -- Loop through all engine parameters
            if Table_ValGet(EngineDamage_Profile,"DMG_"..EngineData[i][j][1],nil,2) == 1 and EngineData[i][j][3] > -1 then -- Check if parameter is enabled and has a limit set
                if EngineData[i][j][2] == "°F" then end -- Input value fahrenheit adjustment
                --print(i.." "..EngineData[i][j][1]..": "..Table_ValGet(EngineDamage_Drefs_Cont,"Eng_"..EngineData[i][j][1],4,i))

            end
        end
    end
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
                            EngineDamage_Profile[i][j] = tonumber(splitline[j])
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
    file:write("# ID, Enabled, base parameter redline (-1 = use dataref val), base redline scalar to calculate damage accumulation rate from, base limit damage tolerance (in seconds), damage tolerance at node calculated from base redline * scalar (in seconds), scalar for damage rate when damage is receding")
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
            end
            if i == 6 then
                if Table_ValGet(EngineDamage_Profile,"DMG_EGT",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_EGT",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_EGT",nil,2,0) end
            end
            if i == 7 then
                if Table_ValGet(EngineDamage_Profile,"DMG_ITT",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_ITT",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_ITT",nil,2,0) end
            end
            if i == 8 then
                if Table_ValGet(EngineDamage_Profile,"DMG_N1",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_N1",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_N1",nil,2,0) end
            end
            if i == 9 then
                if Table_ValGet(EngineDamage_Profile,"DMG_N2",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_N2",nil,2,1) else Table_ValSet(EngineDamage_Profile,"DMG_N2",nil,2,0) end
            end
            if i == 10 then
                if Table_ValGet(EngineDamage_Profile,"DMG_TRQ",nil,2) == 0 then Table_ValSet(EngineDamage_Profile,"DMG_TRQ",nil,2,1)else Table_ValSet(EngineDamage_Profile,"DMG_TRQ",nil,2,0) end
            end
            if i == 12 then
                Table_ValSet(EngineDamage_Profile,"DMG_CHT",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,5)
                Table_ValSet(EngineDamage_Profile,"DMG_EGT",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,6)
                Table_ValSet(EngineDamage_Profile,"DMG_ITT",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,7)
                Table_ValSet(EngineDamage_Profile,"DMG_N1",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,8)
                Table_ValSet(EngineDamage_Profile,"DMG_N2",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,9)
                Table_ValSet(EngineDamage_Profile,"DMG_TRQ",nil,2,0) EngineDamage_Menu_Watchdog(EngineDamage_Menu_Items,10)
                DebugLogOutput(EngineDamage_Config_Vars[1][1]..": Disabled all engine damage sources")
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
        if Table_ValGet(EngineDamage_Profile,"DMG_N1",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        if Table_ValGet(EngineData[1],"N1",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%d",Table_ValGet(EngineData[1],"N1",nil,3)).." "..Table_ValGet(EngineData[1],"N1",nil,2)..")",intable) end
    end
    if index == 9 then
        if Table_ValGet(EngineDamage_Profile,"DMG_N2",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        if Table_ValGet(EngineData[1],"N2",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%d",Table_ValGet(EngineData[1],"N2",nil,3)).." "..Table_ValGet(EngineData[1],"N2",nil,2)..")",intable) end
    end
    if index == 10 then
        if Table_ValGet(EngineDamage_Profile,"DMG_TRQ",nil,2) == 1 then Menu_CheckItem(EngineDamage_Menu_ID,index,"Activate")
        else Menu_CheckItem(EngineDamage_Menu_ID,index,"Deactivate") end
        if Table_ValGet(EngineData[1],"TRQ",nil,3) > -1 then Menu_ChangeItemSuffix(EngineDamage_Menu_ID,index,"("..string.format("%d",Table_ValGet(EngineData[1],"TRQ",nil,3)).." "..Table_ValGet(EngineData[1],"TRQ",nil,2)..")",intable) end
    end
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
    Dataref_Read(EngineDamage_Drefs_Once,4,"All") -- Populate dataref container with currrent values
    Dataref_Read(EngineDamage_Drefs_Cont,4,"All") -- Populate dataref container with currrent values
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
    EngineDamage_Notifications()
    LogOutput(EngineDamage_Config_Vars[1][1]..": Reloaded!")
end
