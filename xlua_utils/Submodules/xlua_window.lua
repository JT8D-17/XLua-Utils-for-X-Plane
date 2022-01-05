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
local Window_FontID = 18
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
local DebugWindow_Text = { }
--[[

FUNCTIONS

]]
function DebugWindow_Listener_Add(string,colorkey)
    DebugWindow_Text[#DebugWindow_Text+1] = {string,colorkey}
end

DebugWindow_Listener_Add("I am a test listener","Nominal")
DebugWindow_Listener_Add("Time: "..os.date("%x, %H:%M:%S"),"Nominal")

function DebugWindow_Listener_Update()
    for i=1,#DebugWindow_Text do 
    
    end
end
--[[ Obtains the window coordinates ]]
function DebugWindow_Coords_Get()
    local out = {ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]")}
    XPLM.XPLMGetWindowGeometry(Window_ID,ffi.cast("int *",out[1]),ffi.cast("int *",out[2]),ffi.cast("int *",out[3]),ffi.cast("int *",out[4])) -- Window ID, left, top, right, bottom
    for i=1,4 do Preferences_ValSet(XluaUtils_Config_Vars,"DebugWindowPos",tonumber(out[i][0]),(i+1)) end
    --for i=1,4 do outtable[i] = tonumber(out[i][0]) end
    --PrintToConsole("Window geometry: "..table.concat(XluaUtils_Config_Vars[4],",",2)) 
end
--[[ Sets the window coordinates ]]
function DebugWindow_Coords_Set()
    XPLM.XPLMSetWindowGeometry(Window_ID,Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2),Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3),Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",4),Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",5))
end
--[[ Obtains information about the window font ]]
function Window_Font_Info(fontid,outtable)
    local out = {ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]")}
    XPLM.XPLMGetFontDimensions(fontid,ffi.cast("int *",out[1]),ffi.cast("int *",out[2]),ffi.cast("int *",out[3])) -- font ID, char width, char height, digits only
    for i=1,3 do outtable[i] = tonumber(out[i][0]) end
    --PrintToConsole("Font info: "..table.concat(outtable,","))
end
--[[ Destroys the window ]]
function DebugWindow_Destroy()
   if Window_ID ~= nil then XPLM.XPLMDestroyWindow(Window_ID) Window_ID = nil end
end
--[[ Toggles debug window visibility ]]
function DebugWindow_Toggle()
    XPLM.XPLMSetWindowIsVisible(Window_ID,Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindow"))
end
--[[ Window main timer ]]
function DebugWindow_MainTimer()
    if XPLM.XPLMGetWindowIsVisible(Window_ID) == 0 and Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindow") == 1 then Preferences_ValSet(XluaUtils_Config_Vars,"DebugWindow",0) XluaUtils_Menu_Watchdog(XluaUtils_Menu_Items,4) end
end
--[[

INITIALIZATION

]]
--[[ Initializes the Window ]]
function DebugWindow_Init()
    XLuaUtils_Window_Props = ffi.new("XPLMCreateWindow_t")
    XLuaUtils_Window_Props.left = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)
    XLuaUtils_Window_Props.top = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)
    XLuaUtils_Window_Props.right = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",4)
    XLuaUtils_Window_Props.bottom = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",5)
    XLuaUtils_Window_Props.visible = Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindow")
    XLuaUtils_Window_Props.drawWindowFunc = function(inWindowID,inRefcon)
        DebugWindow_Coords_Get(inWindowID)
        local window_width = (Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",4)-Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2))
        local window_height = (Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",5))
        local fontinfo = { }
        Window_Font_Info(Window_FontID,fontinfo)
        XPLM.XPLMDrawTranslucentDarkBox(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2),Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3),Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",4),Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",5))
        local char_limit = tonumber(string.format("%d",(window_width / 7.25)))
        local line_height = fontinfo[2]*1.5
        local max_lines = 1
        if math.floor(window_height / line_height) < #DebugWindow_Text then max_lines = math.floor(window_height / line_height) else max_lines = #DebugWindow_Text end
        --XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[1]),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)+5),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-(1*line_height)),ffi.new("char[1024]","This is a dynamic header, displaying time: "..os.date("%x, %H:%M:%S")),nil,Window_FontID)
        local outputstring = " "
        for i = 1,max_lines do
            if string.len(DebugWindow_Text[i][1]) > char_limit then outputstring = string.sub(DebugWindow_Text[i][1],1,char_limit) else outputstring = DebugWindow_Text[i][1] end
            if DebugWindow_Text[i][2] == "Nominal" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[1]),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)+5),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-(i*line_height)),ffi.new("char[1024]",outputstring),nil,Window_FontID) end
            if DebugWindow_Text[i][2] == "Success" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[2]),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)+5),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-(i*line_height)),ffi.new("char[1024]",outputstring),nil,Window_FontID) end
            if DebugWindow_Text[i][2] == "Caution" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[3]),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)+5),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-(i*line_height)),ffi.new("char[1024]",outputstring),nil,Window_FontID) end
            if DebugWindow_Text[i][2] == "Warning" then XPLM.XPLMDrawString(ffi.new("float[3]",Window_StringColors[4]),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",2)+5),(Preferences_ValGet(XluaUtils_Config_Vars,"DebugWindowPos",3)-(i*line_height)),ffi.new("char[1024]",outputstring),nil,Window_FontID) end
        end
    end
    XLuaUtils_Window_Props.handleMouseClickFunc = function(inWindowID,x,y,inMouse,inRefcon) 
        return 1 
    end
    XLuaUtils_Window_Props.handleKeyFunc = function(inWindowID,inKey,inFlags,inVirtualKey,inRefcon,losingFocus) end
    XLuaUtils_Window_Props.handleCursorFunc = function(inWindowID,x,y,inRefcon) return 0 end
    XLuaUtils_Window_Props.handleMouseWheelFunc = function(inWindowID,x,y,wheel,clicks,inRefcon) return 1 end
    XLuaUtils_Window_Props.refcon = nil
    XLuaUtils_Window_Props.decorateAsFloatingWindow = 1
    XLuaUtils_Window_Props.layer = 1
    XLuaUtils_Window_Props.handleRightClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 1 end
    XLuaUtils_Window_Props.structSize = ffi.sizeof(XLuaUtils_Window_Props)
    
    Window_ID = XPLM.XPLMCreateWindowEx(ffi.cast("XPLMCreateWindow_t *",XLuaUtils_Window_Props))    
    if Window_ID ~= nil then
        XPLM.XPLMSetWindowTitle(Window_ID,ffi.new("char[256]",Window_Title));
        PrintToConsole("Window created! (ID: "..tostring(Window_ID)..")")
        run_at_interval(DebugWindow_MainTimer,1)
    end 
end
--[[ Reloads the window ]]
function DebugWindow_Reload()
    Preferences_Read(Xlua_Utils_PrefsFile,XluaUtils_Config_Vars)
    DebugWindow_Coords_Set()
end
