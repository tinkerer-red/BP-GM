# BP-GM

BP-GM is a GameMaker library for connecting to a Buttplug.io compatible server over WebSocket and controlling supported devices from GML.
This is the same Adult Toy engine which Ultra Kill officially supports, bringing the utility of this engine to GM.

It is designed to provide a small public API for:
- connecting and disconnecting
- scanning for devices
- querying device capabilities
- sending scalar, rotate, and linear commands
- reading sensor data such as battery or RSSI

## Requirements

- Intiface Central 3.0.3 ([Release](https://intiface.com/#intiface-central)) ([Github](https://github.com/intiface/intiface-central))

## Basic Setup

---

### You must first install **Intiface Central**, and set up the server to the port you wish to use. Then start the server.

---

Call initialization once, register any callbacks you want, then connect.

```gml
bp_init("My Game");

bp_on_connected(function() {
	show_debug_message("BP-GM connected");
	bp_start_scanning();
});

bp_on_device_added(function(_device_index) {
	show_debug_message("Device: " + bp_device_get_name(_device_index));
});

bp_on_error(function(_error_code, _error_message) {
	show_debug_message("BP-GM error: " + _error_message);
});

bp_connect();
```

## Device Queries

Examples:

```gml
var _name = bp_device_get_name(_device_index);
var _display_name = bp_device_get_display_name(_device_index);
var _can_vibrate = bp_device_has_output(_device_index, BP_OUTPUT_VIBRATE);
var _can_read_battery = bp_device_has_input(_device_index, BP_INPUT_BATTERY);
```

## Device Commands

### Scalar outputs

```gml
bp_device_vibrate(_device_index, 1.0);
bp_device_oscillate(_device_index, 0.5);
bp_device_constrict(_device_index, 0.75);
bp_device_inflate(_device_index, 0.25);
```

You can also target a specific feature or use the generic scalar command:

```gml
bp_device_vibrate_feature(_device_index, _feature_index, 1.0);
bp_device_scalar(_device_index, _feature_index, 0.5, BP_OUTPUT_VIBRATE);
```

### Rotate and linear outputs

```gml
bp_device_rotate(_device_index, 0.5);
bp_device_rotate_feature(_device_index, _feature_index, 0.5);

bp_device_linear(_device_index, 0.5, 1000);
bp_device_linear_feature(_device_index, _feature_index, 0.5, 1000);
```

### Stop commands

```gml
bp_device_stop(_device_index);
bp_stop_all_devices();
```

## Sensor Reads

```gml
bp_device_battery_read(_device_index);
bp_device_sensor_read(_device_index, _sensor_index, BP_INPUT_BATTERY);
bp_device_sensor_subscribe(_device_index, _sensor_index, BP_INPUT_BATTERY);
bp_device_sensor_unsubscribe(_device_index, _sensor_index, BP_INPUT_BATTERY);
```

Register a callback to receive sensor data:

```gml
bp_on_sensor_reading(function(_device_index, _sensor_index, _sensor_type, _data_array) {
	show_debug_message("Sensor update received");
});
```

## Callbacks

Available callback registration functions:

- `bp_on_connected(_callback)`
- `bp_on_disconnected(_callback)`
- `bp_on_error(_callback)`
- `bp_on_device_added(_callback)`
- `bp_on_device_removed(_callback)`
- `bp_on_scanning_finished(_callback)`
- `bp_on_sensor_reading(_callback)`

## Connection Helpers

```gml
bp_is_connected();
bp_get_state();
bp_get_server_name();
bp_disconnect();
bp_cleanup();
```

## Notes

- Initialize before calling any other BP-GM function.
- `bp_update()` should be called once per frame.
- `bp_process_async_networking()` should be called from an Async - Networking event.
- Device indices are assigned by the connected server and should be treated as runtime identifiers.

## Credits

This project would not have been made if not for the Buttplug.io team. Additionally, it's worth noting i do not intend to extend support for this repo. It was a two day project made for April Fools, and I'm just excited to see all the undertale mod names.

## Games!

Currently no game officially supports this. However if you would like to include your game or mod to this page please submit an new issue with a link to your project.
