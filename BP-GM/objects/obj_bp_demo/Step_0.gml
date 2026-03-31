/// @desc Handle all UI input (mouse, keyboard, text fields)

var _mouse_x = device_mouse_x_to_gui(0);
var _mouse_y = device_mouse_y_to_gui(0);
var _pressed  = mouse_check_button_pressed(mb_left);
var _held     = mouse_check_button(mb_left);
var _released = mouse_check_button_released(mb_left);

input_cursor_blink += 1;
if (input_cursor_blink > 60) { input_cursor_blink = 0; }

// Layout (must match Draw_0 exactly)
var _col_width = ui_col_w;
var _col1_x    = ui_pad;
var _col2_x    = ui_pad + _col_width + ui_pad * 3;
var _half_w    = floor((_col_width - ui_pad) / 2);
var _line_h    = 20;

// Hit test state
#macro __DEMO_HIT ((_mouse_x >= _hit_x) && (_mouse_x <= _hit_x + _hit_w) && (_mouse_y >= _hit_y) && (_mouse_y <= _hit_y + _hit_h))
var _hit_x = 0, _hit_y = 0, _hit_w = 0, _hit_h = 0;

// =================================================================
//  LEFT COLUMN
// =================================================================
var _y = ui_pad;

// Title
_y += _line_h + ui_pad;

// URL label + field
_y += _line_h;
_hit_x = _col1_x; _hit_y = _y; _hit_w = _col_width; _hit_h = ui_row_h;
if (_pressed && __DEMO_HIT) { input_focus = "url"; input_cursor_blink = 0; }
_y += ui_row_h + ui_pad;

// Client Name label + field
_y += _line_h;
_hit_x = _col1_x; _hit_y = _y; _hit_w = _col_width; _hit_h = ui_row_h;
if (_pressed && __DEMO_HIT) { input_focus = "client_name"; input_cursor_blink = 0; }
_y += ui_row_h + ui_pad;

// Log Level label + buttons
_y += _line_h;
var _levels = ["NONE", "ERROR", "WARN", "INFO", "DEBUG"];
var _lvl_count = array_length(_levels);
var _lvl_w = floor((_col_width - (_lvl_count - 1) * 4) / _lvl_count);
var _i = 0;
repeat (_lvl_count) {
    _hit_x = _col1_x + _i * (_lvl_w + 4); _hit_y = _y; _hit_w = _lvl_w; _hit_h = ui_btn_h;
    if (_pressed && __DEMO_HIT) { cfg_log_level = _i; bp_set_log_level(_i); }
    _i++;
}
_y += ui_btn_h + ui_pad;

// Connect / Disconnect
_hit_x = _col1_x; _hit_y = _y; _hit_w = _col_width; _hit_h = ui_btn_h;
if (_pressed && __DEMO_HIT) {
    if (bp_get_state() != BP_STATE.DISCONNECTED) {
        bp_disconnect();
    }
    else {
        bp_set_client_name(cfg_client_name);
        bp_connect(cfg_url);
    }
}
_y += ui_btn_h + ui_pad;

// Status (2 lines)
_y += _line_h * 2 + ui_pad;

// Start Scan / Stop Scan
_hit_x = _col1_x; _hit_y = _y; _hit_w = _half_w; _hit_h = ui_btn_h;
if (_pressed && __DEMO_HIT && bp_is_connected()) { bp_start_scanning(); }

_hit_x = _col1_x + _half_w + ui_pad; _hit_y = _y; _hit_w = _half_w; _hit_h = ui_btn_h;
if (_pressed && __DEMO_HIT && bp_is_connected()) { bp_stop_scanning(); }
_y += ui_btn_h + ui_pad;

// Stop All Devices
_hit_x = _col1_x; _hit_y = _y; _hit_w = _col_width; _hit_h = ui_btn_h;
if (_pressed && __DEMO_HIT && bp_is_connected()) {
    bp_stop_all_devices();
    var _skeys = variable_struct_get_names(slider_values);
    var _skey_count = array_length(_skeys);
    var _j = 0;
    repeat (_skey_count) {
        slider_values[$ _skeys[_j]] = 0;
        _j++;
    }
    __demo_log("Emergency stop - all sliders reset");
}
_y += ui_btn_h + ui_pad * 2;

// Devices header
_y += _line_h + 4;

// Device list
var _dev_list   = bp_get_device_list();
var _dev_count  = array_length(_dev_list);
var _dev_item_h = 36;
var _dev_vis    = min(_dev_count, 6);

_i = 0;
repeat (_dev_vis) {
    var _dev_i = _i + device_scroll;
    if (_dev_i >= _dev_count) { break; }
    _hit_x = _col1_x; _hit_y = _y + _i * _dev_item_h; _hit_w = _col_width; _hit_h = _dev_item_h - 2;
    if (_pressed && __DEMO_HIT) { selected_device = _dev_list[_dev_i]; }
    _i++;
}

var _dev_area_h = _dev_vis * _dev_item_h;
if (_mouse_x >= _col1_x) && (_mouse_x <= _col1_x + _col_width) && (_mouse_y >= _y) && (_mouse_y <= _y + _dev_area_h) {
    if (mouse_wheel_down()) { device_scroll = min(device_scroll + 1, max(0, _dev_count - 6)); }
    if (mouse_wheel_up())   { device_scroll = max(device_scroll - 1, 0); }
}

