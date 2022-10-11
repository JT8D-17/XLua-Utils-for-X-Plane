--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
--[[ Persistence save file name ]]
local Persistence_SaveFile = "persistence_save.txt"
local Has_SaveFile = 0
--[[ Table that contains the configuration Variables for the persistence module ]]
local Persistence_Config_Vars = {
{"PERSISTENCE"},
{"Autoload",0},
{"AutoloadDelay",5},
{"Autosave",0},
{"AutosaveInterval",30},
{"AutosaveIntervalDelta",15},
{"AutosaveDelay",10},
{"SaveOnExit",0},
}
--[[ Container Table for the Datarefs to be monitored. Datarefs are stored in subtables {alias,dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local Persistence_Datarefs = {
{"DATAREF"},    
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local Persistence_Menu_Items = {
"Persistence",              -- Menu title, index 1
"Save Cockpit State Now",   -- Item index: 2
"Load Cockpit State Now",   -- Item index: 3
"[Separator]",              -- Item index: 4
"Cockpit State Autosave",   -- Item index: 5
"Cockpit State Autoload",   -- Item index: 6
"Save On Exit",             -- Item index: 7
"[Separator]",              -- Item index: 8
"Increment Autosave Interval (+ "..Table_ValGet(Persistence_Config_Vars,"AutosaveIntervalDelta",nil,2).." s)",   -- Item index: 9
"Autosave Interval: "..Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2).." s",                    -- Item index: 10
"Decrement Autosave Interval (- "..Table_ValGet(Persistence_Config_Vars,"AutosaveIntervalDelta",nil,2).." s)",   -- Item index: 11
"[Separator]",              -- Item index: 12
"",                         -- Item index: 13
}
--[[ Menu variables for FFI ]]
local Persistence_Menu_ID = nil
local Persistence_Menu_Pointer = ffi.new("const char")
--[[

FUNCTIONS

]]
--[[ Persistence dataref file read ]]
function Persistence_DrefFile_Read(inputfile)
    local file = io.open(inputfile, "r") -- Check if file exists
    if file then
        XluaPersist_HasDrefFile = 1
        LogOutput("FILE READ START: Persistence Datarefs")
        local counter = 0
        local drefline = { }
        local temptable = {}
        for line in file:lines() do
            if string.match(line,"^[^#]") then
                counter = counter + 1
                local splitline = SplitString(line,"([^:]+)")
                splitline[1] = TrimEndWhitespace(splitline[1]) -- Trims the end whitespace from a string
                drefline = {"Dref"..counter,splitline[1]} -- Generic dataref identifdier for input table
                Dataref_InitContainer(drefline,temptable)
            end
        end
        file:close()
        if #temptable > 1 then LogOutput("FILE READ SUCCESS: "..inputfile) RegenerateDrefTable(temptable,Persistence_Datarefs) else LogOutput("FILE READ ERROR: "..inputfile) end
    else
        LogOutput("FILE NOT FOUND: Persistence Dataref File")
    end
end
--[[ Persistence dataref save file read ]]
function Persistence_SaveFile_Read(inputfile,outputtable)
    local file = io.open(inputfile, "r") -- Check if file exists
    local i=0
    if file then
        Has_SaveFile = 1
        LogOutput("FILE READ START: Persistence Save File")
        for line in file:lines() do
            if string.match(line,"^[^#]") then
                local splitline = SplitString(line,"([^:]+)")
                --splitline[1] = TrimEndWhitespace(splitline[1]) -- Trims the end whitespace from a string
                for j=2,#outputtable do
                    if splitline[1] == outputtable[j][2] then
                        local splitvalues = SplitString(splitline[3],"([^,]+)")
                        --PrintToConsole(table.concat(splitvalues,","))
                        for k=1,#splitvalues do
                            if splitline[2] == "string" then outputtable[j][4][k] = tostring(splitvalues[k]) end
                            if splitline[2] == "number" then outputtable[j][4][k] = tonumber(splitvalues[k]) end
                            --PrintToConsole(type(outputtable[j][4][k]))
                        end
                        --PrintToConsole(table.concat(outputtable[j][4],","))
                        i=i+1
                    end
                end

            end
        end
        file:close()
        if i ~= nil and i > 0 then LogOutput("FILE READ SUCCESS: "..inputfile) else LogOutput("FILE READ ERROR: "..inputfile) end
    else
        LogOutput("FILE NOT FOUND: Persistence Save File")
        Has_SaveFile = 0
    end
end
--[[ Persistence dataref file write ]]
function Persistence_DrefFile_Write(outputfile)
    LogOutput("FILE WRITE START: Persistence Dataref File")
    local file = io.open(outputfile, "w")
    file:write("# XLua Utils persistence dataref file generated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# This file contains datarefs that are tracked by XLua Utils' persistence module.\n")
    file:write("#\n")
    file:write("# Obtain these datarefs from the list in X-Plane [11/12]/Resources/plugins/DataRefs.txt\n")
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
    file:write("# XLua Utils persistence save file generated/updated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# This file stores the values of datarefs that are tracked by the persistence module.\n")
    file:write("#\n")
    for i=2,#inputtable do
        file:write(inputtable[i][2]..":"..type(inputtable[i][4][1])..":"..table.concat(inputtable[i][4],",").."\n")
    end
    if file:seek("end") > 0 then LogOutput("FILE WRITE SUCCESS: Persistence Save File") else LogOutput("FILE WRITE ERROR: Persistence Save File") end
    file:close()
end
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function Persistence_Menu_Callbacks(itemref)
    for i=2,#Persistence_Menu_Items do
        if itemref == Persistence_Menu_Items[i] then
            if i == 2 then
                Persistence_Save()
            end
            if i == 3 then
                Persistence_Load()
            end
            if i == 5 then
                if Table_ValGet(Persistence_Config_Vars,"Autosave",nil,2) == 0 then Table_ValSet(Persistence_Config_Vars,"Autosave",nil,2,1) else Table_ValSet(Persistence_Config_Vars,"Autosave",nil,2,0) end
                Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
                DebugLogOutput(Persistence_Config_Vars[1][1]..": Set Autosave State to "..Table_ValGet(Persistence_Config_Vars,"Autosave",nil,2))
                Persistence_AutosaveTimerCtrl()
            end
            if i == 6 then
                if Table_ValGet(Persistence_Config_Vars,"Autoload",nil,2) == 0 then Table_ValSet(Persistence_Config_Vars,"Autoload",nil,2,1) else Table_ValSet(Persistence_Config_Vars,"Autoload",nil,2,0) end
                Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
                DebugLogOutput(Persistence_Config_Vars[1][1]..": Set Autoload State to "..Table_ValGet(Persistence_Config_Vars,"Autoload",nil,2))
            end
            if i == 7 then
                if Table_ValGet(Persistence_Config_Vars,"SaveOnExit",nil,2) == 0 then Table_ValSet(Persistence_Config_Vars,"SaveOnExit",nil,2,1) else Table_ValSet(Persistence_Config_Vars,"SaveOnExit",nil,2,0) end
                Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
                DebugLogOutput(Persistence_Config_Vars[1][1]..": Set Save on Exit State to "..Table_ValGet(Persistence_Config_Vars,"SaveOnExit",nil,2))
            end
            if i == 9 then
                Table_ValSet(Persistence_Config_Vars,"AutosaveInterval",nil,2,Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2) + Table_ValGet(Persistence_Config_Vars,"AutosaveIntervalDelta",nil,2))
                Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
                DebugLogOutput(Persistence_Config_Vars[1][1]..": Increased Autosave Interval to "..Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2).." s.")
                Persistence_AutosaveTimerCtrl()
            end
            if i == 11 then
                Table_ValSet(Persistence_Config_Vars,"AutosaveInterval",nil,2,Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2) - Table_ValGet(Persistence_Config_Vars,"AutosaveIntervalDelta",nil,2))
                Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
                DebugLogOutput(Persistence_Config_Vars[1][1]..": Decreased Autosave Interval to "..Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2).." s.")
                Persistence_AutosaveTimerCtrl()
            end
            if i == 13 then
                if XluaPersist_HasDrefFile == 0 then
                    Persistence_DrefFile_Write(Xlua_Utils_Path.."datarefs.cfg")
                    Persistence_DrefFile_Read(Xlua_Utils_Path.."datarefs.cfg")
                    Persistence_Menu_Watchdog(Persistence_Menu_Items,12)
                end
                if XluaPersist_HasDrefFile == 1 then
                    Persistence_Reload()
                end
            end
            Persistence_Menu_Watchdog(Persistence_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function Persistence_Menu_Watchdog(intable,index)
    if index == 5 then
        if Table_ValGet(Persistence_Config_Vars,"Autosave",nil,2) == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[Off]",intable)
        elseif Table_ValGet(Persistence_Config_Vars,"Autosave",nil,2) == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[On] ",intable) end
    end
    if index == 6 then
        if Table_ValGet(Persistence_Config_Vars,"Autoload",nil,2) == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[Off]",intable)
        elseif Table_ValGet(Persistence_Config_Vars,"Autoload",nil,2) == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[On] ",intable) end
    end
    if index == 7 then
        if Table_ValGet(Persistence_Config_Vars,"SaveOnExit",nil,2) == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[Off]",intable)
        elseif Table_ValGet(Persistence_Config_Vars,"SaveOnExit",nil,2) == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"[On] ",intable) end
    end
    if index == 9 or index == 11 then
        if Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2) < 0 then Table_ValSet(Persistence_Config_Vars,"AutosaveInterval",nil,2,0) end
        XPLM.XPLMSetMenuItemName(Persistence_Menu_ID,7,"Increment Autosave Interval (+ "..Table_ValGet(Persistence_Config_Vars,"AutosaveIntervalDelta",nil,2).." s)",1)
        XPLM.XPLMSetMenuItemName(Persistence_Menu_ID,8,"Autosave Interval: "..Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2).." s",1)
        XPLM.XPLMSetMenuItemName(Persistence_Menu_ID,9,"Decrement Autosave Interval (- "..Table_ValGet(Persistence_Config_Vars,"AutosaveIntervalDelta",nil,2).." s)",1)
    end
    if index == 13 then
        if XluaPersist_HasDrefFile == 0 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"Generate Dataref File Template",intable)
        elseif XluaPersist_HasDrefFile == 1 then Menu_ChangeItemPrefix(Persistence_Menu_ID,index,"Reload Config & Dataref File (Drefs: "..(#Persistence_Datarefs-1)..")",intable) end
    end
end
--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function Persistence_Menu_Build(ParentMenuID)
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
        LogOutput(Persistence_Config_Vars[1][1]..": Menu initialized!")
    end
end
--[[

INITIALIZATION

]]
--[[ First start of the persistence module ]]
function Persistence_FirstRun()
    Preferences_Write(Persistence_Config_Vars,Xlua_Utils_PrefsFile)
    if FileExists(Xlua_Utils_Path.."datarefs.cfg") then
        LogOutput(Persistence_Config_Vars[1][1]..": Existing datarefs.cfg found, skipping creation of a new one!")
    else
        Persistence_DrefFile_Write(Xlua_Utils_Path.."datarefs.cfg")
    end
    Preferences_Read(Xlua_Utils_PrefsFile,Persistence_Config_Vars)
    Persistence_DrefFile_Read(Xlua_Utils_Path.."datarefs.cfg")
    Persistence_Menu_Build(XluaUtils_Menu_ID)
    LogOutput(Persistence_Config_Vars[1][1]..": First Initialization Completed!")
end
--[[ Initializes persistence at every startup ]]
function Persistence_Init()
    Preferences_Read(Xlua_Utils_PrefsFile,Persistence_Config_Vars)
    Persistence_DrefFile_Read(Xlua_Utils_Path.."datarefs.cfg")
    Dataref_Read(Persistence_Datarefs,4,"All")
    LogOutput(Persistence_Config_Vars[1][1]..": Initialized!")
end
--[[ Reloads the Persistence configuration ]]
function Persistence_Reload()
    Persistence_Init()
    Persistence_Menu_Watchdog(Persistence_Menu_Items,8)
    Persistence_Menu_Watchdog(Persistence_Menu_Items,12)
    LogOutput(Persistence_Config_Vars[1][1]..": Reloaded!")
end
--[[ Checks if persistence data should be loaded at statup and starts a delay timer ]]
function Persistence_Autoload()
    -- Check persistence automation status and load if necessary
    if Table_ValGet(Persistence_Config_Vars,"Autoload",nil,2) == 1 then
        run_after_time(Persistence_Load,Table_ValGet(Persistence_Config_Vars,"AutoloadDelay",nil,2)) DisplayNotification("Waiting "..Table_ValGet(Persistence_Config_Vars,"AutoloadDelay",nil,2).." seconds before loading persistence data..","Caution",-99)
    end
end
--[[ Autoloads the saved persistence values ]]
function Persistence_Load()
    Persistence_SaveFile_Read(Xlua_Utils_Path..Persistence_SaveFile,Persistence_Datarefs)
    if Has_SaveFile == 1 then Dataref_Write(Persistence_Datarefs,4,"All") LogOutput("Loaded Persistence Data at "..os.date("%X").." h") DisplayNotification("Persistence data loaded!","Success",3) end
    RemoveNotification(-99)
end
--[[ Autosaves the current persistence values ]]
function Persistence_Save()
    Dataref_Read(Persistence_Datarefs,4,"All")
    Persistence_SaveFile_Write(Xlua_Utils_Path..Persistence_SaveFile,Persistence_Datarefs)
    LogOutput(Persistence_Config_Vars[1][1]..": Saved at "..os.date("%X").." h")
end
--[[ Starts an autosave timer ]]
function Persistence_TimerStart()
    run_timer(Persistence_Save,Table_ValGet(Persistence_Config_Vars,"AutosaveDelay",nil,2),Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2))
    LogOutput(Persistence_Config_Vars[1][1]..": Autosave Timer started (Delay: "..Table_ValGet(Persistence_Config_Vars,"AutosaveDelay",nil,2).." s; Interval: "..Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2).." s.)")
end
--[[ Stops an autosave timer ]]
function Persistence_TimerStop()
    stop_timer(Persistence_Save)
    LogOutput(Persistence_Config_Vars[1][1]..": Autosave Timer stopped.")
end
--[[ Controller for timed autosaving of the current persistence values ]]
function Persistence_AutosaveTimerCtrl()
    if Table_ValGet(Persistence_Config_Vars,"Autosave",nil,2) == 1 and Table_ValGet(Persistence_Config_Vars,"AutosaveInterval",nil,2) > 0 then
        if is_timer_scheduled(Persistence_Save) then
            Persistence_TimerStop()
            Persistence_TimerStart()
        else
            Persistence_TimerStart()
        end
    else -- Autosave disabled or interval at zero
        if is_timer_scheduled(Persistence_Save) then
            Persistence_TimerStop()
        end
    end
end
--[[ Unload logic for the persistence module ]]
function Persistence_Unload()
    if Table_ValGet(Persistence_Config_Vars,"SaveOnExit",nil,2) == 1 then Persistence_Save() end -- Check persistence save on exit status and load if necessary
end
