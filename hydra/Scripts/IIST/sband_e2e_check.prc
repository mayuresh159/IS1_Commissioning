;MINXSS COMM_CMD_TEST Procedure
;Purpose: Test COMM (Li-1 Radio) related FSW functions (commands and telemetry)
;Outline
;
;COMM Telemetry Points are Verified in Scripts\comm_tlm_check
;
; ISSUES:
;
; MODIFICATION HISTORY:
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare SBANDpwr dn8
declare beaconPbkPntr dn32l
declare uhfRead dn32l
declare uhfReadtot dn32l
declare commWriteStart dn32l
declare commWriteNum dn32l
declare beaconReadPntr dn32l

; Wait time interval testing
declare WaitTime dn8l

set WaitTime = 3500

;Press GO to test COMM commands
pause

START:
echo Starting COMM Command Test

PKT_CHECK1:
;  Verify that COMM HK Packet telemetry items are correct
;call Scripts/UHF/uhf_comm_tlm_check

SETUP:
if beacon_mode == 0
	echo SC Mode Phoenix is unexpected
	echo Continue?
	pause
endif

;Route BEACON for 3 sec rate

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 1 rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $WaitTime
endwhile
set cmdSucceed = cmdSucceed + 1

; Route SBAND and UHF HK for 3-sec rate

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SBAND_HK rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $WaitTime
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SD_HK rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $WaitTime
endwhile
set cmdSucceed = cmdSucceed + 1

;INIT:
;set cmdCnt = beacon_cmd_succ_count + 1
;while beacon_cmd_succ_count < $cmdCnt
;    cmd_uhf_init
;    set cmdTry = cmdTry + 1
;    wait $WaitTime
;endwhile
;set cmdSucceed = cmdSucceed + 1 

;verify uhf_channel == 0x41

echo Press GO for SBAND_PLAYBACK
pause  

SBAND_PLAYBACK:

if beacon_pwr_status_sband == 0
    set SBANDpwr = 0
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_eps_pwr_on component SBAND override 0
        set cmdTry = cmdTry + 1
        wait $WaitTime
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif

verify sband_power == 3
verify sband_control == 0
verify sband_encoder == 0
verify sband_synth_offset == 4

set beaconPbkPntr = sd_partition_write4 - 3000 % sd_partition_size4
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_sband_sync_on timeout 200
    set cmdTry = cmdTry + 1
    wait $WaitTime
endwhile
set cmdSucceed = cmdSucceed + 1 

verify sband_status == 3
verify sband_control == 130

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_sd_playback stream 3 start $beaconPbkPntr num 1000 timeout 100 partition 4 decimation 1
    set cmdTry = cmdTry + 1
    wait $WaitTime
endwhile
set cmdSucceed = cmdSucceed + 1 

tlmwait sd_partition_pbk4 >= $beaconPbkPntr + 1000 - 1  ? 150000
verify sd_partition_pbk4 >= $beaconPbkPntr + 1000 - 1
verify sd_partition_pbk4 < $beaconPbkPntr + 1000 + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_sband_set_mode mode 0
    set cmdTry = cmdTry + 1
    wait $WaitTime
endwhile
set cmdSucceed = cmdSucceed + 1 



FINISH:

PKT_CHECK2:
;  Verify that COMM HK Packet telemetry items are correct
;call Scripts/UHF/uhf_comm_tlm_check


set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SBAND_HK rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait $WaitTime
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SD_HK rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait $WaitTime
endwhile
set cmdSucceed = cmdSucceed + 1

pause
if $SBANDpwr == 0
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_eps_pwr_off component SBAND override 0
        set cmdTry = cmdTry + 1
        wait $WaitTime
    endwhile
    set cmdSucceed = cmdSucceed + 1
endif

;Route BEACON for 10 sec rate

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 1 rate 10 stream UHF
    set cmdTry = cmdTry + 1
    wait $WaitTime
endwhile
set cmdSucceed = cmdSucceed + 1

echo end to end test is finished

print cmdTry
print cmdSucceed