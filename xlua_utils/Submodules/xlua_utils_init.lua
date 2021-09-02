--[[

XLua Module, required by xlua_utils.lua
Licensed under the EUPL v1.2: https://eupl.eu/

]]

--[[

FFI INITIALIZATION

]]
XPLM = nil  -- Define namespace for XPLM library

--[[ Load XPLM library ]]
if ffi.os == "Windows" then XPLM = ffi.load("XPLM_64")  -- Windows 64bit
elseif ffi.os == "Linux" then XPLM = ffi.load("Resources/plugins/XPLM_64.so")  -- Linux 64bit (Requires "Resources/plugins/" for some reason)
elseif ffi.os == "OSX" then XPLM = ffi.load("Resources/plugins/XPLM.framework/XPLM") -- 64bit MacOS (Requires "Resources/plugins/" for some reason)
else return 
end

--[[ Add C definitions to FFI ]]
ffi.cdef([[
/* XPLMUtilities*/
typedef void *XPLMCommandRef;
void XPLMDebugString(const char *inString);
/* XPLMMenus */
typedef int XPLMMenuCheck;
typedef void *XPLMMenuID;
typedef void (*XPLMMenuHandler_f)(void *inMenuRef,void *inItemRef);
XPLMMenuID XPLMFindPluginsMenu(void);
XPLMMenuID XPLMFindAircraftMenu(void);
XPLMMenuID XPLMCreateMenu(const char *inName, XPLMMenuID inParentMenu, int inParentItem, XPLMMenuHandler_f inHandler,void *inMenuRef);
void XPLMDestroyMenu(XPLMMenuID inMenuID);
void XPLMClearAllMenuItems(XPLMMenuID inMenuID);
int XPLMAppendMenuItem(XPLMMenuID inMenu,const char *inItemName,void *inItemRef,int inDeprecatedAndIgnored);
int XPLMAppendMenuItemWithCommand(XPLMMenuID inMenu,const char *inItemName,XPLMCommandRef inCommandToExecute);
void XPLMAppendMenuSeparator(XPLMMenuID inMenu);      
void XPLMSetMenuItemName(XPLMMenuID inMenu,int inIndex,const char *inItemName,int inForceEnglish);
void XPLMCheckMenuItem(XPLMMenuID inMenu,int index,XPLMMenuCheck inCheck);
void XPLMCheckMenuItemState(XPLMMenuID inMenu,int index,XPLMMenuCheck *outCheck);
void XPLMEnableMenuItem(XPLMMenuID inMenu,int index,int enabled);      
void XPLMRemoveMenuItem(XPLMMenuID inMenu,int inIndex);
/* XPLMDataAccess */
typedef void *XPLMDataRef;
typedef int XPLMDataTypeID;
XPLMDataRef XPLMFindDataRef(const char *inDataRefName);
XPLMDataTypeID XPLMGetDataRefTypes(XPLMDataRef inDataRef);
int XPLMCanWriteDataRef(XPLMDataRef inDataRef);
int XPLMGetDatai(XPLMDataRef inDataRef);
float XPLMGetDataf(XPLMDataRef inDataRef);
double XPLMGetDatad(XPLMDataRef inDataRef);
int XPLMGetDatavi(XPLMDataRef inDataRef,int *outValues,int inOffset,int inMax);
int XPLMGetDatavf(XPLMDataRef inDataRef,int *outValues,int inOffset,int inMax);
int XPLMGetDatab(XPLMDataRef inDataRef,void *outValue,int inOffset,int inMaxBytes);
/* void XPLMSetDatab(XPLMDataRef inDataRef,void *inValue,int inOffset,int inLength); */
/* XPLMPlanes */
void XPLMGetNthAircraftModel(int inIndex,char *outFileName,char *outPath);
/* XPLMDefs */
typedef int XPLMKeyFlags;
/* XPLMDisplay */
typedef void *XPLMWindowID;
typedef void (*XPLMDrawWindow_f)(XPLMWindowID inWindowID,void *inRefcon);
typedef int XPLMMouseStatus;
typedef int (*XPLMHandleMouseClick_f)(XPLMWindowID inWindowID,int x,int y,XPLMMouseStatus inMouse,void *inRefcon);
typedef void (*XPLMHandleKey_f)(XPLMWindowID inWindowID,char inKey,XPLMKeyFlags inFlags,char inVirtualKey,void *inRefcon,int losingFocus);
typedef int XPLMCursorStatus;
typedef XPLMCursorStatus (*XPLMHandleCursor_f)(XPLMWindowID inWindowID,int x,int y,void *inRefcon);
typedef int (*XPLMHandleMouseWheel_f)(XPLMWindowID inWindowID,int x,int y,int wheel,int clicks,void *inRefcon);
typedef int XPLMWindowDecoration;
typedef int XPLMWindowLayer;
typedef struct {
    int structSize;
    int left;
    int top;
    int right;
    int bottom;
    int visible;
    XPLMDrawWindow_f drawWindowFunc;
    XPLMHandleMouseClick_f handleMouseClickFunc;
    XPLMHandleKey_f handleKeyFunc;
    XPLMHandleCursor_f handleCursorFunc;
    XPLMHandleMouseWheel_f handleMouseWheelFunc;
    void *refcon;
    XPLMWindowDecoration decorateAsFloatingWindow;
    XPLMWindowLayer layer;
    XPLMHandleMouseClick_f handleRightClickFunc;
} XPLMCreateWindow_t;
XPLMWindowID XPLMCreateWindowEx(XPLMCreateWindow_t *inParams);
void XPLMDestroyWindow(XPLMWindowID inWindowID);
]])

