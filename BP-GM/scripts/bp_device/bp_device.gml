#region Device Enumeration

#region jsDoc
	/// @func    bp_get_device_count()
	/// @desc    Returns the number of currently known connected devices.
	/// @returns {Real}
#endregion
function bp_get_device_count() {
    if (!instance_exists(obj_bp_handler)) { return 0; }
    return array_length(variable_struct_get_names(obj_bp_handler.devices));
}

#region jsDoc
	/// @func    bp_get_device_list()
	/// @desc    Returns an array of all connected device indices.
	/// @returns {Array<Real>}
#endregion
function bp_get_device_list() {
    if (!instance_exists(obj_bp_handler)) { return []; }
    var _keys  = variable_struct_get_names(obj_bp_handler.devices);
    var _count = array_length(_keys);
    var _result = array_create(_count);
    var _i = 0;
    repeat (_count) {
        _result[_i] = real(_keys[_i]);
        _i++;
    }
    return _result;
}

#region jsDoc
	/// @func    bp_device_exists()
	/// @desc    Returns whether a device index currently exists in the client state.
	/// @param   {Real} _device_index : The device index to check.
	/// @returns {Bool}
#endregion
function bp_device_exists(_device_index) {
    if (!instance_exists(obj_bp_handler)) { return false; }
    return variable_struct_exists(obj_bp_handler.devices, string(_device_index));
}

#endregion

#region Device Identity

#region jsDoc
	/// @func    bp_device_get_name()
	/// @desc    Returns the protocol name for a device.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {String}
#endregion
function bp_device_get_name(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? _dev.name : "";
}

#region jsDoc
	/// @func    bp_device_get_display_name()
	/// @desc    Returns the user-facing display name for a device.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {String}
#endregion
function bp_device_get_display_name(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? _dev.display_name : "";
}

#region jsDoc
	/// @func    bp_device_get_timing_gap()
	/// @desc    Returns the recommended minimum delay between device messages in milliseconds.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Real}
#endregion
function bp_device_get_timing_gap(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? _dev.timing_gap : 0;
}

#endregion

#region Capability Queries

#region jsDoc
	/// @func    bp_device_has_output()
	/// @desc    Returns whether a device exposes at least one output feature of the requested type.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {String} _output_type : The output type constant to test.
	/// @returns {Bool}
#endregion
function bp_device_has_output(_device_index, _output_type) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return false; }
    
    switch (_output_type) {
        case BP_OUTPUT_ROTATE:
            return (array_length(_dev.rotate_features) > 0);
        case BP_OUTPUT_LINEAR:
        case BP_OUTPUT_POSITION:
            return (array_length(_dev.linear_features) > 0);
        default:
            var _count = array_length(_dev.scalar_features);
            var _i = 0;
            repeat (_count) {
                if (_dev.scalar_features[_i].actuator_type == _output_type) { return true; }
                _i++;
            }
            return false;
    }
}

#region jsDoc
	/// @func    bp_device_has_input()
	/// @desc    Returns whether a device exposes a readable or subscribable input of the requested type.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {String} _input_type : The input type constant to test.
	/// @returns {Bool}
#endregion
function bp_device_has_input(_device_index, _input_type) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return false; }
    
    var _count = array_length(_dev.sensor_read_features);
    var _i = 0;
    repeat (_count) {
        if (_dev.sensor_read_features[_i].sensor_type == _input_type) { return true; }
        _i++;
    }
    
    var _sub_count = array_length(_dev.sensor_subscribe_features);
    _i = 0;
    repeat (_sub_count) {
        if (_dev.sensor_subscribe_features[_i].sensor_type == _input_type) { return true; }
        _i++;
    }
    
    return false;
}

#region jsDoc
	/// @func    bp_device_get_scalar_feature_count()
	/// @desc    Returns how many scalar output features the device has.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Real}
#endregion
function bp_device_get_scalar_feature_count(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? array_length(_dev.scalar_features) : 0;
}

#region jsDoc
	/// @func    bp_device_get_linear_feature_count()
	/// @desc    Returns how many linear output features the device has.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Real}
#endregion
function bp_device_get_linear_feature_count(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? array_length(_dev.linear_features) : 0;
}

#region jsDoc
	/// @func    bp_device_get_rotate_feature_count()
	/// @desc    Returns how many rotate output features the device has.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Real}
#endregion
function bp_device_get_rotate_feature_count(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? array_length(_dev.rotate_features) : 0;
}

