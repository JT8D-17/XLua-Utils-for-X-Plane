--[[

XLuaUtils Module, required by xluautils.lua
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
void XPLMGetSystemPath(char *outSystemPath);
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
typedef int (*XPLMGetDatai_f)(void *inRefcon);
typedef void (* XPLMSetDatai_f)(void *inRefcon,int inValue);
typedef float (* XPLMGetDataf_f)(void *inRefcon);
typedef void (* XPLMSetDataf_f)(void *inRefcon,float inValue);
typedef double (* XPLMGetDatad_f)(void *inRefcon);
typedef void (* XPLMSetDatad_f)(void *inRefcon,double inValue);
typedef int (* XPLMGetDatavi_f)(void *inRefcon,int *outValues,int inOffset,int inMax);
typedef void (* XPLMSetDatavi_f)(void *inRefcon,int *inValues,int inOffset,int inCount);
typedef int (* XPLMGetDatavf_f)(void *inRefcon,float *outValues,int inOffset,int inMax);
typedef void (* XPLMSetDatavf_f)(void *inRefcon,float *inValues,int inOffset,int inCount);
typedef int (* XPLMGetDatab_f)(void *inRefcon,void *outValue,int inOffset,int inMaxLength);
typedef void (* XPLMSetDatab_f)(void *inRefcon,void *inValue,int inOffset,int inLength);
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
XPLMDataRef XPLMRegisterDataAccessor(const char *inDataName,XPLMDataTypeID inDataType,int inIsWritable,XPLMGetDatai_f inReadInt,XPLMSetDatai_f inWriteInt,XPLMGetDataf_f inReadFloat,XPLMSetDataf_f inWriteFloat,XPLMGetDatad_f inReadDouble,XPLMSetDatad_f inWriteDouble,XPLMGetDatavi_f inReadIntArray,XPLMSetDatavi_f inWriteIntArray,XPLMGetDatavf_f inReadFloatArray,XPLMSetDatavf_f inWriteFloatArray,XPLMGetDatab_f inReadData,XPLMSetDatab_f inWriteData,void *inReadRefcon,void *inWriteRefcon);
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
void XPLMLocalToWorld(double inX,double inY,double inZ,double *outLatitude,double *outLongitude,double *outAltitude);
void XPLMWorldToLocal(double inLatitude,double inLongitude,double inAltitude,double *outX,double *outY,double *outZ);
/* XPLMScenery */
typedef void *XPLMObjectRef;
typedef void *XPLMProbeRef;
typedef int XPLMProbeType;
typedef int XPLMProbeResult;
typedef struct {int structSize; float x; float y; float z; float pitch; float heading; float roll;} XPLMDrawInfo_t;
typedef void (*XPLMObjectLoaded_f)(XPLMObjectRef inObject, void *inRefcon);
void XPLMLoadObject(const char *inPath);
void XPLMLoadObjectAsync(const char *inPath, XPLMObjectLoaded_f inCallback, void *inRefcon);
void XPLMUnloadObject(XPLMObjectRef inObject);
typedef struct {
    int structSize;
    float locationX;
    float locationY;
    float locationZ;
    float normalX;
    float normalY;
    float normalZ;
    float velocityX;
    float velocityY;
    float velocityZ;
    int is_wet;
} XPLMProbeInfo_t;
XPLMProbeRef XPLMCreateProbe(XPLMProbeType inProbeType);
XPLMProbeResult XPLMProbeTerrainXYZ(XPLMProbeRef inProbe,float inX,float inY,float inZ,XPLMProbeInfo_t *outInfo);
void XPLMDestroyProbe(XPLMProbeRef inProbe);
/* XPLMInstance */
typedef void *XPLMInstanceRef;
XPLMInstanceRef XPLMCreateInstance(XPLMObjectRef obj, const char **datarefs);
void XPLMDestroyInstance(XPLMInstanceRef instance);
void XPLMInstanceSetPosition(XPLMInstanceRef instance, const XPLMDrawInfo_t *new_position, const float *data);
]])
--[[ Checks if the FFI has loaded correctly ]]
function FFI_CheckInit()
    --[[ Print initialization result ]]
    if XPLM ~= nil then DebugLogOutput("FFI: Initialized!") end
    DebugLogOutput("FFI: Operating system detected as "..ffi.os)
end
