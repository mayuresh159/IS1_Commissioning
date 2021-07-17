; Update flight table parameters in the firmware
;Purpose: Upload flight table parameters to the firmware. This code is to be run before shipping the satellite to SHAR
;Outline
;  Commands to set the table parameters
;    	1. Deployment timeout for beacon (40 minutes)
;	    2. Deployment timeout for antenna and SA (40 minutes)
;	    3. Deployment flags (set to 0 pre- launch)
;	    4. Deployment timeouts between retry. (135 minutes)
;	    5. Mode thresholds (phoenix to safe(7.4V), safe to nominal (8.5V), nominal to safe (7.0V), safe to phoenix(6.7V))
;	    6. Eclipse determination (ADCS threshold 2500  )
;	    7. EPS eclipse determination (Current 0.04 );
;	    8. Beacon packet rate (30s)
;	    9. Packet write rates (ADCS (1s), HK (1s), SCIC (1s), SCID(9s))
;	    10. Last command watchdog timeout (Command link loss timer )(24 hours and 48 hours after commissioning)
;	    11. Battery heater temperature (5 (on) - 7 (off))
;	    12. Battery heater samples before turn on (set to 15 currently at 1 Hz)
;	    13. Sd card select (last selected by default)
;	    14. Flash partition sizes (2560 KB per 6 partition currently; Can we change partition sizes to reduce MISC and LOG and increase SCIC and SCID)
;	    15. SD Card error count set to 10
;	    16. DAXSS integration time (60s)

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare waitinterval dn16l

set cmdSucceed = 0
set waitinterval = 3500

; Start routing of packets which include table parameters for monitoring
;mode_hk :
;    avoid_flags
;    mode_transition_thresholds
;    last_cmd_time
;    clt_triggered_flag
;    clt_threshold
;    clt_countdown - remaining seconds before clt_triggers
;    deployables - Commanded state of deployables
;    curr_mode - safe/phoenix/scic/scid
;    launch_delay - threshold value
;    launch_count - counter current value
;    launch_flag - flag if the counter is above the threshold value
;    deployment_interval - reason for selecting 135 minutes?
;    deploy_count - current counter value
;    eclipse_method - adcs/ eps
;    eclipse - flag
;    auto_state - flag indicates if the system is automatically changing modes

;adcs_hk :
;    adcs_eclipse_threshold - css threshold for eclipse determination

;analog_hk : apid - 2
;    eps_eclipse_thresh - solar array eclipse threshold
;    batt_set_low - battery low setpoint
;    batt_set_high - battery high setpoint
;    batt_samples - battery consecutive samples


;tlm_hk : ? to check packet rates of different types of packets?
;    sent_count
;    error_count
;    packet_rate 1280 bits
;    stream_rate

;sd_hk :
;    card_0_state
;    card_1_state
;    card_select - 0/CARD_0, 1/CARD_1, 2/FLASH
;

;   0. Route packets
set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid MODE_HK rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid ADCS_HK rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid ANA_HK rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid TLM_HK rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid SD_HK rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1


;   1. Deployment timeout for beacon (40 minutes)
;   2. Deployment timeout for antenna and SA (40 minutes)
; Delay value to be given in seconds
; The same launch delay works for antenna, SA and beacons.
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_launch_delay value 2400
  set cmdTry = cmdTry + 1
  wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   3. Deployment flags (set to 0 pre- launch)
; Component: 0/PANEL1, 1/PANEL2, 2/Antenna
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_launch_set_flag state 0
  set cmdTry = cmdTry + 1
  wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_deploy_flag component 0 state 0
  set cmdTry = cmdTry + 1
  wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_deploy_flag component 1 state 0
  set cmdTry = cmdTry + 1
  wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_deploy_flag component 2 state 0
  set cmdTry = cmdTry + 1
  wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   4. Deployment timeouts between retry. (135 minutes)
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_deploy_interval value 8100
  set cmdTry = cmdTry + 1
  wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   5. Mode thresholds (phoenix to safe(7.4V), safe to nominal (8.5V), nominal to safe (7.0V), safe to phoenix(6.7V))
; Phoenix to safe
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_set_threshold threshold 0 value 7400
  set cmdTry = cmdTry + 1
  wait $waitinterval
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


; Safe to Phoenix
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_set_threshold threshold 1 value 6700
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


; Safe to nominal
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_set_threshold threshold 2 value 8500
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


; Nominal to Safe
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_set_threshold threshold 3 value 7000
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   6. Eclipse determination (ADCS threshold 2500  )
; Set eclipse method to ADCS
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_mode_eclipse_method method 0
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


set cmdCnt = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < cmdCnt
  cmd_noop
  cmd_adcs_eclipse_update threshold 2500 count 3
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   7. EPS eclipse determination (Current 0.04 )
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_eps_eclipse_thresh threshold 0.04
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause



;   8. Beacon packet rate (30s)
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_set_pkt_rate apid 1 rate 30 stream 1
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   9. Packet write rates (ADCS (1s), HK (1s), SCIC (1s), SCID(9s))
; Write packets to SD card ?


;   10. Last command watchdog timeout (Command link loss timer )(24 hours and 48 hours after commissioning)
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_clt_threshold value 86400
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   11. Battery heater temperature (5 (on) - 7 (off))
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_eps_htr_setpoint low 5 high 7
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   12. Battery heater samples before turn on (set to 15 currently at 1 Hz)
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_eps_htr_samples samples 15
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   13. Sd card select (last selected by default)
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_sd_select card 1
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   14. Flash partition sizes (2560 KB per 6 partition currently; Can we change partition sizes to reduce MISC and LOG and increase SCIC and SCID)


;   15. SD Card error count set to 10
echo Check if FDRI is the correct command
pause
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
  cmd_noop
  cmd_sd_fdri_limit limit 10
  set cmdTry = cmdTry + 1
endwhile
set cmdSucceed = cmdSucceed + 1
echo Wait for table parameter to be updated
pause


;   16. Unroute packets
set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid MODE_HK rate 0 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid ADCS_HK rate 0 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid ANA_HK rate 0 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid TLM_HK rate 0 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid SD_HK rate 0 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1


echo End update_table_params with:
echo count = $cmdCnt
echo success = $cmdSucceed
echo trials = $cmdTry