--[[

CORE FUNCTIONS

]]
--[[ Returns the aircraft ACF file and path ]]
function GetAircraftFolder()
    local fileName = ffi.new("char[256]")
    local filePath = ffi.new("char[512]")
    XPLM.XPLMGetNthAircraftModel(0,fileName,filePath);
    fileName = ffi.string(fileName)
    filePath = ffi.string(filePath):match("(.*[/\\])") -- Cut filename from path
    return filePath,fileName
end

--[[ Initialize printing to terminal/command console and X-Plane developer console/Log.txt ]]
function PrintToConsole(inputstring)
    XPLM.XPLMDebugString(ScriptName.." - "..inputstring.."\n")
    print(ScriptName.." - "..inputstring)
end

--[[ Print initialization result ]]
if XPLM ~= nil then PrintToConsole("FFI: Initialized!") end
PrintToConsole("FFI: Operating system detected as "..ffi.os)

--[[ Write to log file ]]
function WriteToLogFile(inputstring)
	local file = io.open(Xlua_Utils_Path..LogFileName, "a") -- Check if file exists
	file:write(os.date("%x, %H:%M:%S"),": ",inputstring,"\n")
	file:close()
end

--[[ Delete log file ]]
function DeleteLogFile()
    os.remove(Xlua_Utils_Path..LogFileName)
end
--[[ Logging wrapper ]]
function LogOutput(inputstring)
    PrintToConsole(inputstring)
    WriteToLogFile(inputstring)
end
--[[

UTILITY FUNCTIONS

]]
--[[ Splits a line at the designated delimiter, returns a table ]]
function SplitString(input,delim)
    local output = {}
	--PrintToConsole("Line splitting in: "..input)
	for i in string.gmatch(input,delim) do table.insert(output,i) end
	--PrintToConsole("Line splitting out: "..table.concat(output,",",1,#output))
	return output
end
--[[ Trims whitespace from the end of a string - credit: https://snippets.bentasker.co.uk/page-1705231409-Trim-whitespace-from-end-of-string-LUA.html ]]
function TrimEndWhitespace(s)
  return s:match'^(.*%S)%s*$'
end
--[[

GLOBAL MENU FUNCTIONS

]]
--[[ Menu cleanup upon script reload or session exit ]]
function Menu_CleanUp()
   XPLM.XPLMClearAllMenuItems(XluaUtils_Menu_ID)
   XPLM.XPLMDestroyMenu(XluaUtils_Menu_ID)
   XPLM.XPLMRemoveMenuItem(XPLM.XPLMFindAircraftMenu(),XluaUtils_Menu_Index)
end
--[[ Menu item name change ]]
function Menu_ChangeItemPrefix(menu_id,index,prefix,intable)
    --LogOutput("Plopp: "..","..index..","..prefix..","..table.concat(intable,":"))
    XPLM.XPLMSetMenuItemName(menu_id,index-2,prefix.." "..intable[index],1)
end
--[[ Menu item check status change ]]
function Menu_CheckItem(menu_id,index,state)
    index = index - 2
    local out = ffi.new("XPLMMenuCheck[1]")
    XPLM.XPLMCheckMenuItemState(menu_id,index-1,ffi.cast("XPLMMenuCheck *",out))
    if tonumber(out[0]) == 0 then XPLM.XPLMCheckMenuItem(menu_id,index,1) end
    if state == "Activate" and tonumber(out[0]) ~= 2 then XPLM.XPLMCheckMenuItem(menu_id,index,2)
    elseif state == "Deactivate" and tonumber(out[0]) ~= 1 then XPLM.XPLMCheckMenuItem(menu_id,index,1)
    end
end
