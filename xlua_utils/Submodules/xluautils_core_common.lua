--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

COMMON FUNCTIONS

]]
--[[ Returns the aircraft ACF file and path ]]
function GetAircraftFolder()
    local fileName = ffi.new("char[256]")
    local filePath = ffi.new("char[512]")
    XPLM.XPLMGetNthAircraftModel(0,fileName,filePath);
    fileName = ffi.string(fileName)
    filePath = ffi.string(filePath):match("(.*[/\\])") -- Cut filename from path
    return filePath,fileName
end
--[[ Splits a line at the designated delimiter, returns a table ]]
function SplitString(input,delim)
    local output = {}
    --PrintToConsole("Line splitting in: "..input)
    for i in string.gmatch(input,delim) do table.insert(output,i) end
    --PrintToConsole("Line splitting out: "..table.concat(output,",",1,#output))
    return output
end
--[[ Trims whitespace from the end of a string - credit: https://snippets.bentasker.co.uk/page-1705231409-Trim-whitespace-from-end-of-string-LUA.html ]]
function TrimEndWhitespace(s)
  return s:match'^(.*%S)%s*$'
end
--[[ Merges subtables for printing ]]
function TableMergeAndPrint(intable)
    local tmp = {}
    for i=1,#intable do
        if type(intable[i]) ~= "table" then tmp[i] = tostring(intable[i]) end
        if type(intable[i]) == "table" then tmp[i] = tostring("{"..table.concat(intable[i],",").."}") end
    end
    return tostring(table.concat(tmp,","))
end
--[[

PREFERENCE FILE I/O FUNCTIONS

]]
--[[ Accessor: Get value from a subtable ]]
function Preferences_ValGet(inputtable,item,subitem)
    for i=1,#inputtable do
       if inputtable[i][1] == item then
           if subitem == nil then return inputtable[i][2] else return inputtable[i][subitem] end
       end
    end
end
--[[ Accessor: Set value from a subtable ]]
function Preferences_ValSet(inputtable,item,newvalue,subitem)
    for i=1,#inputtable do
       if inputtable[i][1] == item then
           if subitem == nil then inputtable[i][2] = newvalue break else inputtable[i][subitem] = newvalue break end
       end
    end
end
--[[ Preferences config file read ]]
function Preferences_Read(inputfile,outputtable)
    local file = io.open(inputfile, "r") -- Check if file exists
    if file then
        XluaUtils_HasConfig = 1
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
--[[ Preferences config file write ]]
function Preferences_Write(inputtable,outputfile)
    local temptable = { }
    LogOutput("FILE WRITE START: Xlua Utils Preferences")
    local file = io.open(outputfile, "r")
    if file then
        --Read output file and store all lines not part of inputtable and temptable
        for line in io.lines(outputfile) do
            if not string.match(line,"^"..inputtable[1][1]..",") then
                temptable[(#temptable+1)] = line
                --PrintToConsole(temptable[#temptable])
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
--[[

COMMON MENU FUNCTIONS

]]
--[[ Menu cleanup upon script reload or session exit ]]
function Menu_CleanUp(menu_id,menu_index)
   if menu_id ~= nil then XPLM.XPLMClearAllMenuItems(menu_id) XPLM.XPLMDestroyMenu(menu_id) end
   if menu_index ~= nil then XPLM.XPLMRemoveMenuItem(XPLM.XPLMFindAircraftMenu(),XluaUtils_Menu_Index) end
end
--[[ Menu item name change ]]
function Menu_ChangeItemPrefix(menu_id,index,prefix,intable)
    --LogOutput("Plopp: "..","..index..","..prefix..","..table.concat(intable,":"))
    XPLM.XPLMSetMenuItemName(menu_id,index-2,prefix.." "..intable[index],1)
end
--[[ Menu item check status change ]]
function Menu_CheckItem(menu_id,index,state)
    index = index - 2
    local out = ffi.new("XPLMMenuCheck[1]")
    XPLM.XPLMCheckMenuItemState(menu_id,index-1,ffi.cast("XPLMMenuCheck *",out))
    if tonumber(out[0]) == 0 then XPLM.XPLMCheckMenuItem(menu_id,index,1) end
    if state == "Activate" and tonumber(out[0]) ~= 2 then XPLM.XPLMCheckMenuItem(menu_id,index,2)
    elseif state == "Deactivate" and tonumber(out[0]) ~= 1 then XPLM.XPLMCheckMenuItem(menu_id,index,1)
    end
end
--[[

COMMON WINDOW FUNCTIONS

]]
--[[ Obtains X-Plane's window coordinates ]]
function Window_XP_Coords_Get(outtable)
    local out = {ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]")}
    XPLM.XPLMGetScreenBoundsGlobal(ffi.cast("int *",out[1]),ffi.cast("int *",out[2]),ffi.cast("int *",out[3]),ffi.cast("int *",out[4])) -- Window ID, left, top, right, bottom
    for i=1,4 do outtable[i] = tonumber(out[i][0]) end
    --PrintToConsole("X-Plane window geometry: "..table.concat(outtable,","))
end
--[[ Obtains a window's coordinates ]]
function Window_Coords_Get(inwindowid,outtable)
    local out = {ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]")}
    XPLM.XPLMGetWindowGeometry(inwindowid,ffi.cast("int *",out[1]),ffi.cast("int *",out[2]),ffi.cast("int *",out[3]),ffi.cast("int *",out[4])) -- Window ID, left, top, right, bottom
    for i=1,4 do outtable[i] = tonumber(out[i][0]) end
    --PrintToConsole("Window geometry: "..table.concat(outtable,","))
end
--[[ Sets a window's coordinates ]]
function Window_Coords_Set(inwindowid,intable)
    XPLM.XPLMSetWindowGeometry(inwindowid,intable[1],intable[2],intable[3],intable[4])
end
--[[ Destroys a window ]]
function Window_Destroy(inwindowid)
   if inwindowid ~= nil then XPLM.XPLMDestroyWindow(inwindowid) inwindowid = nil end
end
--[[ Obtains information about the window font ]]
function Window_Font_Info(fontid,outtable)
    local out = {ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]")}
    XPLM.XPLMGetFontDimensions(fontid,ffi.cast("int *",out[1]),ffi.cast("int *",out[2]),ffi.cast("int *",out[3])) -- font ID, char width, char height, digits only
    for i=1,3 do outtable[i] = tonumber(out[i][0]) end
    --PrintToConsole("Font info: "..table.concat(outtable,","))
end
