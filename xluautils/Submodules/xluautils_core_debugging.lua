--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
local Window_Title = "XLuaUtils Debug Window"
local Debug_Config_Vars = {
{"DEBUG"},
{"DebugOutput",0},
{"DebugWindow",0},
{"DebugWindowPos",200,600,600,200}, -- left, top, right, bottom
}
local Window_StringColors = {
{0.929, 0.929, 0.929},  -- RGB Nominal
{0, 0.760, 0.090},      -- RGB Success
{1, 0.658, 0.2},        -- RGB Caution
{0.886, 0.031, 0.050},  -- RGB Warning
}
local Window_Coords = { } -- Left, top, right, bottom
local Window_Size = { } -- Width, height
local Window_FontID = 18
local Window_FontProps = { } -- Container table for the font properties (width, height, digits only)
local Window_LineProps = {0,0} -- Window text line height, maximum number of line characters
DebugWindow_ID = nil
-- Format: {string,color string} Color string: "Nominal", "Success", "Caution" or "Warning"
local DebugWindow_Text = { }
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local Debug_Menu_Items = {
"Debug",
"Debug Output",
"Debug Window",
"Debug Reload",
}
--[[ Menu variables for FFI ]]
local Debug_Menu_Pointer = ffi.new("const char")
local Debug_Menu_ID = nil
--[[

LOGGING FUNCTIONS

]]
--[[ Print to terminal/command console and X-Plane developer console/Log.txt ]]
function PrintToConsole(inputstring)
    XPLM.XPLMDebugString("XLuaUtils - "..inputstring.."\n")
    print("XLuaUtils - "..inputstring)
end
--[[ Write to log file ]]
function WriteToLogFile(inputstring,infile)
	local file = io.open(infile, "a") -- Check if file exists
	file:write(os.date("%x, %H:%M:%S"),": ",inputstring,"\n")
	file:close()
end
--[[ Delete log file ]]
function DeleteLogFile(infile)
    os.remove(infile)
end
--[[ Logging wrapper ]]
function LogOutput(inputstring)
    PrintToConsole(inputstring)
    WriteToLogFile(inputstring,XLuaUtils_LogFile) -- Insert logfile name for sanity and efficiency
end
--[[ Debug logging wrapper ]]
function DebugLogOutput(inputstring)
    if Table_ValGet(Debug_Config_Vars,"DebugOutput",nil,2) == 1 then
        PrintToConsole(inputstring)
        WriteToLogFile(inputstring,XLuaUtils_LogFile) -- Insert logfile name for sanity and efficiency
    end
end
--[[ Checks if debugging is enabled ]]
function DebugIsEnabled()
    if Table_ValGet(Debug_Config_Vars,"DebugOutput",nil,2) == 1 then
        return 1
    end
end
--[[

DEBUG WINDOW

]]
--[[ Adds a line to the end of the debug window ]]
function Debug_Window_AddLine(id,string,colorkey)
    if string == nil then string = "" end -- Assign placeholder string if no string was passed
    if colorkey == nil then colorkey = "Nominal" end -- Assign normal coloring if no colorkey was passed
    if id ~= nil then DebugWindow_Text[#DebugWindow_Text+1] = {id,tostring(string),colorkey} end -- Only add a line if an ID was passed
end
--[[ Removes a line from the debug window ]]
function Debug_Window_RemoveLine(id)
    for i=1,#DebugWindow_Text do
        if id == DebugWindow_Text[i][1] then table.remove(DebugWindow_Text,i) end
    end
end
--[[ Removes all lines from the debug window ]]
function Debug_Window_ClearAll()
    DebugWindow_Text = { }
end
--[[ Replaces a line in the debug window ]]
function Debug_Window_ReplaceLine(id,string,colorkey)
    for i=1,#DebugWindow_Text do
        if string == nil then string = "" end -- Assign placeholder string if no string was passed
        if colorkey == nil then colorkey = "Nominal" end -- Assign normal coloring if no colorkey was passed
        if id ~= nil and DebugWindow_Text[i][1] == id then DebugWindow_Text[i] = {id,tostring(string),colorkey} end -- Only add a line if an ID was passed
    end
end
--[[ Reloads a window ]]
function Debug_Window_Reload()
    Preferences_Read(XLuaUtils_PrefsFile,Debug_Config_Vars)
    for i=1,4 do Window_Coords[i] = Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,(i+1)) end
    Window_Coords_Set(DebugWindow_ID,Window_Coords)
