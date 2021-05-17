;
; NAME:
;   command_nonparam_test.prc
;
; PURPOSE:
;   Test all commands related to the PARAM variables (EEPROM parameters)
;
;	This script will read the 3 tables of PARAM, PARAM_MIN, and PARAM_MAX,
;	then it will increment each PARAM by 1 and re-read the tables for verification.
;
; INPUTS: 
;	None
; 
; OPTIONAL INPUTS:
;   None
;   
; KEYWORD PARAMETERS:
;   None
;   
; OUTPUTS:
;   Text verification of the number of successfully tested commands
; 	and the number of commands tested for direct comparison
;   
; OPTIONAL OUTPUTS: 
;   None
;   
; RESTRICTIONS:
;   Requires MinXSS flight software (FSW) version 9.2 for some new commands added
;   
; EXAMPLE: 
;   Just run it
;
; COMMANDS TESTED
;	60 commands -- all of the non-parameter change and non-ADCS bent-pipe commands
;   See Command & Telemetry Handbook worksheet for Commands
;
; ISSUES:
;	None
;
; MODIFICATION HISTORY
;   2016/08/15: James Paul Mason: Wrote script
;	2018/11/08: Robert Sewell: Removed watchdog reset due to FM-2 anomaly
;	2019-03-28: James Paul Mason: Updated for DAXSS
;

; Declarations
declare cmdCnt dn16
declare cmdSuccess dn16
declare contactTimeout dn16
declare playbackCnt dn16
declare initialSeqCntPbk dn16
declare storedCommandTime dn32
declare cmdTry dn16l

set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_set_sci_pkt_rate time 3
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

COMMANDS:
echo Click GO when ready to send 80 commands to test flight software
pause

; 1
set cmdSuccess = 0
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_issue_hk_pkt
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 


; 2
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_time time gpsTime
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 4
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_copy_param set 4 dir 0 default 1
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 5
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_dump_param set 0
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 9 
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_eclipse_calc flag 1
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 13
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_eclipse_out_volt volt 1000
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 14
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_eclipse_out_curr curr 1200
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 16 
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_eclipse_out_end end 10
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 17
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_eclipse_in_volt volt 100
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 18
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_issue_hk_pkt
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 19
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_eclipse_in_curr curr 1000
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 20
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_eclipse_in_start start 10
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 51
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	daxss_cmd_picosim_led_cal EnableLED 1 LEDCurrent 2
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 52
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	daxss_cmd_picosim_led_cal EnableLED 0 LEDCurrent 0
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 53
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_pwr_sps pwr 0
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_pwr_sps pwr 1
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 54
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_pwr_x123 pwr 0
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_pwr_x123 pwr 1
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 62
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_i2c_timeout TimeMinutes 90
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 63 
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_stored_cmd_timeout time 60
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 64
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_clear_stored
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; verify that all Stored Commands have been cleared
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_get_stored_cmd_report
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 66
set storedCommandTime = gpsTime + 50
print gpsTime
print storedCommandTime
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_add_stored GpsSeconds $storedCommandTime
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; The actual command to be stored
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_issue_hk_pkt
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; Verify that repeating the command to store does not cause immediate execution
while daxss_sci_cmd_status != 10
	cmd_daxss_issue_hk_pkt
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; New command can be executed
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_sci_pkt_rate time 3
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; Verify that the stored command can now be executed immediately
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_issue_hk_pkt
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; Report that one command is Stored
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_get_stored_cmd_report
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

echo verfiy Last OpCode goes to 0x33 when stored command is executed
pause

; 67
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_get_stored_cmd_report
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

echo Verify STORED CMDs= 0 =  0%
pause

; 70
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_x123_compress flag 1
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 71
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_clear_stored
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 75
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_sps_sum_thresh threshold 2000
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

; 77
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_last_cmd_timeout timeout 96
	set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSuccess = cmdSuccess + 1 

echo Hit go to trigger soft reset
pause

; 78

cmd_daxss_watchdog
echo Verify watchdog reset after one minute
wait 60529
pause
set cmdSuccess = cmdSuccess + 1 

DONE:
print cmdSuccess
