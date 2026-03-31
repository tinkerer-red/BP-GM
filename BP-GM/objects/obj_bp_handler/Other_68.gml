/// @desc Handle incoming WebSocket events
var _event_type = async_load[? "type"];
var _socket_id  = async_load[? "id"];

// Only handle events for our socket
if (_socket_id != socket) exit;

switch (_event_type) {
    
    // --- Connection result ---
    case network_type_non_blocking_connect:
        var _success = async_load[? "succeeded"];
        if (_success) {
            __bp_log(BP_LOG.INFO, "WebSocket connected - sending handshake");
            state = BP_STATE.HANDSHAKING;
            __bp_send(__bp_msg_request_server_info());
        } else {
            __bp_log(BP_LOG.ERROR, "WebSocket connection failed");
            state = BP_STATE.DISCONNECTED;
            if (socket >= 0) {
                network_destroy(socket);
                socket = -1;
            }
            if (on_error != undefined) {
                on_error(BP_ERROR.INIT, "WebSocket connection failed");
            }
        }
        exit;
    
    // --- Incoming data ---
    case network_type_data:
        var _buff = async_load[? "buffer"];
        var _size = async_load[? "size"];
        
        if (_buff < 0 || _size <= 0) exit;
        
        // Read the raw bytes as a UTF-8 string
        var _temp = buffer_create(_size + 1, buffer_fixed, 1);
        buffer_copy(_buff, 0, _size, _temp, 0);
        buffer_poke(_temp, _size, buffer_u8, 0);
        buffer_seek(_temp, buffer_seek_start, 0);
        var _json = buffer_read(_temp, buffer_text);
        buffer_delete(_temp);
        
        if (string_length(_json) > 0) {
            __bp_process_messages(_json);
        }
        exit;
    
    // --- Disconnection ---
    case network_type_disconnect:
        __bp_log(BP_LOG.INFO, "Server disconnected");
        var _was_connected = (state == BP_STATE.CONNECTED);
        state    = BP_STATE.DISCONNECTED;
        scanning = false;
        
        if (socket >= 0) {
            network_destroy(socket);
            socket = -1;
        }
        
        if (_was_connected && on_disconnected != undefined) {
            on_disconnected();
        }
        exit;
}

exit;
