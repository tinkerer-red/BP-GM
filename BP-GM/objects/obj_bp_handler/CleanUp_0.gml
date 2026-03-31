/// @desc Clean up Buttplug connection and socket resources
if (state != BP_STATE.DISCONNECTED) {
    if (state == BP_STATE.CONNECTED) {
        __bp_send(__bp_msg_stop_all_devices());
    }
    if (socket >= 0) {
        network_destroy(socket);
        socket = -1;
    }
}

__bp_log(BP_LOG.INFO, "Buttplug client cleaned up");
