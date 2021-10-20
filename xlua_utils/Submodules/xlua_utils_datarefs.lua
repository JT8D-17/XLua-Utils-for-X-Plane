--[[

XLua Module, required by xlua_utils.lua
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
function Dataref_InitContainer(inputdref,outputtable)
    local dataref = XPLM.XPLMFindDataRef(inputdref)
    if dataref == nil then -- Check if dataref exists
        LogOutput("Dataref "..inputdref.." discarded: Not found.")
    else
        if XPLM.XPLMCanWriteDataRef(dataref) == 0 then -- Check if dataref is writable
            LogOutput("Dataref "..inputdref.." discarded: Not writable.")
        else
            -- Types: 1 - Integer, 2 - Float, 4 - Double, 8 - Float array, 16 - Integer array, 32 - Data array
            -- Create subtable for dataref
            outputtable[#outputtable+1] = {0,0,{},{}}
            outputtable[#outputtable][1] = inputdref
            outputtable[#outputtable][2] = XPLM.XPLMGetDataRefTypes(dataref)
            -- Write initial dataref values to subtable
            if XPLM.XPLMGetDataRefTypes(dataref) == 1 then outputtable[#outputtable][3][1] = XPLM.XPLMGetDatai(dataref) end
            if XPLM.XPLMGetDataRefTypes(dataref) == 2 then outputtable[#outputtable][3][1] = XPLM.XPLMGetDataf(dataref) end
            if XPLM.XPLMGetDataRefTypes(dataref) == 4 then outputtable[#outputtable][3][1] = XPLM.XPLMGetDatad(dataref) end
            if XPLM.XPLMGetDataRefTypes(dataref) == 8 then
                local size = XPLM.XPLMGetDatavf(dataref,nil,0,0) -- Get size of dataref
                local value = ffi.new("float["..size.."]") -- Define float array
                XPLM.XPLMGetDatavf(dataref,ffi.cast("int *",value),0,size) -- Get float array values from dataref
                for i = 0,(size-1) do
                    outputtable[#outputtable][3][i+1] = value[i] -- Write dataref values to value subtable for dataref
                end
            end
            if XPLM.XPLMGetDataRefTypes(dataref) == 16 then 
                local size = XPLM.XPLMGetDatavi(dataref,nil,0,0) -- Get size of dataref
                local value = ffi.new("int["..size.."]") -- Define integer array
                XPLM.XPLMGetDatavi(dataref,ffi.cast("int *",value),0,size) -- Get integer array values from dataref
                for i = 0,(size-1) do
                    outputtable[#outputtable][3][i+1] = value[i] -- Write dataref values to value subtable for dataref
                end                                 
            end
            if XPLM.XPLMGetDataRefTypes(dataref) == 32 then 
                local size = XPLM.XPLMGetDatab(dataref,nil,0,0) -- Get size of dataref
                local value = ffi.new("char["..size.."]") -- Define character array
                XPLM.XPLMGetDatab(dataref,ffi.cast("void *",value),0,size) -- Get byte array values from dataref
                outputtable[#outputtable][3][1] = ffi.string(value)-- Write dataref value to value subtable for dataref 
            end                            
            outputtable[#outputtable][5] = dataref -- Store handle for faster access
            DebugLogOutput("Found "..outputtable[#outputtable][1].." (Type: "..outputtable[#outputtable][2].."; Values: "..table.concat(outputtable[#outputtable][3],",").."; Handle "..tostring(outputtable[#outputtable][5])..")")
        end
    end
end
--[[ Initializes module datarefs from a table ]]
function DrefTable_Read(inputtable,outputtable)
    local temptable = { }
    for i=1,#inputtable do
        Dataref_InitContainer(inputtable[i],temptable)
    end
    RegenerateDrefTable(temptable,outputtable)
end
--[[ Read a dataref ]]
local function Dataref_Access_Read(intable,index,subtable)
    --local intable[index][5] = XPLM.XPLMFindDataRef(intable[index][1])
    if intable[index][2] == 1 then intable[index][subtable][1] = XPLM.XPLMGetDatai(intable[index][5]) end
    if intable[index][2] == 2 then intable[index][subtable][1] = XPLM.XPLMGetDataf(intable[index][5]) end
    if intable[index][2] == 4 then intable[index][subtable][1] = XPLM.XPLMGetDatad(intable[index][5]) end
    if intable[index][2] == 8 then
        local size = XPLM.XPLMGetDatavf(intable[index][5],nil,0,0) -- Get size of dataref
        local value = ffi.new("float["..size.."]") -- Define float array
        XPLM.XPLMGetDatavf(intable[index][5],ffi.cast("int *",value),0,size) -- Get float array values from dataref
        for i = 0,(size-1) do
            intable[index][subtable][i+1] = value[i] -- Write dataref values to value subtable for dataref
        end
    end
    if intable[index][2] == 16 then
        local size = XPLM.XPLMGetDatavi(intable[index][5],nil,0,0) -- Get size of dataref
        local value = ffi.new("int["..size.."]") -- Define integer array
        XPLM.XPLMGetDatavi(intable[index][5],ffi.cast("int *",value),0,size) -- Get integer array values from dataref
        for i = 0,(size-1) do
            intable[index][subtable][i+1] = value[i] -- Write dataref values to value subtable for dataref
        end
    end
    if XPLM.XPLMGetDataRefTypes(dataref) == 32 then
        local size = XPLM.XPLMGetDatab(dataref,nil,0,0) -- Get size of dataref
        local value = ffi.new("char["..size.."]") -- Define character array
        XPLM.XPLMGetDatab(dataref,ffi.cast("void *",value),0,size) -- Get byte array values from dataref
        intable[#intable][subtable][1] = ffi.string(value) -- Write dataref value to value subtable for dataref
    end
    DebugLogOutput("Reading "..intable[index][1].." (Type: "..intable[index][2].."; Values: "..table.concat(intable[index][subtable],",")..")")
end
--[[ Access a dataref ]]
local function Dataref_Access_Write(intable,index,subtable)
    --local intable[index][5] = XPLM.XPLMFindDataRef(intable[index][1])
    if intable[index][2] == 1 then XPLM.XPLMSetDatai(intable[index][5],intable[index][subtable][1]) end
    if intable[index][2] == 2 then XPLM.XPLMSetDataf(intable[index][5],intable[index][subtable][1]) end
    if intable[index][2] == 4 then XPLM.XPLMSetDatad(intable[index][5],intable[index][subtable][1]) end
    if intable[index][2] == 8 then
        local size = XPLM.XPLMGetDatavf(intable[index][5],nil,0,0) -- Get size of dataref
        local value = ffi.new("float["..size.."]") -- Define float array
        for l=1,#intable[index][subtable] do
            --PrintToConsole(intable[index][subtable][l])
            value[(l-1)] = intable[index][subtable][l]
        end
        XPLM.XPLMSetDatavf(intable[index][5],ffi.cast("float *",value),0,size)
    end
    if intable[index][2] == 16 then
        local size = XPLM.XPLMGetDatavi(intable[index][5],nil,0,0) -- Get size of dataref
        local value = ffi.new("int["..size.."]") -- Define integer array
        for l=1,#intable[index][subtable] do
            --PrintToConsole(intable[index][subtable][l])
            value[(l-1)] = intable[index][subtable][l]
        end
        XPLM.XPLMSetDatavi(intable[index][5],ffi.cast("int *",value),0,size)
    end
    if intable[index][2] == 32 then
        local size = XPLM.XPLMGetDatab(intable[index][5],nil,0,0) -- Get size of dataref
        local value = ffi.new("char["..string.len(intable[index][subtable][1]).."]") -- Define character array, size from string
        value = intable[index][subtable][1]
        XPLM.XPLMSetDatab(intable[index][5],ffi.cast("void *",value),0,size)
    end
    DebugLogOutput("Writing "..intable[index][1].." (Type: "..intable[index][2].."; Values: "..table.concat(intable[index][subtable],",")..")")
end

--[[ Reads all or a single dataref in a table ]]
function Dataref_Read(intable,subtable,filter)
    for j=2,#intable do
        if filter == "All" then -- Loop through all datatrefs
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
        if filter == "All" then -- Loop through all datatrefs
            Dataref_Access_Write(intable,j,subtable)
        end 
        if filter == intable[j][1] then -- Update a single dataref
            Dataref_Access_Write(intable,j,subtable)
        end    
    end
end
