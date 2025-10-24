jit.off()
--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
local Window_Title = "XLuaUtils"
--[[ Table that contains the configuration variables for the XLuaUtils window ]]
local XLuaUtils_Window_Config_Vars = {
{"XLUAUTILS_WINDOW"},
{"Position",200,600,600,200},  -- Left, top, right, bottom in boxels (X-Plane window size across all monitors)
}
local Window_StringColors = {
{0.929, 0.929, 0.929},  -- RGB Nominal
{0, 0.760, 0.090},      -- RGB Success
{1, 0.658, 0.2},        -- RGB Caution
{0.886, 0.031, 0.050},  -- RGB Warning
}
local Window_Coords = {0,0,0,0} -- Left, top, right, bottom
local XP_Window_Coords = {0,0,0,0} -- Left, top, right, bottom
local Window_Size = {0,0} -- Width, height
local Window_FontID = 18
local Window_FontProps = {0,0,0} -- Container table for the font properties (width, height, digits only)
local Window_Lines = {Height=0,MaxChars=0,MaxNum=0} -- Window text line height, maximum number of line characters, maximum number of lines
local Window_Pages = {Current=1,Last=-1,Amount=1,StartLine=1,EndLine=1} -- Window page info
local Window_Buttons = { } -- Delcaration only, actual buttons below!
XLuaUtilsWindow_ID = nil
-- Format: {string,color string} Color string: "Nominal", "Success", "Caution" or "Warning"
local XLuaUtils_Window_TextStack = { }
local XLuaUtils_Window_TextBuffer = { }

local Notification_Stack = { } -- Subtable format: {string,color string} Color string: "Nominal", "Success", "Caution" or "Warning"
local Notification_Stack_Buffer = { } -- Temporary; ignore
local Notification_Stack_ToDelete = { } -- Temporary; ignore

local mouse_x_old = 0
local mouse_y_old = 0

--[[

DATAREFS

]]
Notification_RefTime = find_dataref("sim/time/total_running_time_sec")
Dref_VR_enabled = find_dataref("sim/graphics/VR/enabled")
--Dref_VR_enabled = 1
--[[

XLUAUTILS WINDOW BUTTONS

]]
function XLuaUtils_Window_Update_Buttons()
    -- {1:caption, 2:left, 3:top, 4:right, 5:bottom}
    Window_Buttons = {
    {"<< Prev",(Window_Coords[1]+5),(Window_Coords[4]+20),(Window_Coords[1]+55),(Window_Coords[4]+5)},
    {"        Page "..Window_Pages.Current.." / "..Window_Pages.Amount,(Window_Coords[1]+(Window_Size[1]/2)-50),(Window_Coords[4]+20),(Window_Coords[1]+(Window_Size[1]/2)+50),(Window_Coords[4]+5)},
    {"Next >>",(Window_Coords[3]-55),(Window_Coords[4]+20),(Window_Coords[3]-5),(Window_Coords[4]+5)},
    }
