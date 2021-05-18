function Init_FFI_XPWidgets()
    print(string.format("FFI XPWidgets: Operating system is: %s",ffi.os))
    --[[ Load Widgets library ]]
    XPWidgets = nil
    if ffi.os == "Windows" then XPWidgets = ffi.load("XPWidgets_64")  -- Windows 64bit
    elseif ffi.os == "Linux" then XPWidgets = ffi.load("Resources/plugins/XPWidgets_64.so")  -- Linux 64bit (Requires "Resources/plugins/" for some reason)
    elseif ffi.os == "OSX" then XPWidgets = ffi.load("Resources/plugins/XPWidgets.framework/XPWidgets") -- 64bit MacOS (Requires "Resources/plugins/" for some reason)
    else return 
    end
    if XPWidgets ~= nil then print("FFI XPWidgets: Initialized!") end
    --[[ Add Lua-translated XPWidgets header files to FFI ]]
    FFI_Init_XPWidgetDefs()         --[[ REQUIRES FFI.XPLMDefs.lua ]]
    FFI_Init_XPStandardWidgets()    --[[ REQUIRES FFI.XPWidgetDefs.lua ]]
    FFI_Init_XPUIGraphics()         --[[ REQUIRES FFI.XPWidgetDefs.lua ]]
    FFI_Init_XPWidgets()            --[[ REQUIRES FFI.XPWidgetDefs.lua, XPLMDisplay.lua ]]
    FFI_Init_XPWidgetUtils()        --[[ REQUIRES FFI.XPWidgetDefs.lua ]]
end
