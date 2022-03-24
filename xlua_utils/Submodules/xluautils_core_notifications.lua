--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
local Window_Title = "Xlua Utils Notifications"
local Window_StringColors = {
{0.929, 0.929, 0.929},  -- RGB Nominal
{0, 0.760, 0.090},      -- RGB Success
{1, 0.658, 0.2},        -- RGB Caution
{0.886, 0.031, 0.050},  -- RGB Warning
}
local Window_Coords={0,200,200,100} -- Left, top, right, bottom
local Window_Size = { } -- Width, height
local Window_MaxLines = 10
local Window_FontID = 18    -- ID of the font to be used for this window
local Window_FontProps = { } -- Container table for the font properties (width, height, digits only)
local Window_LineProps = {0,0} -- Window text line height, line length
local Notification_Stack = { } -- Subtable format: {string,color string} Color string: "Nominal", "Success", "Caution" or "Warning"
local Notification_Stack_Buffer = { } -- Temporary; ignore
local Notification_Stack_ToDelete = { } -- Temporary; ignore
local NotifyWindow_ID = nil
--[[

FUNCTIONS

]]
--[[ Function to display a notification. Parameters: inputstring, "Nominal"/"Success"/"Caution"/"Warning", displaytime in seconds (negative number produces a pinned notification; number must be unique!) ]]
function DisplayNotification(inputstring,colorkey,displaytime)
    if displaytime > 0 then displaytime = os.clock() + displaytime end
    Notification_Stack[#Notification_Stack+1] = {inputstring,colorkey,displaytime}
end
--[[ Check if a notification with a unique ID exists ]]
function CheckNotification(inID)
    for i=1,#Notification_Stack do
        if Notification_Stack[i][3] == inID then return true end
    end
end
--[[ Removes a notification with a unique ID from the stack ]]
function RemoveNotification(inID)
    for i=1,#Notification_Stack do
        if Notification_Stack[i][3] == inID then table.remove(Notification_Stack,i) end
    end
end
--[[ Updates a notification with a unique ID ]]
function UpdateNotification(inputstring,colorkey,inID)
    RemoveNotification(inID)
    DisplayNotification(inputstring,colorkey,inID)
end
--[[ Update function for the notification window's buffer ]]
function UpdateNotificationWindowBuffer()
    Notification_Stack_Buffer = { }
    for i=1,#Notification_Stack do
        if Notification_Stack[i][3] <= 0 then
            Notification_Stack_Buffer[#Notification_Stack_Buffer+1] = {Notification_Stack[i][1],Notification_Stack[i][2],"xx"}
        else
            if os.clock() <= Notification_Stack[i][3] then
                Notification_Stack_Buffer[#Notification_Stack_Buffer+1] = {Notification_Stack[i][1],Notification_Stack[i][2],string.format("%02d",Notification_Stack[i][3] - os.clock())}
                --PrintToConsole(table.concat(Notification_Stack_Buffer[#Notification_Stack_Buffer],","))
            else
                Notification_Stack_ToDelete[#Notification_Stack_ToDelete+1] = i
            end
        end
    end
end
--[[ Removes timed out items from the notification stack ]]
function CleanNotificationStack()
    if #Notification_Stack_ToDelete > 0 then
        for k=1,#Notification_Stack_ToDelete do
            table.remove(Notification_Stack,k)
            Notification_Stack_ToDelete = { }
        end
    end
end
--[[ Test timer for notification handling ]]
function NotificationTimer()
    if XPLM.XPLMGetWindowIsVisible(DebugWindow_ID) == 1 then
        UpdateNotification("Debug window open, time: "..os.date("%x, %H:%M:%S"),"Nominal",-10)
    elseif XPLM.XPLMGetWindowIsVisible(DebugWindow_ID) == 0 and CheckNotification(-10) then
        RemoveNotification(-10)
    end
    if #Notification_Stack > 0 then XPLM.XPLMSetWindowIsVisible(NotifyWindow_ID,1) else XPLM.XPLMSetWindowIsVisible(NotifyWindow_ID,0) end
end
--[[ Draw callback for the notification window ]]
function Notify_Window_Draw(inWindowID,inRefcon)
    --XPLM.XPLMDrawTranslucentDarkBox(Window_Coords[1],Window_Coords[2],Window_Coords[3],Window_Coords[4])
    UpdateNotificationWindowBuffer()
    Window_Size[1] = Window_Coords[3] - Window_Coords[1] -- Calculate horizontal window size
    Window_Size[2] = (Window_LineProps[1] * (#Notification_Stack_Buffer+1)) + (0.5 * Window_LineProps[1]) -- Calculate vertical window size
    Window_Coords[4] = Window_Coords[2] - Window_Size[2] -- Calculate window size (top coordinate minus line height)
    Window_Coords_Set(NotifyWindow_ID,Window_Coords)
    Window_LineProps[2] = tonumber(string.format("%d",(Window_Size[1] / (0.75 * Window_FontProps[1])))) -- Maximum number of displayed characters per line
    XPLM.XPLMDrawTranslucentDarkBox(Window_Coords[1],Window_Coords[2],Window_Coords[3],Window_Coords[4])
    XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[1]),(Window_Coords[1]+5),(Window_Coords[2]-Window_LineProps[1]),ffi.new("char[256]","Xlua Utils Notification:"),nil,Window_FontID)
    local buffer = ffi.new("char[1024]")
    for i = 1,#Notification_Stack_Buffer do
        if string.len(Notification_Stack_Buffer[i][1]) > Window_LineProps[2] then buffer = "("..Notification_Stack_Buffer[i][3]..") "..string.sub(Notification_Stack_Buffer[i][1],1,Window_LineProps[2]) else buffer = "("..Notification_Stack_Buffer[i][3]..") "..Notification_Stack_Buffer[i][1] end
        if Notification_Stack_Buffer[i][2] == "Nominal" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[1]),(Window_Coords[1]+5),(Window_Coords[2]-((i+1)*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
        if Notification_Stack_Buffer[i][2] == "Success" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[2]),(Window_Coords[1]+5),(Window_Coords[2]-((i+1)*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
        if Notification_Stack_Buffer[i][2] == "Caution" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[3]),(Window_Coords[1]+5),(Window_Coords[2]-((i+1)*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
        if Notification_Stack_Buffer[i][2] == "Warning" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[4]),(Window_Coords[1]+5),(Window_Coords[2]-((i+1)*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
    end
    CleanNotificationStack()
end
--[[

INITIALIZATION

]]
--[[ Initializes the notification window ]]
function Notify_Window_Build()
    Window_XP_Coords_Get(Window_Coords)
    Window_Font_Info(Window_FontID,Window_FontProps)
    Window_LineProps[1] = Window_FontProps[2] * 1.5 -- Calculate line height
    Window_Coords[1] = Window_Coords[1] + 10
    Window_Coords[2] = Window_Coords[2] - 100
    Window_Coords[3] = Window_Coords[3] - 10
    -- Window_Coords[4] = Window_Coords[2] - (Window_FontProps[2] * 1.5 * Window_MaxLines)
    Window_Coords[4] = Window_Coords[4] + 10
    XLuaUtils_NotifyWin = ffi.new("XPLMCreateWindow_t")
    XLuaUtils_NotifyWin.left = Window_Coords[1]
    XLuaUtils_NotifyWin.top = Window_Coords[2]
    XLuaUtils_NotifyWin.right = Window_Coords[3]
    XLuaUtils_NotifyWin.bottom = Window_Coords[4]
    XLuaUtils_NotifyWin.visible = 1
    XLuaUtils_NotifyWin.drawWindowFunc = Notify_Window_Draw
    XLuaUtils_NotifyWin.handleMouseClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 1 end
    XLuaUtils_NotifyWin.handleKeyFunc = function(inWindowID,inKey,inFlags,inVirtualKey,inRefcon,losingFocus) end
    XLuaUtils_NotifyWin.handleCursorFunc = function(inWindowID,x,y,inRefcon) return 0 end
    XLuaUtils_NotifyWin.handleMouseWheelFunc = function(inWindowID,x,y,wheel,clicks,inRefcon) return 1 end
    XLuaUtils_NotifyWin.refcon = nil
    XLuaUtils_NotifyWin.decorateAsFloatingWindow = 0 -- Or 1
    XLuaUtils_NotifyWin.layer = 1 -- DO NOT PICK 2
    XLuaUtils_NotifyWin.handleRightClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 1 end
    XLuaUtils_NotifyWin.structSize = ffi.sizeof(XLuaUtils_NotifyWin)
    NotifyWindow_ID = XPLM.XPLMCreateWindowEx(ffi.cast("XPLMCreateWindow_t *",XLuaUtils_NotifyWin))
    if NotifyWindow_ID ~= nil then -- Do after window creation
        XPLM.XPLMSetWindowTitle(NotifyWindow_ID,ffi.new("char[256]",Window_Title))
        PrintToConsole("Notification window created! (ID: "..tostring(NotifyWindow_ID)..")")
        run_at_interval(NotificationTimer,0.5)
    end
end
--[[ Notification window unload logic ]]
function Notify_Window_Unload()
    Window_Destroy(NotifyWindow_ID)
end
