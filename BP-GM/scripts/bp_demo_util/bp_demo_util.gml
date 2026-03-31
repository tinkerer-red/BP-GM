#region jsDoc
	/// @func    __demo_log()
	/// @desc    Appends a timestamped message to the on-screen demo log panel.
	/// @param   {String} _msg : The message text to display.
	/// @returns {Undefined}
#endregion
function __demo_log(_msg) {
    if (!instance_exists(obj_bp_demo)) return;
    
    var _timestamp = string(current_hour) + ":" 
        + string_replace(string_format(current_minute, 2, 0), " ", "0") + ":" 
        + string_replace(string_format(current_second, 2, 0), " ", "0");
    
    array_push(obj_bp_demo.log_lines, _timestamp + "  " + _msg);
    
    // Trim to max
    while (array_length(obj_bp_demo.log_lines) > obj_bp_demo.log_max_lines * 2) {
        array_delete(obj_bp_demo.log_lines, 0, 1);
    }
    
    show_debug_message("[Demo] " + _msg);
}
