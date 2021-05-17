cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0
wait 2sec

cmd_set_pkt_rate apid ADCS_CSS rate 1 stream DBG
wait 2sec

cmd_set_pkt_rate apid ADCS_GPS rate 1 stream DBG
wait 2sec

cmd_set_pkt_rate apid ADCS_TRACKER rate 1 stream DBG
wait 2sec

cmd_set_pkt_rate apid ADCS_MAG rate 1 stream DBG
wait 2sec

cmd_set_pkt_rate apid ADCS_IMU rate 1 stream DBG
wait 2sec

cmd_set_pkt_rate apid ADCS_MOMENTUM rate 1 stream DBG
wait 2sec

cmd_set_pkt_rate apid ADCS_REFS rate 1 stream DBG
wait 2sec

cmd_set_pkt_rate apid ADCS_TIME rate 1 stream DBG
wait 2sec