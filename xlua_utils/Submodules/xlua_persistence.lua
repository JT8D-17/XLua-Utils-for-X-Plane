--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
--[[ ]]
Persistence_SaveFile = Xlua_Utils_Path.."persistence_save.txt"
--[[ Table that contains the configuration Variables for the persistence module ]]
Persistence_Config_Vars = {
{"PERSISTENCE"},
{"Autoload",0},
{"Autosave",0},
{"AutosaveInterval",30},
{"AutosaveIntervalDelta",30},
}
--[[ Container Table for the Datarefs to be monitored. Datarefs are stored in subtables {dataref,type,{value(s) as specified by dataref length}} ]]
Persistence_Datarefs = { 
{"DATAREF"},    
}
--[[

FUNCTIONS

]]
--[[ Prepares an empty dataref container table ]]
local function RegenerateDrefTable(inputtable,outputtable)
    for i=2,#outputtable do
        outputtable[i] = nil
    end
    for i=1,#inputtable do
        outputtable[i+1] = inputtable[i]
    end
    --PrintToConsole(#outputtable-1)
end
--[[ Persistence dataref file read ]]
function Persistence_DrefFile_Read(inputfile)
    local file = io.open(inputfile, "r") -- Check if file exists
    if file then
        XluaPersist_HasDrefFile = 1
        LogOutput("FILE READ START: Persistence Datarefs")
        local temptable = {}
        local i=0
        for line in file:lines() do
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
                        -- Create subtable for dataref
                        temptable[#temptable+1] = {0,0,{}}
                        temptable[#temptable][1] = splitline[1]
                        temptable[#temptable][2] = XPLM.XPLMGetDataRefTypes(dataref)
                        -- Write initial dataref values to subtable
                        if XPLM.XPLMGetDataRefTypes(dataref) == 1 then temptable[#temptable][3][1] = XPLM.XPLMGetDatai(dataref) end
                        if XPLM.XPLMGetDataRefTypes(dataref) == 2 then temptable[#temptable][3][1] = XPLM.XPLMGetDataf(dataref) end
                        if XPLM.XPLMGetDataRefTypes(dataref) == 4 then temptable[#temptable][3][1] = XPLM.XPLMGetDatad(dataref) end
                        if XPLM.XPLMGetDataRefTypes(dataref) == 8 then
                            local size = XPLM.XPLMGetDatavf(dataref,nil,0,0) -- Get size of dataref
                            local value = ffi.new("float["..size.."]") -- Define float array
                            XPLM.XPLMGetDatavf(dataref,ffi.cast("int *",value),0,size) -- Get float array values from dataref
                            for i = 0,(size-1) do
                                temptable[#temptable][3][i+1] = value[i] -- Write dataref values to value subtable for dataref
                            end
                        end
                        if XPLM.XPLMGetDataRefTypes(dataref) == 16 then 
                            local size = XPLM.XPLMGetDatavi(dataref,nil,0,0) -- Get size of dataref
                            local value = ffi.new("int["..size.."]") -- Define integer array
                            XPLM.XPLMGetDatavi(dataref,ffi.cast("int *",value),0,size) -- Get integer array values from dataref
                            for i = 0,(size-1) do
                                temptable[#temptable][3][i+1] = value[i] -- Write dataref values to value subtable for dataref
                            end                                 
                        end
                        if XPLM.XPLMGetDataRefTypes(dataref) == 32 then 
                            local size = XPLM.XPLMGetDatab(dataref,nil,0,0) -- Get size of dataref
                            local value = ffi.new("char["..size.."]") -- Define character array
                            XPLM.XPLMGetDatab(dataref,ffi.cast("void *",value),0,size) -- Get byte array values from dataref
                            temptable[#temptable][3][1] = ffi.string(value)-- Write dataref value to value subtable for dataref 
                        end                            
                        temptable[#temptable][4] = dataref -- Store handle for faster access
                        i=i+1
                        --PrintToConsole("Found "..temptable[#temptable][1].." (Type: "..temptable[#temptable][2].."; Values: "..table.concat(temptable[#temptable][3],",").."; Handle "..tostring(temptable[#temptable][4])..")")
                    end
                end
            end
        end
        file:close()
        if i ~= nil and i > 0 then LogOutput("FILE READ SUCCESS: "..inputfile) RegenerateDrefTable(temptable,Persistence_Datarefs) else LogOutput("FILE READ ERROR: "..inputfile) end
    else
        LogOutput("FILE NOT FOUND: Persistence Dataref File")
    end
end
--[[ Persistence dataref save file read ]]
function Persistence_SaveFile_Read(inputfile,outputtable)
    local file = io.open(inputfile, "r") -- Check if file exists
    local i=0
    if file then
        LogOutput("FILE READ START: Persistence Save File")
        for line in file:lines() do
            if string.match(line,"^[^#]") then
                local splitline = SplitString(line,"([^:]+)")
                --splitline[1] = TrimEndWhitespace(splitline[1]) -- Trims the end whitespace from a string
                for j=2,#outputtable do
                    if splitline[1] == outputtable[j][1] then
                        local splitvalues = SplitString(splitline[3],"([^,]+)")
                        --PrintToConsole(table.concat(splitvalues,","))
                        for k=1,#splitvalues do
                            if splitline[2] == "string" then outputtable[j][3][k] = tostring(splitvalues[k]) end
                            if splitline[2] == "number" then outputtable[j][3][k] = tonumber(splitvalues[k]) end
                            --PrintToConsole(type(outputtable[j][3][k]))
                        end
                        --PrintToConsole(table.concat(outputtable[j][3],","))
                        i=i+1
                    end
                end
                
            end
        end
        file:close()
        if i ~= nil and i > 0 then LogOutput("FILE READ SUCCESS: "..inputfile) else LogOutput("FILE READ ERROR: "..inputfile) end
    else
        LogOutput("FILE NOT FOUND: Persistence Save File")
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
--[[ Persistence dataref save file write ]]
function Persistence_SaveFile_Write(outputfile,inputtable)
    LogOutput("FILE WRITE START: Persistence Save File")
    local file = io.open(outputfile, "w")    
    file:write("# Xlua Persistence save file generated/updated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# This file stores the values of datarefs that are tracked by the persistence module.\n")
    file:write("#\n")
    for i=2,#inputtable do
        file:write(inputtable[i][1]..":"..type(inputtable[i][3][1])..":"..table.concat(inputtable[i][3],",").."\n")
    end
    if file:seek("end") > 0 then LogOutput("FILE WRITE SUCCESS: Persistence Save File") else LogOutput("FILE WRITE ERROR: Persistence Save File") end
	file:close()    
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
"Increment Autosave Interval (+ "..Preferences_ValGet("AutosaveIntervalDelta").." s)",   -- Item index: 8
"Autosave Interval: "..Preferences_ValGet("AutosaveInterval").." s",                    -- Item index: 9
"Decrement Autosave Interval (- "..Preferences_ValGet("AutosaveIntervalDelta").." s)",   -- Item index: 10
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
            if i == 2 then
                Dataref_Read("All")
                Persistence_SaveFile_Write(Xlua_Utils_Path.."persistence_save.txt",Persistence_Datarefs)
            end
            if i == 3 then
                Persistence_SaveFile_Read(Xlua_Utils_Path.."persistence_save.txt",Persistence_Datarefs)
                Dataref_Write("All")
            end
            if i == 5 then
                if Preferences_ValGet("Autosave") == 0 then Preferences_ValSet("Autosave",1) else Preferences_ValSet("Autosave",0) end
                Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
                LogOutput("Set Persistence Autosave State to "..Preferences_ValGet("Autosave"))
            end
            if i == 6 then
                if Preferences_ValGet("Autoload") == 0 then Preferences_ValSet("Autoload",1) else Preferences_ValSet("Autoload",0) end
                Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
                LogOutput("Set Persistence Autoload State to "..Preferences_ValGet("Autoload"))
            end
            if i == 8 then
                Preferences_ValSet("AutosaveInterval",Preferences_ValGet("AutosaveInterval") + Preferences_ValGet("AutosaveIntervalDelta"))
                Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
                LogOutput("Increased Persistence Autosave Interval to "..Preferences_ValGet("AutosaveInterval"))
            end
            if i == 10 then
                Preferences_ValSet("AutosaveInterval",Preferences_ValGet("AutosaveInterval") - Preferences_ValGet("AutosaveIntervalDelta"))
                Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
                LogOutput("Increased Persistence Autosave Interval to "..Preferences_ValGet("AutosaveInterval"))
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
        if Preferences_ValGet("Autosave") == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[Off] Enable",intable)
        elseif Preferences_ValGet("Autosave") == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[On] Disable",intable) end
    end
    if index == 6 then
        if Preferences_ValGet("Autoload") == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[Off] Enable",intable)
        elseif Preferences_ValGet("Autoload") == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[On] Disable",intable) end
    end
    if index == 8 or index == 10 then
        if Preferences_ValGet("AutosaveInterval") < 0 then Preferences_ValSet("AutosaveInterval",0) end       
        XPLM.XPLMSetMenuItemName(Persistence_Menu_ID,6,"Increment Autosave Interval (+ "..Preferences_ValGet("AutosaveIntervalDelta").." s)",1)
        XPLM.XPLMSetMenuItemName(Persistence_Menu_ID,7,"Autosave Interval: "..Preferences_ValGet("AutosaveInterval").." s",1)
        XPLM.XPLMSetMenuItemName(Persistence_Menu_ID,8,"Decrement Autosave Interval (- "..Preferences_ValGet("AutosaveIntervalDelta").." s)",1)
    end
    if index == 12 then
        if XluaPersist_HasDrefFile == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"Generate Dataref File Template",intable)
        elseif XluaPersist_HasDrefFile == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"Monitored Datarefs: "..(#Persistence_Datarefs-1),intable) end
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