// =================================================================
//  RIGHT COLUMN - Device Controls
// =================================================================
if (selected_device >= 0 && bp_device_exists(selected_device)) {
    var _right_y = ui_pad;
    _right_y += _line_h + ui_pad;  // device name
    _right_y += _line_h + ui_pad;  // timing gap
    
    // Stop Device
    _hit_x = _col2_x; _hit_y = _right_y; _hit_w = _half_w; _hit_h = ui_btn_h;
    if (_pressed && __DEMO_HIT) {
        bp_device_stop(selected_device);
        var _skeys = variable_struct_get_names(slider_values);
        var _skey_count = array_length(_skeys);
        var _j = 0;
        repeat (_skey_count) {
            if (string_pos(string(selected_device) + ":", _skeys[_j]) == 1) {
                slider_values[$ _skeys[_j]] = 0;
            }
            _j++;
        }
    }
    
    // Read Battery
    _hit_x = _col2_x + _half_w + ui_pad; _hit_y = _right_y; _hit_w = _half_w; _hit_h = ui_btn_h;
    if (_pressed && __DEMO_HIT && bp_device_has_input(selected_device, BP_INPUT_BATTERY)) {
        bp_device_battery_read(selected_device);
    }
    _right_y += ui_btn_h + ui_pad * 2;
    
    // Features header
    _right_y += _line_h + 4;
    
    // Scalar sliders
    var _scalar_feats = bp_device_get_scalar_features(selected_device);
    var _scalar_count = array_length(_scalar_feats);
    _i = 0;
    repeat (_scalar_count) {
        var _skey = string(selected_device) + ":scalar:" + string(_i);
        _right_y += _line_h;
        _hit_x = _col2_x; _hit_y = _right_y; _hit_w = _col_width; _hit_h = ui_slider_h;
        if (_pressed && __DEMO_HIT) { slider_active = _skey; }
        if (slider_active == _skey && _held) { slider_values[$ _skey] = clamp((_mouse_x - _hit_x) / _hit_w, 0, 1); }
        _right_y += ui_slider_h + ui_pad;
        _i++;
    }
    
    // Rotate sliders
    var _rotate_feats = bp_device_get_rotate_features(selected_device);
    var _rotate_count = array_length(_rotate_feats);
    _i = 0;
    repeat (_rotate_count) {
        var _skey = string(selected_device) + ":rotate:" + string(_i);
        _right_y += _line_h;
        _hit_x = _col2_x; _hit_y = _right_y; _hit_w = _col_width; _hit_h = ui_slider_h;
        if (_pressed && __DEMO_HIT) { slider_active = _skey; }
        if (slider_active == _skey && _held) { slider_values[$ _skey] = clamp((_mouse_x - _hit_x) / _hit_w, 0, 1) * 2 - 1; }
        _right_y += ui_slider_h + ui_pad;
        _i++;
    }
    
    // Linear sliders
    var _linear_feats = bp_device_get_linear_features(selected_device);
    var _linear_count = array_length(_linear_feats);
    _i = 0;
    repeat (_linear_count) {
        var _skey = string(selected_device) + ":linear:" + string(_i);
        _right_y += _line_h;
        _hit_x = _col2_x; _hit_y = _right_y; _hit_w = _col_width; _hit_h = ui_slider_h;
        if (_pressed && __DEMO_HIT) { slider_active = _skey; }
        if (slider_active == _skey && _held) { slider_values[$ _skey] = clamp((_mouse_x - _hit_x) / _hit_w, 0, 1); }
        _right_y += ui_slider_h + ui_pad;
        _i++;
    }
}

// Live slider command dispatch
if (slider_active != "" && _held) {
    var _value = variable_struct_exists(slider_values, slider_active) ? slider_values[$ slider_active] : 0;
    var _parts = string_split(slider_active, ":");
    if (array_length(_parts) >= 3) {
        var _dev_idx  = real(_parts[0]);
        var _cmd_type = _parts[1];
        var _feat_idx = real(_parts[2]);
        switch (_cmd_type) {
            case "scalar":
                var _feats = bp_device_get_scalar_features(_dev_idx);
                if (_feat_idx < array_length(_feats)) { bp_device_scalar(_dev_idx, _feat_idx, _value, _feats[_feat_idx].actuator_type); }
                break;
            case "rotate":
                bp_device_rotate_feature(_dev_idx, _feat_idx, _value);
                break;
            case "linear":
                bp_device_linear_feature(_dev_idx, _feat_idx, _value, 100);
                break;
        }
    }
}

if (_released) { slider_active = ""; }

// Keyboard text input
if (input_focus != "") {
    if (keyboard_check_pressed(vk_escape) || keyboard_check_pressed(vk_enter)) {
        input_focus = "";
    }
    else if (keyboard_check_pressed(vk_backspace)) {
        if (input_focus == "url" && string_length(cfg_url) > 0) {
            cfg_url = string_delete(cfg_url, string_length(cfg_url), 1);
        }
        else if (input_focus == "client_name" && string_length(cfg_client_name) > 0) {
            cfg_client_name = string_delete(cfg_client_name, string_length(cfg_client_name), 1);
        }
    }
    else {
        var _char = keyboard_string;
        if (string_length(_char) > 0) {
            if (input_focus == "url") { cfg_url += _char; }
            else if (input_focus == "client_name") { cfg_client_name += _char; }
        }
    }
    keyboard_string = "";
}
