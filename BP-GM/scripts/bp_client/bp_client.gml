#region jsDoc
	/// @func    bp_init()
	/// @desc    Spawns the persistent singleton handler and initializes the Buttplug client.
	/// @param   {String} [_client_name="GameMaker"] : The client name reported during handshake.
	/// @returns {Id.Instance}
#endregion
function bp_init(_client_name = "GameMaker") {
    // Singleton guard - return existing instance if already alive
    if (instance_exists(obj_bp_handler)) {
        __bp_log(BP_LOG.WARN, "bp_init() called but handler already exists");
        return obj_bp_handler.id;
    }
    
    var _inst = instance_create_depth(0, 0, 0, obj_bp_handler);
    _inst.persistent   = true;
    _inst.client_name  = _client_name;
    
    __bp_log(BP_LOG.INFO, "Buttplug client initialized (\"" + _client_name + "\")");
    return _inst;
}

#region jsDoc
	/// @func    bp_cleanup()
	/// @desc    Destroys the handler instance, triggering its Clean Up event.
	/// @returns {Undefined}
#endregion
function bp_cleanup() {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_cleanup() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    instance_destroy(obj_bp_handler);
}

#region jsDoc
	/// @func    bp_set_client_name()
	/// @desc    Sets the client name used by the next connection handshake.
	/// @param   {String} _name : The client name to report.
	/// @returns {Undefined}
#endregion
function bp_set_client_name(_name) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_set_client_name() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    obj_bp_handler.client_name = _name;
}

#region jsDoc
	/// @func    bp_set_log_level()
	/// @desc    Sets the current internal logging verbosity.
	/// @param   {Real} _level : The BP_LOG level value to use.
	/// @returns {Undefined}
#endregion
function bp_set_log_level(_level) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_set_log_level() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    obj_bp_handler.log_level = _level;
}

#region Connection

#region jsDoc
	/// @func    bp_connect()
	/// @desc    Starts an asynchronous connection to a Buttplug server.
	/// @param   {String} [_url="ws://127.0.0.1:12345"] : The WebSocket server url.
	/// @returns {Undefined}
#endregion
function bp_connect(_url = "ws://127.0.0.1:12345") {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_connect() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    
    if (obj_bp_handler.state != BP_STATE.DISCONNECTED) {
        __bp_log(BP_LOG.WARN, "Already connected or connecting - call bp_disconnect() first");
        return;
    }
    
    // Parse URL
    var _parsed = __bp_parse_url(_url);
    obj_bp_handler.host = _parsed.host;
    obj_bp_handler.port = _parsed.port;
    
    __bp_log(BP_LOG.INFO, "Connecting to " + obj_bp_handler.host + ":" + string(obj_bp_handler.port));
    
    // Create WebSocket client socket
    obj_bp_handler.socket = network_create_socket(network_socket_ws);
    if (obj_bp_handler.socket < 0) {
        __bp_log(BP_LOG.ERROR, "Failed to create WebSocket socket");
        if (obj_bp_handler.on_error != undefined) {
            obj_bp_handler.on_error(BP_ERROR.INIT, "Failed to create WebSocket socket");
        }
        return;
    }
    
    // Begin async connection
    obj_bp_handler.state = BP_STATE.CONNECTING;
    
    // Reset state for new connection
    obj_bp_handler.devices              = {};
    obj_bp_handler.message_id           = 0;
    obj_bp_handler.handshake_id         = -1;
    obj_bp_handler.scanning             = false;
    obj_bp_handler.pending_sensor_reads = {};
    
    network_connect_raw_async(obj_bp_handler.socket, obj_bp_handler.host, obj_bp_handler.port);
}

#region jsDoc
	/// @func    bp_disconnect()
	/// @desc    Disconnects from the server and clears the current device cache.
	/// @returns {Undefined}
#endregion
function bp_disconnect() {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_disconnect() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    if (obj_bp_handler.state == BP_STATE.DISCONNECTED) return;
    
    var _was_connected = (obj_bp_handler.state == BP_STATE.CONNECTED);
    
    if (obj_bp_handler.socket >= 0) {
        network_destroy(obj_bp_handler.socket);
        obj_bp_handler.socket = -1;
    }
    
    obj_bp_handler.state    = BP_STATE.DISCONNECTED;
    obj_bp_handler.scanning = false;
    obj_bp_handler.devices  = {};
    
    __bp_log(BP_LOG.INFO, "Disconnected");
    
    if (_was_connected && obj_bp_handler.on_disconnected != undefined) {
        obj_bp_handler.on_disconnected();
    }
}

#region jsDoc
	/// @func    bp_is_connected()
	/// @desc    Returns whether the handshake has completed and the client is fully connected.
	/// @returns {Bool}
#endregion
function bp_is_connected() {
    if (!instance_exists(obj_bp_handler)) return false;
    return (obj_bp_handler.state == BP_STATE.CONNECTED);
}

