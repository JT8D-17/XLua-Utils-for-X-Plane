--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
local Automix_Profile_File = "automixture_profile.cfg"
local Automix_HasProfile = 0 -- Used by util_automixture.lua
--[[ Table that contains the configuration Variables for the NC Headset module ]]
local Automix_Config_Vars = {
{"AUTOMIXTURE"},
{"MainTimerInterval",0.05},    -- Main timer interval, in seconds
{"MixtureMode","Manual","Manual","Manual","Manual","Manual","Manual","Manual","Manual"}, -- "Manual", "IdleCutoff" "AutoLean", "AutoRich", "FullRich"
}
--[[ Default values for the automixture profile ]]
local Automix_Profile = {
{"AirFuelRatio_Targets",12.5,16.25}, -- The air-fuel-ratio targets for auto lean and auro rich
{"Eng_Displace_Litres",30.0}, -- The engine displacement in litres
{"Eng_Volumetric_Efficiency",1.0}, -- The volumetric efficiency of the engine
{"Gas_Constant",287.058}, -- The gas constant of air in J/kg*K
{"Lever_Detents",0.05,0.4,0.9,0.975}, -- The mixture lever detents: Idle Cutoff, Auto Lean, Auto Rich, Full Rich
{"Lever_Detent_Magnet",0.04}, -- "Sticky" range for the detents
{"Minimum_RPM",500}, -- Minimum RPM at which the automixture modes are active
{"Mixture_Range",0.58,1.0}, -- Value range for the default mixture function
}
--[[ Container tables for items to be replaced in files. First item is the path, all following subtables contain target and replacement strings.
Format: {Path,{target string, replacement string},{target string, replacement string}, etc.}}
Paths are relative to the aircraft main folder. Square brackets and minus signs must be escaped with percent signs.
]]
local Automix_Replacements_Temp = {}
local Automix_FileReplacements_Files = {}
--[[ List of continuously monitored datarefs used by this module ]]
local Dref_List_Cont = {
{"Eng_Carb","sim/cockpit2/engine/indicators/carburetor_temperature_C"}, -- deg C
{"Eng_FADEC","sim/aircraft/overflow/acf_drive_by_wire"},
{"Eng_FF","sim/flightmodel/engine/ENGN_FF_"}, -- kg/s
{"Eng_MAP","sim/cockpit2/engine/indicators/MPR_in_hg"}, -- inHg
{"Eng_Mixt","sim/cockpit2/engine/actuators/mixture_ratio"}, -- ratio
{"Eng_RPM","sim/cockpit2/engine/indicators/engine_speed_rpm"}, -- RPM
}
--[[ List of one-shot updated datarefs used by this module ]]
local Dref_List_Once = {
{"Eng_Num","sim/aircraft/engine/acf_num_engines"}, -- Number of engines
{"Type_Eng","sim/aircraft/prop/acf_en_type"}, -- Engine type 0 = recip carb, 1 = recip injected, 3 = electric, 5 = single spool jet, 6 = rocket, 7 = multi spool jet, 9 = free turboprop, 10 = fixed turboprop
}
--[[ Container table for continuously monitored datarefs, which are stored in subtables {alias,dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local Automix_Drefs_Cont = {
"DREFS_CONT",
}
--[[ Container table for continuously monitored datarefs, which are stored in subtables {alias,dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local Automix_Drefs_Once = {
"DREFS_ONCE",
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local Automix_Menu_Items = {
"Automixture",              -- Menu title, index 1
"",                         -- Item index: 2
"[Separator]",              -- Item index: 3
"Full Rich",                -- Item index: 4
"Auto Rich",                -- Item index: 5
"Auto Lean",                -- Item index: 6
"Idle Cutoff",              -- Item index: 7
"Manual",                   -- Item index: 8
}
--[[ Menu variables for FFI ]]
local Automix_Menu_ID = nil
local Automix_Menu_Pointer = ffi.new("const char")
--[[ Temporary variables ]]
local Automix_Vars = {
p_in = { }, -- Intake air pressure
V_d = 0, -- Engine displacement, in m³
N_e = { }, -- Engine RPM, in 1/s
R_spec = 0, -- Specific air constant, in J /kg*K
T_in = { }, -- Manifold intake temperature, in K
m_dot = { }, -- Mass flow intake air, in kg/s
AFR_Act = { }, -- Actual air-fuel ratio
AFR_Tgt = { },  -- Target air-fuel ratio
}
--[[

DEBUG WINDOW

]]
--[[ Adds things to the debug window ]]
function Automix_DebugWindow_Init()
    if Table_ValGet(Automix_Drefs_Once,"Type_Eng",4,1) < 2 then -- Only initialize automixture if the engine is a reciprocating type
        Debug_Window_AddLine("AM_Spacer"," ")
        Debug_Window_AddLine("AM_Header","===== Automixture =====")
        Debug_Window_AddLine("AM_EngineProps","Engine Displacement: "..Table_ValGet(Automix_Profile,"Eng_Displace_Litres",nil,2).." l = "..string.format("%.3f",Automix_Vars.V_d).." m³")
        Debug_Window_AddLine("AM_AirProps","Gas Constant: "..Table_ValGet(Automix_Profile,"Gas_Constant",nil,2).." J / kg*K")
        for i=1,Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1) do
            Debug_Window_AddLine("AM_E"..i.."L0","Engine "..i..":") -- Reserving a line in the debug window only requires an ID.
            Debug_Window_AddLine("AM_E"..i.."MM")
            Debug_Window_AddLine("AM_E"..i.."L1")
            Debug_Window_AddLine("AM_E"..i.."L2")
            Debug_Window_AddLine("AM_E"..i.."L3")
            Debug_Window_AddLine("AM_E"..i.."L4")
            Debug_Window_AddLine("AM_E"..i.."L5")
        end
    end
end
--[[ Updates the debug window ]]
function Automix_DebugWindow_Update()
    for i=1,Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1) do
        Debug_Window_ReplaceLine("AM_E"..i.."MM","  Mode: "..Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+1)) -- Replaces a line by means of its ID. Use this within a timer to refresh the displayed values of variables.
        Debug_Window_ReplaceLine("AM_E"..i.."L1","  p_in: "..string.format("%.3f",Table_ValGet(Automix_Drefs_Cont,"Eng_MAP",4,i)).." inHg = "..string.format("%.3f",Automix_Vars.p_in[i]).." N/m²")
        Debug_Window_ReplaceLine("AM_E"..i.."L2","  N_e: "..string.format("%.3f",Table_ValGet(Automix_Drefs_Cont,"Eng_RPM",4,i)).." 1/min = "..string.format("%.3f",Automix_Vars.N_e[i]).." 1/s")
        Debug_Window_ReplaceLine("AM_E"..i.."L3","  T_in: "..string.format("%.3f",Table_ValGet(Automix_Drefs_Cont,"Eng_Carb",4,i)).." °C = "..string.format("%.3f",Automix_Vars.T_in[i]).." K")
        Debug_Window_ReplaceLine("AM_E"..i.."L4","  --> AFR: "..string.format("%.2f",Automix_Vars.AFR_Act[i]).." = "..string.format("%.4f",Automix_Vars.m_dot[i]).." kg/s air / "..string.format("%.4f",Table_ValGet(Automix_Drefs_Cont,"Eng_FF",4,i)).." kg/s fuel")
        Debug_Window_ReplaceLine("AM_E"..i.."L5","  AFR Target / Mixture: "..string.format("%.2f",Automix_Vars.AFR_Tgt[i]).." / "..string.format("%.3f",Table_ValGet(Automix_Drefs_Cont,"Eng_Mixt",4,i)))
    end
end
--[[

FUNCTIONS

]]
--[[ Automixture profile read ]]
function Automix_Profile_Read(inputfile)
    local file = io.open(inputfile, "r") -- Check if file exists
    if file then
        Automix_HasProfile = 1
        LogOutput("FILE READ START: Engine Profile")
        local counter = 0
        Automix_Replacements_Temp = {}
        for line in file:lines() do
            if string.match(line,"^[^#]") then
                counter = counter + 1
                local splitline = SplitString(line,"([^,]+)")
                splitline[1] = TrimEndWhitespace(splitline[1]) -- Trims the end whitespace from a string
                if splitline[1] == "CONFIG" then -- Profile configuration
                    for i=1,#Automix_Profile do
                        if splitline[2] == Automix_Profile[i][1] then
                            for j=3,#splitline do
                                Automix_Profile[i][j-1] = tonumber(splitline[j])
                            end
                            --print(table.concat(Automix_Profile[i],","))
                        end
                    end
                end
                if splitline[1] == "REPLACE" then -- Object file replacements
                    Automix_Replacements_Temp[#Automix_Replacements_Temp+1] = {}
                    for i=2,#splitline do
                         Automix_Replacements_Temp[#Automix_Replacements_Temp][i-1] = splitline[i]
                    end
                    --print(table.concat(Automix_Replacements_Temp[#Automix_Replacements_Temp],","))
                end
            end
        end
        file:close()
        if counter > 1 then LogOutput("FILE READ SUCCESS: "..inputfile) else LogOutput("FILE READ ERROR: "..inputfile) end
    else
        LogOutput("FILE NOT FOUND: Automixture Profile")
    end
end
--[[ Automixture profile write ]]
function Automix_Profile_Write(outputfile)
    LogOutput("FILE WRITE START: Automixture Profile")
    local file = io.open(outputfile, "w")
    file:write("# XLua Utils automixture profile generated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# This file contains profile information for XLua Utils' automixture module.\n")
    file:write("#\n")
    file:write("# Line format pattern: CATEGORY, Name, Value 1, Value 2, etc.\n")
    file:write("# Supports these entries:\n")
    file:write("# - CONFIG,[subtable identifier in the target table],[value 1],[value 2],etc.\n")
    file:write("# - REPLACE,[path to file],[expression or line to be replaced],[replacement line or expression]\n")
    file:write("#\n")
    file:write("# Replacement usage rules and notes:\n")
    file:write("# - Only text files (OBJ or else) are supported, not binary files!\n")
    file:write("# - A backup of the file is made before the first modification.\n")
    file:write("# - Replacements work line by line.\n")
    file:write("# - Multiple replacements per file are possible and supported. Just create multiple entries pointing to the same file.\n")
    file:write("# - The path to the file is stated relative to the aircraft's root folder!\n")
    file:write("# - Square parenthesis ('[' and ']') must be prefixed with a percent character ('%'), i.e. 'engine_RPM%[2%]'.\n")
    file:write("# - Minus signs must be prefixed with percent characters ('%') e.g. 'ANIM_rotate_key %-85.000000'.\n")
    file:write("#\n")
    for i=1,#Automix_Profile do
        file:write("CONFIG,"..table.concat(Automix_Profile[i],",").."\n")
    end
    file:write("#REPLACE,objects/My_Example.obj,This is a target string or line %-%[0%],This is the replacement line") -- Example replacement line
    if file:seek("end") > 0 then LogOutput("FILE WRITE SUCCESS: Automixture Profile") else LogOutput("FILE WRITE ERROR: Automixture Profile") end
    file:close()
end
--[[ Sort file replacement operations per file by finding unique filenames first and then write all operations to be performed in that file as subtables to the filename ]]
function Automix_Sort_By_Filename(intable,outtable)
    outtable = {}
    local temptable = {}
    local found = false
    -- Find unique filenames and store them in temporary table
    for i=1,#intable do
        found = false
        for j=0,#temptable do
            if temptable[j] == intable[i][1] then found = true end
        end
        if not found then table.insert(temptable,intable[i][1]) end
    end
    -- Prepare outputtable
    for i=1,#temptable do
        outtable[i] = {temptable[i]}
    end
    -- Add search and replacement strings for each file as subtable
    for i=1,#intable do
        for j=1,#outtable do
            if intable[i][1] == outtable[j][1] then
                outtable[j][#outtable[j]+1] = { }
                for k=2,#intable[i] do
                    outtable[j][#outtable[j]][k-1] = intable[i][k]
                end
                --print("For "..outtable[j][1]..": "..table.concat(outtable[j][#outtable[j]],";"))
            end
        end
    end
    for i=1,#outtable do print(outtable[i][1].." has "..(#outtable[i]-1).." replacements") end
    return outtable
end
--[[ Modifies a (text) file by reading it into a table, writing it to a backup file if none exists, modifying it according to the input table by line replacement and writing the modified file back to disk ]]
function Automix_File_Modifier(inputtable)
    for i=1,#inputtable do -- Loop through input table
        local temptable = { }
        local counter = 0
        local inputfile = tostring(ACF_Folder..inputtable[i][1])
        local hasinput = FileExists(inputfile)
        local backupfile = inputfile..".backup"
        local hasbackup = FileExists(backupfile)
        --print("Input: "..tostring(hasinput)..", Backup: "..tostring(hasbackup))
        if hasinput then
            LogOutput("FILE MOD: START READ ("..inputfile..")")
            local file
            if hasbackup then
                LogOutput("FILE MOD: BACKUP EXISTS, READING FROM BACKUP FILE")
                file = io.open(backupfile,"r")
            else
                file = io.open(inputfile,"r")
            end
            for line in file:lines() do
                temptable[#temptable+1] = line
            end
            file:close()
            LogOutput("FILE MOD: END READ ("..#temptable.." lines)")
        else
            LogOutput("FILE MOD: NOT FOUND ("..inputfile..")")
        end
        -- Modify file when it was successfully read
        if #temptable > 0 then
            -- Make backup
            if not hasbackup then
                file = io.open(backupfile,"w")
                for j=1,#temptable do
                    file:write(temptable[j].."\n")
                end
                if file:seek("end") > 0 then LogOutput("FILE MOD: BACKUP SUCCESS") else LogOutput("FILE MOD: BACKUP ERROR") end
                file:close()
            end
            -- Modify file
            for j=1,#temptable do
                for k=2,#inputtable[i] do
                    -- Escape sequences for square brackets
                    --str = string.gsub(temptable[j],"%[","%%[")
                    --str = string.gsub(str,"%]","%%]")
                    if string.match(temptable[j],inputtable[i][k][1]) then
                        LogOutput("FOUND: "..temptable[j])
                        temptable[j] = string.gsub(temptable[j],inputtable[i][k][1],inputtable[i][k][2])
                        LogOutput("REPLACED: "..temptable[j])
                        counter = counter + 1
                    end
                end
            end
            -- Write modified file if replacements were made
            if counter > 0 then
                file = io.open(inputfile,"w")
                for j=1,#temptable do
                    file:write(temptable[j].."\n")
                end
                if file:seek("end") > 0 then LogOutput("FILE MOD: SUCCESS ("..inputfile..")") else LogOutput("FILE MOD: FAILURE ("..inputfile..")") end
                file:close()
            end
        end
    end
end
--[[ Applies the automixture profile ]]
function Automix_Profile_Apply()
    -- Apply constants from profile file or defaults
    Automix_Vars.V_d = Table_ValGet(Automix_Profile,"Eng_Displace_Litres",nil,2) / 1000 -- Displacement: l to m³
    Automix_Vars.R_spec = Table_ValGet(Automix_Profile,"Gas_Constant",nil,2) -- J / kg K
    -- Create table with temporary variables for each engine
    for i=1,Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1) do
        Automix_Vars.p_in[i] = 0
        Automix_Vars.N_e[i] = 0
        Automix_Vars.T_in[i] = 0
        Automix_Vars.m_dot[i] = 0
        Automix_Vars.AFR_Act[i] = 0
        Automix_Vars.AFR_Tgt[i] = 0
    end
end
--[[ Sets the mxiture lever animations from the menu ]]
function Automix_Menu_To_Anim(mixmode)
    for i=0,(Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1)-1) do
        if mixmode == "IdleCutoff" then
            DRef_MixtureLeversAnim[i] = 0 -- Idle cutoff
            DRef_ManualToggle = 0
        end
        if mixmode == "AutoLean" then
            DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) -- Auto lean
            DRef_ManualToggle = 0
        end
        if mixmode == "AutoRich" then
            DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) -- Auto rich
            DRef_ManualToggle = 0
        end
        if mixmode == "FullRich" then
            DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,5) -- Full rich
            DRef_ManualToggle = 0
        end
        if mixmode == "Manual" then
            DRef_ManualToggle = 1
        end
        Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,mixmode)
        DebugLogOutput(Automix_Config_Vars[1][1]..": Set automixture mode for engine "..i.." to "..Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+2))
        DisplayNotification("Automixture mode for engine "..i..": "..Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+2),"Nominal",4)
        --print("Engine "..i.." mixture mode is "..Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+2))
    end
end
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function Automix_Menu_Callbacks(itemref)
    for i=2,#Automix_Menu_Items do
        if itemref == Automix_Menu_Items[i] then
            if i == 2 then
                if Automix_HasProfile == 0 then Automix_Profile_Write(Xlua_Utils_Path..Automix_Profile_File) Automix_Profile_Read(Xlua_Utils_Path..Automix_Profile_File) Automix_Menu_Watchdog(Automix_Menu_Items,2) end
                if Automix_HasProfile == 1 then Automix_Reload() end
            end
            if i == 4 then
                Automix_Menu_To_Anim("FullRich")
            end
            if i == 5 then
                Automix_Menu_To_Anim("AutoRich")
            end
            if i == 6 then
                Automix_Menu_To_Anim("AutoLean")
            end
            if i == 7 then
                Automix_Menu_To_Anim("IdleCutoff")
            end
            if i == 8 then
                Automix_Menu_To_Anim("Manual")
            end
            Automix_Menu_Watchdog(Automix_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function Automix_Menu_Watchdog(intable,index)
    if index == 2 then
        if Automix_HasProfile == 0 then Menu_ChangeItemPrefix(Automix_Menu_ID,index,"Generate Automix Profile",intable)
        elseif Automix_HasProfile == 1 then Menu_ChangeItemPrefix(Automix_Menu_ID,index,"Reload Automix Profile",intable) end
    end
    if index == 4 then
        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,2) == "FullRich" then
            Menu_CheckItem(Automix_Menu_ID,index,"Activate")
            Menu_CheckItem(Automix_Menu_ID,5,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,6,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,7,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,8,"Deactivate")
        end
    end
    if index == 5 then
        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,2) == "AutoRich" then
            Menu_CheckItem(Automix_Menu_ID,4,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,index,"Activate")
            Menu_CheckItem(Automix_Menu_ID,6,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,7,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,8,"Deactivate")
        end
    end
    if index == 6 then
        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,2) == "AutoLean" then
            Menu_CheckItem(Automix_Menu_ID,4,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,5,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,index,"Activate")
            Menu_CheckItem(Automix_Menu_ID,7,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,8,"Deactivate")
        end
    end
    if index == 7 then
        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,2) == "IdleCutoff" then
            Menu_CheckItem(Automix_Menu_ID,4,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,5,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,6,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,index,"Activate")
            Menu_CheckItem(Automix_Menu_ID,8,"Deactivate")
        end
    end
    if index == 8 then
        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,2) == "Manual" then
            Menu_CheckItem(Automix_Menu_ID,4,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,5,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,6,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,7,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,index,"Activate")
        end
    end
    if index == 9 then -- Deactivate all menu mixture modes
            Menu_CheckItem(Automix_Menu_ID,4,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,5,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,6,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,7,"Deactivate")
            Menu_CheckItem(Automix_Menu_ID,8,"Deactivate")
    end
end
--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function Automix_Menu_Build(ParentMenuID)
    if Table_ValGet(Automix_Drefs_Once,"Type_Eng",4,1) < 2 then -- Only initialize automixture menu if the engine is a reciprocating type
        local Menu_Indices = {}
        for i=2,#Automix_Menu_Items do Menu_Indices[i] = 0 end
        if XPLM ~= nil then
            local Menu_Index = nil
            Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,Automix_Menu_Items[1],ffi.cast("void *","None"),1)
            Automix_Menu_ID = XPLM.XPLMCreateMenu(Automix_Menu_Items[1],ParentMenuID,Menu_Index,function(inMenuRef,inItemRef) Automix_Menu_Callbacks(inItemRef) end,ffi.cast("void *",Automix_Menu_Pointer))
            for i=2,#Automix_Menu_Items do
                if Automix_Menu_Items[i] ~= "[Separator]" then
                    Automix_Menu_Pointer = Automix_Menu_Items[i]
                    Menu_Indices[i] = XPLM.XPLMAppendMenuItem(Automix_Menu_ID,Automix_Menu_Items[i],ffi.cast("void *",Automix_Menu_Pointer),1)
                else
                    XPLM.XPLMAppendMenuSeparator(Automix_Menu_ID)
                end
            end
            for i=2,#Automix_Menu_Items do
                if Automix_Menu_Items[i] ~= "[Separator]" then
                    Automix_Menu_Watchdog(Automix_Menu_Items,i)
                end
            end
            LogOutput(Automix_Config_Vars[1][1].." Menu initialized!")
        end
    end
end
--[[

RUNTIME FUNCTIONS

]]
--[[ Main timer for the Automixture logic ]]
function Automix_MainTimer()
    if DebugIsEnabled() == 1 then Automix_DebugWindow_Update() end
    Dataref_Read(Automix_Drefs_Cont,4,"All") -- Update continuously monitored datarefs
    --[[ Calculate mass flow per engine
    Source: Equation 3.14 from: Fantenberg, E. "Estimation of Air Mass Flow in Engines with Variable Valve Timing",Linköping, 2018
    ]]
    for i=1,Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1) do
        Automix_Vars.p_in[i] = Table_ValGet(Automix_Drefs_Cont,"Eng_MAP",4,i) * 3386.388333333334 -- inHG to N/m²
        Automix_Vars.N_e[i] = Table_ValGet(Automix_Drefs_Cont,"Eng_RPM",4,i) / 60 -- 1/min to 1 / s
        Automix_Vars.T_in[i] = Table_ValGet(Automix_Drefs_Cont,"Eng_Carb",4,i) + 273.15 -- °C in K
        Automix_Vars.m_dot[i] = (Automix_Vars.p_in[i] * Automix_Vars.V_d * Automix_Vars.N_e[i]) / (2 * Automix_Vars.R_spec * Automix_Vars.T_in[i]) -- Factor 2 accounts for 1 intake in 2 revolutions in a 4 stroke engine
        Automix_Vars.AFR_Act[i] = Automix_Vars.m_dot[i] / Table_ValGet(Automix_Drefs_Cont,"Eng_FF",4,i)
        --
        if Table_ValGet(Automix_Drefs_Cont,"Eng_FADEC",4,1) == 1 then Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+1,"Manual") end

        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+1) == "FullRich" then Automix_Vars.AFR_Tgt[i] = 0 Table_ValSet(Automix_Drefs_Cont,"Eng_Mixt",4,i,1.0) Table_ValSet(Automix_Drefs_Cont,"Eng_FADEC",4,1,0) Dataref_Write(Automix_Drefs_Cont,4,"Eng_FADEC") end
        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+1) == "AutoRich" then Automix_Vars.AFR_Tgt[i] = Table_ValGet(Automix_Profile,"AirFuelRatio_Targets",nil,2) Table_ValSet(Automix_Drefs_Cont,"Eng_FADEC",4,1,0) Dataref_Write(Automix_Drefs_Cont,4,"Eng_FADEC") end
        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+1) == "AutoLean" then Automix_Vars.AFR_Tgt[i] = Table_ValGet(Automix_Profile,"AirFuelRatio_Targets",nil,3) Table_ValSet(Automix_Drefs_Cont,"Eng_FADEC",4,1,0) Dataref_Write(Automix_Drefs_Cont,4,"Eng_FADEC") end
        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+1) == "IdleCutoff" then Automix_Vars.AFR_Tgt[i] = 0 Table_ValSet(Automix_Drefs_Cont,"Eng_Mixt",4,i,0.0) Table_ValSet(Automix_Drefs_Cont,"Eng_FADEC",4,1,0) Dataref_Write(Automix_Drefs_Cont,4,"Eng_FADEC") end
        --
        if Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+1) == "AutoRich" or Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+1) == "AutoLean" then
            if Table_ValGet(Automix_Drefs_Cont,"Eng_RPM",4,i) > Table_ValGet(Automix_Profile,"Minimum_RPM",nil,2) then
                    if Table_ValGet(Automix_Drefs_Cont,"Eng_Mixt",4,i) <= Table_ValGet(Automix_Profile,"Mixture_Range",nil,3) and Table_ValGet(Automix_Drefs_Cont,"Eng_Mixt",4,i) >= Table_ValGet(Automix_Profile,"Mixture_Range",nil,2) then
                        Table_ValSet(Automix_Drefs_Cont,"Eng_Mixt",4,i,Table_ValGet(Automix_Drefs_Cont,"Eng_Mixt",4,i) - (0.001 * (Automix_Vars.AFR_Tgt[i] - Automix_Vars.AFR_Act[i])))
                    end
                    if Table_ValGet(Automix_Drefs_Cont,"Eng_Mixt",4,i) > Table_ValGet(Automix_Profile,"Mixture_Range",nil,3) then Table_ValSet(Automix_Drefs_Cont,"Eng_Mixt",4,i,Table_ValGet(Automix_Profile,"Mixture_Range",nil,3)) end -- Correct high limit
                    if Table_ValGet(Automix_Drefs_Cont,"Eng_Mixt",4,i) < Table_ValGet(Automix_Profile,"Mixture_Range",nil,2) then Table_ValSet(Automix_Drefs_Cont,"Eng_Mixt",4,i,Table_ValGet(Automix_Profile,"Mixture_Range",nil,2)) end -- Correct low limit
            else
                Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+1,"Manual")
            end
        end
    end
    Dataref_Write(Automix_Drefs_Cont,4,"Eng_Mixt")
