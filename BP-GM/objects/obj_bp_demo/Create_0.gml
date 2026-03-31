/// @desc Initialize demo UI state and Buttplug client

// ---- Initialize Buttplug ----
bp_init("ButtplugIO Demo");
bp_set_log_level(BP_LOG.DEBUG);

// ---- UI Layout Constants ----
ui_pad       = 8;
ui_col_w     = 320;
ui_row_h     = 28;
ui_btn_h     = 30;
ui_slider_h  = 20;
ui_font       = -1; // default font

// ---- Connection Settings ----
cfg_url         = "ws://127.0.0.1:12345";
cfg_client_name = "ButtplugIO Demo";
cfg_log_level   = BP_LOG.DEBUG;

// ---- Text Input State ----
// Which field is focused: "url", "client_name", or ""
input_focus     = "";
input_cursor_blink = 0;

// ---- Device Selection ----
selected_device = -1;

// ---- Slider State ----
// Map of "device_index:feature_type:feature_index" -> current value
slider_values = {};
// Which slider is actively being dragged (key string or "")
slider_active = "";

// ---- Log Messages ----
log_lines     = [];
log_max_lines = 12;

// ---- Scroll State ----
device_scroll = 0;

// ---- Register Callbacks ----
bp_on_connected(function() {
    __demo_log("Connected to " + bp_get_server_name());
    bp_start_scanning();
});

bp_on_disconnected(function() {
    __demo_log("Disconnected");
    selected_device = -1;
    slider_values   = {};
});

bp_on_error(function(_code, _msg) {
    __demo_log("ERROR [" + string(_code) + "]: " + _msg);
});

bp_on_device_added(function(_device_index) {
    var _name = bp_device_get_name(_device_index);
    __demo_log("Device added: " + _name + " [" + string(_device_index) + "]");
    
    // Auto-select first device
    if (selected_device < 0) {
        selected_device = _device_index;
    }
});

bp_on_device_removed(function(_device_index) {
    __demo_log("Device removed: [" + string(_device_index) + "]");
    if (selected_device == _device_index) {
        selected_device = -1;
    }
});

bp_on_scanning_finished(function() {
    __demo_log("Scanning finished");
});

bp_on_sensor_reading(function(_dev, _sensor, _type, _data) {
    __demo_log("Sensor [" + _type + "] dev " + string(_dev) + ": " + string(_data));
});

__demo_log("Demo initialized - press Connect to begin");
