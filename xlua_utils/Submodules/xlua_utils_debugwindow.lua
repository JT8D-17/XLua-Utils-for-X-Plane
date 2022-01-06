--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]

local Window_Title = "Xlua Utils Debug Window"
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
local strings = {
{"123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X","Nominal"},
{"I am line 2.","Nominal"},
{"I am line 3.","Success"},
{"I am line 4.","Nominal"},
{"I am line 5.","Nominal"},
{"I am line 6.","Warning"},
{"I am line 7.","Nominal"},
{"I am line 8.","Nominal"},
{"I am line 9.","Nominal"},
{"I am line 10.","Caution"},
{"I am line 11.","Nominal"},
{"I am line 12.","Nominal"},
{"I am line 13.","Nominal"},
{"I am line 14.","Nominal"},
{"I am line 15.","Nominal"},
{"I am line 16.","Nominal"},
}

local Window_ID = nil
-- Format: {string,color string} Color string: "Nominal", "Success", "Caution" or "Warning"
DebugWindow_Text = { }
--[[

FUNCTIONS

]]
function DebugWindow_AddText(string,colorkey)
    DebugWindow_Text[#DebugWindow_Text+1] = {string,colorkey}
end



function DebugWindow_Refresh()
    DebugWindow_Text = { }
    DebugWindow_AddText("Time: "..os.date("%x, %H:%M:%S"),"Nominal")
    DebugWindow_AddText("123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X123456789X","Nominal")
end

--[[ Window main timer ]]
function DebugWindow_MainTimer()
    if XPLM.XPLMGetWindowIsVisible(XluaUtils_DebugWinID) == 0 and Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindow") == 1 then Preferences_ValSet(XluaUtils_Config_Vars,"DebugWindow",0) XluaUtils_Menu_Watchdog(XluaUtils_Menu_Items,4) end
end
--[[ Draw callback for the debug window ]]
function DebugWindow_Draw(inWindowID,inRefcon)
    Window_Coords_Get(XluaUtils_DebugWinID,Window_Coords)
    Window_Size[1] = Window_Coords[3] - Window_Coords[1]
    Window_Size[2] = Window_Coords[2] - Window_Coords[4]
    for i=1,4 do Preferences_ValSet(XluaUtils_Config_Vars,"DebugWindowPos",Window_Coords[i],(i+1)) end
    --XPLM.XPLMDrawTranslucentDarkBox(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2),Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3),Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",4),Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",5))
    Window_LineProps[2] = tonumber(string.format("%d",(Window_Size[1] / (0.75 * Window_FontProps[1])))) -- Maximum number of displayed characters per line
    local max_lines = 1
    if math.floor(Window_Size[2] / Window_LineProps[1]) < #DebugWindow_Text then max_lines = math.floor(Window_Size[2] / Window_LineProps[1]) else max_lines = #DebugWindow_Text end
    local buffer = ffi.new("char[1024]")
    for i = 1,max_lines do
        if string.len(DebugWindow_Text[i][1]) > Window_LineProps[2] then buffer = string.sub(DebugWindow_Text[i][1],1,Window_LineProps[2]) else buffer = DebugWindow_Text[i][1] end
        if DebugWindow_Text[i][2] == "Nominal" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[1]),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)+5),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-(i*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
        if DebugWindow_Text[i][2] == "Success" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[2]),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)+5),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-(i*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
        if DebugWindow_Text[i][2] == "Caution" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[3]),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)+5),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-(i*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
        if DebugWindow_Text[i][2] == "Warning" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[4]),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)+5),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-(i*Window_LineProps[1])),ffi.cast("char *",buffer),nil,Window_FontID) end
    end
end
--[[

INITIALIZATION

]]
--[[ Initializes the debug window ]]
function DebugWindow_Init()
    Window_Font_Info(Window_FontID,Window_FontProps)
    Window_LineProps[1] = Window_FontProps[2] * 1.5 -- Calculate line height
    XLuaUtils_Window_Props = ffi.new("XPLMCreateWindow_t")
    XLuaUtils_Window_Props.left = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)
    XLuaUtils_Window_Props.top = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)
    XLuaUtils_Window_Props.right = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",4)
    XLuaUtils_Window_Props.bottom = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",5)
    XLuaUtils_Window_Props.visible = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindow")
    XLuaUtils_Window_Props.drawWindowFunc = DebugWindow_Draw
    XLuaUtils_Window_Props.handleMouseClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 1 end
    XLuaUtils_Window_Props.handleKeyFunc = function(inWindowID,inKey,inFlags,inVirtualKey,inRefcon,losingFocus) end
    XLuaUtils_Window_Props.handleCursorFunc = function(inWindowID,x,y,inRefcon) return 0 end
    XLuaUtils_Window_Props.handleMouseWheelFunc = function(inWindowID,x,y,wheel,clicks,inRefcon) return 1 end
    XLuaUtils_Window_Props.refcon = nil
    XLuaUtils_Window_Props.decorateAsFloatingWindow = 1 -- Or 1
    XLuaUtils_Window_Props.layer = 1 -- DO NOT PICK 2
    XLuaUtils_Window_Props.handleRightClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 1 end
    XLuaUtils_Window_Props.structSize = ffi.sizeof(XLuaUtils_Window_Props)
    XluaUtils_DebugWinID = XPLM.XPLMCreateWindowEx(ffi.cast("XPLMCreateWindow_t *",XLuaUtils_Window_Props))
    if XluaUtils_DebugWinID ~= nil then
        XPLM.XPLMSetWindowTitle(XluaUtils_DebugWinID,ffi.new("char[256]",Window_Title));
        PrintToConsole("Debug Window created! (ID: "..tostring(XluaUtils_DebugWinID)..")")
        run_at_interval(DebugWindow_MainTimer,1)
        run_at_interval(DebugWindow_Refresh,Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowRefreshRate",2))
    end
end
--[[ Reloads a window ]]
function DebugWindow_Reload()
    stop_timer(DebugWindow_Refresh)
    Preferences_Read(Xlua_Utils_PrefsFile,XluaUtils_Config_Vars)
    run_at_interval(DebugWindow_Refresh,Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowRefreshRate",2))
    for i=1,4 do Window_Coords[i] = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",(i+1)) end
    Window_Coords_Set(XluaUtils_DebugWinID,Window_Coords)
end
