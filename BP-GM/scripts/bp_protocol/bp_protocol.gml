#region jsDoc
	/// @func    __bp_log()
	/// @desc    Writes an internal library log message if the current log level allows it.
	/// @param   {Real} _level : The log severity value from BP_LOG.
	/// @param   {String} _msg : The message text to print.
	/// @returns {Undefined}
#endregion
function __bp_log(_level, _msg) {
    if (!instance_exists(obj_bp_handler)) return;
    if (_level > obj_bp_handler.log_level) return;
    
    var _prefix = "[Buttplug] ";
    switch (_level) {
        case BP_LOG.ERROR: _prefix += "ERROR: "; break;
        case BP_LOG.WARN:  _prefix += "WARN: ";  break;
        case BP_LOG.INFO:  _prefix += "INFO: ";  break;
        case BP_LOG.DEBUG: _prefix += "DEBUG: "; break;
    }
    
    show_debug_message(_prefix + _msg);
}

#region jsDoc
	/// @func    __bp_next_id()
	/// @desc    Returns the next protocol message id used for request correlation.
	/// @returns {Real}
#endregion
function __bp_next_id() {
    obj_bp_handler.message_id++;
    return obj_bp_handler.message_id;
}

#region jsDoc
	/// @func    __bp_parse_url()
	/// @desc    Splits a WebSocket url into host and port values.
	/// @param   {String} _url : The full server url.
	/// @returns {Struct}
#endregion
function __bp_parse_url(_url) {
    var _host = BP_DEFAULT_ADDRESS;
    var _port = BP_DEFAULT_PORT;
    
    var _addr = _url;
    if (string_pos("ws://", _addr) == 1) {
        _addr = string_delete(_addr, 1, 5);
    }
    else if (string_pos("wss://", _addr) == 1) {
        _addr = string_delete(_addr, 1, 6);
    }
    
    if (string_char_at(_addr, string_length(_addr)) == "/") {
        _addr = string_delete(_addr, string_length(_addr), 1);
    }
    
    var _colon = string_pos(":", _addr);
    if (_colon > 0) {
        _host = string_copy(_addr, 1, _colon - 1);
        var _port_str = string_delete(_addr, 1, _colon);
        _port = real(_port_str);
    }
    else if (string_length(_addr) > 0) {
        _host = _addr;
    }
    
    return { host: _host, port: _port };
}

#region jsDoc
	/// @func    __bp_send()
	/// @desc    Serializes and sends an array of Buttplug protocol messages over the active socket.
	/// @param   {Array} _msg_array : The protocol message array to send.
	/// @returns {Undefined}
#endregion
function __bp_send(_msg_array) {
    if (obj_bp_handler.socket < 0) {
        __bp_log(BP_LOG.ERROR, "Cannot send - socket not created");
        return;
    }
    
    var _json = json_stringify(_msg_array);
	
	// Fix GameMaker float serialization - protocol requires integer types
	_json = string_replace_all(_json, ".0,", ",");
	_json = string_replace_all(_json, ".0}", "}");
	_json = string_replace_all(_json, ".0]", "]");
	
    var _len  = string_byte_length(_json);
    var _buff = buffer_create(_len + 1, buffer_fixed, 1);
    buffer_write(_buff, buffer_text, _json);
    network_send_raw(obj_bp_handler.socket, _buff, _len, network_send_text);
	
    buffer_delete(_buff);
    
    __bp_log(BP_LOG.DEBUG, "SEND: " + _json);
}

#region Message Builders

#region jsDoc
	/// @func    __bp_msg_request_server_info()
	/// @desc    Builds the RequestServerInfo handshake message.
	/// @returns {Array}