#region jsDoc
	/// @func    bp_device_get_scalar_features()
	/// @desc    Returns the stored scalar feature structs for a device.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Array}
#endregion
function bp_device_get_scalar_features(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? _dev.scalar_features : [];
}

#region jsDoc
	/// @func    bp_device_get_linear_features()
	/// @desc    Returns the stored linear feature structs for a device.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Array}
#endregion
function bp_device_get_linear_features(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? _dev.linear_features : [];
}

#region jsDoc
	/// @func    bp_device_get_rotate_features()
	/// @desc    Returns the stored rotate feature structs for a device.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Array}
#endregion
function bp_device_get_rotate_features(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? _dev.rotate_features : [];
}

#region jsDoc
	/// @func    bp_device_get_sensor_features()
	/// @desc    Returns the readable sensor feature structs for a device.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Array}
#endregion
function bp_device_get_sensor_features(_device_index) {
    var _dev = __bp_get_device(_device_index);
    return (_dev != undefined) ? _dev.sensor_read_features : [];
}

#region jsDoc
	/// @func    bp_device_get_scalar_step_count()
	/// @desc    Returns the reported step count for one scalar feature.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _feature_index : The scalar feature array index.
	/// @returns {Real}
#endregion
function bp_device_get_scalar_step_count(_device_index, _feature_index) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return 0; }
    if (_feature_index < 0 || _feature_index >= array_length(_dev.scalar_features)) { return 0; }
    return _dev.scalar_features[_feature_index].step_count;
}

#endregion

#region Scalar Commands

#region jsDoc
	/// @func    bp_device_vibrate()
	/// @desc    Sends one vibration value to all vibrate features on a device.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_vibrate(_device_index, _value) {
    __bp_device_scalar_by_type(_device_index, BP_OUTPUT_VIBRATE, clamp(_value, 0, 1));
}

#region jsDoc
	/// @func    bp_device_vibrate_feature()
	/// @desc    Sends one vibration value to a specific vibrate feature.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _feature_index : The scalar feature array index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_vibrate_feature(_device_index, _feature_index, _value) {
    __bp_device_scalar_single(_device_index, _feature_index, clamp(_value, 0, 1), BP_OUTPUT_VIBRATE);
}

#region jsDoc
	/// @func    bp_device_oscillate()
	/// @desc    Sends one oscillation value to all oscillate features on a device.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_oscillate(_device_index, _value) {
    __bp_device_scalar_by_type(_device_index, BP_OUTPUT_OSCILLATE, clamp(_value, 0, 1));
}

#region jsDoc
	/// @func    bp_device_oscillate_feature()
	/// @desc    Sends one oscillation value to a specific oscillate feature.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _feature_index : The scalar feature array index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_oscillate_feature(_device_index, _feature_index, _value) {
    __bp_device_scalar_single(_device_index, _feature_index, clamp(_value, 0, 1), BP_OUTPUT_OSCILLATE);
}

#region jsDoc
	/// @func    bp_device_constrict()
	/// @desc    Sends one constrict value to all constrict features on a device.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_constrict(_device_index, _value) {
    __bp_device_scalar_by_type(_device_index, BP_OUTPUT_CONSTRICT, clamp(_value, 0, 1));
}

#region jsDoc
	/// @func    bp_device_constrict_feature()
	/// @desc    Sends one constrict value to a specific constrict feature.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _feature_index : The scalar feature array index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_constrict_feature(_device_index, _feature_index, _value) {
    __bp_device_scalar_single(_device_index, _feature_index, clamp(_value, 0, 1), BP_OUTPUT_CONSTRICT);
}

#region jsDoc
	/// @func    bp_device_inflate()
	/// @desc    Sends one inflate value to all inflate features on a device.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_inflate(_device_index, _value) {
    __bp_device_scalar_by_type(_device_index, BP_OUTPUT_INFLATE, clamp(_value, 0, 1));
}

#region jsDoc
	/// @func    bp_device_inflate_feature()
	/// @desc    Sends one inflate value to a specific inflate feature.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _feature_index : The scalar feature array index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_inflate_feature(_device_index, _feature_index, _value) {
    __bp_device_scalar_single(_device_index, _feature_index, clamp(_value, 0, 1), BP_OUTPUT_INFLATE);
}

#region jsDoc
	/// @func    bp_device_scalar()
	/// @desc    Sends one scalar value to a specific scalar feature using the supplied actuator type.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _feature_index : The scalar feature array index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @param   {String} _actuator_type : The actuator type to include in the command.
	/// @returns {Undefined}
