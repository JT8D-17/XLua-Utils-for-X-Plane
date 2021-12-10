--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]

local Window_Origin = {200,600}
local Window_Size = {400,220}
local colors = {
{0.929, 0.929, 0.929},  -- Nominal
{0, 0.760, 0.090},      -- Success
{1, 0.658, 0.2},        -- Caution
{0.886, 0.031, 0.050},  -- Warning
}
local font_id = 18
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

function Window_Coords_Get(windowid,intable)
    local out = {ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]")}
    XPLM.XPLMGetWindowGeometry(windowid,ffi.cast("int *",out[1]),ffi.cast("int *",out[2]),ffi.cast("int *",out[3]),ffi.cast("int *",out[4])) -- Window ID, left, top, right, bottom
    for i=1,4 do intable[i] = tonumber(out[i][0]) end
    --PrintToConsole("Window geometry: "..table.concat(intable,",")) 
end

function Window_Font_Info(fontid,intable)
    local out = {ffi.new("int[1]"),ffi.new("int[1]"),ffi.new("int[1]")}
    XPLM.XPLMGetFontDimensions(fontid,ffi.cast("int *",out[1]),ffi.cast("int *",out[2]),ffi.cast("int *",out[3])) -- font ID, char width, char height, digits only
    for i=1,3 do intable[i] = tonumber(out[i][0]) end
    --PrintToConsole("Font info: "..table.concat(intable,","))
end

function Start_Window()
    
    XLuaUtils_Window_Props = ffi.new("XPLMCreateWindow_t")

    XLuaUtils_Window_Props.left = Window_Origin[1]
    XLuaUtils_Window_Props.top = Window_Origin[2]
    XLuaUtils_Window_Props.right = Window_Origin[1] + Window_Size[1]
    XLuaUtils_Window_Props.bottom = Window_Origin[2] - Window_Size[2]
    XLuaUtils_Window_Props.visible = 1
    XLuaUtils_Window_Props.drawWindowFunc = function(inWindowID,inRefcon) 
        local coords = { }
        Window_Coords_Get(inWindowID,coords)
        local window_width = (coords[3]-coords[1])
        local window_height = (coords[2]-coords[4])
        local fontinfo = { }
        Window_Font_Info(font_id,fontinfo)
        XPLM.XPLMDrawTranslucentDarkBox(coords[1],coords[2],coords[3],coords[4])
        local char_limit = tonumber(string.format("%d",(window_width / 7.25)))
        local line_height = fontinfo[2]*1.5
        local max_lines = 1
        if math.floor(window_height / line_height) < #strings then max_lines = math.floor(window_height / line_height) else max_lines = #strings end
        local outputstring = " "
        for i = 1,max_lines do
            if string.len(strings[i][1]) > char_limit then outputstring = string.sub(strings[i][1],1,char_limit) else outputstring = strings[i][1] end
            if strings[i][2] == "Nominal" then XPLM.XPLMDrawString(ffi.new("float[3]",colors[1]),(coords[1]+5),(coords[2]-(i*line_height)),ffi.new("char[1024]",outputstring),nil,font_id) end
            if strings[i][2] == "Success" then XPLM.XPLMDrawString(ffi.new("float[3]",colors[2]),(coords[1]+5),(coords[2]-(i*line_height)),ffi.new("char[1024]",outputstring),nil,font_id) end
            if strings[i][2] == "Caution" then XPLM.XPLMDrawString(ffi.new("float[3]",colors[3]),(coords[1]+5),(coords[2]-(i*line_height)),ffi.new("char[1024]",outputstring),nil,font_id) end
            if strings[i][2] == "Warning" then XPLM.XPLMDrawString(ffi.new("float[3]",colors[4]),(coords[1]+5),(coords[2]-(i*line_height)),ffi.new("char[1024]",outputstring),nil,font_id) end
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
    
    XLuaUtils_Window_ID = XPLM.XPLMCreateWindowEx(ffi.cast("XPLMCreateWindow_t *",XLuaUtils_Window_Props))
    if XLuaUtils_Window_ID ~= nil then
        PrintToConsole("Window created! (ID: "..tostring(XLuaUtils_Window_ID)..")")
    end 

end
