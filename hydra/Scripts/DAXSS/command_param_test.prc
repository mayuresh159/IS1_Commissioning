;
; NAME:
;   command_param_test.prc
;
; PURPOSE:
;   Test all commands related to the PARAM variables (EEPROM parameters)
;
; This script will read the 3 tables of PARAM, PARAM_MIN, and PARAM_MAX,
; then it will increment each PARAM by 1 and re-read the tables for verification.
;
;  COMMANDS TESTED
;   See Command & Telemetry Handbook worksheet for Commands and Table Parameters
;
; MODIFICATION HISTORY
;   2016-08-10: Tom Woods: Original code
;	2016-08-17: Tom Woods: Remove variables (hard code values to change)
;	2018-11-08: Robert Sewell: Removed watchdog reset due to FM-2 anomaly
;	2019-03-28: James Paul Mason: Updated for DAXSS

declare cmdCntDaxss dn16
declare cmdCnt dn16
declare paramCnt dn16
declare cmdSucceed dn16l
declare cmdTry dn16l
declare cmdSucceedDaxss dn16l
declare cmdTryDaxss dn16l

echo Starting command_param_test script

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
    cmd_daxss_set_sci_pkt_rate time 3
    set cmdTryDaxss = cmdTryDaxss + 1
    wait 3500
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1 

READ_PARAM:
set paramCnt = ccsdsTlmHeader_count_daxss_mem + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 3 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

while ccsdsTlmHeader_count_daxss_mem < paramCnt
	set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
	while daxss_sci_cmd_acpt_count < $cmdCntDaxss
		set cmdTryDaxss = cmdTryDaxss + 1
		cmd_daxss_dump_param set 0
		wait 5029
	endwhile
	set cmdSucceedDaxss = cmdSucceedDaxss + 1
endwhile

while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 0 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

; verify those parameters DEFAULT values
verify daxss_param_rtc_sync_period == 3600
verify daxss_param_sps_sum_thresh == 2000
verify daxss_param_cmd_wdog_time == 96
verify daxss_param_eclipse_pwr_sci == 0
verify daxss_param_eclipse_out_volt == 6000
verify daxss_param_eclipse_out_curr == 1500
verify daxss_param_eclipse_out_end == 10
verify daxss_param_eclipse_in_volt == 3000
verify daxss_param_eclipse_in_curr == 750
verify daxss_param_eclipse_in_start == 10
verify daxss_param_sps_rate == 0
verify daxss_param_sci_rate == 3
verify daxss_param_i2c_timeout == 360
;verify daxss_param_tx_timeout == 900
verify daxss_param_led_timeout == 301
verify daxss_param_sps_asic_off[0] == 30948
verify daxss_param_sps_asic_off[1] == 30948
verify daxss_param_sps_asic_off[2] == 30948
verify daxss_param_sps_asic_off[3] == 30948
verify daxss_param_sps_asic_off[4] == 30948
verify daxss_param_sps_asic_off[5] == 30948
verify daxss_param_sps_offset_x == 0
verify daxss_param_sps_offset_y == 0
verify daxss_param_sps_adc_gain == 0
verify daxss_param_pico_sim_gain == 0
verify daxss_param_pico_sim_int == 32
;verify daxss_param_sd_write_ctrl_addr == 1
;verify daxss_param_sd_ephem_ctrl_addr == 128
verify daxss_param_sd_x123_comp == 1

; *********************************************************************************

READ_PARAM_MIN:
set paramCnt = ccsdsTlmHeader_count_daxss_mem + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 3 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

while ccsdsTlmHeader_count_daxss_mem < paramCnt
	set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
	while daxss_sci_cmd_acpt_count < $cmdCntDaxss
		set cmdTryDaxss = cmdTryDaxss + 1
		cmd_daxss_dump_param set 2
		wait 5029
	endwhile
	set cmdSucceedDaxss = cmdSucceedDaxss + 1
endwhile

while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 0 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