end
--[[ Toggles a window's visibility ]]
function Debug_Window_Visibility(inwindowid)
    XPLM.XPLMSetWindowIsVisible(inwindowid,Table_ValGet(Debug_Config_Vars,"DebugWindow",nil,2))
end
--[[ Window main timer ]]
function Debug_Window_MainTimer()
    if XPLM.XPLMGetWindowIsVisible(DebugWindow_ID) == 0 and Table_ValGet(Debug_Config_Vars,"DebugWindow",nil,2) == 1 then Table_ValSet(Debug_Config_Vars,"DebugWindow",nil,2,0) Debug_Menu_Watchdog(Debug_Menu_Items,3) end
end
--[[ Draw callback for the debug window ]]
function Debug_Window_Draw(inWindowID,inRefcon)
    Window_Coords_Get(DebugWindow_ID,Window_Coords)
    Window_Size[1] = Window_Coords[3] - Window_Coords[1]
    Window_Size[2] = Window_Coords[2] - Window_Coords[4]
    for i=1,4 do Table_ValSet(Debug_Config_Vars,"DebugWindowPos",nil,(i+1),Window_Coords[i]) end
    --XPLM.XPLMDrawTranslucentDarkBox(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,2),Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,3),Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,4),Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,5))
    --print(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,2)..","..Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,3)..","..Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,4)..","..Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,5))
    Window_LineProps[2] = tonumber(string.format("%d",(Window_Size[1] / Window_FontProps[1]) * 1.7)) -- Maximum number of displayed characters per line
    local max_lines = 1
    if math.floor(Window_Size[2] / Window_LineProps[1]) < #DebugWindow_Text then max_lines = math.floor(Window_Size[2] / Window_LineProps[1]) else max_lines = #DebugWindow_Text end
    local buffer = ffi.new("char[1024]")
    for i = 1,max_lines do
        if string.len(DebugWindow_Text[i][2])  > Window_LineProps[2] then buffer = string.sub(DebugWindow_Text[i][2],1,Window_LineProps[2]) else buffer = DebugWindow_Text[i][2] end -- Cut off overly long strings to keep them within the window
        if DebugWindow_Text[i][3] == "Nominal" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[1]),(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,2)+5),(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,3)-(i*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
        if DebugWindow_Text[i][3] == "Success" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[2]),(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,2)+5),(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,3)-(i*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
        if DebugWindow_Text[i][3] == "Caution" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[3]),(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,2)+5),(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,3)-(i*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
        if DebugWindow_Text[i][3] == "Warning" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[4]),(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,2)+5),(Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,3)-(i*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
    end
end
--[[ Builds the debug window ]]
function Debug_Window_Build()
    Window_Font_Info(Window_FontID,Window_FontProps)
    Window_LineProps[1] = Window_FontProps[2] * 1.5 -- Calculate line height
    XLuaUtils_Window_Props = ffi.new("XPLMCreateWindow_t")
    XLuaUtils_Window_Props.left = Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,2)
    XLuaUtils_Window_Props.top = Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,3)
    XLuaUtils_Window_Props.right = Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,4)
    XLuaUtils_Window_Props.bottom = Table_ValGet(Debug_Config_Vars,"DebugWindowPos",nil,5)
    XLuaUtils_Window_Props.visible = Table_ValGet(Debug_Config_Vars,"DebugWindow",nil,2)
    XLuaUtils_Window_Props.drawWindowFunc = Debug_Window_Draw
    XLuaUtils_Window_Props.handleMouseClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 1 end
    XLuaUtils_Window_Props.handleKeyFunc = function(inWindowID,inKey,inFlags,inVirtualKey,inRefcon,losingFocus) end
    XLuaUtils_Window_Props.handleCursorFunc = function(inWindowID,x,y,inRefcon) return 0 end
    XLuaUtils_Window_Props.handleMouseWheelFunc = function(inWindowID,x,y,wheel,clicks,inRefcon) return 1 end
    XLuaUtils_Window_Props.refcon = nil
    XLuaUtils_Window_Props.decorateAsFloatingWindow = 1 -- Or 1
    XLuaUtils_Window_Props.layer = 1 -- DO NOT PICK 2
    XLuaUtils_Window_Props.handleRightClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 1 end
    XLuaUtils_Window_Props.structSize = ffi.sizeof(XLuaUtils_Window_Props)
    DebugWindow_ID = XPLM.XPLMCreateWindowEx(ffi.cast("XPLMCreateWindow_t *",XLuaUtils_Window_Props))
    if DebugWindow_ID ~= nil then
        XPLM.XPLMSetWindowTitle(DebugWindow_ID,ffi.new("char[256]",Window_Title));
        DebugLogOutput("Debug Window created! (ID: "..tostring(DebugWindow_ID)..")")
        run_at_interval(Debug_Window_MainTimer,1)
    end