end
--[[

INITIALIZATION

]]
--[[ First start of the automixture module ]]
function Automix_FirstRun()
    Preferences_Write(Automix_Config_Vars,Xlua_Utils_PrefsFile)
    Preferences_Read(Xlua_Utils_PrefsFile,Automix_Config_Vars)
    DrefTable_Read(Dref_List_Once,Automix_Drefs_Once)
    DrefTable_Read(Dref_List_Cont,Automix_Drefs_Cont)
    Automix_Menu_Build(XluaUtils_Menu_ID)
    LogOutput(Automix_Config_Vars[1][1]..": First Run!")
end
--[[ Initializes automixture at every startup ]]
function Automix_Init()
    -- Read datarefs that are only read once
    DrefTable_Read(Dref_List_Once,Automix_Drefs_Once)
    Dataref_Read(Automix_Drefs_Once,4,"All") -- Populate dataref container with current values
    if Table_ValGet(Automix_Drefs_Once,"Type_Eng",4,1) < 2 then -- Only initialize automixture if the engine is a reciprocating type
        Preferences_Read(Xlua_Utils_PrefsFile,Automix_Config_Vars)
        DrefTable_Read(Dref_List_Cont,Automix_Drefs_Cont)
        Dataref_Read(Automix_Drefs_Cont,4,"All") -- Populate dataref container with currrent values
        Automix_Profile_Read(Xlua_Utils_Path..Automix_Profile_File)
        Automix_Profile_Apply()
        run_at_interval(Automix_MainTimer,Table_ValGet(Automix_Config_Vars,"MainTimerInterval",nil,2))
        LogOutput(Automix_Config_Vars[1][1]..": Initialized!")
    end
