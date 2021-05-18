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
/* XPLMDataAccess - inop because they're dumb cunts and can not be accessed */
/* typedef void *XPLMDataRef;
int XPLMGetDatab(XPLMDataRef inDataRef,void *outValue,int inOffset,int inMaxBytes);
void XPLMSetDatab(XPLMDataRef inDataRef,void *inValue,int inOffset,int inLength); */
/* XPLMPlanes */
void XPLMGetNthAircraftModel(int inIndex,char *outFileName,char *outPath);    
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
	local file = io.open(ACF_Folder..LogFileName, "a") -- Check if file exists
	file:write(os.date("%x, %H:%M:%S"),": ",inputstring,"\n")
	file:close()
end

--[[ Delete log file ]]
function DeleteLogFile()
    os.remove(ACF_Folder..LogFileName)
end
--[[ Logging wrapper ]]
function LogOutput(inputstring)
    WriteToLogFile(inputstring)
    PrintToConsole(inputstring)
end
