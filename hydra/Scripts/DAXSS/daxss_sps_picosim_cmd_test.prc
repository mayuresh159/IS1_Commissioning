; DAXSS SPS_CMD_TEST Procedure
; Purpose: Test SPS related FSW functions (commands and telemetry)
; Outline
;  		Turn on SPS
;		Verify SPS Science Packets
;		Verify Science Packet Compression
;		Query SPS (AUO1 as doesn't affect calibration)
;		Send SPS Command
;		Query SPS to see if it changed
;		Send SPS Command to set back to default value
;		Query SPS to see if it changed
;
;  Commands Tested
;		switch_power_sps
; 		TODO: The gain cal may not be allowed for DAXSS
;		initiate_asic_gain_cal
;		set_sps_asic_offsets
;
;	Commands Not Tested (but tested by CDH)
;       route_sps_pkt
;       set_sps_pkt_rate
;  		set_sps_sum_threshold
;		set_sps_to_xact_offset
;		
;	SPS Telemetry Points are Verified in Scripts\sps_tlm_check
;
; MODIFICATION HISTORY: 
;	2014-12-11: Tom Woods: Wrote script
;	2014-12-12: James Paul Mason: Checked script for bugs and fine tuning
;								  Script takes 
;	2019-03-28: James Paul Mason: Updated for DAXSS
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14
declare test_asic_offset dn16
declare asic_offset0 dn16
declare asic_offset1 dn16
declare asic_offset2 dn16
declare asic_offset3 dn16
declare asic_offset4 dn16
declare asic_offset5 dn16

echo Press GO to test SPS commands
pause

START:
echo Starting SPS Command Test

; Switch on SPS if it is Off
if daxss_sci_sps_enabled == 0
    set cmdCnt = daxss_sci_cmd_acpt_count + 1
    while daxss_sci_cmd_acpt_count < $cmdCnt
        cmd_daxss_pwr_sps pwr 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif

; set SCI rate to 3 sec
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_set_sci_pkt_rate time 3
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

PKT_CHECK:
; Verify that Sci Packet telemetry items are correct (for dark data)
call Scripts\DAXSS\sps_tlm_check_daxss

SPS_CMDS:

TEST_SPS_ASIC_OFFSETS:
; read the current asic offsets
; dumps current MinXSS parameters stored in RAM
call Scripts\DAXSS\dump_parameters

; Check/record the SPS asic offset values
echo Record ASIC Offset-0 value
pause 

; Set the SPS asic offset0 to its original value + 100
set asic_offset0 = daxss_param_sps_asic_off[0]
set asic_offset1 = daxss_param_sps_asic_off[1]
set asic_offset2 = daxss_param_sps_asic_off[2]
set asic_offset3 = daxss_param_sps_asic_off[3]
set asic_offset4 = daxss_param_sps_asic_off[4]
set asic_offset5 = daxss_param_sps_asic_off[5]
set test_asic_offset = daxss_param_sps_asic_off[0] + 100

; Check if the command count increases
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_sps_offset offset1 $test_asic_offset offset2 $asic_offset1 offset3 $asic_offset2 offset4 $asic_offset3 offset5 $asic_offset4 offset6 $asic_offset5
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

; read the current asic offsets
; dumps current MinXSS parameters stored in RAM
call Scripts\DAXSS\dump_parameters

verify daxss_param_sps_asic_off[0] == test_asic_offset
verify daxss_param_sps_asic_off[1] == asic_offset1
verify daxss_param_sps_asic_off[2] == asic_offset2
verify daxss_param_sps_asic_off[3] == asic_offset3
verify daxss_param_sps_asic_off[4] == asic_offset4
verify daxss_param_sps_asic_off[5] == asic_offset5

echo Record new ASIC Offset-0 value
pause 

set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	cmd_daxss_set_sps_offset offset1 $asic_offset0 offset2 $asic_offset1 offset3 $asic_offset2 offset4 $asic_offset3 offset5 $asic_offset4 offset6 $asic_offset5
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

; read the current asic offsets
; dumps current MinXSS parameters stored in RAM
call Scripts\DAXSS\dump_parameters

verify daxss_param_sps_asic_off[0] == asic_offset0
verify daxss_param_sps_asic_off[1] == asic_offset1
verify daxss_param_sps_asic_off[2] == asic_offset2
verify daxss_param_sps_asic_off[3] == asic_offset3
verify daxss_param_sps_asic_off[4] == asic_offset4
verify daxss_param_sps_asic_off[5] == asic_offset5

echo Verify original ASIC Offset-0 value
pause 

echo Record PSIM data prior to gain change
pause

; Check if the command count increases
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_daxss_set_pico_gain gain 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo Record PSIM data post gain change
pause

; Check if the command count increases
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_daxss_set_pico_gain gain 0
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo Record PSIM data pre integration period change
pause

; Check if the command count increases
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_daxss_set_pico_int_time time 256
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo Record PSIM data post integration period change
pause
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_daxss_set_pico_int_time time 32
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo Verify PSIM data back to normal prior to power toggle
pause

set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    set cmdTry = cmdTry + 1
    cmd_daxss_set_picosim_led_power_timeout Duration 301
    wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo Press go for PSIM LED cal (record value during calibration)
pause

set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    set cmdTry = cmdTry + 1
    daxss_cmd_picosim_led_cal EnableLED 1 LEDCurrent 2
    wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo Verify LED turn-off after Timeout Period (301)
pause

POWER_TOGGLE:
; Power off SPS
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_pwr_sps pwr 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
wait 1000

;Check SPS and PSIM diodes are off
verify daxss_sci_sps_enabled == 0

verify daxss_sci_sps_sum == 0
verify daxss_sci_sps_xpos == 0
verify daxss_sci_sps_ypos == 0
verify daxss_sci_sps_int_time == 0
verify daxss_sci_sps_data1 == 0
verify daxss_sci_sps_data2 == 0
verify daxss_sci_sps_data3 == 0
verify daxss_sci_sps_data4 == 0

verify daxss_sci_pico_sim_data1 == 0
verify daxss_sci_pico_sim_data1 == 0
verify daxss_sci_pico_sim_data1 == 0
verify daxss_sci_pico_sim_data1 == 0
verify daxss_sci_pico_sim_data1 == 0
verify daxss_sci_pico_sim_data1 == 0

; Power on SPS
set cmdCnt = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCnt
    cmd_daxss_pwr_sps pwr 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
wait 1000
verify daxss_sci_sps_enabled == 1


FINISH:
echo Done with SPS command test


print cmdTry
print cmdSucceed