end
--[[ Reloads the Persistence configuration ]]
function Automix_Reload()
    Preferences_Read(Xlua_Utils_PrefsFile,Automix_Config_Vars)
    Automix_Profile_Read(Xlua_Utils_Path..Automix_Profile_File)
    Automix_Profile_Apply()
    Automix_File_Modifier(Automix_Sort_By_Filename(Automix_Replacements_Temp))
    LogOutput(Automix_Config_Vars[1][1]..": Reloaded!")
end
--[[

XLUA DATAREFS

]]
--[[ Mixture lever animation dataref ]]
function MixtureLeverCallback()
    local average = 0
    for i=0,(Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1)-1) do
        if DRef_ManualToggle == 0 then
            if DRef_MixtureLeversAnim[i] < Table_ValGet(Automix_Profile,"Lever_Detents",nil,2) then
                DRef_MixtureLeversAnim[i] = 0 -- Idle cutoff
                Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"IdleCutoff") -- Set idle cutoff
            elseif DRef_MixtureLeversAnim[i] > (Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) - Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) and DRef_MixtureLeversAnim[i] < (Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) + Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) then
                DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) -- Auto lean
                Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"AutoLean") -- Set auto lean
            elseif DRef_MixtureLeversAnim[i] > (Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) - Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) and DRef_MixtureLeversAnim[i] < (Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) + Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) then
                DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) -- Auto rich
                Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"AutoRich") -- Set auto rich
            elseif DRef_MixtureLeversAnim[i] > (Table_ValGet(Automix_Profile,"Lever_Detents",nil,5) - Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) then
                DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,5) -- Full rich
                Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"FullRich") -- Set full rich
            end
        end
        Automix_Menu_Watchdog(Automix_Menu_Items,9)
        -- Adjust manipulator for both levers
        average = average + DRef_MixtureLeversAnim[i]
    end
    DRef_MixtureLeversAllAnim = average / Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1)
