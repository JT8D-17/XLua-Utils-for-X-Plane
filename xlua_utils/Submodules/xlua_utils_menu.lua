--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

MENU LABELS, ITEMS AND ACTIONS

]]
local Menu_Items = {" Test 1","[Separator]","Test 2"}  -- Menu entries, index starts at 1
--[[ Variables for FFI ]]
local Menu_ID = nil
local Menu_Pointer = ffi.new("const char")
--[[

INITIALIZATION

]]
--[[ Menu item callback wrapper ]]
local function CallbackWrapper(itemref,intable)
    for i=2,#intable do
        if itemref == intable[i] then
            MenuCallbacks(i)
            MenuWatchdog(intable,i)
        end
    end
end
--[[

MENU INITALIZATION AND CLEANUP

]]
--[[ Menu initialization ]]
function Menu_Init(intable)
    local Menu_Indices = {}
    for i=2,#intable do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        Menu_ID = XPLM.XPLMCreateMenu(intable[1],nil,0, function(inMenuRef,inItemRef) CallbackWrapper(inItemRef,intable) end,ffi.cast("void *",Menu_Pointer))
        for i=2,#intable do
            if intable[i] ~= "[Separator]" then
                Menu_Pointer = intable[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(Menu_ID,intable[i],ffi.cast("void *",Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(Menu_ID)
            end
        end
        for i=2,#intable do
            if intable[i] ~= "[Separator]" then
                MenuWatchdog(intable,i)
            end
        end
        LogOutput(intable[1].." menu initialized!")
    end
end
--[[ Menu cleanup upon script reload or session exit ]]
function Menu_CleanUp()
   XPLM.XPLMClearAllMenuItems(XPLM.XPLMFindPluginsMenu())
   --XPLM.XPLMDestroyMenu(Menu_ID)
end
--[[

MENU MANIPULATION WRAPPERS

]]
--[[ Menu item name change ]]
function Menu_ChangeItemPrefix(intable,index,prefix)
    XPLM.XPLMSetMenuItemName(Menu_ID,index-2,prefix.." "..intable[index],1)
end
--[[ Menu item check status change ]]
function Menu_CheckItem(index,state)
    index = index - 2
    local out = ffi.new("XPLMMenuCheck[1]")
    XPLM.XPLMCheckMenuItemState(Menu_ID,index-1,ffi.cast("XPLMMenuCheck *",out))
    if tonumber(out[0]) == 0 then XPLM.XPLMCheckMenuItem(Menu_ID,index,1) end
    if state == "Activate" and tonumber(out[0]) ~= 2 then XPLM.XPLMCheckMenuItem(Menu_ID,index,2)
    elseif state == "Deactivate" and tonumber(out[0]) ~= 1 then XPLM.XPLMCheckMenuItem(Menu_ID,index,1)
    end
end
--PrintToConsole("Successful parse of xlua_utils_menu.lua")
