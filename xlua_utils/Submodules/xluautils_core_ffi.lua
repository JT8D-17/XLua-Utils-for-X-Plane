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
void XPLMSetDatai(XPLMDataRef inDataRef,int inValue);
float XPLMGetDataf(XPLMDataRef inDataRef);
void XPLMSetDataf(XPLMDataRef inDataRef,float inValue);
double XPLMGetDatad(XPLMDataRef inDataRef);
void XPLMSetDatad(XPLMDataRef inDataRef,double inValue);
int XPLMGetDatavi(XPLMDataRef inDataRef,int *outValues,int inOffset,int inMax);
void XPLMSetDatavi(XPLMDataRef inDataRef,int *inValues,int inoffset,int inCount);
int XPLMGetDatavf(XPLMDataRef inDataRef,int *outValues,int inOffset,int inMax);
void XPLMSetDatavf(XPLMDataRef inDataRef,float *inValues,int inoffset,int inCount);
int XPLMGetDatab(XPLMDataRef inDataRef,void *outValue,int inOffset,int inMaxBytes);
void XPLMSetDatab(XPLMDataRef inDataRef,void *inValue,int inOffset,int inLength);
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
void XPLMGetScreenBoundsGlobal(int *outLeft,int *outTop,int *outRight,int *outBottom);
void XPLMGetWindowGeometry(XPLMWindowID inWindowID,int *outLeft,int *outTop,int *outRight,int *outBottom);
void XPLMSetWindowGeometry(XPLMWindowID inWindowID,int inLeft,int inTop,int inRight,int inBottom);
int  XPLMGetWindowIsVisible(XPLMWindowID inWindowID);
void XPLMSetWindowIsVisible(XPLMWindowID inWindowID,int inIsVisible);
void XPLMSetWindowTitle(XPLMWindowID inWindowID, const char *inWindowTitle);
/* XPLMGraphics */
typedef int XPLMFontID;
void XPLMDrawString(float *inColorRGB,int inXOffset,int inYOffset, char *inChar,int *inWordWrapWidth,XPLMFontID inFontID);
void XPLMDrawTranslucentDarkBox(int inLeft,int inTop,int inRight,int inBottom);
void XPLMGetFontDimensions(XPLMFontID inFontID,int *outCharWidth,int *outCharHeight,int *outDigitsOnly);
]])
--[[ Checks if the FFI has loaded correctly ]]
function FFI_CheckInit()
    --[[ Print initialization result ]]
    if XPLM ~= nil then PrintToConsole("FFI: Initialized!") end
    PrintToConsole("FFI: Operating system detected as "..ffi.os)
end