end
DRef_MixtureLeversAnim = create_dataref("xlua/automixture/mixture_lever_anim","array[8]",MixtureLeverCallback)
--[[ All mixture lever animation dataref ]]
function MixtureLeverAllCallback()
    for i=0,(Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1)-1) do
        DRef_MixtureLeversAnim[i] = DRef_MixtureLeversAllAnim
        if DRef_ManualToggle == 0 then
            if DRef_MixtureLeversAnim[i] < Table_ValGet(Automix_Profile,"Lever_Detents",nil,2) then
                DRef_MixtureLeversAnim[i] = 0 -- Idle cutoff
                Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"IdleCutoff") -- Set idle cutoff
            elseif DRef_MixtureLeversAnim[i] > (Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) - Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) and DRef_MixtureLeversAnim[i] < (Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) + Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) then
                DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) -- Auto lean
                Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"AutoLean") -- Set auto lean
            elseif DRef_MixtureLeversAnim[i] > (Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) - Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) and DRef_MixtureLeversAnim[i] < (Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) + Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) then
                DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) -- Auto rich
                Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"AutoRich") -- Set auto rich
            elseif DRef_MixtureLeversAnim[i] > (Table_ValGet(Automix_Profile,"Lever_Detents",nil,5) - Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) then
                DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,5) -- Full rich
                Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"FullRich") -- Set full rich
            end
            DRef_MixtureLeversAllAnim = DRef_MixtureLeversAnim[i]
        end
    end
