--[[

XLuaUtils Example
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ Adds a static line with a unique ID to XLuaUtils' debug window ]]
DebugWindow_AddLine("Header","I am a static debug window line, created on "..os.date("%x, %H:%M:%S"),"Nominal") -- Adds a static line that is not updated to the debug window. Useful for headers or other things. ID should be unique.
DebugWindow_AddLine("TimeTest") -- Reserving a line in the debug window only requires an ID.
--[[ The update timer that refreshes a line by its specific ID ]]
function UpdateTimer()
    DebugWindow_ReplaceLine("TimeTest","This is the current time: "..os.date("%x, %H:%M:%S"),"Nominal") -- Replaces a line by means of its ID. Use this within a timer to refresh the displayed values of variables.
end
--[[ Calling the update timer, refresh interval is 0.5 seconds ]]
run_at_interval(UpdateTimer,0.5)
