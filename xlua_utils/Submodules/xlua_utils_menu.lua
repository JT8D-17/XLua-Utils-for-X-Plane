--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[ Test variable table for the menu items ]]
local MenuVarTest = {0,false}
--[[

XLUA MENU

]]
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local XluaUtils_Menu_Items = {
"XLua Utils",
"Persistence Files",
}
--[[ Menu variables for FFI ]]
--local XluaUtils_Menu_ID = nil
XluaUtils_Menu_ID = nil     -- GLOBAL!
XluaUtils_Menu_Index = nil  --  GLOBAL!
local XluaUtils_Menu_Pointer = ffi.new("const char")
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function XluaUtils_Menu_Callbacks(itemref)
    for i=2,#XluaUtils_Menu_Items do
        if itemref == XluaUtils_Menu_Items[i] then
            if i == 2 then
                if XluaPersist_HasConfig == 0 then
                    Persistence_Config_Write(Xlua_Utils_Path.."persistence.cfg")
                    Persistence_DrefFile_Write(Xlua_Utils_Path.."datarefs.cfg")
                    Persistence_Config_Read(Xlua_Utils_Path.."persistence.cfg")
                    Persistence_DrefFile_Read(Xlua_Utils_Path.."datarefs.cfg")
                    Persistence_Menu_Init(XluaUtils_Menu_ID)
                elseif XluaPersist_HasConfig == 1 then
                    Persistence_Config_Read(Xlua_Utils_Path.."persistence.cfg")
                    Persistence_DrefFile_Read(Xlua_Utils_Path.."datarefs.cfg")
                    Persistence_Menu_Watchdog(Persistence_Menu_Items,8)
                    Persistence_Menu_Watchdog(Persistence_Menu_Items,12)
                end
            end
            if i == 3 then
                if MenuVarTest[2] == false then MenuVarTest[2] = true else MenuVarTest[2] = false end
            end
            XluaUtils_Menu_Watchdog(XluaUtils_Menu_Items,i)
        end
    end
end
--[[ Menu watchdog that is used to check an item or change its prefix ]]
function XluaUtils_Menu_Watchdog(intable,index)
    if index == 2 then
        if XluaPersist_HasConfig == 0 then Menu_ChangeItemPrefix(XluaUtils_Menu_ID,index,"Initialize",intable)
        elseif XluaPersist_HasConfig == 1 then Menu_ChangeItemPrefix(XluaUtils_Menu_ID,index,"Reload",intable) end
    end
    --if index == 3 then
    --    if MenuVarTest[2] == false then Menu_CheckItem(XluaUtils_Menu_ID,index,"Deactivate") -- Menu_CheckItem must be "Activate" or "Deactivate"!
    --    elseif MenuVarTest[2] == true then Menu_CheckItem(XluaUtils_Menu_ID,index,"Activate") end
    --end
end
--[[ Menu initialization routine ]]
function XluaUtils_Menu_Init()
    local Menu_Indices = {}
    for i=2,#XluaUtils_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        XluaUtils_Menu_Index = XPLM.XPLMAppendMenuItem(XPLM.XPLMFindAircraftMenu(),XluaUtils_Menu_Items[1],ffi.cast("void *","None"),1)
        XluaUtils_Menu_ID = XPLM.XPLMCreateMenu(XluaUtils_Menu_Items[1],XPLM.XPLMFindAircraftMenu(),XluaUtils_Menu_Index, function(inMenuRef,inItemRef) XluaUtils_Menu_Callbacks(inItemRef) end,ffi.cast("void *",XluaUtils_Menu_Pointer))
        for i=2,#XluaUtils_Menu_Items do
            if XluaUtils_Menu_Items[i] ~= "[Separator]" then
                XluaUtils_Menu_Pointer = XluaUtils_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(XluaUtils_Menu_ID,XluaUtils_Menu_Items[i],ffi.cast("void *",XluaUtils_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(XluaUtils_Menu_ID)
            end
        end
        for i=2,#XluaUtils_Menu_Items do
            if XluaUtils_Menu_Items[i] ~= "[Separator]" then
                XluaUtils_Menu_Watchdog(XluaUtils_Menu_Items,i)
            end
        end
        LogOutput(XluaUtils_Menu_Items[1].." menu initialized!")
    end
end

--PrintToConsole("Successful parse of xlua_utils_menu.lua")