end
DRef_MixtureLeversAllAnim = create_dataref("xlua/automixture/mixture_lever_anim_all","number",MixtureLeverAllCallback)
--[[ Manual mode toggle dataref ]]
function ManualToggleCallback()
    if DRef_ManualToggle == 1 then
        for i=0,(Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1)-1) do
            DebugLogOutput(Automix_Config_Vars[1][1]..": Enabled manual mixture mode for engine "..i)
            Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"Manual")
            DisplayNotification("Automixture Mode: "..Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+2),"Nominal",4)
        end
    end
    if DRef_ManualToggle == 0 then
        local average = 0
        for i=0,(Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1)-1) do
            DebugLogOutput(Automix_Config_Vars[1][1]..": Disabled manual mixture mode for engine "..i)
            if DRef_ManualToggle == 0 then
                if DRef_MixtureLeversAnim[i] < Table_ValGet(Automix_Profile,"Lever_Detents",nil,2) then
                    DRef_MixtureLeversAnim[i] = 0 -- Idle cutoff
                    Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"IdleCutoff") -- Set idle cutoff
                elseif DRef_MixtureLeversAnim[i] > (Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) - Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) and DRef_MixtureLeversAnim[i] < (Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) + Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) then
                    DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,3) -- Auto lean
                    Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"AutoLean") -- Set auto lean
                elseif DRef_MixtureLeversAnim[i] > (Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) - Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) and DRef_MixtureLeversAnim[i] < (Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) + Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) then
                    DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,4) -- Auto rich
                    Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"AutoRich") -- Set auto rich
                elseif DRef_MixtureLeversAnim[i] > (Table_ValGet(Automix_Profile,"Lever_Detents",nil,5) - Table_ValGet(Automix_Profile,"Lever_Detent_Magnet",nil,2)) then
                    DRef_MixtureLeversAnim[i] = Table_ValGet(Automix_Profile,"Lever_Detents",nil,5) -- Full rich
                    Table_ValSet(Automix_Config_Vars,"MixtureMode",nil,i+2,"FullRich") -- Set full rich
                end
            end
            DebugLogOutput(Automix_Config_Vars[1][1]..": Set automixture mode for engine "..i.." to "..Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+2))
            DisplayNotification("Automixture mode for engine "..i..": "..Table_ValGet(Automix_Config_Vars,"MixtureMode",nil,i+2),"Nominal",4)
            -- Adjust manipulator for both levers
            average = average + DRef_MixtureLeversAnim[i]
        end
        DRef_MixtureLeversAllAnim = average / Table_ValGet(Automix_Drefs_Once,"Eng_Num",4,1)
    end
end
DRef_ManualToggle = create_dataref("xlua/automixture/toggle_manual_mode","number",ManualToggleCallback)
