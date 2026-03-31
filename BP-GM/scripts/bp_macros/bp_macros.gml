// ---------------------------------------------------------------------------
// Output Types (Actuators) - match Buttplug protocol ActuatorType strings
// Used with bp_device_has_output() and bp_device_scalar()
// ---------------------------------------------------------------------------
#macro BP_OUTPUT_VIBRATE     "Vibrate"
#macro BP_OUTPUT_ROTATE      "Rotate"
#macro BP_OUTPUT_OSCILLATE   "Oscillate"
#macro BP_OUTPUT_CONSTRICT   "Constrict"
#macro BP_OUTPUT_INFLATE     "Inflate"
#macro BP_OUTPUT_POSITION    "Position"
#macro BP_OUTPUT_LINEAR      "Linear"

// ---------------------------------------------------------------------------
// Input Types (Sensors) - match Buttplug protocol SensorType strings
// Used with bp_device_has_input() and bp_device_sensor_read()
// ---------------------------------------------------------------------------
#macro BP_INPUT_BATTERY      "Battery"
#macro BP_INPUT_RSSI         "RSSI"
#macro BP_INPUT_BUTTON       "Button"
#macro BP_INPUT_PRESSURE     "Pressure"

// ---------------------------------------------------------------------------
// Connection States
// Returned by bp_get_state()
// ---------------------------------------------------------------------------
enum BP_STATE {
	DISCONNECTED = 0,
	CONNECTING   = 1,
	HANDSHAKING  = 2,
	CONNECTED    = 3
}

// ---------------------------------------------------------------------------
// Log Levels
// Used with bp_set_log_level()
// ---------------------------------------------------------------------------
enum BP_LOG {
	NONE  = 0,
	ERROR = 1,
	WARN  = 2,
	INFO  = 3,
	DEBUG = 4
}


// ---------------------------------------------------------------------------
// Error Codes (from Buttplug protocol)
// ---------------------------------------------------------------------------
enum BP_ERROR {
	UNKNOWN = 0,
	INIT    = 1,
	PING    = 2,
	MSG     = 3,
	DEVICE  = 4
}
