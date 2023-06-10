--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ Prepares an empty dataref container table ]]
function RegenerateDrefTable(inputtable,outputtable)
    for i=2,#outputtable do
        outputtable[i] = nil
    end
    for i=1,#inputtable do
        outputtable[i+1] = inputtable[i]
    end
    --PrintToConsole(#outputtable-1)
end
--[[ Initializes a dataref container table ]]
function Dataref_InitContainer(inputdrefline,outputtable)
    local dataref = XPLM.XPLMFindDataRef(inputdrefline[2])
    if dataref == nil then -- Check if dataref exists
        LogOutput("Dataref "..inputdrefline[2].." discarded: Not found.")
    else
        if XPLM.XPLMCanWriteDataRef(dataref) == 0 then -- Check if dataref is writable
            --print("Dataref "..inputdrefline[2].." discarded: Not writable.")
            LogOutput("WARNING: Dataref "..inputdrefline[2].." is not writable!")
        end
        -- Types: 1 - Integer, 2 - Float, 4 - Double, 7 - Unspecified numerical, 8 - Float array, 16 - Integer array, 32 - Data array
        -- Create subtable for dataref
        outputtable[#outputtable+1] = {"","",0,{},{}} -- Alias, dataref, {values 1}, {values 2}
        outputtable[#outputtable][1] = inputdrefline[1]
        outputtable[#outputtable][2] = inputdrefline[2]
        outputtable[#outputtable][3] = XPLM.XPLMGetDataRefTypes(dataref)
        -- Write initial dataref values to subtable
        if XPLM.XPLMGetDataRefTypes(dataref) == 1 then outputtable[#outputtable][4][1] = XPLM.XPLMGetDatai(dataref) end
        if XPLM.XPLMGetDataRefTypes(dataref) == 2 then outputtable[#outputtable][4][1] = XPLM.XPLMGetDataf(dataref) end
        if XPLM.XPLMGetDataRefTypes(dataref) == 4 then outputtable[#outputtable][4][1] = XPLM.XPLMGetDatad(dataref) end
        if XPLM.XPLMGetDataRefTypes(dataref) == 6 then outputtable[#outputtable][4][1] = XPLM.XPLMGetDataf(dataref) end
        if XPLM.XPLMGetDataRefTypes(dataref) == 7 then outputtable[#outputtable][4][1] = XPLM.XPLMGetDataf(dataref) end -- Custom datarefs with unspecified numerical type (can be int and float and double)
        if XPLM.XPLMGetDataRefTypes(dataref) == 8 then
            local size = XPLM.XPLMGetDatavf(dataref,nil,0,0) -- Get size of dataref
            local value = ffi.new("float["..size.."]") -- Define float array
            XPLM.XPLMGetDatavf(dataref,ffi.cast("int *",value),0,size) -- Get float array values from dataref
            for i = 0,(size-1) do
                outputtable[#outputtable][4][i+1] = value[i] -- Write dataref values to value subtable for dataref
            end
        end
        if XPLM.XPLMGetDataRefTypes(dataref) == 16 then
            local size = XPLM.XPLMGetDatavi(dataref,nil,0,0) -- Get size of dataref
            local value = ffi.new("int["..size.."]") -- Define integer array
            XPLM.XPLMGetDatavi(dataref,ffi.cast("int *",value),0,size) -- Get integer array values from dataref
            for i = 0,(size-1) do
                outputtable[#outputtable][4][i+1] = value[i] -- Write dataref values to value subtable for dataref
            end
        end
        if XPLM.XPLMGetDataRefTypes(dataref) == 32 then
            local size = XPLM.XPLMGetDatab(dataref,nil,0,0) -- Get size of dataref
            local value = ffi.new("char["..size.."]") -- Define character array
            XPLM.XPLMGetDatab(dataref,ffi.cast("void *",value),0,size) -- Get byte array values from dataref
            outputtable[#outputtable][4][1] = ffi.string(value)-- Write dataref value to value subtable for dataref
        end
        outputtable[#outputtable][6] = dataref -- Store handle for faster access
        DebugLogOutput("Found "..outputtable[#outputtable][1].." ("..outputtable[#outputtable][2].."; Type: "..outputtable[#outputtable][3].."; Values: "..table.concat(outputtable[#outputtable][4],",").."; Handle "..tostring(outputtable[#outputtable][6])..")")
    end
end
--[[ Initializes module datarefs from a table ]]
function DrefTable_Read(inputtable,outputtable)
    local temptable = { }
    for i=1,#inputtable do
        if inputtable[i][1] == "Dref[n]" then
            inputtable[i][1] = "Dref"..i
            --print("XXXXXXXXX: "..table.concat(inputtable[i]))
        end
        Dataref_InitContainer(inputtable[i],temptable)
    end
    RegenerateDrefTable(temptable,outputtable)
end
--[[ Read a dataref ]]
local function Dataref_Access_Read(intable,index,subtable)
    --local intable[index][6] = XPLM.XPLMFindDataRef(intable[index][1])
    -- Sanitize dataref value output table
    for i=0,#intable[index][subtable] do
        intable[index][subtable][i] = nil
    end
    if intable[index][3] == 1 then intable[index][subtable][1] = XPLM.XPLMGetDatai(intable[index][6]) end
    if intable[index][3] == 2 then intable[index][subtable][1] = XPLM.XPLMGetDataf(intable[index][6]) end
    if intable[index][3] == 4 then intable[index][subtable][1] = XPLM.XPLMGetDatad(intable[index][6]) end
    if intable[index][3] == 6 then intable[index][subtable][1] = XPLM.XPLMGetDataf(intable[index][6]) end
    if intable[index][3] == 7 then intable[index][subtable][1] = XPLM.XPLMGetDataf(intable[index][6]) end -- Custom datarefs with unspecified numerical type (can be int and float and double)
    if intable[index][3] == 8 then
        local size = XPLM.XPLMGetDatavf(intable[index][6],nil,0,0) -- Get size of dataref
        local value = ffi.new("float["..size.."]") -- Define float array
        XPLM.XPLMGetDatavf(intable[index][6],ffi.cast("int *",value),0,size) -- Get float array values from dataref
        for i = 0,(size-1) do
            intable[index][subtable][i+1] = value[i] -- Write dataref values to value subtable for dataref
        end
    end
    if intable[index][3] == 16 then
        local size = XPLM.XPLMGetDatavi(intable[index][6],nil,0,0) -- Get size of dataref
        local value = ffi.new("int["..size.."]") -- Define integer array
        XPLM.XPLMGetDatavi(intable[index][6],ffi.cast("int *",value),0,size) -- Get integer array values from dataref
        for i = 0,(size-1) do
            intable[index][subtable][i+1] = value[i] -- Write dataref values to value subtable for dataref
        end
    end
    if intable[index][3] == 32 then
        local size = XPLM.XPLMGetDatab(intable[index][6],nil,0,0) -- Get size of dataref
        local value = ffi.new("char["..size.."]") -- Define character array
        XPLM.XPLMGetDatab(intable[index][6],ffi.cast("void *",value),0,size) -- Get byte array values from dataref
        intable[index][subtable][1] = ffi.string(value) -- Write dataref value to value subtable for dataref
    end
    --DebugLogOutput("Reading "..intable[index][1].." ("..intable[index][2].."; Type: "..intable[index][3].."; Values: "..table.concat(intable[index][subtable],",")..")")
end
--[[ Write a dataref ]]
local function Dataref_Access_Write(intable,index,subtable)
    --local intable[index][6] = XPLM.XPLMFindDataRef(intable[index][1])
    if intable[index][3] == 1 then XPLM.XPLMSetDatai(intable[index][6],intable[index][subtable][1]) end
    if intable[index][3] == 2 then XPLM.XPLMSetDataf(intable[index][6],intable[index][subtable][1]) end
    if intable[index][3] == 4 then XPLM.XPLMSetDatad(intable[index][6],intable[index][subtable][1]) end
    if intable[index][3] == 6 then XPLM.XPLMSetDataf(intable[index][6],intable[index][subtable][1]) end
    if intable[index][3] == 7 then XPLM.XPLMSetDataf(intable[index][6],intable[index][subtable][1]) end -- Custom datarefs with unspecified numerical type (can be int and float and double)
    if intable[index][3] == 8 then
        local size = XPLM.XPLMGetDatavf(intable[index][6],nil,0,0) -- Get size of dataref
        local value = ffi.new("float["..size.."]") -- Define float array
        for l=1,#intable[index][subtable] do
            --print(intable[index][subtable][l])
            value[(l-1)] = intable[index][subtable][l]
        end
        XPLM.XPLMSetDatavf(intable[index][6],ffi.cast("float *",value),0,size)
    end
    if intable[index][3] == 16 then
        local size = XPLM.XPLMGetDatavi(intable[index][6],nil,0,0) -- Get size of dataref
        local value = ffi.new("int["..size.."]") -- Define integer array
        for l=1,#intable[index][subtable] do
            --print(intable[index][subtable][l])
            value[(l-1)] = intable[index][subtable][l]
        end
        XPLM.XPLMSetDatavi(intable[index][6],ffi.cast("int *",value),0,size)
    end
    if intable[index][3] == 32 then
        local size = XPLM.XPLMGetDatab(intable[index][6],nil,0,0) -- Get size of dataref
        local value = ffi.new("char["..string.len(intable[index][subtable][1]).."]") -- Define character array, size from string
        value = intable[index][subtable][1]
        XPLM.XPLMSetDatab(intable[index][6],ffi.cast("void *",value),0,size)
    end
    DebugLogOutput("Writing "..intable[index][1].." ("..intable[index][2].."; Type: "..intable[index][3].."; Values: "..table.concat(intable[index][subtable],",")..")")
end

--[[ Reads all or a single dataref in a table ]]
function Dataref_Read(intable,subtable,filter)
    for j=2,#intable do
        if filter == "All" then -- Loop through all datarefs
            Dataref_Access_Read(intable,j,subtable)
        end 
        if filter == intable[j][1] then -- Update a single dataref
            Dataref_Access_Read(intable,j,subtable)
        end    
    end
end
--[[ Writes all or a single dataref in a table ]]
function Dataref_Write(intable,subtable,filter)
    for j=2,#intable do
        if filter == "All" then -- Loop through all datarefs
            Dataref_Access_Write(intable,j,subtable)
        end 
        if filter == intable[j][1] then -- Update a single dataref
            Dataref_Access_Write(intable,j,subtable)
        end    
    end
end