; verify those parameters MIN values
verify daxss_param_rtc_sync_period == 0
verify daxss_param_sps_sum_thresh == 1
verify daxss_param_cmd_wdog_time == 0
verify daxss_param_eclipse_pwr_sci == 0
verify daxss_param_eclipse_out_volt == 0
verify daxss_param_eclipse_out_curr == 100
verify daxss_param_eclipse_out_end == 0
verify daxss_param_eclipse_in_volt == 0
verify daxss_param_eclipse_in_curr == 0
verify daxss_param_eclipse_in_start == 0
verify daxss_param_sps_rate == 0
verify daxss_param_sci_rate == 3
verify daxss_param_i2c_timeout == 5
;verify daxss_param_tx_timeout == 120
verify daxss_param_led_timeout == 1
verify daxss_param_sps_asic_off[0] == 0
verify daxss_param_sps_asic_off[1] == 0
verify daxss_param_sps_asic_off[2] == 0
verify daxss_param_sps_asic_off[3] == 0
verify daxss_param_sps_asic_off[4] == 0
verify daxss_param_sps_asic_off[5] == 0
verify daxss_param_sps_offset_x == -10000
verify daxss_param_sps_offset_y == -10000
verify daxss_param_sps_adc_gain == 0
verify daxss_param_pico_sim_gain == 0
verify daxss_param_pico_sim_int == 1
;verify daxss_param_sd_write_ctrl_addr == 1
;verify daxss_param_sd_ephem_ctrl_addr == 128
verify daxss_param_sd_x123_comp == 0

; *********************************************************************************

READ_PARAM_MAX:
set paramCnt = ccsdsTlmHeader_count_daxss_mem + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 3 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

while ccsdsTlmHeader_count_daxss_mem < paramCnt
	set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
	while daxss_sci_cmd_acpt_count < $cmdCntDaxss
		set cmdTryDaxss = cmdTryDaxss + 1
		cmd_daxss_dump_param set 3
		wait 5029
	endwhile
	set cmdSucceedDaxss = cmdSucceedDaxss + 1
endwhile

while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 0 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

; verify those parameters MAX values
verify daxss_param_rtc_sync_period == 3600
verify daxss_param_sps_sum_thresh == 40000
verify daxss_param_cmd_wdog_time == 360
verify daxss_param_eclipse_pwr_sci == 63
verify daxss_param_eclipse_out_volt == 18000
verify daxss_param_eclipse_out_curr == 60000
verify daxss_param_eclipse_out_end == 200
verify daxss_param_eclipse_in_volt == 18000
verify daxss_param_eclipse_in_curr == 60000
verify daxss_param_eclipse_in_start == 200
verify daxss_param_sps_rate == 40
verify daxss_param_sci_rate == 600
verify daxss_param_i2c_timeout == 60000
;verify daxss_param_tx_timeout == 7200
verify daxss_param_led_timeout == 1000
verify daxss_param_sps_asic_off[0] == 32767
verify daxss_param_sps_asic_off[1] == 32767
verify daxss_param_sps_asic_off[2] == 32767
verify daxss_param_sps_asic_off[3] == 32767
verify daxss_param_sps_asic_off[4] == 32767
verify daxss_param_sps_asic_off[5] == 32767
verify daxss_param_sps_offset_x == 10000
verify daxss_param_sps_offset_y == 10000
verify daxss_param_sps_adc_gain == 3
verify daxss_param_pico_sim_gain == 3
verify daxss_param_pico_sim_int == 256
;verify daxss_param_sd_write_ctrl_addr == 127
;verify daxss_param_sd_ephem_ctrl_addr == 255
verify daxss_param_sd_x123_comp == 1

; *********************************************************************************
echo Click GO when ready to send 45 commands to change the Table Parameters
pause

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_rtc_sync_all Period 3599  Min 1  Max 3599
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_sps_sum_thresh_all Threshold 2001  Min 2  Max 39999
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_last_cmd_timeout_all Timeout 97  Min 1  Max 359
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_eclipse_out_volt_all milliVolt 6001  Min 1  Max 17999
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_eclipse_out_curr_all CSSdn 1001  Min 101  Max 59999
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_eclipse_out_end_all HkCounts 21  Min 1  Max 199
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_eclipse_in_volt_all milliVolt 3001  Min 1  Max 17999
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_eclipse_in_curr_all CSSdn 2001  Min 1  Max 59999
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_eclipse_in_start_all HkCounts 21  Min 1  Max 199
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_sci_pkt_rate_all RateSec 2  Min 2  Max 599
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_pico_gain_all Gain 2  Min 1  Max 2
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_pico_int_time_all Integration 33  Min 10  Max 250
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_pico_int_time_all Integration 33  Min 10  Max 250
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
 	cmd_daxss_set_picosim_led_power_timeout Duration 301
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
	cmd_daxss_set_i2c_timeout_all TimeMinutes 361  Min 6  Max 59999
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
 	cmd_daxss_set_eclipse_opt_all EnableFlag 48  Min 40  Max 50
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1


