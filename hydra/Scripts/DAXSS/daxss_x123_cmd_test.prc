;MINXSS X123 FSW Test
;Purpose: Test X123 related FSW functions
;Outline
;		Verify / set to Safe Mode (so can power cycle X123 without doing ADCS fine point)
;  		Turn on X123
;		Verify X123 Science Packets
;		Verify Science Packet Compression
;		Query X123 (AUO1 as doesn't affect calibration)
;		Send X123 Command
;		Query X123 to see if it changed
;		Send X123 Command to set back to default value
;		Query X123 to see if it changed
;
;  Commands Tested
;		switch_power_x123
;		toggle_data_comp
;		query_x123_status
;		send_x123_cmd
;
;	Commands Not Tested (but could be added)
;		set_x123_auto_input_offset
;       set_x123_auto_fast_threshold
;
;	HK Packet Telemetry Points Verified
;		MINXSSX123Enabled_Sci_All
;		MINXSSSdx123Comp
;		MINXSSX123FastCountNorm
;		MINXSSX123SlowCountNorm
;		MINXSSX123DetTemp
;		MINXSSX123BrdTemp
;		MINXSSSciRouting
;		MINXSSSdSciWriteOffset
;   Sci Packet Telemetry Points Verified
;		MINXSSSeqCnt_Sci_All
;		MINXSSX123FastCount
;		MINXSSX123SlowCount
;		X123_GP_Count
;		X123_Accum_Time
;		X123_Live_Time
;		X123_Real_Time
;		X123_HV
;		X123_Det_Temp
;		X123_Brd_Temp
;		X123_Flags1
;		X123_Flags2
;		X123_Flags3
;		X123_Read_Errors
;		X123_Write_Errors
;		X123_Cmp_Info
;		X123_Spect_Len
;
; ISSUES: 
;	None
;
; MODIFICATION HISTORY: 
;	2014/12/11: Tom Woods: Wrote script
;	2014/12/12: James Paul Mason: Checked for bugs and fine tuning
;								  Script takes 2.5 minutes to run
;


declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14

;Press GO to test X123 commands
pause

START:
echo Starting X123 Command Test


SWITCH_POWER:
if daxss_sci_x123_enabled == 0 
  set cmdCnt = daxss_sci_cmd_acpt_count + 1
  while daxss_sci_cmd_acpt_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_daxss_pwr_x123 pwr 1
	wait 3529
  endwhile
  set cmdSucceed = cmdSucceed + 1
endif

verify daxss_sci_x123_enabled == 1

PKT_CHECK:
;  Verify that X123 HK and Sci Packet telemetry items are correct (for dark data)
call Scripts\DAXSS\x123_tlm_check_daxss

set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_set_sci_pkt_rate time 3
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

TOGGLE_COMPRESSION:
; test that X123 data compression can be turned off and back on

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 177 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

while daxss_param_sd_x123_comp != 0
    cmd_daxss_set_x123_compress flag 0
    cmd_daxss_dump_param set 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

verify daxss_param_sd_x123_comp == 0

while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 177 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

;  take 30 sec of data as not compressed
wait 35290

set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_set_x123_compress flag 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

call Scripts\DAXSS\dump_parameters

verify daxss_param_sd_x123_comp == 1

verify daxss_param_sci_rate == 3

X123_CMDS:

; Verify X123 Gain value
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_query_x123 cmd "GAIN;"
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

echo verify daxss_log_msg == "X123 config: GAIN=15.098;"
pause


X123_QUERY_CMD:
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_query_x123 cmd "AUO1;"
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

echo verify daxss_log_msg == "X123 config: AUO1=ICR;" 
pause

X123_SEND_CMD:
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_send_x123 cmd "AUO1=MCAEN;"
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

;Query changed parameter to see if AUO1 changed to new value
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_query_x123 cmd "AUO1;"
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

echo verify daxss_log_msg == "X123 config: AUO1=MCAEN;" 
pause

X123_RESTORE_CMD:
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_send_x123 cmd "AUO1=ICR;"
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

;Query changed parameter to see if AUO1 changed to new value
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_query_x123 cmd "AUO1;"
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

echo verify daxss_log_msg == "X123 config: AUO1=ICR;" 
pause 

X123_QUERY_SLOW:
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_query_x123 cmd "THSL;"
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

echo verify daxss_log_msg == "X123 config: THSL=0.622;"
echo Record the Slow Threshold in the CPT Document
pause

X123_QUERY_FAST:
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_query_x123 cmd "THFA;"
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

echo verify daxss_log_msg == "X123 config: THFA=8.00;"
echo Record the Slow Threshold in the CPT Document
pause

FINISH:
echo Done with X123 command test


print cmdTry
print cmdSucceed