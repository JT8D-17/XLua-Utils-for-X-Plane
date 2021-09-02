--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
--[[ Table that contains the configuration Variables for the persistence module ]]
Persistence_Config_Vars = {
{"CONFIG"},
{"Autoload",0},
{"Autosave",0},
{"AutosaveInterval",30},
{"AutosaveIntervalDelta",30},
}
--[[ Container Table for the Datarefs to be monitored. Datarefs are stored in subtables {dataref,type,{value(s) as specified by dataref length}} ]]
Persistence_Datarefs = { 
{"DATAREF"}
}
-- sim/aircraft/view/acf_livery_path
--[[

FUNCTIONS

]]
--[[ Persistence config file read ]]
function Persistence_Config_Read(inputfile)
    local file = io.open(inputfile, "r") -- Check if file exists
    if file then
        XluaPersist_HasConfig = 1
        LogOutput("FILE READ START: Persistence Configuration")
        local i=0
        for line in file:lines() do
            -- Find lines matching first subtable of output table
            if string.match(line,"^"..Persistence_Config_Vars[1][1]..":") then
                local splitline = SplitString(line,"([^:]+)")
                local substringline = SplitString(splitline[2],"([^=]+)")
                for j=2,#Persistence_Config_Vars do
                    if Persistence_Config_Vars[j][1] == substringline[1] then
                        Persistence_Config_Vars[j][2] = tonumber(substringline[2])
                        --PrintToConsole(Persistence_Config_Vars[j][1].." set to "..Persistence_Config_Vars[j][2])
                        --LogOutput("Persistence: "..Persistence_Config_Vars[j][1].." set to "..Persistence_Config_Vars[j][2])
                        i=i+1
                    end
                end
            end
        end
        file:close()
        if i ~= nil and i > 0 then LogOutput("FILE READ SUCCESS: "..inputfile) else LogOutput("FILE READ ERROR: "..inputfile) end
    else
        LogOutput("FILE NOT FOUND: Persistence Configuration")
    end
end
--[[ Persistence config file write ]]
function Persistence_Config_Write(outputfile)
    LogOutput("FILE WRITE START: Persistence Configuration")
    local file = io.open(outputfile, "w")
    file:write("# Xlua Persistence configuration file generated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# - Autoload is either 0 or 1\n")
    file:write("# - Autosave is either 0 or 1\n")
    file:write("# - AutosaveInterval is handled in seconds\n")
    file:write("# - AutosaveIntervalDelta is handled in seconds\n")
    file:write("#\n")
    for j=2,#Persistence_Config_Vars do
        file:write(Persistence_Config_Vars[1][1]..":"..Persistence_Config_Vars[j][1].."="..Persistence_Config_Vars[j][2].."\n")
    end
    --for d=1,#ECC_DatarefTable do
        --print("{"..ECC_DatarefTable[d][1]..",{"..table.concat(ECC_DatarefTable[d][3],",",0).."}}")
        --if ECC_DatarefTable[d][3][0] ~= nil then
            --file:write(ECC_DatarefTable[d][1]..";"..table.concat(ECC_DatarefTable[d][3],",",0)..";"..ECC_DatarefTable[d][4]..";"..table.concat(ECC_DatarefTable[d][6],",")..";"..tostring(ECC_DatarefTable[d][8])..";"..ECC_DatarefTable[d][9]..";"..ECC_DatarefTable[d][10].."\n")
        --end
    --end
    --file:write("--- DATAREFS ---\n--- Line formatting: ---\n--- DATAREF#/any/writable/dataref#Dataref length ---\n------------------------------------\n")
    if file:seek("end") > 0 then LogOutput("FILE WRITE SUCCESS: Persistence Configuration") else LogOutput("FILE WRITE ERROR: Persistence Configuration") end
	file:close()
