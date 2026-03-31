/// @desc Render the Buttplug demo UI

draw_set_font(ui_font);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Layout (must match Step_0 exactly)
var _col_width = ui_col_w;
var _col1_x    = ui_pad;
var _col2_x    = ui_pad + _col_width + ui_pad * 3;
var _half_w    = floor((_col_width - ui_pad) / 2);
var _line_h    = 20;

// Colors
var _c_bg      = #1a1a2e;
var _c_panel   = #16213e;
var _c_field   = #0f0f23;
var _c_focus   = #1a1a4e;
var _c_btn     = #2a4a7f;
var _c_btn_act = #1e90ff;
var _c_danger  = #c0392b;
var _c_success = #27ae60;
var _c_warn    = #f39c12;
var _c_text    = #e0e0e0;
var _c_dim     = #808080;
var _c_slider  = #333355;
var _c_thumb   = #5599ff;
var _c_sel     = #2a4a7f;

// Background
draw_set_color(_c_bg);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

// =================================================================
//  LEFT COLUMN
// =================================================================
var _y = ui_pad;

// Title
draw_set_color(_c_text);
draw_text(_col1_x, _y, "BUTTPLUG.IO  -  GAMEMAKER DEMO");
_y += _line_h + ui_pad;

// URL
draw_set_color(_c_dim);
draw_text(_col1_x, _y, "Server URL:");
_y += _line_h;

draw_set_color((input_focus == "url") ? _c_focus : _c_field);
draw_rectangle(_col1_x, _y, _col1_x + _col_width, _y + ui_row_h, false);
draw_set_color(_c_text);
var _url_str = cfg_url;
if (input_focus == "url" && (input_cursor_blink mod 40) < 20) { _url_str += "|"; }
draw_text(_col1_x + 4, _y + 6, _url_str);
_y += ui_row_h + ui_pad;

// Client Name
draw_set_color(_c_dim);
draw_text(_col1_x, _y, "Client Name:");
_y += _line_h;

draw_set_color((input_focus == "client_name") ? _c_focus : _c_field);
draw_rectangle(_col1_x, _y, _col1_x + _col_width, _y + ui_row_h, false);
draw_set_color(_c_text);
var _name_str = cfg_client_name;
if (input_focus == "client_name" && (input_cursor_blink mod 40) < 20) { _name_str += "|"; }
draw_text(_col1_x + 4, _y + 6, _name_str);
_y += ui_row_h + ui_pad;

// Log Level
draw_set_color(_c_dim);
draw_text(_col1_x, _y, "Log Level:");
_y += _line_h;

var _levels = ["NONE", "ERROR", "WARN", "INFO", "DEBUG"];
var _lvl_count = array_length(_levels);
var _lvl_w = floor((_col_width - (_lvl_count - 1) * 4) / _lvl_count);
var _i = 0;
repeat (_lvl_count) {
    var _btn_x = _col1_x + _i * (_lvl_w + 4);
    draw_set_color((_i == cfg_log_level) ? _c_btn_act : _c_btn);
    draw_rectangle(_btn_x, _y, _btn_x + _lvl_w, _y + ui_btn_h, false);
    draw_set_color(_c_text);
    draw_set_halign(fa_center);  draw_set_valign(fa_middle);
    draw_text(_btn_x + _lvl_w / 2, _y + ui_btn_h / 2, _levels[_i]);
    _i++;
}
draw_set_halign(fa_left);  draw_set_valign(fa_top);
_y += ui_btn_h + ui_pad;

// Connect / Disconnect
var _bp_state  = bp_get_state();
var _connected = (_bp_state != BP_STATE.DISCONNECTED);
draw_set_color(_connected ? _c_danger : _c_success);
draw_rectangle(_col1_x, _y, _col1_x + _col_width, _y + ui_btn_h, false);
draw_set_color(_c_text);
draw_set_halign(fa_center);  draw_set_valign(fa_middle);
draw_text(_col1_x + _col_width / 2, _y + ui_btn_h / 2, _connected ? "Disconnect" : "Connect");
draw_set_halign(fa_left);  draw_set_valign(fa_top);
_y += ui_btn_h + ui_pad;