#endregion
function bp_device_scalar(_device_index, _feature_index, _value, _actuator_type) {
    __bp_device_scalar_single(_device_index, _feature_index, clamp(_value, 0, 1), _actuator_type);
}

#endregion

#region Rotation Commands

#region jsDoc
	/// @func    bp_device_rotate()
	/// @desc    Rotates all rotate features on a device. Sign controls direction, magnitude controls speed.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _value : The signed speed from -1 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_rotate(_device_index, _value) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return; }
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    
    var _speed     = clamp(abs(_value), 0, 1);
    var _clockwise = (_value >= 0);
    var _rotations = [];
    var _count     = array_length(_dev.rotate_features);
    
    var _i = 0;
    repeat (_count) {
        array_push(_rotations, {
            Index:     _dev.rotate_features[_i].index,
            Speed:     _speed,
            Clockwise: _clockwise
        });
        _i++;
    }
    
    if (array_length(_rotations) > 0) {
        __bp_send(__bp_msg_rotate_cmd(_device_index, _rotations));
    }
}

#region jsDoc
	/// @func    bp_device_rotate_feature()
	/// @desc    Rotates one specific rotate feature. Sign controls direction, magnitude controls speed.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _feature_index : The rotate feature array index.
	/// @param   {Real} _value : The signed speed from -1 to 1.
	/// @returns {Undefined}
#endregion
function bp_device_rotate_feature(_device_index, _feature_index, _value) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return; }
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    if (_feature_index < 0 || _feature_index >= array_length(_dev.rotate_features)) { return; }
    
    var _speed     = clamp(abs(_value), 0, 1);
    var _clockwise = (_value >= 0);
    
    __bp_send(__bp_msg_rotate_cmd(_device_index, [{
        Index:     _dev.rotate_features[_feature_index].index,
        Speed:     _speed,
        Clockwise: _clockwise
    }]));
}

#endregion

#region Linear Commands

#region jsDoc
	/// @func    bp_device_linear()
	/// @desc    Moves all linear features on a device to a position over a duration.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _position : The target position from 0 to 1.
	/// @param   {Real} _duration_ms : The travel time in milliseconds.
	/// @returns {Undefined}
#endregion
function bp_device_linear(_device_index, _position, _duration_ms) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return; }
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    
    var _pos     = clamp(_position, 0, 1);
    var _dur     = max(0, _duration_ms);
    var _vectors = [];
    var _count   = array_length(_dev.linear_features);
    
    var _i = 0;
    repeat (_count) {
        array_push(_vectors, {
            Index:    _dev.linear_features[_i].index,
            Duration: _dur,
            Position: _pos
        });
        _i++;
    }
    
    if (array_length(_vectors) > 0) {
        __bp_send(__bp_msg_linear_cmd(_device_index, _vectors));
    }
}

#region jsDoc
	/// @func    bp_device_linear_feature()
	/// @desc    Moves one linear feature on a device to a position over a duration.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _feature_index : The linear feature array index.
	/// @param   {Real} _position : The target position from 0 to 1.
	/// @param   {Real} _duration_ms : The travel time in milliseconds.
	/// @returns {Undefined}
#endregion
function bp_device_linear_feature(_device_index, _feature_index, _position, _duration_ms) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return; }
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    if (_feature_index < 0 || _feature_index >= array_length(_dev.linear_features)) { return; }
    
    __bp_send(__bp_msg_linear_cmd(_device_index, [{
        Index:    _dev.linear_features[_feature_index].index,
        Duration: max(0, _duration_ms),
        Position: clamp(_position, 0, 1)
    }]));
}

#endregion

#region Stop Commands

#region jsDoc
	/// @func    bp_device_stop()
	/// @desc    Stops all active actions on a single device.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Undefined}
#endregion
function bp_device_stop(_device_index) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_device_stop() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    if (!bp_device_exists(_device_index)) { return; }
    
    __bp_send(__bp_msg_stop_device(_device_index));
}

#endregion

#region Sensor Commands

#region jsDoc
	/// @func    bp_device_battery_read()
	/// @desc    Requests one battery reading from a device if a battery sensor exists.
	/// @param   {Real} _device_index : The target device index.
	/// @returns {Undefined}