;  There is no option to change MIN and MAX for ASIC Offset PARAM table
set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
 	cmd_daxss_set_sps_offset offset1 12010  offset2 12210 offset3 12210 offset4 12210  offset5 7945 offset6 7990
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

;  The SPS angle offset can not change MIN or MAX values
set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
	set cmdTryDaxss = cmdTryDaxss + 1
 	cmd_daxss_set_sps_xact_offset x 100  y -100
	wait 3529
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1

; This PARAM can only be Enabled or Disabled
;set cmdCnt = MINXSSCmdAcceptCnt_Sci_All + 1
;while MINXSSCmdAcceptCnt_Sci_All < $cmdCnt
; set_x123_data_comp EnableFlag 0
; wait 3529
;endwhile
;set cmdSucceedDaxss = cmdSucceedDaxss + 1

echo *************************
print cmdSucceedDaxss

; *********************************************************************************
echo NOTE 1. The Analog Dwell Index will only change in the PARAM table.
echo NOTE 2. The ANT and SA Deploy Retry flags in PARAM table are set to Deployed state.
echo NOTE 3. The LED timeout is not commandable and thus is not changed.
echo NOTE 4. The ASIC Offset values will only change in the PARAM table.
echo NOTE 5. The SPS X & Y offsets are only changed in the PARAM table.
echo NOTE 6. The SD Block Addresses only change in the PARAM table.
echo NOTE 6. The X123 compression is disabled; no changes to its MIN or MAX values.

VERIFY_PARAM:
set paramCnt = ccsdsTlmHeader_count_daxss_mem + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 3 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

while ccsdsTlmHeader_count_daxss_mem < paramCnt
	set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
	while daxss_sci_cmd_acpt_count < $cmdCntDaxss
		set cmdTryDaxss = cmdTryDaxss + 1
		cmd_daxss_dump_param set 0
		wait 5029
	endwhile
	set cmdSucceedDaxss = cmdSucceedDaxss + 1
endwhile

while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 0 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

; verify those parameters DEFAULT values have changed by above commands
verify daxss_param_rtc_sync_period == 3599
verify daxss_param_sps_sum_thresh == 2001
verify daxss_param_cmd_wdog_time == 97
verify daxss_param_eclipse_pwr_sci == 48
verify daxss_param_eclipse_out_volt == 6001
verify daxss_param_eclipse_out_curr == 1001
verify daxss_param_eclipse_out_end == 21
verify daxss_param_eclipse_in_volt == 3001
verify daxss_param_eclipse_in_curr == 2001
verify daxss_param_eclipse_in_start == 21
;verify daxss_param_sps_rate == 3
verify daxss_param_sci_rate == 2
verify daxss_param_i2c_timeout == 361
;verify daxss_param_tx_timeout == 901
verify daxss_param_led_timeout == 301
verify daxss_param_sps_asic_off[0] == 12010
verify daxss_param_sps_asic_off[1] == 12210
verify daxss_param_sps_asic_off[2] == 12210
verify daxss_param_sps_asic_off[3] == 12210
verify daxss_param_sps_asic_off[4] == 7945
verify daxss_param_sps_asic_off[5] == 7990
verify daxss_param_sps_offset_x == 100
verify daxss_param_sps_offset_y == -100
verify daxss_param_pico_sim_gain == 2
verify daxss_param_pico_sim_int == 33
;verify daxss_param_sd_write_ctrl_addr == 33
;verify daxss_param_sd_ephem_ctrl_addr == 129
verify daxss_param_sd_x123_comp == 1

; *********************************************************************************

VERIFY_PARAM_MIN:
set paramCnt = ccsdsTlmHeader_count_daxss_mem + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 3 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

