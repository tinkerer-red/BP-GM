/// @desc Handle ping keepalive
if (state != BP_STATE.CONNECTED) exit;

if (max_ping_time > 0) {
    var _elapsed = current_time - last_ping_time;
    if (_elapsed >= ping_interval) {
        __bp_send(__bp_msg_ping());
        last_ping_time = current_time;
    }
}
