jit.off()
--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
local Debug_Config_Vars = {
{"DEBUG"},
{"DebugOutput",0},
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local Debug_Menu_Items = {
"Debug",
"Debug Output",
"Toggle XLuaUtils Window",
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

OTHER FUNCTIONS

]]
function Debug_Clock_Timer()
    XLuaUtils_Window_ReplaceLine("Clock","Date and time: "..os.date("%x, %H:%M:%S"),nil) -- Replaces a line by means of its ID. Use this within a timer to refresh the displayed values of variables.
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
                if XPLM.XPLMGetWindowIsVisible(XLuaUtilsWindow_ID) == 0 then
                    XLuaUtils_Window_AddText("Debug Test","Forcing the XLuaUtils window open","Nominal",nil)
                    XLuaUtils_Window_AddText("Debug Test","Clock placeholder","Nominal","Clock")
                    XPLM.XPLMSetWindowIsVisible(XLuaUtilsWindow_ID,1)
                    run_at_interval(Debug_Clock_Timer,1)
                else
                    stop_timer(Debug_Clock_Timer)
                    XLuaUtils_Window_RemoveText("Debug Test")
                end
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
    if FileExists(XLuaUtils_PrefsFile) then Preferences_Write(Debug_Config_Vars,XLuaUtils_PrefsFile) end
end