#region jsDoc
	/// @func    bp_get_state()
	/// @desc    Returns the current connection state value.
	/// @returns {Real}
#endregion
function bp_get_state() {
    if (!instance_exists(obj_bp_handler)) return BP_STATE.DISCONNECTED;
    return obj_bp_handler.state;
}

#region jsDoc
	/// @func    bp_get_server_name()
	/// @desc    Returns the server name reported by the connected Buttplug server.
	/// @returns {String}
#endregion
function bp_get_server_name() {
    if (!instance_exists(obj_bp_handler)) return "";
    return obj_bp_handler.server_name;
}

#endregion

#region Scanning

#region jsDoc
	/// @func    bp_start_scanning()
	/// @desc    Requests device scanning from the server.
	/// @returns {Undefined}
#endregion
function bp_start_scanning() {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_start_scanning() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    if (obj_bp_handler.state != BP_STATE.CONNECTED) {
        __bp_log(BP_LOG.WARN, "Cannot scan - not connected");
        return;
    }
    
    obj_bp_handler.scanning = true;
    __bp_send(__bp_msg_start_scanning());
    __bp_log(BP_LOG.INFO, "Scanning started");
}

#region jsDoc
	/// @func    bp_stop_scanning()
	/// @desc    Requests that device scanning stop.
	/// @returns {Undefined}
#endregion
function bp_stop_scanning() {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_stop_scanning() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    if (obj_bp_handler.state != BP_STATE.CONNECTED) return;
    
    __bp_send(__bp_msg_stop_scanning());
    __bp_log(BP_LOG.INFO, "Scanning stop requested");
}

#region jsDoc
	/// @func    bp_is_scanning()
	/// @desc    Returns whether the client currently considers scanning active.
	/// @returns {Bool}
#endregion
function bp_is_scanning() {
    if (!instance_exists(obj_bp_handler)) return false;
    return obj_bp_handler.scanning;
}

#endregion

#region Emergency Stop

#region jsDoc
	/// @func    bp_stop_all_devices()
	/// @desc    Sends the emergency stop command to all connected devices.
	/// @returns {Undefined}
#endregion
function bp_stop_all_devices() {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_stop_all_devices() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    if (obj_bp_handler.state != BP_STATE.CONNECTED) return;
    
    __bp_send(__bp_msg_stop_all_devices());
    __bp_log(BP_LOG.INFO, "Stop all devices sent");
}

#endregion

#region Callback Registration

#region jsDoc
	/// @func    bp_on_connected()
	/// @desc    Registers the callback fired after the handshake completes.
	/// @param   {Function} _callback : The callback to invoke.
	/// @returns {Undefined}
#endregion
function bp_on_connected(_callback) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_on_connected() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    obj_bp_handler.on_connected = _callback;
}

#region jsDoc
	/// @func    bp_on_disconnected()
	/// @desc    Registers the callback fired when the connection is lost or closed.
	/// @param   {Function} _callback : The callback to invoke.
	/// @returns {Undefined}
#endregion
function bp_on_disconnected(_callback) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_on_disconnected() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    obj_bp_handler.on_disconnected = _callback;
}

#region jsDoc
	/// @func    bp_on_error()
	/// @desc    Registers the callback fired when the library receives or produces an error.
	/// @param   {Function} _callback : The callback to invoke.
	/// @returns {Undefined}
#endregion
function bp_on_error(_callback) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_on_error() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    obj_bp_handler.on_error = _callback;
}

#region jsDoc
	/// @func    bp_on_device_added()
	/// @desc    Registers the callback fired when a device is discovered or added.
	/// @param   {Function} _callback : The callback to invoke.
	/// @returns {Undefined}
#endregion
function bp_on_device_added(_callback) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_on_device_added() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    obj_bp_handler.on_device_added = _callback;
}

#region jsDoc
	/// @func    bp_on_device_removed()
	/// @desc    Registers the callback fired when a device is removed.
	/// @param   {Function} _callback : The callback to invoke.
	/// @returns {Undefined}
#endregion
function bp_on_device_removed(_callback) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_on_device_removed() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    obj_bp_handler.on_device_removed = _callback;
}

#region jsDoc
	/// @func    bp_on_scanning_finished()
	/// @desc    Registers the callback fired when scanning completes.
	/// @param   {Function} _callback : The callback to invoke.
	/// @returns {Undefined}
#endregion
function bp_on_scanning_finished(_callback) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_on_scanning_finished() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    obj_bp_handler.on_scanning_finished = _callback;
}

#region jsDoc
	/// @func    bp_on_sensor_reading()
	/// @desc    Registers the callback fired when a sensor reading is received.
	/// @param   {Function} _callback : The callback to invoke.
	/// @returns {Undefined}
#endregion
function bp_on_sensor_reading(_callback) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_on_sensor_reading() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    obj_bp_handler.on_sensor_reading = _callback;
}

#endregion
