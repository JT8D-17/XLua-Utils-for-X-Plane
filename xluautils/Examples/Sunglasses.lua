--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

Replaces the default "sim/view/sunglasses" command and draws a transluicent dark box to act as a polarization filter to replace the way too weak default sunglasses.
dofile("Submodules/util_oxygensystem.lua")  -- UTILITY --> Add to the other "dofile" calls in xluautils.lua
Sunglasses_Build() --> Add to the flight_start() function in xluautils.lua
Sunglasses_Unload() --> Add to the aircraft_unload() function in xluautils.lua

]]
local Sunglasses_Size={0,200,200,100} -- Left, top, right, bottom
local Sunglasses_WinID = nil
local Sunglasses_Request = 0
--[[

DATAREFS

]]
simDR_View_External = find_dataref("sim/graphics/view/view_is_external")
simDR_Attenuation = find_dataref("sim/graphics/misc/light_attenuation_2d")
--[[

FUNCTIONS

]]
--[[ Handler for the custom command ]]
function Sunglasses_Handler(phase,duration)
    if phase == 0 then
        if Sunglasses_Request == 0 then Sunglasses_Request = 1 else Sunglasses_Request = 0 end
    end
end
--[[ Main timer for the sunglasses ]]
function Sunglasses_Timer()
    -- Auto-remove sunglasses when view is external or not enough light outside, put back on when back inside
    if (simDR_View_External == 1 or simDR_Attenuation >= 0.43) and XPLM.XPLMGetWindowIsVisible(Sunglasses_WinID) == 1 then XPLM.XPLMSetWindowIsVisible(Sunglasses_WinID,0) end
    if (simDR_View_External == 0 and simDR_Attenuation < 0.43) and Sunglasses_Request == 1 and XPLM.XPLMGetWindowIsVisible(Sunglasses_WinID) == 0 then XPLM.XPLMSetWindowIsVisible(Sunglasses_WinID,1) end
    -- Remove the sunglasses when manually requested to
    if Sunglasses_Request == 0 and XPLM.XPLMGetWindowIsVisible(Sunglasses_WinID) == 1 then XPLM.XPLMSetWindowIsVisible(Sunglasses_WinID,0) end
end
--[[ Draw callback for the sunglasses window ]]
function Sunglasses_Draw(inWindowID,inRefcon)
    Window_XP_Coords_Get(Sunglasses_Size)
    Sunglasses_Size[1] = Sunglasses_Size[1] + (0.01 * (Sunglasses_Size[3] - Sunglasses_Size[1])) -- Left, from zero
    Sunglasses_Size[2] = Sunglasses_Size[2] * 0.98 -- Top, window height
    Sunglasses_Size[3] = Sunglasses_Size[3] * 0.99 -- Right, window width
    Sunglasses_Size[4] = Sunglasses_Size[4] + (0.02 * Sunglasses_Size[2] - Sunglasses_Size[4]) -- Bottom, from zero
    XPLM.XPLMDrawTranslucentDarkBox(Sunglasses_Size[1],Sunglasses_Size[2],Sunglasses_Size[3],Sunglasses_Size[4]) -- Refresh sunglasses box
end
--[[ Builder for the sunglasses window ]]
function Sunglasses_Build()
    Window_XP_Coords_Get(Sunglasses_Size)
    Sunglasses_Window = ffi.new("XPLMCreateWindow_t")
    Sunglasses_Window.left = Sunglasses_Size[1]
    Sunglasses_Window.top = Sunglasses_Size[2]
    Sunglasses_Window.right = Sunglasses_Size[3]
    Sunglasses_Window.bottom = Sunglasses_Size[4]
    Sunglasses_Window.visible = 1
    Sunglasses_Window.drawWindowFunc = Sunglasses_Draw
    Sunglasses_Window.handleMouseClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 0 end -- Left mouse clicks pass through
    Sunglasses_Window.handleKeyFunc = function(inWindowID,inKey,inFlags,inVirtualKey,inRefcon,losingFocus) end
    Sunglasses_Window.handleCursorFunc = function(inWindowID,x,y,inRefcon) return 0 end
    Sunglasses_Window.handleMouseWheelFunc = function(inWindowID,x,y,wheel,clicks,inRefcon) return 0 end -- Mouse wheel passes through
    Sunglasses_Window.refcon = nil
    Sunglasses_Window.decorateAsFloatingWindow = 0 -- Must be 0 because no decoration necessary
    Sunglasses_Window.layer = 0 -- DO NOT PICK 2
    Sunglasses_Window.handleRightClickFunc = function(inWindowID,x,y,inMouse,inRefcon) return 0 end -- Right mouse clicks pass through
    Sunglasses_Window.structSize = ffi.sizeof(Sunglasses_Window)
    Sunglasses_WinID = XPLM.XPLMCreateWindowEx(ffi.cast("XPLMCreateWindow_t *",Sunglasses_Window))
    if Sunglasses_WinID ~= nil then -- Do after window creation
        XPLM.XPLMSetWindowTitle(Sunglasses_WinID,ffi.new("char[256]","Sunglasses"))
        PrintToConsole("Sunglasses window created! (ID: "..tostring(Sunglasses_WinID)..")")
        run_at_interval(Sunglasses_Timer,0.5)
    end
end
--[[

COMMANDS

]]
CMD_Sunglasses = replace_command("sim/view/sunglasses",Sunglasses_Handler)
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
--[[ Registration routine for the menu ]]
--[[ Initialization routine for the menu ]]

--[[

RUNTIME CALLBACKS

]]
--[[ Module Main Timer ]]

--[[

INITIALIZATION

]]
--[[ Module is run for the very first time ]]
--[[ Module initialization at every Xlua Utils start ]]
--[[ Module reload ]]


--[[ Window unload logic ]]
function Sunglasses_Unload()
    Window_Destroy(Sunglasses_WinID)
end
