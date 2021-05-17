cmd_pkt_stream_set stream UHF state DIS
wait 1sec

cmd_set_pkt_rate apid SBAND_HK rate 1 stream DBG
wait 1sec

cmd_eps_pwr_on component SBAND override 0
wait 1sec

cmd_sband_sync_on timeout 1000
wait 3sec

cmd_sd_read stream SBAND timeout 40 sector BEACON
wait 1sec
