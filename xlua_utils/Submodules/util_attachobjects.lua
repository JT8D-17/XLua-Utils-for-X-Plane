--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

VARIABLES

]]
local AttachObj_Config_File = "attached_objs.cfg" -- Configuration file name
--[[ Table that contains the configuration Variables for the NC Headset module ]]
local AttachObj_Config_Vars = {
{"ATTACHOBJECT"},
{"MainTimerInterval",1},    -- Main timer interval, in seconds
{"HideObjs",0},
}
--[[ List of continuously monitored datarefs used by this module ]]
local Dref_List_Cont = {
--{"Eng_CHT","sim/flightmodel2/engines/CHT_deg_C"}, -- deg C
--{"Wt","sim/flightmodel/weight/m_stations"}, -- deg C
}
--[[ Container table for continuously monitored datarefs, which are stored in subtables {alias,dataref,type,{dataref value(s) storage 1 as specified by dataref length}, {dataref value(s) storage 2 as specified by dataref length}, dataref handler} ]]
local AttachObj_Drefs_Cont = {
"DREFS_CONT",
}
--[[ Menu item table. The first item ALWAYS contains the menu's title! All other items list the menu item's name. ]]
local AttachObj_Menu_Items = {
"Attach Objects",           -- Menu title, index 1
"",                         -- Item index: 2
"",                         -- Item index: 3
"Hide All",                 -- Item index: 4
}
--[[ Menu variables for FFI ]]
local AttachObj_Menu_ID = nil
local AttachObj_Menu_Pointer = ffi.new("const char")
--[[ Other variables ]]
--local Objects = {
-- Name, path,pos x (+ = right),pos y (+ = up),pos z (+ = aft),rot x (+ = aft),rot y (+ = cw),rot z (+ = right),display dataref,dataref index (if array),operator,value
--{"Pole_Test","plugins/xlua/scripts/xlua_utils/Examples/Resources/pole.obj",0,0,0,0,0,0,"sim/flightmodel/weight/m_stations",0,"gt",600},
--{"Pole_Test2","plugins/xlua/scripts/xlua_utils/Examples/Resources/pole.obj",-5,0,0,0,0,45,"sim/flightmodel/weight/m_stations",1,"gt",600},
--}
local AttachObj_Container = { } -- Container table for object data
local AttachObj_Inst                                                -- Placeholder for instance array
local AttachObj_InstRefs = { }                                      -- Instance reference table
local AttachObj_DrawInfo = ffi.new("XPLMDrawInfo_t[?]",1)           -- Creates an information array depending on the length of the input table
local AttachObj_DrawInfoAddr = ffi.new("const XPLMDrawInfo_t*")     -- Arbitrary to store address of drawinfo
local AttachObj_DrawFloat = ffi.new("float[1]")                     -- Some float value
local AttachObj_DrawFloatAddr = ffi.new("const float*")             -- Arbitrary to store addr of float value
local AttachObj_DrefArray                                           -- Placeholder for dataref array
local AttachObj_DrefAddr = ffi.new("const char**")                  -- Arbitrary to store addr of dataref array (source: https://forums.x-plane.org/index.php?/files/file/53433-follow-me-car/)
local AttachObj_HasConfig = 0
local AttachObj_AllowDrawing = 0
local AttachObj_BodyNew = {x=0,y=0,z=0}
local AttachObj_WorldNew = {x=0,y=0,z=0}
--[[

DATAREFS

]]
simDR_pos_local_x = find_dataref("sim/flightmodel/position/local_x")
simDR_pos_local_y = find_dataref("sim/flightmodel/position/local_y")
simDR_pos_local_z = find_dataref("sim/flightmodel/position/local_z")
simDR_pos_the = find_dataref("sim/flightmodel/position/theta") -- Pitch
simDR_pos_phi = find_dataref("sim/flightmodel/position/phi") -- Roll
simDR_pos_psi = find_dataref("sim/flightmodel/position/psi") -- Yaw
--[[

DEBUG WINDOW

]]
--[[ Adds things to the debug window ]]
function AttachObj_DebugWindow_Init()

end
--[[ Updates the debug window ]]
function AttachObj_DebugWindow_Update()

end
--[[

FUNCTIONS

]]
--[[ Attached object config file write ]]
function AttachObject_Config_Write()
    LogOutput("FILE WRITE START: Attached Object Configuration")
    local file = io.open(Xlua_Utils_Path..AttachObj_Config_File, "w")
    file:write("# XLua Utils attachable object configuration generated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# This file contains profile information for XLua Utils' attachable objects module.\n")
    file:write("#\n")
    file:write("# Line format pattern: Object alias, object path relative to the aircraft's root folder, Position X (+ = right), Position Y (+ = up), Position Z (+ = aft), Rotation X (+ = aft), Rotation Y (+ = cw), Rotation Z (+ = right)\n")
    file:write("# Display dataref name, display dataref value index (should be zero if not array), comparison operator (lt,eq,gt), dataref value\n")
    file:write("# Example: Pole_Test,plugins/xlua/scripts/xlua_utils/Examples/Resources/pole.obj,5,1,2,45,10,22,sim/flightmodel/weight/m_stations,1,gt,600\n")
    file:write("# (An object named Pole_Test is loaded from the specified path, is located 5 m to the right, 1 m up and 2 m aft of the aircraft's origin and is rotaten 45° back, 10° clockwise and 22° to the right. It will display when sim/flightmodel/weight/m_stations[1] is greater than 600 kg.)\n")
    file:write("#\n")
    if file:seek("end") > 0 then LogOutput("FILE WRITE SUCCESS: Attached Object Configuration") else LogOutput("FILE WRITE ERROR: Attached Object Configuration") end
    file:close()
end
--[[ Attached object config file write ]]
function AttachObject_Config_Read()
    local file = io.open(Xlua_Utils_Path..AttachObj_Config_File, "r") -- Check if file exists
    if file then
        LogOutput("FILE READ START: Attached Object Configuration")
        local i=0
        for line in file:lines() do
            if string.match(line,"^[^#]") then -- Only catch lines that are not starting with a "#"
                local splitvalues = SplitString(line,"([^,]+)") -- Split line at commas
                --print(table.concat(splitvalues,";"))
                AttachObj_Container[#AttachObj_Container+1] = { }
                for k=1,2 do
                    AttachObj_Container[#AttachObj_Container][k] = tostring(splitvalues[k]) -- Alias, OBJ path
                end
                for k=3,8 do
                    AttachObj_Container[#AttachObj_Container][k] = tonumber(splitvalues[k]) -- X/Y/Z Position, X/Y/Z Rotation
                end
                AttachObj_Container[#AttachObj_Container][9] = tostring(splitvalues[9]) -- Dataref
                AttachObj_Container[#AttachObj_Container][10] = tonumber(splitvalues[10]) -- Dataref index
                AttachObj_Container[#AttachObj_Container][11] = tostring(splitvalues[11]) -- Dataref comparison operator
                AttachObj_Container[#AttachObj_Container][12] = tonumber(splitvalues[12]) -- Dataref comparison value
                AttachObj_Container[#AttachObj_Container][13] = 0 -- "Is hidden flag"
                --print(table.concat(AttachObj_Container[#AttachObj_Container],";"))
                i=i+1
            end
        end
        file:close()
        if i ~= nil and i > 0 then LogOutput("FILE READ SUCCESS: Attached Object Configuration") else LogOutput("FILE READ ERROR: Attached Object Configuration") end
    else
        LogOutput("FILE NOT FOUND: Attached Object Configuration")
    end
end
--[[ Checks if any object datarefs is already present in Dref_List_Cont and if not, adds it ]]
function AttachObject_Init_CopyDrefTable()
    for j=1,#AttachObj_Container do
        local present = false
        for k=1,#Dref_List_Cont do if AttachObj_Container[j][9] == Dref_List_Cont[k][2] then present = true --[[print("Already present: "..AttachObj_Container[j][9])]] end end
        if not present then Dref_List_Cont[#Dref_List_Cont+1] = {"Dref[n]",AttachObj_Container[j][9]} end
    end
end
--[[ ]]
function AttachObject_CheckVisibility()
    Dataref_Read(AttachObj_Drefs_Cont,4,"All")
    for i=1,#AttachObj_Container do
        for j=1,#AttachObj_Drefs_Cont do
            if AttachObj_Container[i][9] == AttachObj_Drefs_Cont[j][2] then
                if AttachObj_Container[i][11] == "lt" then
                    if AttachObj_Drefs_Cont[j][4][(AttachObj_Container[i][10]+1)] < AttachObj_Container[i][12] then
                        AttachObj_Container[i][13] = 1
                        --print(i..": Lower")
                    else AttachObj_Container[i][13] = 0 end

                elseif AttachObj_Container[i][11] == "eq" then
                    if AttachObj_Drefs_Cont[j][4][(AttachObj_Container[i][10]+1)] == AttachObj_Container[i][12] then
                        AttachObj_Container[i][13] = 1
                        --print(i..": Equal")
                    else AttachObj_Container[i][13] = 0 end

                elseif AttachObj_Container[i][11] == "gt" then
                    if AttachObj_Drefs_Cont[j][4][(AttachObj_Container[i][10]+1)] > AttachObj_Container[i][12] then
                        AttachObj_Container[i][13] = 1
                        --print(i..": Greater")
                    else AttachObj_Container[i][13] = 0 end
                end
            end
        end
    end
    --AttachObj_Drefs_Cont
end
--[[ Delays the drawing of objects ]]
function AttachObject_Delayed()
    AttachObj_AllowDrawing = 1
end
--[[ Initialize object instances ]]
function AttachObject_CreateInstances()
    if #AttachObj_Container > 0 then
        if AttachObj_Inst == nil then
            AttachObj_Inst = ffi.new("XPLMInstanceRef[?]",#AttachObj_Container)   -- Create an instance array depending on the length of the input table
            AttachObj_DrefArray = ffi.new("const char*[?]",1)         -- Create a dataref array with a length of 1
            AttachObj_DrefArray[0] = NULL                             -- Fill array with null value to satisfy https://developer.x-plane.com/sdk/XPLMCreateInstance/
            AttachObj_DrefAddr = AttachObj_DrefArray                  -- Write array to arbitrary
        end
        for i=1,#AttachObj_Container do -- Check if object has been instanced
            if AttachObj_Inst[i-1] == nil then
                AttachObj_InstRefs[i] = ffi.new("XPLMObjectRef")
                XPLM.XPLMLoadObjectAsync(ACF_Folder..AttachObj_Container[i][2],function(inObject, inRefcon) AttachObj_Inst[i-1] = XPLM.XPLMCreateInstance(inObject,AttachObj_DrefAddr) AttachObj_InstRefs[i] = inObject end, inRefcon)
                --print("Loading object "..AttachObj_Container[i][1].." from "..AttachObj_Container[i][2].." at X/Y/Z "..AttachObj_Container[i][3].." / "..AttachObj_Container[i][4].." / "..AttachObj_Container[i][5].." m and Phi/Psi/Theta "..AttachObj_Container[i][6].." / "..AttachObj_Container[i][7].." / "..AttachObj_Container[i][8].." °")
            end
        end
        run_after_time(AttachObject_Delayed,0.25) -- Delay initial drawing a bit
    end
end
--[[ Transforms aircraft coordinates into local coordinates. Source: Austin Meyer himself. :) ]]
function AttachObject_AcftToWorld(x_acft,y_acft,z_acft,in_phi_deg,in_psi_deg,in_the_deg)
        local phi_rad = math.rad(in_phi_deg) -- Convert to radians
        local psi_rad = math.rad(in_psi_deg)
        local the_rad = math.rad(in_the_deg)
        local x_phi = (x_acft * math.cos(phi_rad)) + (y_acft * math.sin(phi_rad))
        local y_phi = (y_acft * math.cos(phi_rad)) - (x_acft * math.sin(phi_rad))
        local z_the = (z_acft * math.cos(the_rad)) + (y_phi * math.sin(the_rad))
        local out_x = (x_phi * math.cos(psi_rad)) - (z_the * math.sin(psi_rad))
        local out_y = (y_phi * math.cos(the_rad)) - (z_acft * math.sin(the_rad))
        local out_z = (z_the * math.cos(psi_rad)) + (x_phi * math.sin(psi_rad))
        return out_x,out_y,out_z
end
--[[ Updates the position of all objects in a list of instance refs ]]
function AttachObject_Show(index)
    AttachObj_WorldNew.x,AttachObj_WorldNew.y,AttachObj_WorldNew.z = AttachObject_AcftToWorld(AttachObj_Container[index][3],AttachObj_Container[index][4],AttachObj_Container[index][5],simDR_pos_phi,simDR_pos_psi,simDR_pos_the)
    AttachObj_DrawInfo[0].x = simDR_pos_local_x + AttachObj_WorldNew.x
    AttachObj_DrawInfo[0].y = simDR_pos_local_y + AttachObj_WorldNew.y
    AttachObj_DrawInfo[0].z = simDR_pos_local_z + AttachObj_WorldNew.z
    AttachObj_DrawInfo[0].pitch = simDR_pos_the + AttachObj_Container[index][6]
    AttachObj_DrawInfo[0].heading = simDR_pos_psi + AttachObj_Container[index][7]
    AttachObj_DrawInfo[0].roll = simDR_pos_phi + AttachObj_Container[index][8]
    AttachObj_DrawInfoAddr = AttachObj_DrawInfo
    AttachObj_DrawFloat[0] = 0
    AttachObj_DrawFloatAddr = AttachObj_DrawFloat
    XPLM.XPLMInstanceSetPosition(AttachObj_Inst[index-1],AttachObj_DrawInfoAddr,AttachObj_DrawFloatAddr)
end
--[[ Hides an object by moving it to 0,0,0 ]]
function AttachObject_Hide(index)
    AttachObj_DrawInfo[0].x = 0
    AttachObj_DrawInfo[0].y = -1000
    AttachObj_DrawInfo[0].z = 0
    AttachObj_DrawInfo[0].pitch = 0
    AttachObj_DrawInfo[0].heading = 0
    AttachObj_DrawInfo[0].roll = 0
    AttachObj_DrawInfoAddr = AttachObj_DrawInfo
    AttachObj_DrawFloat[0] = 0
    AttachObj_DrawFloatAddr = AttachObj_DrawFloat
    XPLM.XPLMInstanceSetPosition(AttachObj_Inst[index-1],AttachObj_DrawInfoAddr,AttachObj_DrawFloatAddr)
end
--[[ Wrapper to hide all objects ]]
function AttachObject_Hide_All()
    for i=1,#AttachObj_InstRefs do
        AttachObject_Hide(i)
    end
end
--[[ Unloads all objects by destroying their instances and unloading the OBJ files ]]
function AttachObject_Unload()
    for i=1,#AttachObj_InstRefs do
        if AttachObj_Inst[i] ~= nil and AttachObj_InstRefs[i] ~= nil then
            --print("Unloading object "..AttachObj_Container[i][1])
            AttachObj_DrawInfo[0].x = 0
            AttachObj_DrawInfo[0].y = 0
            AttachObj_DrawInfo[0].z = 0
            AttachObj_DrawInfo[0].pitch = 0
            AttachObj_DrawInfo[0].heading = 0
            AttachObj_DrawInfo[0].roll = 0
            XPLM.XPLMDestroyInstance(AttachObj_Inst[i-1])
            AttachObj_Inst[i-1] = nil
            XPLM.XPLMUnloadObject(AttachObj_InstRefs[i-1])
            AttachObj_InstRefs[i] = nil
            if AttachObj_Inst[i-1] == nil --[[ and AttachObj_InstRefs[i] == nil ]] then print("SUCCESS: Unloaded object "..AttachObj_Container[i][1]) end
        end
    end
end
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function AttachObject_Menu_Callbacks(itemref)
    for i=2,#AttachObj_Menu_Items do
        if itemref == AttachObj_Menu_Items[i] then
            if i == 2 then
                if AttachObj_HasConfig == 0 then
                    AttachObject_FirstRun() -- Generates the config file for the attached objects module
                elseif AttachObj_HasConfig == 1 then
                    AttachObject_Reload() -- Reloads the config file for the attached objects module
                end
            end
            if i == 4 then
                if Table_ValGet(AttachObj_Config_Vars,"HideObjs",nil,2) == 0 then Table_ValSet(AttachObj_Config_Vars,"HideObjs",nil,2,1) AttachObject_Hide_All() else Table_ValSet(AttachObj_Config_Vars,"HideObjs",nil,2,0) end
            end
            --Preferences_Write(AttachObj_Config_Vars,Xlua_Utils_PrefsFile)
            AttachObject_Menu_Watchdog(AttachObj_Menu_Items,i)
            if DebugIsEnabled() == 1 then Debug_Reload() end
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function AttachObject_Menu_Watchdog(intable,index)
    if index == 2 then
        if AttachObj_HasConfig == 0 then Menu_ChangeItemPrefix(AttachObj_Menu_ID,index,"Initialize",intable)
        elseif AttachObj_HasConfig == 1 then Menu_ChangeItemPrefix(AttachObj_Menu_ID,index,"Reload Config",intable) end
    end
    if index == 3 then
        Menu_ChangeItemPrefix(AttachObj_Menu_ID,index,"Objs: "..#AttachObj_InstRefs.." (Vis.: "..")",intable)
    end
    if index == 4 then
        if Table_ValGet(AttachObj_Config_Vars,"HideObjs",nil,2) == 1 then Menu_CheckItem(AttachObj_Menu_ID,index,"Activate") else Menu_CheckItem(AttachObj_Menu_ID,index,"Deactivate") end
    end
end
--[[ Initialization routine for the menu. WARNING: Takes the menu ID of the main XLua Utils Menu! ]]
function AttachObject_Menu_Build(ParentMenuID)
    local Menu_Indices = {}
    for i=2,#AttachObj_Menu_Items do Menu_Indices[i] = 0 end
    if XPLM ~= nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(ParentMenuID,AttachObj_Menu_Items[1],ffi.cast("void *","None"),1)
        AttachObj_Menu_ID = XPLM.XPLMCreateMenu(AttachObj_Menu_Items[1],ParentMenuID,Menu_Index,function(inMenuRef,inItemRef) AttachObject_Menu_Callbacks(inItemRef) end,ffi.cast("void *",AttachObj_Menu_Pointer))
        for i=2,#AttachObj_Menu_Items do
            if AttachObj_Menu_Items[i] ~= "[Separator]" then
                AttachObj_Menu_Pointer = AttachObj_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(AttachObj_Menu_ID,AttachObj_Menu_Items[i],ffi.cast("void *",AttachObj_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(AttachObj_Menu_ID)
            end
        end
        for i=2,#AttachObj_Menu_Items do
            if AttachObj_Menu_Items[i] ~= "[Separator]" then
                AttachObject_Menu_Watchdog(AttachObj_Menu_Items,i)
            end
        end
        LogOutput(AttachObj_Config_Vars[1][1].." Menu initialized!")
    end
end
--[[

RUNTIME FUNCTIONS

]]
--[[ Main timer for the engine damage logic ]]
function AttachObject_MainTimer()
    AttachObject_CheckVisibility()
end
--[[ X-Plane runtime integration: After physics calculations, each frame ]]
function after_physics()
    if #AttachObj_InstRefs > 0 and AttachObj_AllowDrawing == 1  and Table_ValGet(AttachObj_Config_Vars,"HideObjs",nil,2) == 0 then
        for i=1,#AttachObj_InstRefs do
            if AttachObj_Container[i][13] == 0 then AttachObject_Hide(i) end -- Update object position if object is supposed to be visible
            if AttachObj_Container[i][13] == 1 then AttachObject_Show(i) end -- Update object position if object is supposed to be visible
        end
    end
end
--[[

INITIALIZATION

]]
--[[ Collection of all functions relevant during initialization or reloading ]]
function AttachObject_Startup()
    AttachObject_Config_Read()
    AttachObject_Init_CopyDrefTable()
    DrefTable_Read(Dref_List_Cont,AttachObj_Drefs_Cont)
    Dataref_Read(AttachObj_Drefs_Cont,4,"All") -- Populate dataref container with currrent values
    AttachObject_CreateInstances()
    AttachObject_Menu_Watchdog(AttachObj_Menu_Items,3)
    run_at_interval(AttachObject_MainTimer,Table_ValGet(AttachObj_Config_Vars,"MainTimerInterval",nil,2))
end
--[[ First start of the engine damage module ]]
function AttachObject_FirstRun()
    AttachObject_Config_Write() -- Write new skeleton config file
    if FileExists(Xlua_Utils_Path..AttachObj_Config_File) then AttachObj_HasConfig = 1 end -- Check if config file exists
    --Preferences_Write(AttachObj_Config_Vars,Xlua_Utils_PrefsFile)
    --Preferences_Read(Xlua_Utils_PrefsFile,AttachObj_Config_Vars)
    --DrefTable_Read(Dref_List_Cont,AttachObj_Drefs_Cont)
    --AttachObj_Menu_Build(XluaUtils_Menu_ID)
    LogOutput(AttachObj_Config_Vars[1][1]..": First Run!")
end
--[[ Initializes engine damage at every startup ]]
function AttachObject_Init()
    if FileExists(Xlua_Utils_Path..AttachObj_Config_File) then -- Check if config file exists
        AttachObj_HasConfig = 1
        AttachObject_Startup()
    end
    LogOutput(AttachObj_Config_Vars[1][1]..": Initialized!")
end
--[[ Reloads the Persistence configuration ]]
function AttachObject_Reload()
    AttachObj_AllowDrawing = 0
    if is_timer_scheduled(AttachObject_MainTimer) then stop_timer(AttachObject_MainTimer) end
    AttachObject_Unload()
    AttachObj_Container = { }
    AttachObject_Startup()
    LogOutput(AttachObj_Config_Vars[1][1]..": Reloaded!")
end