end
--[[ Handles mouse clicks on buttons in the XLuaUtils window ]]
function XLuaUtils_Window_Mouse(x,y,inMouse)
    -- On mouse button click begin
    if inMouse == 1 then -- 1 = Begin, 2 = held, 3 = release
        mouse_x_old = x
        mouse_y_old = y
        --print("Window left "..Window_Coords[1]..", right "..Window_Coords[3]..", top "..Window_Coords[2]..", bottom "..Window_Coords[4])
        -- Detect if mouse position on clicking is within area defined by left, top, right, bottom coordinate of box
        for i=1,#Window_Buttons do
            --print("x "..x..", y "..y.." / "..Window_Buttons[i][1]..": left "..Window_Buttons[i][2]..", right "..Window_Buttons[i][4]..", top "..Window_Buttons[i][3]..", bottom "..Window_Buttons[i][5])
            if x > Window_Buttons[i][2] and x < Window_Buttons[i][4] and y < Window_Buttons[i][3] and y > Window_Buttons[i][5] then
                if i == 1 and Window_Pages.Current > 1 then Window_Pages.Current = Window_Pages.Current - 1  end -- "Prev" button
                if i == 3 and Window_Pages.Current < Window_Pages.Amount then Window_Pages.Current = Window_Pages.Current + 1  end -- "Next" button
            end
        end
    end
    -- On mouse button held down
    if inMouse == 2 then
        Window_XP_Coords_Get(XP_Window_Coords)
        -- Move the window when not decorated, but keep it within the XP window bounds
        if (x > (mouse_x_old+5) or x < (mouse_x_old-5)) and Window_Coords[1] + (x - mouse_x_old) > XP_Window_Coords[1] and  Window_Coords[3] + (x - mouse_x_old) < XP_Window_Coords[3] then
            Window_Coords[1] = Window_Coords[1] + (x - mouse_x_old)
            Window_Coords[3] = Window_Coords[3] + (x - mouse_x_old)
            mouse_x_old = x
        end
        if (y > (mouse_y_old+5) or y < (mouse_y_old-5)) and  Window_Coords[2] + (y - mouse_y_old) < XP_Window_Coords[2] and Window_Coords[4] + (y - mouse_y_old) > XP_Window_Coords[4] then
            Window_Coords[2] = Window_Coords[2] + (y - mouse_y_old)
            Window_Coords[4] = Window_Coords[4] + (y - mouse_y_old)
            mouse_y_old = y
        end
        Window_Coords_Set(XLuaUtilsWindow_ID,Window_Coords)
    end
