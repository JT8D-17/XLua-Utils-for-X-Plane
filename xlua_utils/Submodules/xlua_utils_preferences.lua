--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ Accessor: Get value from a subtable ]]
function Preferences_ValGet(item)
    for i=1,#Persistence_Config_Vars do
       if Persistence_Config_Vars[i][1] == item then return Persistence_Config_Vars[i][2] end
    end
end
--[[ Accessor: Set value from a subtable ]]
function Preferences_ValSet(item,newvalue)
    for i=1,#Persistence_Config_Vars do
       if Persistence_Config_Vars[i][1] == item then Persistence_Config_Vars[i][2] = newvalue break end
    end
end
--[[ Persistence config file read ]]
function Preferences_Read(inputfile,outputtable)
    local file = io.open(inputfile, "r") -- Check if file exists
    if file then
        XluaPersist_HasConfig = 1
        LogOutput("FILE READ START: Xlua Utils Preferences")
        local i=0
        for line in file:lines() do
            -- Find lines matching first subtable of output table
            if string.match(line,"^"..outputtable[1][1]..",") then
                local temptable = {}
                local splitline = SplitString(line,"([^,]+)")                
                for j=2,#splitline do
                   if string.match(splitline[j],"{") then -- Handle tables
                       local tempsubtable = {}
                       local splittable = SplitString(splitline[j],"{(.*)}") -- Strip brackets
                       local splittableelements = SplitString(splittable[1],"([^;]+)") -- Split at ;
                       for k=1,#splittableelements do
                          local substringtemp = SplitString(splittableelements[k],"([^:]+)")
                          if substringtemp[2] == "string" then tempsubtable[k] = tostring(substringtemp[1]) end
                          if substringtemp[2] == "number" then tempsubtable[k] = tonumber(substringtemp[1]) end
                       end
                       temptable[j-1] = tempsubtable
                       --PrintToConsole("Table: "..table.concat(temptable[j-1],"-"))
                   else -- Handle regular variables
                        local substringtemp = SplitString(splitline[j],"([^:]+)")
                        if substringtemp[2] == "string" then substringtemp[1] = tostring(substringtemp[1]) end
                        if substringtemp[2] == "number" then substringtemp[1] = tonumber(substringtemp[1]) end
                        temptable[j-1] = substringtemp[1]
                   end
                end
                --PrintToConsole(TableMergeAndPrint(temptable))
                -- Find matching line in output table
                for m=2,#outputtable do
                    -- Handle string at index 1
                    if type(temptable[1]) ~= "table" and temptable[1] == outputtable[m][1] then
                        --PrintToConsole("Old: "..TableMergeAndPrint(outputtable[m]))
                        for n=2,#temptable do
                            outputtable[m][n] = temptable[n]
                        end
                        --PrintToConsole("New: "..TableMergeAndPrint(outputtable[m]))
                    elseif type(temptable[1]) == "table" and temptable[1][1] == outputtable[m][1][1] then
                        --PrintToConsole("Old: "..TableMergeAndPrint(outputtable[m]))
                        for n=1,#temptable do
                            outputtable[m][n] = temptable[n]
                        end
                        --PrintToConsole("New: "..TableMergeAndPrint(outputtable[m]))
                    end
                end
            end
            i = i+1            
        end
        file:close()
        if i ~= nil and i > 0 then LogOutput("FILE READ SUCCESS: "..inputfile) else LogOutput("FILE READ ERROR: "..inputfile) end
    else
        LogOutput("FILE NOT FOUND: Xlua Utils Preferences")
    end
end
--[[ Persistence config file write ]]
function Preferences_Write(inputtable,outputfile)
    local temptable = { }
    LogOutput("FILE WRITE START: Xlua Utils Preferences")
    local file = io.open(outputfile, "r")
    if file then
        --Read output file and store all lines not part of inputtable and temptable
        for line in io.lines(outputfile) do
            if not string.match(line,"^"..inputtable[1][1]..",") then
                temptable[(#temptable+1)] = line
                PrintToConsole(temptable[#temptable])
            end
        end
    end
    -- Start writing to output file, write temptable and then inputtable
    file = io.open(outputfile,"w")
    file:write("# Xlua Utils Preferences File generated/updated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("\n")
    for j=3,#temptable do
        file:write(temptable[j].."\n")
    end
    for j=2,#inputtable do
        file:write(inputtable[1][1]..",")
        for k=1,#inputtable[j] do
            if type(inputtable[j][k]) == "string" or type(inputtable[j][k]) == "number" then file:write(inputtable[j][k]..":"..type(inputtable[j][k])) end
            if type(inputtable[j][k]) == "table" then
                file:write("{")
                for l=1,#inputtable[j][k] do
                    file:write(inputtable[j][k][l]..":"..type(inputtable[j][k][l]))
                    if l < #inputtable[j][k] then file:write(";") end
                end
                file:write("}")
            end
            if k < #inputtable[j] then file:write(",") else file:write("\n") end
        end
    end
    if file:seek("end") > 0 then LogOutput("FILE WRITE SUCCESS: Xlua Utils Preferences") else LogOutput("FILE WRITE ERROR: Xlua Utils Preferences") end
	file:close()
end