#endregion
function bp_device_battery_read(_device_index) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return; }
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    
    var _count = array_length(_dev.sensor_read_features);
    var _i = 0;
    repeat (_count) {
        if (_dev.sensor_read_features[_i].sensor_type == BP_INPUT_BATTERY) {
            __bp_send(__bp_msg_sensor_read(
                _device_index,
                _dev.sensor_read_features[_i].index,
                BP_INPUT_BATTERY
            ));
            return;
        }
        _i++;
    }
    
    __bp_log(BP_LOG.WARN, "Device " + string(_device_index) + " has no battery sensor");
}

#region jsDoc
	/// @func    bp_device_sensor_read()
	/// @desc    Requests one reading from a specific sensor.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _sensor_index : The sensor feature array index.
	/// @param   {String} _sensor_type : The sensor type string.
	/// @returns {Undefined}
#endregion
function bp_device_sensor_read(_device_index, _sensor_index, _sensor_type) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_device_sensor_read() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    if (!bp_device_exists(_device_index)) { return; }
    
    __bp_send(__bp_msg_sensor_read(_device_index, _sensor_index, _sensor_type));
}

#region jsDoc
	/// @func    bp_device_sensor_subscribe()
	/// @desc    Starts continuous updates for a specific sensor.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _sensor_index : The sensor feature array index.
	/// @param   {String} _sensor_type : The sensor type string.
	/// @returns {Undefined}
#endregion
function bp_device_sensor_subscribe(_device_index, _sensor_index, _sensor_type) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_device_sensor_subscribe() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    if (!bp_device_exists(_device_index)) { return; }
    
    __bp_send(__bp_msg_sensor_subscribe(_device_index, _sensor_index, _sensor_type));
}

#region jsDoc
	/// @func    bp_device_sensor_unsubscribe()
	/// @desc    Stops continuous updates for a specific sensor.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _sensor_index : The sensor feature array index.
	/// @param   {String} _sensor_type : The sensor type string.
	/// @returns {Undefined}
#endregion
function bp_device_sensor_unsubscribe(_device_index, _sensor_index, _sensor_type) {
    if (!instance_exists(obj_bp_handler)) {
		__bp_log(BP_LOG.WARN, "bp_device_sensor_unsubscribe() called but handler doesnt exists, you must call bp_init() first");
		return;
	}
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    if (!bp_device_exists(_device_index)) { return; }
    
    __bp_send(__bp_msg_sensor_unsubscribe(_device_index, _sensor_index, _sensor_type));
}

#endregion

#region Internal Scalar Helpers

#region jsDoc
	/// @func    __bp_device_scalar_by_type()
	/// @desc    Sends one scalar value to every feature matching an actuator type.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {String} _actuator_type : The actuator type to match.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @returns {Undefined}
#endregion
function __bp_device_scalar_by_type(_device_index, _actuator_type, _value) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return; }
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    
    var _scalars = [];
    var _count   = array_length(_dev.scalar_features);
    
    var _i = 0;
    repeat (_count) {
        var _feat = _dev.scalar_features[_i];
        if (_feat.actuator_type == _actuator_type) {
            array_push(_scalars, {
                Index:        _feat.index,
                Scalar:       _value,
                ActuatorType: _actuator_type
            });
        }
        _i++;
    }
    
    if (array_length(_scalars) > 0) {
        __bp_send(__bp_msg_scalar_cmd(_device_index, _scalars));
    }
    else {
        __bp_log(BP_LOG.WARN, "Device " + string(_device_index) 
            + " has no " + _actuator_type + " features");
    }
}

#region jsDoc
	/// @func    __bp_device_scalar_single()
	/// @desc    Sends one scalar value to a single scalar feature.
	/// @param   {Real} _device_index : The target device index.
	/// @param   {Real} _feature_index : The scalar feature array index.
	/// @param   {Real} _value : The strength from 0 to 1.
	/// @param   {String} _actuator_type : The actuator type to include in the command.
	/// @returns {Undefined}
#endregion
function __bp_device_scalar_single(_device_index, _feature_index, _value, _actuator_type) {
    var _dev = __bp_get_device(_device_index);
    if (_dev == undefined) { return; }
    if (obj_bp_handler.state != BP_STATE.CONNECTED) { return; }
    if (_feature_index < 0 || _feature_index >= array_length(_dev.scalar_features)) { return; }
    
    var _feat = _dev.scalar_features[_feature_index];
    
    __bp_send(__bp_msg_scalar_cmd(_device_index, [{
        Index:        _feat.index,
        Scalar:       _value,
        ActuatorType: _actuator_type
    }]));
}

#endregion