end
--[[

XLUAUTILS WINDOW INTERACTION

]]
--[[ Adds a line to the end of the XLuaUtils window ]]
function XLuaUtils_Window_AddText(group,string,colorkey,id)
    if string == nil then string = "" end -- Assign placeholder string if no string was passed
    if colorkey == nil then colorkey = "Nominal" end -- Assign normal coloring if no colorkey was passed
    if id == nil then id = "none" end -- Assign an ID if none was supplied
    if group ~= nil then -- Only add a line if a group was passed
        -- Check if a group name already exists in order to avoid adding multiple titles
        if #XLuaUtils_Window_TextStack == 0 then
            XLuaUtils_Window_TextStack[#XLuaUtils_Window_TextStack+1] = {group,"[Title]"..tostring(group).." ",colorkey,"none"}
        else
            local has_group = false
            for i=1,#XLuaUtils_Window_TextStack do
                if XLuaUtils_Window_TextStack[i][1] == group then has_group = true end
            end
            if not has_group then
                XLuaUtils_Window_TextStack[#XLuaUtils_Window_TextStack+1] = {group,"[Title]"..tostring(group).." ",colorkey,"none"}
            end
        end
        -- Splita line at new line and returns
        for line in string:gmatch("[^\r\n]+") do
            XLuaUtils_Window_TextStack[#XLuaUtils_Window_TextStack+1] = {group,tostring(line),colorkey,id}
        end
    end
end
--[[ Removes a line from the XLuaUtils window ]]
function XLuaUtils_Window_RemoveText(group)
    local temp = XLuaUtils_Window_TextStack
    --print(#XLuaUtils_Window_TextStack..","..#temp)
    if #XLuaUtils_Window_TextStack == 1 then
        XLuaUtils_Window_TextStack = {}
    else
        XLuaUtils_Window_TextStack = {}
        for i=1,#temp do
            if group ~= temp[i][1] then XLuaUtils_Window_TextStack[#XLuaUtils_Window_TextStack+1] = temp[i] end
        end
    end
    --print(#XLuaUtils_Window_TextStack..","..#temp)
end
--[[ Removes all lines from the XLuaUtils window ]]
function XLuaUtils_Window_ClearAll()
    XLuaUtils_Window_TextStack = { }
end
--[[ Replaces a line in the XLuaUtils window ]]
function XLuaUtils_Window_ReplaceLine(id,string,colorkey)
    if string == nil then string = "" end -- Assign placeholder string if no string was passed
    if colorkey == nil then colorkey = "Nominal" end -- Assign normal coloring if no colorkey was passed
    if id ~= nil then
        for i=1,#XLuaUtils_Window_TextStack do
            -- If a line matches the ID, replace its ID and color key
            if XLuaUtils_Window_TextStack[i][4] == id then XLuaUtils_Window_TextStack[i][2] = string XLuaUtils_Window_TextStack[i][3] = colorkey  end
        end
    end
end
--[[ Reloads the XLuaUtils window ]]
function XLuaUtils_Window_Reload()
    Preferences_Read(XLuaUtils_PrefsFile,XLuaUtils_Window_Config_Vars)
    for i=1,4 do Window_Coords[i] = Table_ValGet(XLuaUtils_Window_Config_Vars,"Position",nil,(i+1)) end
    Window_Coords_Set(XLuaUtilsWindow_ID,Window_Coords)
end
--[[

XLUAUTILS NOTIFICATIONS

]]
--[[ Notifications: Function to display a notification. Parameters: inputstring, "Nominal"/"Success"/"Caution"/"Warning", displaytime in seconds (negative number produces a pinned notification; number must be unique!) ]]
function DisplayNotification(inputstring,colorkey,displaytime)
    if displaytime > 0 then displaytime = Notification_RefTime + displaytime end
    Notification_Stack[#Notification_Stack+1] = {inputstring,colorkey,displaytime}
end
--[[ Notifications: Check if a notification with a unique ID exists ]]
function CheckNotification(inID)
    for i=1,#Notification_Stack do
        if Notification_Stack[i][3] == inID then return true end
    end
end
--[[ Notifications: Removes a notification with a unique ID from the stack ]]
function RemoveNotification(inID)
    for i=1,#Notification_Stack do
        if Notification_Stack[i][3] == inID then
            Notification_Stack[i][3] = Notification_RefTime
        end
    end
end
--[[ Notifiations: Updates a notification with a unique ID ]]
function UpdateNotification(inputstring,colorkey,inID)
    RemoveNotification(inID)
    DisplayNotification(inputstring,colorkey,inID)
end
--[[ Notifications: Update function for the notification window's buffer ]]
function UpdateNotificationWindowBuffer()
    Notification_Stack_Buffer = { }
    for i=1,#Notification_Stack do
        if Notification_Stack[i][3] <= 0 or Notification_RefTime < Notification_Stack[i][3] then
            Notification_Stack_Buffer[#Notification_Stack_Buffer+1] = Notification_Stack[i] --{Notification_Stack[i][1],Notification_Stack[i][2],"xx"}
        --else
            --print("Remove: "..Notification_Stack[i][3].." --> "..Notification_RefTime)
        end
    end
    Notification_Stack = Notification_Stack_Buffer
end
--[[

XLUAUTILS WINDOW CORE FUNCTIONS

]]
--[[ Toggles XLuaUtils window's visibility ]]
function XLuaUtils_Window_Toggle()
    if XPLM.XPLMGetWindowIsVisible(XLuaUtilsWindow_ID) == 0 then XPLM.XPLMSetWindowIsVisible(XLuaUtilsWindow_ID,1) else XPLM.XPLMSetWindowIsVisible(XLuaUtilsWindow_ID,0) end
    Preferences_Write(XLuaUtils_Window_Config_Vars,XLuaUtils_PrefsFile)
    DebugLogOutput("Set XLuaUtils Debug Window state to "..XLuaUtils_Window_Open)
end
--[[ Marks a menu item ]]
function XLuaUtils_WindowStatus(inmenuid,inindex)
    if XPLM.XPLMGetWindowIsVisible(XLuaUtilsWindow_ID) == 1 then Menu_CheckItem(inmenuid,inindex,"Activate") else Menu_CheckItem(inmenuid,inindex,"Deactivate") end
end
--[[ Window main timer ]]
function XLuaUtils_Window_MainTimer()
    if #Notification_Stack > 0 and XPLM.XPLMGetWindowIsVisible(XLuaUtilsWindow_ID) == 0 then XPLM.XPLMSetWindowIsVisible(XLuaUtilsWindow_ID,1) end
    -- Close the window if there is no content to display
    if #Notification_Stack == 0 and #XLuaUtils_Window_TextStack == 0 and XPLM.XPLMGetWindowIsVisible(XLuaUtilsWindow_ID) == 1 then XPLM.XPLMSetWindowIsVisible(XLuaUtilsWindow_ID,0) end
end
--[[ Draws a window button, see "XLuaUtils_Window_Update_Buttons()" above ]]
function XLuaUtils_Window_DrawButton(index)
    XPLM.XPLMDrawTranslucentDarkBox(Window_Buttons[index][2],Window_Buttons[index][3],Window_Buttons[index][4],Window_Buttons[index][5])
    XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[1]),Window_Buttons[index][2],(Window_Buttons[index][5]+(0.5*(Window_Buttons[index][3]-Window_Buttons[index][5]))),ffi.cast("char *",Window_Buttons[index][1]),nil,Window_FontID)
end

--[[ Rebuilds the text buffer, keeping any notifications on top ]]
function XLuaUtils_Window_Rebuild_TextBuffer()
    XLuaUtils_Window_TextBuffer = { }
    -- Notifications are always on top
    UpdateNotificationWindowBuffer()
    if #Notification_Stack_Buffer > 0 then
        XLuaUtils_Window_TextBuffer[#XLuaUtils_Window_TextBuffer+1] = {"Notifications","[Title]XLuaUtils Notifications ","Nominal"}
        for i=1,#Notification_Stack_Buffer do
            XLuaUtils_Window_TextBuffer[#XLuaUtils_Window_TextBuffer+1] = {"Notifications",tostring(Notification_Stack_Buffer[i][1]),Notification_Stack_Buffer[i][2],nil}
        end
        XLuaUtils_Window_TextBuffer[#XLuaUtils_Window_TextBuffer+1] = {"Notifications","[Dashes]","Nominal",nil}
        XLuaUtils_Window_TextBuffer[#XLuaUtils_Window_TextBuffer+1] = {"Notifications"," ","Nominal",nil}
        if Window_Pages.Last == -1 then Window_Pages.Last = Window_Pages.Current end -- Store the page the user was last on when a notification appeared
        Window_Pages.Current = 1 -- Reset the page to 1
    elseif Window_Pages.Last > 0 then
        Window_Pages.Current = Window_Pages.Last
        Window_Pages.Last = -1
    end
    -- Fill the rest of the buffer with the window text stack
    if #XLuaUtils_Window_TextStack > 0 then
        for i=1,#XLuaUtils_Window_TextStack do
            XLuaUtils_Window_TextBuffer[#XLuaUtils_Window_TextBuffer+1] = {XLuaUtils_Window_TextStack[i][1],tostring(XLuaUtils_Window_TextStack[i][2]),XLuaUtils_Window_TextStack[i][3],XLuaUtils_Window_TextStack[i][4]}
        end
    end
end
--[[ Draw callback for the XLuaUtils window ]]
function XLuaUtils_Window_Draw(inWindowID,inRefcon)
    Window_Coords_Get(XLuaUtilsWindow_ID,Window_Coords)
    Window_Size[1] = Window_Coords[3] - Window_Coords[1] -- Width = right - left
    Window_Size[2] = Window_Coords[2] - Window_Coords[4] -- Height = top - bottom
    --for i=1,4 do Table_ValSet(XLuaUtils_Window_Config_Vars,"Position",nil,(i+1),Window_Coords[i]) end
    XPLM.XPLMDrawTranslucentDarkBox(Window_Coords[1],Window_Coords[2],Window_Coords[3],Window_Coords[4])
    -- Calculate the maximum number of characters per line that can be accomodated by the window width
    Window_Lines.MaxChars = tonumber(string.format("%d",(Window_Size[1] / Window_FontProps[1] * 1.855)))
    -- Calculate the maximum number of lines that can be accomodated by the window height
    Window_Lines.MaxNum = math.floor(Window_Size[2] / Window_Lines.Height)
    if Window_Lines.MaxNum == 0 then Window_Lines.MaxNum = 1 end
    -- Rebuild the text buffer for the stack
    XLuaUtils_Window_Rebuild_TextBuffer()
    -- Calculate maximum number of lines that can be displayed in the window. If longer than allowed, reserve space at the bottom for page scrolling buttons
    if #XLuaUtils_Window_TextBuffer > Window_Lines.MaxNum then Window_Lines.MaxNum = Window_Lines.MaxNum - 2  Window_Pages.Amount = math.ceil(#XLuaUtils_Window_TextBuffer/Window_Lines.MaxNum) else Window_Pages.Amount = 1 end
    if Window_Pages.Current > Window_Pages.Amount then Window_Pages.Current = Window_Pages.Amount end
    -- Calculate the start and end lines for the page
    Window_Pages.StartLine = ((Window_Pages.Current - 1) * Window_Lines.MaxNum) + 1
    Window_Pages.EndLine = Window_Pages.StartLine + Window_Lines.MaxNum - 1
    if Window_Pages.EndLine > #XLuaUtils_Window_TextBuffer then Window_Pages.EndLine = #XLuaUtils_Window_TextBuffer end
    -- Fill the page
    local buffer = ffi.new("char[1024]")
    for i=Window_Pages.StartLine,Window_Pages.EndLine do
        -- Cut off overly long strings to keep them within the window
        if (string.len(XLuaUtils_Window_TextBuffer[i][2]) * Window_FontProps[1])  > Window_Lines.MaxChars then buffer = string.sub(XLuaUtils_Window_TextBuffer[i][2],1,Window_Lines.MaxChars) else buffer = XLuaUtils_Window_TextBuffer[i][2] end
        -- Replace placeholder with dashes that fill the window width
        if XLuaUtils_Window_TextBuffer[i][2] == "[Dashes]" then buffer = string.rep("-",(Window_Lines.MaxChars * 1.3)) end
        -- Title items get a line of dashes to the window's edge'
        if string.find(XLuaUtils_Window_TextBuffer[i][2],"%[Title%]") then buffer = string.gsub(XLuaUtils_Window_TextBuffer[i][2],"%[Title%]","")..string.rep("-",(Window_Lines.MaxChars - string.len(string.gsub(XLuaUtils_Window_TextBuffer[i][2],"%[Title%]","")))* 1.3) end
        if XLuaUtils_Window_TextBuffer[i][3] == "Nominal" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[1]),(Window_Coords[1]+5),(Window_Coords[2]-((i-Window_Pages.StartLine+1)*Window_Lines.Height)),ffi.cast("char *",buffer),nil,Window_FontID) end
        if XLuaUtils_Window_TextBuffer[i][3] == "Success" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[2]),(Window_Coords[1]+5),(Window_Coords[2]-((i-Window_Pages.StartLine+1)*Window_Lines.Height)),ffi.cast("char *",buffer),nil,Window_FontID) end
        if XLuaUtils_Window_TextBuffer[i][3] == "Caution" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[3]),(Window_Coords[1]+5),(Window_Coords[2]-((i-Window_Pages.StartLine+1)*Window_Lines.Height)),ffi.cast("char *",buffer),nil,Window_FontID) end
        if XLuaUtils_Window_TextBuffer[i][3] == "Warning" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[4]),(Window_Coords[1]+5),(Window_Coords[2]-((i-Window_Pages.StartLine+1)*Window_Lines.Height)),ffi.cast("char *",buffer),nil,Window_FontID) end
    end
    -- Page navigation controls display when more lines are displayed than can fit on screen
    if Window_Pages.Amount > 1 then
        XLuaUtils_Window_Update_Buttons()
        for i=1,#Window_Buttons do
            if i == 1 and Window_Pages.Current > 1 then XLuaUtils_Window_DrawButton(i) end -- "Prev" button
            if i == 2 then XLuaUtils_Window_DrawButton(i) end -- Pages display
            if i == 3 and Window_Pages.Current < Window_Pages.Amount then XLuaUtils_Window_DrawButton(i) end -- "Next" button
        end
    end
end
--[[ Builds the XLuaUtils window ]]
function XLuaUtils_Window_Build()
    Window_Font_Info(Window_FontID,Window_FontProps)
    Window_Lines.Height = Window_FontProps[2] * 1.5 -- Calculate line height
    XLuaUtils_Window_Props = ffi.new("XPLMCreateWindow_t")
    XLuaUtils_Window_Props.left = Table_ValGet(XLuaUtils_Window_Config_Vars,"Position",nil,2)
    XLuaUtils_Window_Props.top = Table_ValGet(XLuaUtils_Window_Config_Vars,"Position",nil,3)
    XLuaUtils_Window_Props.right = Table_ValGet(XLuaUtils_Window_Config_Vars,"Position",nil,4)
    XLuaUtils_Window_Props.bottom = Table_ValGet(XLuaUtils_Window_Config_Vars,"Position",nil,5)
    XLuaUtils_Window_Props.visible = 0
    XLuaUtils_Window_Props.drawWindowFunc = XLuaUtils_Window_Draw
    XLuaUtils_Window_Props.handleMouseClickFunc = function(inWindowID,x,y,inMouse,inRefcon) XLuaUtils_Window_Mouse(x,y,inMouse) return 1 end
    XLuaUtils_Window_Props.handleKeyFunc = function(inWindowID,inKey,inFlags,inVirtualKey,inRefcon,losingFocus) end
    XLuaUtils_Window_Props.handleCursorFunc = function(inWindowID,x,y,inRefcon) return 0 end
    XLuaUtils_Window_Props.handleMouseWheelFunc = function(inWindowID,x,y,wheel,clicks,inRefcon) return 1 end
    XLuaUtils_Window_Props.refcon = nil
    if Dref_VR_enabled == 0 then XLuaUtils_Window_Props.decorateAsFloatingWindow = 0 else XLuaUtils_Window_Props.decorateAsFloatingWindow = 1 end
    XLuaUtils_Window_Props.layer = 1 -- DO NOT PICK 2
    XLuaUtils_Window_Props.handleRightClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 1 end
    XLuaUtils_Window_Props.structSize = ffi.sizeof(XLuaUtils_Window_Props)
    XLuaUtilsWindow_ID = XPLM.XPLMCreateWindowEx(ffi.cast("XPLMCreateWindow_t *",XLuaUtils_Window_Props))
    if XLuaUtilsWindow_ID ~= nil then
        XPLM.XPLMSetWindowTitle(XLuaUtilsWindow_ID,ffi.new("char[256]",Window_Title));
        DebugLogOutput("XLuaUtils Window created! (ID: "..tostring(XLuaUtilsWindow_ID)..")")
        run_at_interval(XLuaUtils_Window_MainTimer,0.5)
    end
end
--[[

INITIALIZATION

]]
--[[ Initializes the XLuaUtils window module at every startup ]]
function XLuaUtils_Window_Init()
    Preferences_Read(XLuaUtils_PrefsFile,XLuaUtils_Window_Config_Vars)
    LogOutput(XLuaUtils_Window_Config_Vars[1][1]..": Initialized!")
end
--[[ Unload logic for this module ]]
function XLuaUtils_Window_Unload()
    if XLuaUtilsWindow_ID ~= 0 then Window_Destroy(XLuaUtilsWindow_ID) end
    if FileExists(XLuaUtils_PrefsFile) then Preferences_Write(XLuaUtils_Window_Config_Vars,XLuaUtils_PrefsFile) end
end
--[[

TESTING AREA

]]
--[[
XPLM.XPLMSetWindowIsVisible(XLuaUtilsWindow_ID,1)
local test_lines = ""
for i=1,100 do test_lines = test_lines.."line "..i.."\n" end
XLuaUtils_Window_AddText("TestLines",test_lines,"Nominal","none")
]]