#endregion
function __bp_msg_request_server_info() {
    var _msg_id = __bp_next_id();
    obj_bp_handler.handshake_id = _msg_id;
    return [{
        RequestServerInfo: {
            Id: _msg_id,
            ClientName: obj_bp_handler.client_name,
            MessageVersion: BP_PROTOCOL_VERSION
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_request_device_list()
	/// @desc    Builds a RequestDeviceList message.
	/// @returns {Array}
#endregion
function __bp_msg_request_device_list() {
    return [{
        RequestDeviceList: {
            Id: __bp_next_id()
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_start_scanning()
	/// @desc    Builds a StartScanning message.
	/// @returns {Array}
#endregion
function __bp_msg_start_scanning() {
    return [{
        StartScanning: {
            Id: __bp_next_id()
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_stop_scanning()
	/// @desc    Builds a StopScanning message.
	/// @returns {Array}
#endregion
function __bp_msg_stop_scanning() {
    return [{
        StopScanning: {
            Id: __bp_next_id()
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_ping()
	/// @desc    Builds a Ping keepalive message.
	/// @returns {Array}
#endregion
function __bp_msg_ping() {
    return [{
        Ping: {
            Id: __bp_next_id()
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_scalar_cmd()
	/// @desc    Builds a ScalarCmd message for one device.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Array} _scalars : The scalar command entries to send.
	/// @returns {Array}
#endregion
function __bp_msg_scalar_cmd(_device_index, _scalars) {
    return [{
        ScalarCmd: {
            Id: __bp_next_id(),
            DeviceIndex: _device_index,
            Scalars: _scalars
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_linear_cmd()
	/// @desc    Builds a LinearCmd message for one device.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Array} _vectors : The linear movement entries to send.
	/// @returns {Array}
#endregion
function __bp_msg_linear_cmd(_device_index, _vectors) {
    return [{
        LinearCmd: {
            Id: __bp_next_id(),
            DeviceIndex: _device_index,
            Vectors: _vectors
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_rotate_cmd()
	/// @desc    Builds a RotateCmd message for one device.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Array} _rotations : The rotation command entries to send.
	/// @returns {Array}
#endregion
function __bp_msg_rotate_cmd(_device_index, _rotations) {
    return [{
        RotateCmd: {
            Id: __bp_next_id(),
            DeviceIndex: _device_index,
            Rotations: _rotations
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_stop_device()
	/// @desc    Builds a StopDeviceCmd message for one device.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Array}
#endregion
function __bp_msg_stop_device(_device_index) {
    return [{
        StopDeviceCmd: {
            Id: __bp_next_id(),
            DeviceIndex: _device_index
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_stop_all_devices()
	/// @desc    Builds a StopAllDevices message.
	/// @returns {Array}
#endregion
function __bp_msg_stop_all_devices() {
    return [{
        StopAllDevices: {
            Id: __bp_next_id()
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_sensor_read()
	/// @desc    Builds a SensorReadCmd message and records the pending read metadata.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _sensor_index : The target sensor index on the device.
	/// @param   {String} _sensor_type : The sensor type string.
	/// @returns {Array}
#endregion
function __bp_msg_sensor_read(_device_index, _sensor_index, _sensor_type) {
    var _msg_id = __bp_next_id();
    obj_bp_handler.pending_sensor_reads[$ string(_msg_id)] = {
        device_index: _device_index,
        sensor_index: _sensor_index,
        sensor_type: _sensor_type
    };
    return [{
        SensorReadCmd: {
            Id: _msg_id,
            DeviceIndex: _device_index,
            SensorIndex: _sensor_index,
            SensorType: _sensor_type
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_sensor_subscribe()
	/// @desc    Builds a SensorSubscribeCmd message.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _sensor_index : The target sensor index on the device.
	/// @param   {String} _sensor_type : The sensor type string.
	/// @returns {Array}
#endregion
function __bp_msg_sensor_subscribe(_device_index, _sensor_index, _sensor_type) {
    return [{
        SensorSubscribeCmd: {
            Id: __bp_next_id(),
            DeviceIndex: _device_index,
            SensorIndex: _sensor_index,
            SensorType: _sensor_type
        }
    }];
}

#region jsDoc
	/// @func    __bp_msg_sensor_unsubscribe()
	/// @desc    Builds a SensorUnsubscribeCmd message.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _sensor_index : The target sensor index on the device.
	/// @param   {String} _sensor_type : The sensor type string.
	/// @returns {Array}
#endregion
function __bp_msg_sensor_unsubscribe(_device_index, _sensor_index, _sensor_type) {
    return [{
        SensorUnsubscribeCmd: {
            Id: __bp_next_id(),
            DeviceIndex: _device_index,
            SensorIndex: _sensor_index,
            SensorType: _sensor_type
        }
    }];
}

#endregion

#region Message Processing

#region jsDoc
	/// @func    __bp_process_messages()
	/// @desc    Parses a raw json batch from the server and dispatches each payload to its handler.
	/// @param   {String} _json_string : The raw json message array from the socket.
	/// @returns {Undefined}
#endregion
function __bp_process_messages(_json_string) {
    __bp_log(BP_LOG.DEBUG, "RECV: " + _json_string);
    
    var _data;
    try {
        _data = json_parse(_json_string);
    } catch (_exc) {
        __bp_log(BP_LOG.ERROR, "Failed to parse JSON: " + string(_exc));
        return;
    }
    
    if (!is_array(_data)) {
        __bp_log(BP_LOG.ERROR, "Expected JSON array, got: " + typeof(_data));
        return;
    }
    
    var _count = array_length(_data);
    var _i = 0;
    repeat (_count) {
        var _msg = _data[_i];
        if (is_struct(_msg)) {
            var _keys = variable_struct_get_names(_msg);
            if (array_length(_keys) > 0) {
                var _type    = _keys[0];
                var _payload = variable_struct_get(_msg, _type);
                
                switch (_type) {
                    case "ServerInfo":       __bp_handle_server_info(_payload);        break;
                    case "Ok":               __bp_handle_ok(_payload);                break;
                    case "Error":            __bp_handle_error(_payload);             break;
                    case "DeviceList":       __bp_handle_device_list(_payload);       break;
                    case "DeviceAdded":      __bp_handle_device_added(_payload);      break;
                    case "DeviceRemoved":    __bp_handle_device_removed(_payload);    break;
                    case "ScanningFinished": __bp_handle_scanning_finished(_payload); break;
                    case "SensorReading":    __bp_handle_sensor_reading(_payload);    break;
                    default:
                        __bp_log(BP_LOG.WARN, "Unknown message type: " + _type);
                        break;
                }
            }
        }
        _i++;
    }
}

#region jsDoc
	/// @func    __bp_handle_server_info()
	/// @desc    Applies the ServerInfo handshake payload and finalizes the connected state.
	/// @param   {Struct} _payload : The ServerInfo payload struct.
	/// @returns {Undefined}
#endregion
function __bp_handle_server_info(_payload) {
    obj_bp_handler.server_name   = variable_struct_exists(_payload, "ServerName") 
        ? _payload.ServerName : "Unknown";
    obj_bp_handler.max_ping_time = variable_struct_exists(_payload, "MaxPingTime") 
        ? _payload.MaxPingTime : 0;
    
    __bp_log(BP_LOG.INFO, "Connected to server: " + obj_bp_handler.server_name);
    __bp_log(BP_LOG.INFO, "Max ping time: " + string(obj_bp_handler.max_ping_time) + "ms");
    
    if (obj_bp_handler.max_ping_time > 0) {
        obj_bp_handler.ping_interval  = obj_bp_handler.max_ping_time / 2;
        obj_bp_handler.last_ping_time = current_time;
    }
    
    obj_bp_handler.state = BP_STATE.CONNECTED;
    
    __bp_send(__bp_msg_request_device_list());
    
    if (obj_bp_handler.on_connected != undefined) {
        obj_bp_handler.on_connected();
    }
}

#region jsDoc
	/// @func    __bp_handle_ok()
	/// @desc    Handles an Ok response from the server.
	/// @param   {Struct} _payload : The Ok payload struct.
	/// @returns {Undefined}
#endregion
function __bp_handle_ok(_payload) {
    var _msg_id = variable_struct_exists(_payload, "Id") ? _payload.Id : -1;
    __bp_log(BP_LOG.DEBUG, "Ok received for message Id: " + string(_msg_id));
}

#region jsDoc
	/// @func    __bp_handle_error()
	/// @desc    Handles an Error response and forwards it to the registered error callback.
	/// @param   {Struct} _payload : The Error payload struct.
	/// @returns {Undefined}
#endregion
function __bp_handle_error(_payload) {
    var _msg_id = variable_struct_exists(_payload, "Id") ? _payload.Id : -1;
    var _msg = variable_struct_exists(_payload, "ErrorMessage") 
        ? _payload.ErrorMessage : "Unknown error";
    var _code = variable_struct_exists(_payload, "ErrorCode") 
        ? _payload.ErrorCode : BP_ERROR.UNKNOWN;
    
    __bp_log(BP_LOG.ERROR, "Server error (Id " + string(_msg_id) + ", Code " + string(_code) + "): " + _msg);
    
    if (_msg_id == obj_bp_handler.handshake_id) {
        __bp_log(BP_LOG.ERROR, "Handshake failed - disconnecting");
        bp_disconnect();
    }
    
    if (obj_bp_handler.on_error != undefined) {
        obj_bp_handler.on_error(_code, _msg);
    }
}

#region jsDoc
	/// @func    __bp_handle_device_list()
	/// @desc    Stores each device from a DeviceList payload.
	/// @param   {Struct} _payload : The DeviceList payload struct.
	/// @returns {Undefined}
#endregion
function __bp_handle_device_list(_payload) {
    if (!variable_struct_exists(_payload, "Devices")) { return; }
    
    var _devices = _payload.Devices;
    if (!is_array(_devices)) { return; }
    
    var _count = array_length(_devices);
    __bp_log(BP_LOG.INFO, "Device list received: " + string(_count) + " device(s)");
    
    var _i = 0;
    repeat (_count) {
        var _dev_data = _devices[_i];
        var _dev = __bp_parse_device(_dev_data);
        if (_dev != undefined) {
            var _key = string(_dev.index);
            obj_bp_handler.devices[$ _key] = _dev;
            __bp_log(BP_LOG.INFO, "  Device [" + string(_dev.index) + "]: " + _dev.name);
            
            if (obj_bp_handler.on_device_added != undefined) {
                obj_bp_handler.on_device_added(_dev.index);
            }
        }
        _i++;
    }
}

#region jsDoc
	/// @func    __bp_handle_device_added()
	/// @desc    Adds a single device reported by the server.
	/// @param   {Struct} _payload : The DeviceAdded payload struct.
	/// @returns {Undefined}
#endregion
function __bp_handle_device_added(_payload) {
    var _dev = __bp_parse_device(_payload);
    if (_dev == undefined) { return; }
    
    var _key = string(_dev.index);
    obj_bp_handler.devices[$ _key] = _dev;
    __bp_log(BP_LOG.INFO, "Device added [" + string(_dev.index) + "]: " + _dev.name);
    
    if (obj_bp_handler.on_device_added != undefined) {
        obj_bp_handler.on_device_added(_dev.index);
    }
}

#region jsDoc
	/// @func    __bp_handle_device_removed()
	/// @desc    Removes a device reported as disconnected by the server.
	/// @param   {Struct} _payload : The DeviceRemoved payload struct.
	/// @returns {Undefined}
#endregion
function __bp_handle_device_removed(_payload) {
    var _device_index = variable_struct_exists(_payload, "DeviceIndex") 
        ? _payload.DeviceIndex : -1;
    
    if (_device_index < 0) { return; }
    
    var _key = string(_device_index);
    if (variable_struct_exists(obj_bp_handler.devices, _key)) {
        var _name = obj_bp_handler.devices[$ _key].name;
        variable_struct_remove(obj_bp_handler.devices, _key);
        __bp_log(BP_LOG.INFO, "Device removed [" + string(_device_index) + "]: " + _name);
    }
    
    if (obj_bp_handler.on_device_removed != undefined) {
        obj_bp_handler.on_device_removed(_device_index);
    }
}

#region jsDoc
	/// @func    __bp_handle_scanning_finished()
	/// @desc    Clears the scanning flag and fires the scanning callback.
	/// @param   {Struct} _payload : The ScanningFinished payload struct.
	/// @returns {Undefined}
#endregion
function __bp_handle_scanning_finished(_payload) {
    obj_bp_handler.scanning = false;
    __bp_log(BP_LOG.INFO, "Scanning finished");
    
    if (obj_bp_handler.on_scanning_finished != undefined) {
        obj_bp_handler.on_scanning_finished();
    }
}

#region jsDoc
	/// @func    __bp_handle_sensor_reading()
	/// @desc    Forwards a SensorReading payload to the registered sensor callback.
	/// @param   {Struct} _payload : The SensorReading payload struct.
	/// @returns {Undefined}
#endregion
function __bp_handle_sensor_reading(_payload) {
    var _device_index = variable_struct_exists(_payload, "DeviceIndex") 
        ? _payload.DeviceIndex : -1;
    var _sensor_index = variable_struct_exists(_payload, "SensorIndex") 
        ? _payload.SensorIndex : -1;
    var _sensor_type = variable_struct_exists(_payload, "SensorType") 
        ? _payload.SensorType : "";
    var _data = variable_struct_exists(_payload, "Data") 
        ? _payload.Data : [];
    
    __bp_log(BP_LOG.DEBUG, "Sensor reading - Device " + string(_device_index) 
        + " Sensor " + string(_sensor_index) + " (" + _sensor_type + "): " 
        + string(_data));
    
    if (obj_bp_handler.on_sensor_reading != undefined) {
        obj_bp_handler.on_sensor_reading(_device_index, _sensor_index, _sensor_type, _data);
    }
}

#endregion

#region Device Parsing

#region jsDoc
	/// @func    __bp_parse_device()
	/// @desc    Converts a raw protocol device struct into the internal format.
	/// @param   {Struct} _data : The raw device payload struct.
	/// @returns {Struct|Undefined}
#endregion
function __bp_parse_device(_data) {
    if (!is_struct(_data)) { return undefined; }
    
    var _dev = {
        index:                     variable_struct_exists(_data, "DeviceIndex") ? _data.DeviceIndex : -1,
        name:                      variable_struct_exists(_data, "DeviceName") ? _data.DeviceName : "Unknown",
        display_name:              variable_struct_exists(_data, "DeviceDisplayName") ? _data.DeviceDisplayName : "",
        timing_gap:                variable_struct_exists(_data, "DeviceMessageTimingGap") ? _data.DeviceMessageTimingGap : 0,
        scalar_features:           [],
        linear_features:           [],
        rotate_features:           [],
        sensor_read_features:      [],
        sensor_subscribe_features: []
    };
    
    if (_dev.index < 0) { return undefined; }
    
    if (!variable_struct_exists(_data, "DeviceMessages")) { return _dev; }
    var _msgs = _data.DeviceMessages;
    
    if (variable_struct_exists(_msgs, "ScalarCmd")) {
        var _arr = _msgs.ScalarCmd;
        if (is_array(_arr)) {
            var _len = array_length(_arr);
            var _i = 0;
            repeat (_len) {
                var _feat = _arr[_i];
                array_push(_dev.scalar_features, {
                    index:         _i,
                    descriptor:    variable_struct_exists(_feat, "FeatureDescriptor") ? _feat.FeatureDescriptor : "",
                    actuator_type: variable_struct_exists(_feat, "ActuatorType") ? _feat.ActuatorType : "Vibrate",
                    step_count:    variable_struct_exists(_feat, "StepCount") ? _feat.StepCount : 20
                });
                _i++;
            }
        }
    }
    
    if (variable_struct_exists(_msgs, "LinearCmd")) {
        var _arr = _msgs.LinearCmd;
        if (is_array(_arr)) {
            var _len = array_length(_arr);
            var _i = 0;
            repeat (_len) {
                var _feat = _arr[_i];
                array_push(_dev.linear_features, {
                    index:         _i,
                    descriptor:    variable_struct_exists(_feat, "FeatureDescriptor") ? _feat.FeatureDescriptor : "",
                    actuator_type: variable_struct_exists(_feat, "ActuatorType") ? _feat.ActuatorType : "Linear",
                    step_count:    variable_struct_exists(_feat, "StepCount") ? _feat.StepCount : 100
                });
                _i++;
            }
        }
    }
    
    if (variable_struct_exists(_msgs, "RotateCmd")) {
        var _arr = _msgs.RotateCmd;
        if (is_array(_arr)) {
            var _len = array_length(_arr);
            var _i = 0;
            repeat (_len) {
                var _feat = _arr[_i];
                array_push(_dev.rotate_features, {
                    index:         _i,
                    descriptor:    variable_struct_exists(_feat, "FeatureDescriptor") ? _feat.FeatureDescriptor : "",
                    actuator_type: variable_struct_exists(_feat, "ActuatorType") ? _feat.ActuatorType : "Rotate",
                    step_count:    variable_struct_exists(_feat, "StepCount") ? _feat.StepCount : 20
                });
                _i++;
            }
        }
    }
    
    if (variable_struct_exists(_msgs, "SensorReadCmd")) {
        var _arr = _msgs.SensorReadCmd;
        if (is_array(_arr)) {
            var _len = array_length(_arr);
            var _i = 0;
            repeat (_len) {
                var _feat = _arr[_i];
                array_push(_dev.sensor_read_features, {
                    index:        _i,
                    descriptor:   variable_struct_exists(_feat, "FeatureDescriptor") ? _feat.FeatureDescriptor : "",
                    sensor_type:  variable_struct_exists(_feat, "SensorType") ? _feat.SensorType : "",
                    sensor_range: variable_struct_exists(_feat, "SensorRange") ? _feat.SensorRange : [[0, 100]]
                });
                _i++;
            }
        }
    }
    
    if (variable_struct_exists(_msgs, "SensorSubscribeCmd")) {
        var _arr = _msgs.SensorSubscribeCmd;
        if (is_array(_arr)) {
            var _len = array_length(_arr);
            var _i = 0;
            repeat (_len) {
                var _feat = _arr[_i];
                array_push(_dev.sensor_subscribe_features, {
                    index:        _i,
                    descriptor:   variable_struct_exists(_feat, "FeatureDescriptor") ? _feat.FeatureDescriptor : "",
                    sensor_type:  variable_struct_exists(_feat, "SensorType") ? _feat.SensorType : "",
                    sensor_range: variable_struct_exists(_feat, "SensorRange") ? _feat.SensorRange : [[0, 100]]
                });
                _i++;
            }
        }
    }
    
    return _dev;
}

#region jsDoc
	/// @func    __bp_get_device()
	/// @desc    Returns the stored device struct for a given index.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Struct|Undefined}
#endregion
function __bp_get_device(_device_index) {
    var _key = string(_device_index);
    if (variable_struct_exists(obj_bp_handler.devices, _key)) {
        return obj_bp_handler.devices[$ _key];
    }
    return undefined;
}

#endregion
