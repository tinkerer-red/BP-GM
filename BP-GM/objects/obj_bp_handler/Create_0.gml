/// @desc Initialize all Buttplug client instance state

// Connection state
socket         = -1;
state          = BP_STATE.DISCONNECTED;
server_name    = "";
max_ping_time  = 0;
ping_interval  = 0;
last_ping_time = 0;
host           = BP_DEFAULT_ADDRESS;
port           = BP_DEFAULT_PORT;

// Protocol state
message_id   = 0;
handshake_id = -1;
client_name  = "GameMaker";

// Device storage (struct used as map: string(index) -> device struct)
devices = {};

// Pending sensor read tracking
pending_sensor_reads = {};

// Scanning state
scanning = false;

// Logging
log_level = BP_LOG.INFO;

// Callbacks (set via bp_on_* functions)
on_connected          = undefined;
on_disconnected       = undefined;
on_error              = undefined;
on_device_added       = undefined;
on_device_removed     = undefined;
on_scanning_finished  = undefined;
on_sensor_reading     = undefined;
