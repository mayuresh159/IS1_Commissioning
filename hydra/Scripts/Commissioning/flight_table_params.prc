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
;	    10. Last command watchdog timeout (Command link loss timer )(24 hours and 28 hours after commissioning)
;	    11. Battery heater temperature (5 (on) - 7 (off))
;	    12. Battery heater samples before turn on (set to 15 currently at 1 Hz)
;	    13. Sd card select (last selected by default)
;	    14. Flash partition sizes (2560 KB per 6 partition currently; Can we change partition sizes to reduce MISC and LOG and increase SCIC and SCID)
;	    15. SD Card error count set to 10
;	    16. DAXSS integration time (60s)

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l


;   1. Deployment timeout for beacon (40 minutes)
;   2. Deployment timeout for antenna and SA (40 minutes)
; Delay value to be given in seconds
; The same launch delay works for antenna, SA and beacons.
cmd_mode_launch_delay value 2400

;   3. Deployment flags (set to 0 pre- launch)
; Component: 0/PANEL1, 1/PANEL2, 2/Antenna
cmd_mode_launch_set_flag state 0
cmd_mode_deploy_flag component 0 state 0
cmd_mode_deploy_flag component 1 state 0
cmd_mode_deploy_flag component 2 state 0

;   4. Deployment timeouts between retry. (135 minutes)
cmd_mode_deploy_interval value 8100
