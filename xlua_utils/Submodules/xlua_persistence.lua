--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ Test variable table for the menu items ]]
local MenuVarTest2 = {0,false,false}
--[[

VARIABLES

]]
--[[ Table that contains the configuration Variables for the persistence module ]]
Persistence_Config_Vars = {
{"CONFIG"},
{"Autoload",0},
{"Autosave",0},
{"AutosaveInterval",0},
}
--[[ Container Table for the Datarefs to be monitored ]]
Persistence_Datarefs = {
{"DATAREF"},
}
-- sim/aircraft/view/acf_livery_path
--[[

FUNCTIONS

]]
--[[ ]]
function Persistence_Config_Read(inputfile)
    local file = io.open(inputfile, "r") -- Check if file exists
    if file then
        XluaPersist_HasConfig = 1
        LogOutput("FILE READ START: Persistence Configuration")
        local temptable = { }
        local i=0
        for line in file:lines() do
            -- Find lines matching first subtable of output table
            if string.match(line,"^"..Persistence_Config_Vars[1][1]..":") then
                local temptable = {}
                local splitline = SplitString(line,"([^:]+)")
                local substringline = SplitString(splitline[2],"([^=]+)")
                for j=2,#Persistence_Config_Vars do
                    if Persistence_Config_Vars[j][1] == substringline[1] then
                        Persistence_Config_Vars[j][2] = substringline[2]
                        --PrintToConsole(Persistence_Config_Vars[j][1].." set to "..Persistence_Config_Vars[j][2])
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
--[[ ]]
function Persistence_Config_Write(outputfile)
    LogOutput("FILE WRITE START: Persistence Configuration")
    local file = io.open(outputfile, "w")
    file:write("# Xlua Persistence configuration file generated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# - Autoload is either 0 or 1\n")
    file:write("# - Autosave is either 0 or 1\n")
    file:write("# - AutosaveInterval is handled in seconds\n")
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

--[[

MENU

]]
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local Persistence_Menu_Items = {
"Persistence",              -- Menu title, index 1
"Save Cockpit State Now",   -- Item index: 2
"Load Cockpit State Now",   -- Item index: 3
"[Separator]",              -- Item index: 4
"Cockpit State Autosave",   -- Item index: 5
"Cockpit State Autoload",   -- Item index: 6
"[Separator]",              -- Item index: 7
"Datarefs Tracked",         -- Item index: 8
"Second Save Interval",     -- Item index: 9
}
--[[ Menu variables for FFI ]]
Persistence_Menu_ID = nil
Persistence_Menu_Pointer = ffi.new("const char")
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function Persistence_Menu_Callbacks(itemref)
    for i=2,#Persistence_Menu_Items do
        if itemref == Persistence_Menu_Items[i] then
            if i == 5 then
                if MenuVarTest2[2] == false then MenuVarTest2[2] = true else MenuVarTest2[2] = false end
            end
            if i == 6 then
                if MenuVarTest2[3] == false then MenuVarTest2[3] = true else MenuVarTest2[3] = false end
            end
            Persistence_Menu_Watchdog(Persistence_Menu_Items,i)
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function Persistence_Menu_Watchdog(intable,index)
    if index == 5 then
        if MenuVarTest2[2] == false then Menu_CheckItem(Persistence_Menu_ID,index,"Deactivate") -- Menu_CheckItem must be "Activate" or "Deactivate"!
        elseif MenuVarTest2[2] == true then Menu_CheckItem(Persistence_Menu_ID,index,"Activate") end
    end
    if index == 6 then
        if MenuVarTest2[3] == false then Menu_CheckItem(Persistence_Menu_ID,index,"Deactivate") -- Menu_CheckItem must be "Activate" or "Deactivate"!
        elseif MenuVarTest2[3] == true then Menu_CheckItem(Persistence_Menu_ID,index,"Activate") end
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
