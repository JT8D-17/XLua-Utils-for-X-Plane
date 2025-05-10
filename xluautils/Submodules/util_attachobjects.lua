jit.off()
--[[

XLuaUtils Module, required by xluautils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]
--[[

Credit to XPJavelin (SGES) and laurenzo (SGS) for some code inspiration.

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
--{"Pole_Test","plugins/xlua/scripts/xluautils/Examples/Resources/pole.obj",0,0,0,0,0,0,"sim/flightmodel/weight/m_stations",0,"gt",600},
--{"Pole_Test2","plugins/xlua/scripts/xluautils/Examples/Resources/pole.obj",-5,0,0,0,0,45,"sim/flightmodel/weight/m_stations",1,"gt",600},
--}
local AttachObj_Container = { }                                     -- Container table for object data
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
local AttachObj_ProbeContainer = {x=0,y=0,z=0}                      -- Container with x,y,z coordinates of terrain probe result
local AttachObj_ProbeInfo = ffi.new("XPLMProbeInfo_t[?]",1)         -- Creates an information array depending on the length of the input table
local AttachObj_ProbeInfoAddr = ffi.new("XPLMProbeInfo_t*")         -- Arbitrary to store terrain probe address
local AttachObj_ProbeRef = ffi.new("XPLMProbeRef")                  -- Terrrain probe reference
local AttachObj_ProbeType = ffi.new("int[1]")                       -- Defines terrain probe type
local AttachObj_ProbeX = ffi.new("double[1]")                       -- Probe result output for OpenGL (local) x coordinate
local AttachObj_ProbeY = ffi.new("double[1]")                       -- Probe result output for OpenGL (local) y coordinate
local AttachObj_ProbeZ = ffi.new("double[1]")                       -- Probe result output for OpenGL (local) z coordinate
local AttachObj_Shift = {Dist=0,Hdg=0,X=0,Z=0}                      -- Stores distance from aircraft, object heading and recalculated x and y positions for ground objects
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
    DebugLogOutput("FILE WRITE START: Attached Object Configuration")
    local file = io.open(XLuaUtils_Path..AttachObj_Config_File, "w")
    file:write("# XLuaUtils attachable object configuration generated on ",os.date("%x, %H:%M:%S"),"\n")
    file:write("#\n")
    file:write("# This file contains profile information for XLuaUtils' attachable objects module.\n")
    file:write("#\n")
    file:write("# Line format pattern:")
    file:write("# Object alias, root folder (ACF_Folder/XP_Folder), object path relative to root folder, Position X (+ = right), Position Y (+ = up), Position Z (+ = aft), Rotation X (+ = aft), Rotation Y (+ = cw), Rotation Z (+ = right)\n")
    file:write("# Display dataref name, display dataref value index (should be zero if not array), comparison operator (lt,eq,gt), dataref value, on ground flag (0/1)\n")
    file:write("# Example: Pole_Test,ACF_Folder,plugins/xlua/scripts/xluautils/Examples/Resources/pole.obj,5,1,2,45,10,22,sim/flightmodel/weight/m_stations,1,gt,600,0\n")
    file:write("# (An object named Pole_Test is loaded from the specified path relative to the aircraft folder, is located 5 m to the right, 1 m up and 2 m aft of the aircraft's origin and is rotated 45° back, 10° clockwise and 22° to the right. It will display when sim/flightmodel/weight/m_stations[1] is greater than 600 kg and does not stick to the ground.)\n")
    file:write("#\n")
    if file:seek("end") > 0 then DebugLogOutput("FILE WRITE SUCCESS: Attached Object Configuration") else LogOutput("FILE WRITE ERROR: Attached Object Configuration") end
    file:close()
end
--[[ Attached object config file write ]]
function AttachObject_Config_Read()
    local file = io.open(XLuaUtils_Path..AttachObj_Config_File, "r") -- Check if file exists
    if file then
        DebugLogOutput("FILE READ START: Attached Object Configuration")
        local i=0
        for line in file:lines() do
            if string.match(line,"^[^#]") then -- Only catch lines that are not starting with a "#"
                local splitvalues = SplitString(line,"([^,]+)") -- Split line at commas
                --print(table.concat(splitvalues,";"))
                if #splitvalues == 14 and splitvalues[2] ~= "skip" and splitvalues[3] ~= "skip" then
                    AttachObj_Container[#AttachObj_Container+1] = { }
                    if splitvalues[1] ~= "skip" then AttachObj_Container[#AttachObj_Container][1] = tostring(splitvalues[1]) else AttachObj_Container[#AttachObj_Container][1] = "Obj_"..(i+1) end -- Object alias
                    AttachObj_Container[#AttachObj_Container][2] = tostring(splitvalues[2]) -- Object root folder
                    AttachObj_Container[#AttachObj_Container][3] = tostring(splitvalues[3]) -- Object path
                    for k=4,9 do
                        if splitvalues[k] ~= "skip" then
                            AttachObj_Container[#AttachObj_Container][k] = tonumber(splitvalues[k]) -- X/Y/Z Position, X/Y/Z Rotation
                        else
                            AttachObj_Container[#AttachObj_Container][k] = 0
                        end
                    end
                    if splitvalues[10] ~= "skip" then AttachObj_Container[#AttachObj_Container][10] = tostring(splitvalues[10]) else AttachObj_Container[#AttachObj_Container][10] = "None" end -- Dataref
                    if splitvalues[11] ~= "skip" then AttachObj_Container[#AttachObj_Container][11] = tonumber(splitvalues[11]) else AttachObj_Container[#AttachObj_Container][11] = 0 end -- Dataref index
                    if splitvalues[12] ~= "skip" then AttachObj_Container[#AttachObj_Container][12] = tostring(splitvalues[12]) else AttachObj_Container[#AttachObj_Container][12] = "None" end -- Dataref comparison operator
                    if splitvalues[13] ~= "skip" then AttachObj_Container[#AttachObj_Container][13] = tonumber(splitvalues[13]) else AttachObj_Container[#AttachObj_Container][13] = -1 end -- Dataref comparison value
                    if splitvalues[14] ~= "skip" then AttachObj_Container[#AttachObj_Container][14] = tonumber(splitvalues[14]) else AttachObj_Container[#AttachObj_Container][14] = 0 end -- "On ground" flag
                    AttachObj_Container[#AttachObj_Container][15] = 0 -- "Is hidden flag"
                    print(table.concat(AttachObj_Container[#AttachObj_Container],";"))
                    i=i+1
                else
                    LogOutput("OBJECT READ ERROR: Not Enough Parameters (Requires 14) or Invalid Path Formatting")
                end
            end
        end
        file:close()
        if i ~= nil and i > 0 then DebugLogOutput("FILE READ SUCCESS: Attached Object Configuration") else LogOutput("FILE READ ERROR: Attached Object Configuration") end
    else
        LogOutput("FILE NOT FOUND: Attached Object Configuration")
    end
end
--[[ Checks if any object datarefs is already present in Dref_List_Cont and if not, adds it ]]
function AttachObject_Init_CopyDrefTable()
    for j=1,#AttachObj_Container do
        if AttachObj_Container[j][10] ~= "None" then
            local present = false
            for k=1,#Dref_List_Cont do if AttachObj_Container[j][10] == Dref_List_Cont[k][2] then present = true --[[print("Already present: "..AttachObj_Container[j][10])]] end end
            if not present then Dref_List_Cont[#Dref_List_Cont+1] = {"Dref[n]",AttachObj_Container[j][10]} end
        end
    end
end
--[[ ]]
function AttachObject_CheckVisibility()
    Dataref_Read(AttachObj_Drefs_Cont,4,"All")
    for i=1,#AttachObj_Container do
        if AttachObj_Container[i][10] ~= "None" then
            for j=1,#AttachObj_Drefs_Cont do
                if AttachObj_Container[i][10] == AttachObj_Drefs_Cont[j][2] then
                    if AttachObj_Container[i][12] == "lt" then
                        if AttachObj_Drefs_Cont[j][4][(AttachObj_Container[i][11]+1)] < AttachObj_Container[i][13] then
                            AttachObj_Container[i][15] = 1
                            --print(i..": Lower")
                        else AttachObj_Container[i][15] = 0 end

                    elseif AttachObj_Container[i][12] == "eq" then
                        if AttachObj_Drefs_Cont[j][4][(AttachObj_Container[i][11]+1)] == AttachObj_Container[i][13] then
                            AttachObj_Container[i][15] = 1
                            --print(i..": Equal")
                        else AttachObj_Container[i][15] = 0 end

                    elseif AttachObj_Container[i][12] == "gt" then
                        if AttachObj_Drefs_Cont[j][4][(AttachObj_Container[i][11]+1)] > AttachObj_Container[i][13] then
                            AttachObj_Container[i][15] = 1
                            --print(i..": Greater")
                        else AttachObj_Container[i][15] = 0 end
                    end
                end
            end
        else
            AttachObj_Container[i][15] = 1 -- Always draw object when it has no dataref
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
                if AttachObj_Container[i][2] == "ACF_Folder" then
                    XPLM.XPLMLoadObjectAsync(ACF_Folder..AttachObj_Container[i][3],function(inObject, inRefcon) AttachObj_Inst[i-1] = XPLM.XPLMCreateInstance(inObject,AttachObj_DrefAddr) AttachObj_InstRefs[i] = inObject end, inRefcon)
                end
                if AttachObj_Container[i][2] == "XP_Folder" then
                    XPLM.XPLMLoadObjectAsync(XP_Folder..AttachObj_Container[i][3],function(inObject, inRefcon) AttachObj_Inst[i-1] = XPLM.XPLMCreateInstance(inObject,AttachObj_DrefAddr) AttachObj_InstRefs[i] = inObject end, inRefcon)
                end
                --print("Loading object "..AttachObj_Container[i][1].." from "..AttachObj_Container[i][2]..AttachObj_Container[i][3].." at X/Y/Z "..AttachObj_Container[i][4].." / "..AttachObj_Container[i][5].." / "..AttachObj_Container[i][6].." m and Phi/Psi/Theta "..AttachObj_Container[i][7].." / "..AttachObj_Container[i][8].." / "..AttachObj_Container[i][9].." °")
            end
        end
        run_after_time(AttachObject_Delayed,0.25) -- Delay initial drawing a bit
    end
end
--[[ Transforms aircraft coordinates into local GL coordinates. Source: Austin Meyer himself. :) ]]
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
--[[ Updates the position of all airplane-attached objects in a list of instance refs ]]
function AttachObject_Show_Acft(index)
    AttachObj_WorldNew.x,AttachObj_WorldNew.y,AttachObj_WorldNew.z = AttachObject_AcftToWorld(AttachObj_Container[index][4],AttachObj_Container[index][5],AttachObj_Container[index][6],simDR_pos_phi,simDR_pos_psi,simDR_pos_the)
    AttachObj_DrawInfo[0].x = simDR_pos_local_x + AttachObj_WorldNew.x
    AttachObj_DrawInfo[0].y = simDR_pos_local_y + AttachObj_WorldNew.y
    AttachObj_DrawInfo[0].z = simDR_pos_local_z + AttachObj_WorldNew.z
    AttachObj_DrawInfo[0].pitch = simDR_pos_the + AttachObj_Container[index][7]
    AttachObj_DrawInfo[0].heading = simDR_pos_psi + AttachObj_Container[index][8]
    AttachObj_DrawInfo[0].roll = simDR_pos_phi + AttachObj_Container[index][9]
    AttachObj_DrawInfoAddr = AttachObj_DrawInfo
    AttachObj_DrawFloat[0] = 0
    AttachObj_DrawFloatAddr = AttachObj_DrawFloat
    XPLM.XPLMInstanceSetPosition(AttachObj_Inst[index-1],AttachObj_DrawInfoAddr,AttachObj_DrawFloatAddr)
end
--[[ Updates the position of all ground objects in a list of instance refs ]]
function AttachObject_Show_Gnd(index)
    AttachObj_Shift.Dist = math.sqrt(((AttachObj_Container[index][4])^2)+((AttachObj_Container[index][6])^2)) -- Calculate distance from aircraft
    AttachObj_Shift.Hdg = math.fmod((math.deg(math.atan2(AttachObj_Container[index][4],AttachObj_Container[index][6]))+360),360) -- Shift for heading
    AttachObj_Shift.X = simDR_pos_local_x - math.sin(math.rad(simDR_pos_psi - AttachObj_Shift.Hdg)) * AttachObj_Shift.Dist
    AttachObj_Shift.Z = simDR_pos_local_z - math.cos(math.rad(simDR_pos_psi - AttachObj_Shift.Hdg)) * AttachObj_Shift.Dist * -1
    AttachObject_Probe_Update(AttachObj_Shift.X,simDR_pos_local_y,AttachObj_Shift.Z) -- Probes the ground below the object's position
    AttachObj_DrawInfo[0].x = AttachObj_Shift.X -- Terrain X is local Z?
    AttachObj_DrawInfo[0].y = AttachObj_ProbeContainer.y + AttachObj_Container[index][5]
    AttachObj_DrawInfo[0].z = AttachObj_Shift.Z -- Terrain Z is local X?
    AttachObj_DrawInfo[0].pitch = AttachObj_Container[index][7]
    AttachObj_DrawInfo[0].heading = simDR_pos_psi + AttachObj_Container[index][8]
    AttachObj_DrawInfo[0].roll = AttachObj_Container[index][9]
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
function AttachObject_Objs_Unload()
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
--[[ Creates a terrain probe ]]
function AttachObject_Probe_Create()
    AttachObj_ProbeInfo[0].structSize = ffi.sizeof(AttachObj_ProbeInfo[0])
    AttachObj_ProbeInfoAddr = AttachObj_ProbeInfo
    AttachObj_ProbeType[1] = 0
    AttachObj_ProbeRef = XPLM.XPLMCreateProbe(AttachObj_ProbeType[1])
end
--[[ Probes the unterlying terrain ]]
function AttachObject_Probe_Update(in_x,in_y,in_z)
    AttachObj_ProbeX[0] = in_x
    AttachObj_ProbeY[0] = in_y
    AttachObj_ProbeZ[0] = in_z
    XPLM.XPLMProbeTerrainXYZ(AttachObj_ProbeRef,AttachObj_ProbeX[0],AttachObj_ProbeY[0],AttachObj_ProbeZ[0],AttachObj_ProbeInfoAddr)
    AttachObj_ProbeInfo = AttachObj_ProbeInfoAddr
    AttachObj_ProbeContainer.x = AttachObj_ProbeInfo[0].locationX
    AttachObj_ProbeContainer.y = AttachObj_ProbeInfo[0].locationY
    AttachObj_ProbeContainer.z = AttachObj_ProbeInfo[0].locationZ
end
--[[

MENU

]]
--[[ Menu callbacks. The functions to run or actions to do when picking any non-title and nonseparator item from the table above ]]
function AttachObject_Menu_Callbacks(itemref)
    for i=2,#AttachObj_Menu_Items do
        if itemref == AttachObj_Menu_Items[i] then
            if i == 2 then
                if AttachObj_HasConfig == 0 then AttachObject_FirstRun() end -- Generates the config file for the attached objects module
                if AttachObj_HasConfig == 1 then AttachObject_Reload() end -- Reloads the config file for the attached objects module
            end
            if i == 4 then
                if Table_ValGet(AttachObj_Config_Vars,"HideObjs",nil,2) == 0 then Table_ValSet(AttachObj_Config_Vars,"HideObjs",nil,2,1) AttachObject_Hide_All() else Table_ValSet(AttachObj_Config_Vars,"HideObjs",nil,2,0) end
            end
            --Preferences_Write(AttachObj_Config_Vars,XLuaUtils_PrefsFile)
            AttachObject_Menu_Watchdog(AttachObj_Menu_Items,i)
            if DebugIsEnabled() == 1 then Debug_Reload() end
        end
    end
end
--[[ This is the menu watchdog that is used to check an item or change its prefix ]]
function AttachObject_Menu_Watchdog(intable,index)
    if index == 2 then
        if AttachObj_HasConfig == 0 then Menu_ChangeItemPrefix(AttachObj_Menu_ID,index,"Generate Config File",intable)
        elseif AttachObj_HasConfig == 1 then Menu_ChangeItemPrefix(AttachObj_Menu_ID,index,"Reload Config File",intable) end
    end
    if index == 3 then
        Menu_ChangeItemPrefix(AttachObj_Menu_ID,index,"Objs: "..#AttachObj_InstRefs.." (Vis.: "..")",intable)
    end
    if index == 4 then
        if Table_ValGet(AttachObj_Config_Vars,"HideObjs",nil,2) == 1 then Menu_CheckItem(AttachObj_Menu_ID,index,"Activate") else Menu_CheckItem(AttachObj_Menu_ID,index,"Deactivate") end
    end
end
--[[ Registration routine for the menu ]]
function AttachObject_Menu_Register()
    if XPLM ~= nil and AttachObj_Menu_ID == nil then
        local Menu_Index = nil
        Menu_Index = XPLM.XPLMAppendMenuItem(XLuaUtils_Menu_ID,AttachObj_Menu_Items[1],ffi.cast("void *","None"),1)
        AttachObj_Menu_ID = XPLM.XPLMCreateMenu(AttachObj_Menu_Items[1],XLuaUtils_Menu_ID,Menu_Index,function(inMenuRef,inItemRef) AttachObject_Menu_Callbacks(inItemRef) end,ffi.cast("void *",AttachObj_Menu_Pointer))
        AttachObject_Menu_Build()
        DebugLogOutput(AttachObj_Config_Vars[1][1].." Menu registered!")
    end
end
--[[ Initialization routine for the menu ]]
function AttachObject_Menu_Build()
    XPLM.XPLMClearAllMenuItems(AttachObj_Menu_ID)
    local Menu_Indices = {}
    local endindex = 2
    if AttachObj_HasConfig == 1 then endindex = #AttachObj_Menu_Items end
    for i=2,endindex do Menu_Indices[i] = 0 end
    if AttachObj_Menu_ID ~= nil then
        for i=2,endindex do
            if AttachObj_Menu_Items[i] ~= "[Separator]" then
                AttachObj_Menu_Pointer = AttachObj_Menu_Items[i]
                Menu_Indices[i] = XPLM.XPLMAppendMenuItem(AttachObj_Menu_ID,AttachObj_Menu_Items[i],ffi.cast("void *",AttachObj_Menu_Pointer),1)
            else
                XPLM.XPLMAppendMenuSeparator(AttachObj_Menu_ID)
            end
        end
        for i=2,endindex do
            if AttachObj_Menu_Items[i] ~= "[Separator]" then
                AttachObject_Menu_Watchdog(AttachObj_Menu_Items,i)
            end
        end
        DebugLogOutput(AttachObj_Config_Vars[1][1].." Menu built!")
    end
end
--[[

RUNTIME CALLBACKS

]]
--[[ Module Main Timer ]]
function AttachObject_MainTimer()
    AttachObject_CheckVisibility()
end
--[[ X-Plane runtime integration: After physics calculations, each frame ]]
function after_physics()
    if #AttachObj_InstRefs > 0 and AttachObj_AllowDrawing == 1  and Table_ValGet(AttachObj_Config_Vars,"HideObjs",nil,2) == 0 then
        for i=1,#AttachObj_InstRefs do
            if AttachObj_Container[i][15] == 0 then AttachObject_Hide(i) end -- Update object position if object is supposed to be visible
            if AttachObj_Container[i][15] == 1 then  -- Update object position if object is supposed to be visible
                if AttachObj_Container[i][14] == 0 then AttachObject_Show_Acft(i) end
                if AttachObj_Container[i][14] == 1 then AttachObject_Show_Gnd(i) end
            end
        end
    end
end
--[[

INITIALIZATION

]]
--[[ Common start items ]]
function AttachObject_Start()
    --Preferences_Read(XLuaUtils_PrefsFile,AttachObj_Config_Vars)
    AttachObject_Config_Read()
    if AttachObj_HasConfig == 1 then
        AttachObject_Init_CopyDrefTable()
        DrefTable_Read(Dref_List_Cont,AttachObj_Drefs_Cont)
        Dataref_Read(AttachObj_Drefs_Cont,4,"All") -- Populate dataref container with currrent values
        AttachObject_Probe_Create()
        AttachObject_Probe_Update(simDR_pos_local_x,simDR_pos_local_y,simDR_pos_local_z)
        AttachObject_CreateInstances()
        AttachObject_Menu_Watchdog(AttachObj_Menu_Items,3)
        run_at_interval(AttachObject_MainTimer,Table_ValGet(AttachObj_Config_Vars,"MainTimerInterval",nil,2))
        if is_timer_scheduled(AttachObject_MainTimer) then DisplayNotification("Attach Object: Initialized","Nominal",5) end
    end
end
--[[ Module is run for the very first time ]]
function AttachObject_FirstRun()
    AttachObject_Config_Write() -- Write new skeleton config file
    if FileExists(XLuaUtils_Path..AttachObj_Config_File) then AttachObj_HasConfig = 1 end -- Check if config file exists
    AttachObject_Start()
    AttachObject_Menu_Build()
    LogOutput(AttachObj_Config_Vars[1][1]..": First Run!")
end
--[[ Module initialization at every Xlua Utils start ]]
function AttachObject_Init()
    if XLuaUtils_HasConfig == 1 then
        AttachObject_Start()
        AttachObject_Menu_Register()
    end
    LogOutput(AttachObj_Config_Vars[1][1]..": Initialized!")
end
--[[ Module reload ]]
function AttachObject_Reload()
    AttachObj_AllowDrawing = 0
    if is_timer_scheduled(AttachObject_MainTimer) then stop_timer(AttachObject_MainTimer) DisplayNotification("Attach Object: Uninitialized","Nominal",5) end
    AttachObject_Objs_Unload()
    AttachObj_Container = { }
    AttachObject_Start()
    AttachObject_Menu_Build()
    LogOutput(AttachObj_Config_Vars[1][1]..": Reloaded!")
end
--[[ Module unload ]]
function AttachObject_Unload()
    AttachObject_Objs_Unload()
end
