function FFI_Init_XPLMDefs()
    ffi.cdef([[ 
        /***************************************************************************
        * GLOBAL DEFINITIONS
        ***************************************************************************/
        /*
        * These definitions are used in all parts of the SDK.                         
        *
        */

        /*
        * XPLMPluginID
        * 
        * Each plug-in is identified by a unique integer ID.  This ID can be used to 
        * disable or enable a plug-in, or discover what plug-in is 'running' at the 
        * time.  A plug-in ID is unique within the currently running instance of 
        * X-Plane unless plug-ins are reloaded.  Plug-ins may receive a different 
        * unique ID each time they are loaded. 
        * 
        * For persistent identification of plug-ins, use XPLMFindPluginBySignature in 
        * XPLMUtiltiies.h 
        * 
        * -1 indicates no plug-in.                                                    
        *
        */
        typedef int XPLMPluginID;
        
        /*
        * XPLMKeyFlags
        * 
        * These bitfields define modifier keys in a platform independent way. When a 
        * key is pressed, a series of messages are sent to your plugin.  The down 
        * flag is set in the first of these messages, and the up flag in the last.  
        * While the key is held down, messages are sent with neither to indicate that 
        * the key is being held down as a repeated character. 
        * 
        * The control flag is mapped to the control flag on Macintosh and PC.  
        * Generally X-Plane uses the control key and not the command key on 
        * Macintosh, providing a consistent interface across platforms that does not 
        * necessarily match the Macintosh user interface guidelines.  There is not 
        * yet a way for plugins to access the Macintosh control keys without using 
        * #ifdefed code.                                                              
        *
        */
        enum {
            /* The shift key is down                                                       */
            xplm_ShiftFlag                           = 1

            /* The option or alt key is down                                               */
            ,xplm_OptionAltFlag                       = 2

            /* The control key is down*                                                    */
            ,xplm_ControlFlag                         = 4

            /* The key is being pressed down                                               */
            ,xplm_DownFlag                            = 8

            /* The key is being released                                                   */
            ,xplm_UpFlag                              = 16
        };
        typedef int XPLMKeyFlags;
                    
        ]])
        WriteLogOutput(ScriptName..": FFI cdefs - Loaded XPLMDefs")
end
