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

set SBANDpwr = 1

;Press GO to test COMM commands
pause

START:
echo Starting COMM Command Test

PKT_CHECK1:
;  Verify that COMM HK Packet telemetry items are correct
call Scripts\UHF\uhf_comm_tlm_check

SETUP:
if beacon_mode == 0
	echo SC Mode Phoenix is unexpected
	echo Continue?
	pause
endif

if beacon_pwr_status_sband == 0
    set SBANDpwr = 0
	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
        cmd_noop
	    cmd_eps_pwr_on component SBAND override 1
	    set cmdTry = cmdTry + 1
	    wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1 
endif

; Route SBAND and UHF HK for 3-sec rate
set commWriteStart = beacon_sd_write_misc
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 40 rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 40 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 52 rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 52 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 42 rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 42 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

UHF_CMD_TEST:

CHANGE_CHANNEL:
echo Do  you want to test changing the UHF channel
echo Note: DO NOT do this if commanding over UHF!
echo Only do this if commanding over the hardline
echo GOTO REINT to skip
pause
verify uhf_channel == 0x41

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_uhf_pass len 2 data PC
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
wait 3000

verify uhf_channel == 0x43

REINIT:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_uhf_init
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

verify uhf_channel == 0x41

UHF_PLAYBACK:
set uhfRead = sd_partition_read4
set cmdCnt = beacon_cmd_succ_count + 1
set beaconReadPntr = sd_partition_write4
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_sd_read stream 1 timeout 300 partition 4 decimation 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

tlmwait sd_partition_read4 >= $beaconReadPntr ? 300000
set uhfReadtot = sd_partition_read4 - $uhfRead % sd_partition_size4
echo UHF playedback $uhfReadtot in 5 mins

SBAND_CMD_TEST:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_sband_set_pa_level level 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

wait 3000
verify sband_power == 0

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_sband_set_encoder dr 1 qpsk 1 filter 1 scram 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3000
verify sband_encoder == 29

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_sband_set_synth value 50
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3000
verify sband_synth_offset == 50

;SBAND reset command doesn't work
;set cmdCnt = beacon_cmd_succ_count + 1
;while beacon_cmd_succ_count < $cmdCnt
;    cmd_sband_reset 
;    set cmdTry = cmdTry + 1
;    wait 3500
;endwhile
;set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_eps_pwr_off component SBAND override 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_eps_pwr_on component SBAND override 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
verify sband_power == 3
verify sband_control == 0
verify sband_encoder == 0
verify sband_synth_offset == 4


SBAND_PLAYBACK:
set beaconPbkPntr = sd_partition_write4 - 3000 % sd_partition_size4
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_sband_sync_on timeout 300
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

verify sband_status == 3
verify sband_control == 130

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_sd_playback stream 3 start $beaconPbkPntr num 3000 timeout 240 partition 4 decimation 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

tlmwait sd_partition_pbk4 >= $beaconPbkPntr + 3000 - 1  ? 300000
verify sd_partition_pbk4 >= $beaconPbkPntr + 3000 - 1
verify sd_partition_pbk4 < $beaconPbkPntr + 3000 + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_sband_set_mode mode 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

PKT_CHECK2:
;  Verify that COMM HK Packet telemetry items are correct
call Scripts\UHF\uhf_comm_tlm_check

ClOSEOUT:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid SD_HK rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set commWriteNum = beacon_sd_write_misc - $commWriteStart
set commWriteNum = $commWriteNum % sd_partition_size0
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_sd_playback stream UHF start $commWriteStart num $commWriteNum timeout 600 partition 0 decimation 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
tlmwait sd_partition_pbk0 == ( $commWriteStart + $commWriteNum ) % sd_partition_size0 ? 600000
echo Verify UHF playback complete
pause

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid SD_HK rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

FINISH:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 40 rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 52 rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 42 rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 40 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 52 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 42 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Done with COMM Command Test

print cmdTry
print cmdSucceed