// Status
var _state_names  = ["Disconnected", "Connecting...", "Handshaking...", "Connected"];
var _state_colors = [_c_dim, _c_warn, _c_warn, _c_success];
var _state_idx = clamp(_bp_state, 0, 3);
draw_set_color(_c_dim);
draw_text(_col1_x, _y, "Status: ");
draw_set_color(_state_colors[_state_idx]);
draw_text(_col1_x + string_width("Status: "), _y, _state_names[_state_idx]);
_y += _line_h;

if (_bp_state == BP_STATE.CONNECTED) {
    draw_set_color(_c_dim);
    draw_text(_col1_x, _y, "Server: " + bp_get_server_name());
}
_y += _line_h + ui_pad;

// Scan Buttons
var _scan_ok = bp_is_connected();
draw_set_color(_scan_ok ? _c_btn : _c_slider);
draw_rectangle(_col1_x, _y, _col1_x + _half_w, _y + ui_btn_h, false);
draw_set_color(_c_text);
draw_set_halign(fa_center);  draw_set_valign(fa_middle);
draw_text(_col1_x + _half_w / 2, _y + ui_btn_h / 2, "Start Scan");

draw_set_color(_scan_ok ? _c_btn : _c_slider);
draw_rectangle(_col1_x + _half_w + ui_pad, _y, _col1_x + _col_width, _y + ui_btn_h, false);
draw_set_color(_c_text);
draw_text(_col1_x + _half_w + ui_pad + _half_w / 2, _y + ui_btn_h / 2, "Stop Scan");
draw_set_halign(fa_left);  draw_set_valign(fa_top);

if (bp_is_scanning()) {
    draw_set_color(_c_warn);
    var _dots = string_repeat(".", (current_time div 400) mod 4);
    draw_text(_col1_x + _col_width + ui_pad, _y + 7, "scanning" + _dots);
}
_y += ui_btn_h + ui_pad;

// Stop All
draw_set_color(_scan_ok ? _c_danger : _c_slider);
draw_rectangle(_col1_x, _y, _col1_x + _col_width, _y + ui_btn_h, false);
draw_set_color(_c_text);
draw_set_halign(fa_center);  draw_set_valign(fa_middle);
draw_text(_col1_x + _col_width / 2, _y + ui_btn_h / 2, "STOP ALL DEVICES");
draw_set_halign(fa_left);  draw_set_valign(fa_top);
_y += ui_btn_h + ui_pad * 2;

// Device List
draw_set_color(_c_text);
var _dev_count = bp_get_device_count();
draw_text(_col1_x, _y, "Devices (" + string(_dev_count) + "):");
_y += _line_h + 4;

var _dev_list   = bp_get_device_list();
var _dev_item_h = 36;
var _dev_vis    = min(_dev_count, 6);

if (_dev_count == 0) {
    draw_set_color(_c_dim);
    draw_text(_col1_x + 8, _y + 4, _scan_ok ? "No devices found" : "Not connected");
}
else {
    _i = 0;
    repeat (_dev_vis) {
        var _dev_i = _i + device_scroll;
        if (_dev_i >= _dev_count) { break; }
        
        var _dev_idx  = _dev_list[_dev_i];
        var _dev_name = bp_device_get_name(_dev_idx);
        var _disp     = bp_device_get_display_name(_dev_idx);
        if (_disp != "") { _dev_name = _disp + " (" + _dev_name + ")"; }
        
        var _item_y = _y + _i * _dev_item_h;
        
        draw_set_color((_dev_idx == selected_device) ? _c_sel : _c_panel);
        draw_rectangle(_col1_x, _item_y, _col1_x + _col_width, _item_y + _dev_item_h - 2, false);
        
        draw_set_color(_c_text);
        draw_text(_col1_x + 6, _item_y + 3, "[" + string(_dev_idx) + "] " + _dev_name);
        
        // Feature summary
        var _tags = "";
        var _scalar_count = bp_device_get_scalar_feature_count(_dev_idx);
        var _linear_count = bp_device_get_linear_feature_count(_dev_idx);
        var _rotate_count = bp_device_get_rotate_feature_count(_dev_idx);
        if (_scalar_count > 0) { _tags += string(_scalar_count) + " scalar"; }
        if (_linear_count > 0) { if (_tags != "") { _tags += " | "; } _tags += string(_linear_count) + " linear"; }
        if (_rotate_count > 0) { if (_tags != "") { _tags += " | "; } _tags += string(_rotate_count) + " rotate"; }
        if (bp_device_has_input(_dev_idx, BP_INPUT_BATTERY)) {
            if (_tags != "") { _tags += " | "; }
            _tags += "battery";
        }
        
        draw_set_color(_c_dim);
        draw_text(_col1_x + 20, _item_y + 19, _tags);
        _i++;
    }
    
    if (_dev_count > 6) {
        draw_set_color(_c_dim);
        var _scroll_txt = string(device_scroll + 1) + "-" + string(min(device_scroll + 6, _dev_count)) + " of " + string(_dev_count);
        draw_text(_col1_x + _col_width - string_width(_scroll_txt), _y + _dev_vis * _dev_item_h + 2, _scroll_txt);
    }
}

