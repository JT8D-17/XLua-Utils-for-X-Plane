--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ Access a dataref ]]
local function Dataref_Access(intable,index,mode)
    --local intable[index][4] = XPLM.XPLMFindDataRef(intable[index][1])
    if mode == "read" then
        if intable[index][2] == 1 then intable[index][3][1] = XPLM.XPLMGetDatai(intable[index][4]) end
        if intable[index][2] == 2 then intable[index][3][1] = XPLM.XPLMGetDataf(intable[index][4]) end
        if intable[index][2] == 4 then intable[index][3][1] = XPLM.XPLMGetDatad(intable[index][4]) end
        if intable[index][2] == 8 then
            local size = XPLM.XPLMGetDatavf(intable[index][4],nil,0,0) -- Get size of dataref
            local value = ffi.new("float["..size.."]") -- Define float array
            XPLM.XPLMGetDatavf(intable[index][4],ffi.cast("int *",value),0,size) -- Get float array values from dataref
            for i = 0,(size-1) do
                intable[index][3][i+1] = value[i] -- Write dataref values to value subtable for dataref
            end
        end
        if intable[index][2] == 16 then
            local size = XPLM.XPLMGetDatavi(intable[index][4],nil,0,0) -- Get size of dataref
            local value = ffi.new("int["..size.."]") -- Define integer array
            XPLM.XPLMGetDatavi(intable[index][4],ffi.cast("int *",value),0,size) -- Get integer array values from dataref
            for i = 0,(size-1) do
                intable[index][3][i+1] = value[i] -- Write dataref values to value subtable for dataref
            end                                 
        end
        --PrintToConsole("Reading "..intable[index][1].." (Type: "..intable[index][2].."; Values: "..table.concat(intable[index][3],",")..")")
    end
    if mode == "write" then
        if intable[index][2] == 1 then XPLM.XPLMSetDatai(intable[index][4],intable[index][3][1]) end
        if intable[index][2] == 2 then XPLM.XPLMSetDataf(intable[index][4],intable[index][3][1]) end
        if intable[index][2] == 4 then XPLM.XPLMSetDatad(intable[index][4],intable[index][3][1]) end        
        if intable[index][2] == 8 then
            --XPLM.XPLMSetDatavf(intable[index][4],intable[index][3],0,#intable[index][3])
        end
        if intable[index][2] == 16 then
            --XPLM.XPLMSetDatavi(intable[index][4],intable[index][3],0,#intable[index][3])            
        end
        PrintToConsole("Writing "..intable[index][1].." (Type: "..intable[index][2].."; Values: "..table.concat(intable[index][3],",")..")")
    end
end

--[[ Reads all or a single dataref in a table ]]
function Dataref_Read(filter)
    for j=2,#Persistence_Datarefs do
        if filter == "All" then -- Loop through all datatrefs
            Dataref_Access(Persistence_Datarefs,j,"read")
        end 
        if filter == Persistence_Datarefs[j][1] then -- Update a single dataref
            Dataref_Access(Persistence_Datarefs,j,"read")
        end    
    end
end
--[[ Writes all or a single dataref in a table ]]
function Dataref_Write(filter)
    for j=2,#Persistence_Datarefs do
        if filter == "All" then -- Loop through all datatrefs
            Dataref_Access(Persistence_Datarefs,j,"write")
        end 
        if filter == Persistence_Datarefs[j][1] then -- Update a single dataref
            Dataref_Access(Persistence_Datarefs,j,"write")
        end    
    end
end