end
--[[ Persistence dataref file read ]]
function Persistence_DrefFile_Read(inputfile)
    local file = io.open(inputfile, "r") -- Check if file exists
    if file then
        XluaPersist_HasDrefFile = 1
        LogOutput("FILE READ START: Persistence Datarefs")
        local temptable = { }
        local i=0
        for line in file:lines() do
            -- Find lines matching first subtable of output table
            if string.match(line,"^[^#]") then
                local splitline = SplitString(line,"([^:]+)")
                splitline[1] = TrimEndWhitespace(splitline[1]) -- Trims the end whitespace from a string
                local dataref = XPLM.XPLMFindDataRef(splitline[1])
                if dataref == nil then -- Check if dataref exists
                    LogOutput("Dataref "..splitline[1].." could not be found and is discarded.")
                else
                    if XPLM.XPLMCanWriteDataRef(dataref) == 0 then -- Check if dataref is writable
                        LogOutput("Dataref "..splitline[1].." is not writable and is discarded.")
                    else
                        -- Types: 1 - Integer, 2 - Float, 4 - Double, 8 - Float array, 16 - Integer array, 32 - Data array
                        if XPLM.XPLMGetDataRefTypes(dataref) == 32 then
                            LogOutput("Dataref "..splitline[1].." is of an unsupported type ("..XPLM.XPLMGetDataRefTypes(dataref)..") and is discarded.")
                        else
                            -- Create subtable for dataref
                            Persistence_Datarefs[#Persistence_Datarefs+1] = {0,0,{}}
                            Persistence_Datarefs[#Persistence_Datarefs][1] = splitline[1]
                            Persistence_Datarefs[#Persistence_Datarefs][2] = XPLM.XPLMGetDataRefTypes(dataref)
                            -- Write initial dataref values to subtable
                            if XPLM.XPLMGetDataRefTypes(dataref) == 1 then Persistence_Datarefs[#Persistence_Datarefs][3][1] = XPLM.XPLMGetDatai(dataref) end
                            if XPLM.XPLMGetDataRefTypes(dataref) == 2 then Persistence_Datarefs[#Persistence_Datarefs][3][1] = XPLM.XPLMGetDataf(dataref) end
                            if XPLM.XPLMGetDataRefTypes(dataref) == 4 then Persistence_Datarefs[#Persistence_Datarefs][3][1] = XPLM.XPLMGetDatad(dataref) end
                            if XPLM.XPLMGetDataRefTypes(dataref) == 8 then
                                local size = XPLM.XPLMGetDatavf(dataref,nil,0,0) -- Get size of dataref
                                local value = ffi.new("float["..size.."]") -- Define float array
                                XPLM.XPLMGetDatavf(dataref,ffi.cast("int *",value),0,size) -- Get float array values from dataref
                                for i = 0,(size-1) do
                                   Persistence_Datarefs[#Persistence_Datarefs][3][i+1] = value[i] -- Write dataref values to value subtable for dataref
                                end
                            end
                            if XPLM.XPLMGetDataRefTypes(dataref) == 16 then 
                                local size = XPLM.XPLMGetDatavi(dataref,nil,0,0) -- Get size of dataref
                                local value = ffi.new("int["..size.."]") -- Define integer array
                                XPLM.XPLMGetDatavi(dataref,ffi.cast("int *",value),0,size) -- Get integer array values from dataref
                                for i = 0,(size-1) do
                                   Persistence_Datarefs[#Persistence_Datarefs][3][i+1] = value[i] -- Write dataref values to value subtable for dataref
                                end                                 
                            end                           
                            PrintToConsole(Persistence_Datarefs[#Persistence_Datarefs][1].."; type "..Persistence_Datarefs[#Persistence_Datarefs][2].."; values: "..table.concat(Persistence_Datarefs[#Persistence_Datarefs][3],","))
                        end
                    end
                end
                --local temptable = {}
                --local splitline = SplitString(line,"([^:]+)")
                --local substringline = SplitString(splitline[2],"([^=]+)")
                --for j=2,#Persistence_Config_Vars do
                --    if Persistence_Config_Vars[j][1] == substringline[1] then
                --        Persistence_Config_Vars[j][2] = tonumber(substringline[2])
                        --PrintToConsole(Persistence_Config_Vars[j][1].." set to "..Persistence_Config_Vars[j][2])
                        --LogOutput("Persistence: "..Persistence_Config_Vars[j][1].." set to "..Persistence_Config_Vars[j][2])
                        --i=i+1
                    --end
                --end
            end
        end
        file:close()
        if i ~= nil and i > 0 then LogOutput("FILE READ SUCCESS: "..inputfile) else LogOutput("FILE READ ERROR: "..inputfile) end
    else
        LogOutput("FILE NOT FOUND: Persistence Dataref File")
    end
end
--[[ Persistence dataref file write ]]
function Persistence_DrefFile_Write(outputfile)
    LogOutput("FILE WRITE START: Persistence Dataref File")
    local file = io.open(outputfile, "w")
    file:write("# Xlua Persistence dataref file generated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# This file contains datarefs that are tracked by the persistence module.\n")
    file:write("#\n")
    file:write("# Obtain these datarefs from the list in X-Plane 11/Resources/plugins/DataRefs.txt\n")
    file:write("# or from DataRefTool: https://github.com/leecbaker/datareftool\n")
    file:write("# or from DataRefEditor: https://developer.x-plane.com/tools/datarefeditor\n")
    file:write("#\n")
    file:write("# Add the datarefs to be tracked after the end of this comment section.\n")
    file:write("#\n")
    file:write("# Datarefs are read in the order they appear in in this file, so mind any possible sequencing issues!\n")
    file:write("# If a dataref can not be found upon reading this file, it will not be tracked!\n")
    file:write("#\n")
    if file:seek("end") > 0 then LogOutput("FILE WRITE SUCCESS: Persistence Dataref File") else LogOutput("FILE WRITE ERROR: Persistence Dataref File") end
	file:close()
end
--[[ Accessor: Get value from a subtable ]]
function Persistence_ValGet(item)
    for i=1,#Persistence_Config_Vars do
       if Persistence_Config_Vars[i][1] == item then return Persistence_Config_Vars[i][2] end
    end
end
--[[ Accessor: Set value from a subtable ]]
function Persistence_ValSet(item,newvalue)
    for i=1,#Persistence_Config_Vars do
       if Persistence_Config_Vars[i][1] == item then Persistence_Config_Vars[i][2] = newvalue break end
    end
end
--[[

MENU

]]
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
Persistence_Menu_Items = {
"Persistence",              -- Menu title, index 1
"Save Cockpit State Now",   -- Item index: 2
"Load Cockpit State Now",   -- Item index: 3
"[Separator]",              -- Item index: 4
"Cockpit State Autosave",   -- Item index: 5
"Cockpit State Autoload",   -- Item index: 6
"[Separator]",              -- Item index: 7
"Increment Autosave Interval (+ "..Persistence_ValGet("AutosaveIntervalDelta").." s)",   -- Item index: 8
"Autosave Interval: "..Persistence_ValGet("AutosaveInterval").." s",                    -- Item index: 9
"Decrement Autosave Interval (- "..Persistence_ValGet("AutosaveIntervalDelta").." s)",   -- Item index: 10
"[Separator]",              -- Item index: 11
"",                         -- Item index: 12
}
--[[ Menu variables for FFI ]]
Persistence_Menu_ID = nil
Persistence_Menu_Pointer = ffi.new("const char")
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function Persistence_Menu_Callbacks(itemref)
    for i=2,#Persistence_Menu_Items do
        if itemref == Persistence_Menu_Items[i] then
            if i == 5 then
                if Persistence_ValGet("Autosave") == 0 then Persistence_ValSet("Autosave",1) else Persistence_ValSet("Autosave",0) end
                Persistence_Config_Write(Xlua_Utils_Path.."persistence.cfg")
                LogOutput("Set Persistence Autosave State to "..Persistence_ValGet("Autosave"))
            end
            if i == 6 then
                if Persistence_ValGet("Autoload") == 0 then Persistence_ValSet("Autoload",1) else Persistence_ValSet("Autoload",0) end
                Persistence_Config_Write(Xlua_Utils_Path.."persistence.cfg")
                LogOutput("Set Persistence Autoload State to "..Persistence_ValGet("Autoload"))
            end
            if i == 8 then
                Persistence_ValSet("AutosaveInterval",Persistence_ValGet("AutosaveInterval") + Persistence_ValGet("AutosaveIntervalDelta"))
                Persistence_Config_Write(Xlua_Utils_Path.."persistence.cfg")
                LogOutput("Increased Persistence Autosave Interval to "..Persistence_ValGet("AutosaveInterval"))
            end
            if i == 10 then
                Persistence_ValSet("AutosaveInterval",Persistence_ValGet("AutosaveInterval") - Persistence_ValGet("AutosaveIntervalDelta"))
                Persistence_Config_Write(Xlua_Utils_Path.."persistence.cfg")
                LogOutput("Increased Persistence Autosave Interval to "..Persistence_ValGet("AutosaveInterval"))
            end
            if i == 12 then
                if XluaPersist_HasDrefFile == 0 then 
                    Persistence_DrefFile_Write(Xlua_Utils_Path.."datarefs.cfg")
                    Persistence_DrefFile_Read(Xlua_Utils_Path.."datarefs.cfg")
                    Persistence_Menu_Watchdog(Persistence_Menu_Items,12)
                end
            end           
            Persistence_Menu_Watchdog(Persistence_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function Persistence_Menu_Watchdog(intable,index)
    if index == 5 then
        if Persistence_ValGet("Autosave") == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[Off] Enable",intable)
        elseif Persistence_ValGet("Autosave") == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[On] Disable",intable) end
    end
    if index == 6 then
        if Persistence_ValGet("Autoload") == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[Off] Enable",intable)
        elseif Persistence_ValGet("Autoload") == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[On] Disable",intable) end
    end
    if index == 8 or index == 10 then
        if Persistence_ValGet("AutosaveInterval") < 0 then Persistence_ValSet("AutosaveInterval",0) end       
        XPLM.XPLMSetMenuItemName(Persistence_Menu_ID,6,"Increment Autosave Interval (+ "..Persistence_ValGet("AutosaveIntervalDelta").." s)",1)
        XPLM.XPLMSetMenuItemName(Persistence_Menu_ID,7,"Autosave Interval: "..Persistence_ValGet("AutosaveInterval").." s",1)
        XPLM.XPLMSetMenuItemName(Persistence_Menu_ID,8,"Decrement Autosave Interval (- "..Persistence_ValGet("AutosaveIntervalDelta").." s)",1)
    end
    if index == 12 then
        if XluaPersist_HasDrefFile == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"Generate Dataref File Template",intable)
        elseif XluaPersist_HasDrefFile == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"Drefs Handled",intable) end
    end
end

--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function Persistence_Menu_Init(ParentMenuID)
    local Menu_Indices = {}
    for i=2,#Persistence_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,Persistence_Menu_Items[1],ffi.cast("void *","None"),1)
        Persistence_Menu_ID = XPLM.XPLMCreateMenu(Persistence_Menu_Items[1],ParentMenuID,Menu_Index,function(inMenuRef,inItemRef) Persistence_Menu_Callbacks(inItemRef) end,ffi.cast("void *",Persistence_Menu_Pointer))
        for i=2,#Persistence_Menu_Items do
            if Persistence_Menu_Items[i] ~= "[Separator]" then
                Persistence_Menu_Pointer = Persistence_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(Persistence_Menu_ID,Persistence_Menu_Items[i],ffi.cast("void *",Persistence_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(Persistence_Menu_ID)
            end
        end
        for i=2,#Persistence_Menu_Items do
            if Persistence_Menu_Items[i] ~= "[Separator]" then
                Persistence_Menu_Watchdog(Persistence_Menu_Items,i)
            end
        end
        LogOutput(Persistence_Menu_Items[1].." menu initialized!")
    end
end

LogOutput("Persistence initialized")