// =================================================================
//  RIGHT COLUMN - Device Controls
// =================================================================
if (selected_device >= 0 && bp_device_exists(selected_device)) {
    var _right_y = ui_pad;
    
    var _dev_name = bp_device_get_name(selected_device);
    var _disp     = bp_device_get_display_name(selected_device);
    if (_disp != "") { _dev_name = _disp; }
    
    draw_set_color(_c_text);
    draw_text(_col2_x, _right_y, "Device: " + _dev_name + "  [" + string(selected_device) + "]");
    _right_y += _line_h + ui_pad;
    
    draw_set_color(_c_dim);
    draw_text(_col2_x, _right_y, "Timing gap: " + string(bp_device_get_timing_gap(selected_device)) + "ms");
    _right_y += _line_h + ui_pad;
    
    // Stop / Battery
    draw_set_color(_c_danger);
    draw_rectangle(_col2_x, _right_y, _col2_x + _half_w, _right_y + ui_btn_h, false);
    draw_set_color(_c_text);
    draw_set_halign(fa_center);  draw_set_valign(fa_middle);
    draw_text(_col2_x + _half_w / 2, _right_y + ui_btn_h / 2, "Stop Device");
    
    var _has_batt = bp_device_has_input(selected_device, BP_INPUT_BATTERY);
    draw_set_color(_has_batt ? _c_btn : _c_slider);
    draw_rectangle(_col2_x + _half_w + ui_pad, _right_y, _col2_x + _col_width, _right_y + ui_btn_h, false);
    draw_set_color(_c_text);
    draw_text(_col2_x + _half_w + ui_pad + _half_w / 2, _right_y + ui_btn_h / 2, "Read Battery");
    draw_set_halign(fa_left);  draw_set_valign(fa_top);
    _right_y += ui_btn_h + ui_pad * 2;
    
    // Features Header
    draw_set_color(_c_text);
    draw_text(_col2_x, _right_y, "Features:");
    _right_y += _line_h + 4;
    
    var _any_features = false;
    
    // Scalar Sliders
    var _scalar_feats = bp_device_get_scalar_features(selected_device);
    var _scalar_count = array_length(_scalar_feats);
    _i = 0;
    repeat (_scalar_count) {
        _any_features = true;
        var _feat = _scalar_feats[_i];
        var _skey = string(selected_device) + ":scalar:" + string(_i);
        var _value = variable_struct_exists(slider_values, _skey) ? slider_values[$ _skey] : 0;
        
        var _label = _feat.actuator_type;
        if (_feat.descriptor != "") { _label += " - " + _feat.descriptor; }
        _label += "  (" + string(_feat.step_count) + " steps)";
        draw_set_color(_c_dim);
        draw_text(_col2_x, _right_y, _label);
        _right_y += _line_h;
        
        // Track
        draw_set_color(_c_slider);
        draw_rectangle(_col2_x, _right_y, _col2_x + _col_width, _right_y + ui_slider_h, false);
        // Fill
        if (_value > 0) {
            draw_set_color(_c_thumb);
            draw_rectangle(_col2_x, _right_y, _col2_x + _col_width * _value, _right_y + ui_slider_h, false);
        }
        // Percent
        draw_set_color(_c_text);
        draw_set_halign(fa_center);  draw_set_valign(fa_middle);
        draw_text(_col2_x + _col_width / 2, _right_y + ui_slider_h / 2, string(round(_value * 100)) + "%");
        draw_set_halign(fa_left);  draw_set_valign(fa_top);
        _right_y += ui_slider_h + ui_pad;
        _i++;
    }
    
    // Rotate Sliders
    var _rotate_feats = bp_device_get_rotate_features(selected_device);
    var _rotate_count = array_length(_rotate_feats);
    _i = 0;
    repeat (_rotate_count) {
        _any_features = true;
        var _feat = _rotate_feats[_i];
        var _skey = string(selected_device) + ":rotate:" + string(_i);
        var _value = variable_struct_exists(slider_values, _skey) ? slider_values[$ _skey] : 0;
        
        var _label = "Rotate";
        if (_feat.descriptor != "") { _label += " - " + _feat.descriptor; }
        draw_set_color(_c_dim);
        draw_text(_col2_x, _right_y, _label);
        _right_y += _line_h;
        
        // Track
        draw_set_color(_c_slider);
        draw_rectangle(_col2_x, _right_y, _col2_x + _col_width, _right_y + ui_slider_h, false);
        // Center line
        var _center_x = _col2_x + _col_width / 2;
        draw_set_color(_c_dim);
        draw_line(_center_x, _right_y, _center_x, _right_y + ui_slider_h);
        // Fill from center
        var _fill_x = _center_x + (_col_width / 2) * _value;
        draw_set_color(_c_thumb);
        draw_rectangle(min(_center_x, _fill_x), _right_y, max(_center_x, _fill_x), _right_y + ui_slider_h, false);
        // Direction label
        var _dir_label = (_value >= 0) ? "CW" : "CCW";
        draw_set_color(_c_text);
        draw_set_halign(fa_center);  draw_set_valign(fa_middle);
        draw_text(_col2_x + _col_width / 2, _right_y + ui_slider_h / 2, _dir_label + " " + string(round(abs(_value) * 100)) + "%");
        draw_set_halign(fa_left);  draw_set_valign(fa_top);
        _right_y += ui_slider_h + ui_pad;
        _i++;
    }
    
    // Linear Sliders
    var _linear_feats = bp_device_get_linear_features(selected_device);
    var _linear_count = array_length(_linear_feats);
    _i = 0;
    repeat (_linear_count) {
        _any_features = true;
        var _feat = _linear_feats[_i];
        var _skey = string(selected_device) + ":linear:" + string(_i);
        var _value = variable_struct_exists(slider_values, _skey) ? slider_values[$ _skey] : 0;
        
        var _label = "Linear";
        if (_feat.descriptor != "") { _label += " - " + _feat.descriptor; }
        draw_set_color(_c_dim);
        draw_text(_col2_x, _right_y, _label + "  (300ms travel)");
        _right_y += _line_h;
        
        // Track
        draw_set_color(_c_slider);
        draw_rectangle(_col2_x, _right_y, _col2_x + _col_width, _right_y + ui_slider_h, false);
        // Position marker
        var _pos_x = _col2_x + _col_width * _value;
        draw_set_color(_c_thumb);
        draw_rectangle(_pos_x - 3, _right_y, _pos_x + 3, _right_y + ui_slider_h, false);
        // Position label
        draw_set_color(_c_text);
        draw_set_halign(fa_center);  draw_set_valign(fa_middle);
        draw_text(_col2_x + _col_width / 2, _right_y + ui_slider_h / 2, "pos " + string(round(_value * 100)) + "%");
        draw_set_halign(fa_left);  draw_set_valign(fa_top);
        _right_y += ui_slider_h + ui_pad;
        _i++;
    }
    
    if (!_any_features) {
        draw_set_color(_c_dim);
        draw_text(_col2_x + 8, _right_y, "No controllable features reported");
    }
}
else {
    draw_set_color(_c_dim);
    draw_text(_col2_x, ui_pad, "Select a device from the list");
}

// =================================================================
//  BOTTOM - Log Panel
// =================================================================
var _log_h     = log_max_lines * 14 + 8;
var _log_top   = display_get_gui_height() - _log_h - ui_pad - _line_h;
var _log_width = _col2_x + _col_width;

draw_set_color(_c_text);
draw_text(_col1_x, _log_top, "Log:");
_log_top += _line_h;

draw_set_color(_c_field);
draw_rectangle(_col1_x, _log_top, _log_width, _log_top + _log_h, false);

draw_set_color(_c_dim);
var _log_count = array_length(log_lines);
var _log_vis   = min(_log_count, log_max_lines);
_i = 0;
repeat (_log_vis) {
    var _log_idx = _log_count - 1 - _i;
    draw_text(_col1_x + 4, _log_top + 4 + (log_max_lines - 1 - _i) * 14, log_lines[_log_idx]);
    _i++;
}

// Reset draw state
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