end
--[[

DEBUG MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function Debug_Menu_Callbacks(itemref)
    for i=2,#Debug_Menu_Items do
        if itemref == Debug_Menu_Items[i] then
            if i == 2 then
                if Table_ValGet(Debug_Config_Vars,"DebugOutput",nil,2) == 0 then Debug_Start() Table_ValSet(Debug_Config_Vars,"DebugOutput",nil,2,1) else Debug_Stop() Table_ValSet(Debug_Config_Vars,"DebugOutput",nil,2,0)  end
                Preferences_Write(Debug_Config_Vars,XLuaUtils_PrefsFile)
                DebugLogOutput("Set XLuaUtils Debug Output to "..Table_ValGet(Debug_Config_Vars,"DebugOutput",nil,2))
            end
            if i == 3 then
                if Table_ValGet(Debug_Config_Vars,"DebugWindow",nil,2) == 0 then Table_ValSet(Debug_Config_Vars,"DebugWindow",nil,2,1) else Table_ValSet(Debug_Config_Vars,"DebugWindow",nil,2,0) end
                Debug_Window_Visibility(DebugWindow_ID)
                Preferences_Write(Debug_Config_Vars,XLuaUtils_PrefsFile)
                DebugLogOutput("Set XLuaUtils Debug Window state to "..Table_ValGet(Debug_Config_Vars,"DebugWindow",nil,2))
            end
            if i == 4 then
                Debug_Reload()
            end
            Debug_Menu_Watchdog(Debug_Menu_Items,i)
        end
    end
end
--[[ Menu watchdog that is used to check an item or change its prefix ]]
function Debug_Menu_Watchdog(intable,index)
    if index == 2 then
        if Table_ValGet(Debug_Config_Vars,"DebugOutput",nil,2) == 0 then Menu_CheckItem(Debug_Menu_ID,index,"Deactivate") -- Menu_CheckItem must be "Activate" or "Deactivate"!
        elseif Table_ValGet(Debug_Config_Vars,"DebugOutput",nil,2) == 1 then Menu_CheckItem(Debug_Menu_ID,index,"Activate") end
    end
    if index == 3 then
        if Table_ValGet(Debug_Config_Vars,"DebugWindow",nil,2) == 0 then Menu_ChangeItemPrefix(Debug_Menu_ID,index,"Open",intable)
        elseif Table_ValGet(Debug_Config_Vars,"DebugWindow",nil,2) == 1 then Menu_ChangeItemPrefix(Debug_Menu_ID,index,"Close",intable) end
    end
end
--[[ Menu initialization routine ]]
function Debug_Menu_Build(ParentMenuID)
    local Menu_Indices = {}
    for i=2,#Debug_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,Debug_Menu_Items[1],ffi.cast("void *","None"),1)
        Debug_Menu_ID = XPLM.XPLMCreateMenu(Debug_Menu_Items[1],ParentMenuID,Menu_Index, function(inMenuRef,inItemRef) Debug_Menu_Callbacks(inItemRef) end,ffi.cast("void *",Debug_Menu_Pointer))
        for i=2,#Debug_Menu_Items do
            if Debug_Menu_Items[i] ~= "[Separator]" then
                Debug_Menu_Pointer = Debug_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(Debug_Menu_ID,Debug_Menu_Items[i],ffi.cast("void *",Debug_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(Debug_Menu_ID)
            end
        end
        for i=2,#Debug_Menu_Items do
            if Debug_Menu_Items[i] ~= "[Separator]" then
                Debug_Menu_Watchdog(Debug_Menu_Items,i)
            end
        end
        DebugLogOutput(Debug_Menu_Items[1].." menu initialized!")
    end
end
--[[

INITIALIZATION

]]
--[[ Initializes the debug module at every startup ]]
function Debug_Init()
    Preferences_Read(XLuaUtils_PrefsFile,Debug_Config_Vars)
    LogOutput(Debug_Config_Vars[1][1]..": Initialized!")
end
--[[ Unload logic for this module ]]
function Debug_Unload()
    if DebugWindow_ID ~= 0 then Window_Destroy(DebugWindow_ID) end
    if FileExists(XLuaUtils_PrefsFile) then Preferences_Write(Debug_Config_Vars,XLuaUtils_PrefsFile) end
end