while ccsdsTlmHeader_count_daxss_mem < paramCnt
	set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
	while daxss_sci_cmd_acpt_count < $cmdCntDaxss
		set cmdTryDaxss = cmdTryDaxss + 1
		cmd_daxss_dump_param set 2
		wait 5029
	endwhile
	set cmdSucceedDaxss = cmdSucceedDaxss + 1
endwhile

while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 0 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

; verify those parameters MIN values
verify daxss_param_rtc_sync_period == 1
verify daxss_param_sps_sum_thresh == 2
verify daxss_param_cmd_wdog_time == 1
verify daxss_param_eclipse_pwr_sci == 40
verify daxss_param_eclipse_out_volt == 1
verify daxss_param_eclipse_out_curr == 101
verify daxss_param_eclipse_out_end == 1
verify daxss_param_eclipse_in_volt == 1
verify daxss_param_eclipse_in_curr == 1
verify daxss_param_eclipse_in_start == 1
;verify daxss_param_sps_rate == 1
verify daxss_param_sci_rate == 2
verify daxss_param_i2c_timeout == 6
;verify daxss_param_tx_timeout == 121
verify daxss_param_led_timeout == 1
verify daxss_param_sps_asic_off[0] == 0
verify daxss_param_sps_asic_off[1] == 0
verify daxss_param_sps_asic_off[2] == 0
verify daxss_param_sps_asic_off[3] == 0
verify daxss_param_sps_asic_off[4] == 0
verify daxss_param_sps_asic_off[5] == 0
verify daxss_param_sps_offset_x == -10000
verify daxss_param_sps_offset_y == -10000
verify daxss_param_pico_sim_gain == 1
verify daxss_param_pico_sim_int == 10
;verify daxss_param_sd_write_ctrl_addr == 1
;verify daxss_param_sd_ephem_ctrl_addr == 128
verify daxss_param_sd_x123_comp == 0

; *********************************************************************************

VERIFY_PARAM_MAX:
set paramCnt = ccsdsTlmHeader_count_daxss_mem + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 3 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

while ccsdsTlmHeader_count_daxss_mem < paramCnt
	set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
	while daxss_sci_cmd_acpt_count < $cmdCntDaxss
		set cmdTryDaxss = cmdTryDaxss + 1
		cmd_daxss_dump_param set 3
		wait 5029
	endwhile
	set cmdSucceedDaxss = cmdSucceedDaxss + 1
endwhile

while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 0 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

; verify those parameters MAX values
verify daxss_param_rtc_sync_period == 3599
verify daxss_param_sps_sum_thresh == 39999
verify daxss_param_cmd_wdog_time == 359
verify daxss_param_eclipse_pwr_sci == 50
verify daxss_param_eclipse_out_volt == 17999
verify daxss_param_eclipse_out_curr == 59999
verify daxss_param_eclipse_out_end == 199
verify daxss_param_eclipse_in_volt == 17999
verify daxss_param_eclipse_in_curr == 59999
verify daxss_param_eclipse_in_start == 199
;verify daxss_param_sps_rate == 39
verify daxss_param_sci_rate == 599
verify daxss_param_i2c_timeout == 59999
;verify daxss_param_tx_timeout == 7199
verify daxss_param_led_timeout == 1000
verify daxss_param_sps_asic_off[0] == 32767
verify daxss_param_sps_asic_off[1] == 32767
verify daxss_param_sps_asic_off[2] == 32767
verify daxss_param_sps_asic_off[3] == 32767
verify daxss_param_sps_asic_off[4] == 32767
verify daxss_param_sps_asic_off[5] == 32767
verify daxss_param_sps_offset_x == 10000
verify daxss_param_sps_offset_y == 10000
verify daxss_param_pico_sim_gain == 2
verify daxss_param_pico_sim_int == 250
;verify daxss_param_sd_write_ctrl_addr == 127
;verify daxss_param_sd_ephem_ctrl_addr == 255
verify daxss_param_sd_x123_comp == 1

; *********************************************************************************

echo Click GO to do a soft power reset of CDH or RETURN to skip it
pause

REBOOT_CDH:

; only do ONCE (so not in while loop)
cmd_daxss_watchdog
echo Verify reset after one minute
wait 60529
pause
DONE:
echo End of command_param_test script
