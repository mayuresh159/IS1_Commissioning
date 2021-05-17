;
; NAME:
;   daxss_cmd_test
;
; PURPOSE:
;   
;  COMMANDS TESTED
;
;	HK PACKET TELEMETRY POINTS VERIFIED
;
; ISSUES:
;   None
;
; MODIFICATION HISTORY
;   2020-04-28   Robert Sewell   Wrote script
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14
declare writeDAXSSstart dn32l
declare writeDAXSSnum dn32l

echo Beginning DAXSS cmd test
echo Press go to turn on DAXSS and start Test
;Turn on by going to SCI-D and route DAXSS

if beacon_mode < 1 
	echo INSPIRE in PHOENIX is unexpect
	echo INSPIRE Should be in SAFE, CHARGING or SCI-C/D for this test
	pause
endif

set writeDAXSSstart = beacon_sd_write_scid

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 178 rate 3 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 176 rate 10 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

if beacon_pwr_status_daxss == 0
	if beacon_eclipse_state == 0
		set cmdCnt = beacon_cmd_succ_count + 1
		while beacon_cmd_succ_count < $cmdCnt
			cmd_mode_set apid 1 mode 3
			set cmdTry = cmdTry + 1
			wait 3500
		endwhile
		set cmdSucceed = cmdSucceed + 1 
	else
		set cmdCnt = beacon_cmd_succ_count + 1
		while beacon_cmd_succ_count < $cmdCnt
			cmd_eps_pwr_on component 0 override 1
			set cmdTry = cmdTry + 1
			wait 3500
		endwhile
		set cmdSucceed = cmdSucceed + 1 
	endif
endif

verify beacon_pwr_status_daxss == 1

;Aliveness
call Scripts/DAXSS/aliveness_daxss

;CMD tests
call Scripts/DAXSS/daxss_x123_cmd_test
call Scripts/DAXSS/daxss_sps_picosim_cmd_test
call Scripts/DAXSS/daxss_cdh_cmd_test

;Stimulated Responses
echo Populate Stimulated Responses for DAXSS in the CPT document
pause

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SD_HK rate 3 stream DBG
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set writeDAXSSnum = beacon_sd_write_scid - $writeDAXSSstart
set writeDAXSSnum = $writeDAXSSnum % sd_partition_size2
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_sd_playback stream UHF start $writeDAXSSstart num $writeDAXSSnum timeout 600 partition 2 decimation 1
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
tlmwait sd_partition_pbk2 == ( $writeDAXSSstart + $writeDAXSSnum ) % sd_partition_size2 ? 600000
echo Verify UHF playback complete
pause

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SD_HK rate 0 stream DBG
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

;Closeout 

if beacon_pwr_status_daxss == 0
	if beacon_eclipse_state == 0
		set cmdCnt = beacon_cmd_succ_count + 1
		while beacon_cmd_succ_count < $cmdCnt
			cmd_mode_set apid 1 mode 3
			set cmdTry = cmdTry + 1
			wait 3500
		endwhile
		set cmdSucceed = cmdSucceed + 1 
	else
		set cmdCnt = beacon_cmd_succ_count + 1
		while beacon_cmd_succ_count < $cmdCnt
			cmd_mode_set apid 1 mode 4
			set cmdTry = cmdTry + 1
			wait 3500
		endwhile
		set cmdSucceed = cmdSucceed + 1 
	endif
endif

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 178 rate 0 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 176 rate 0 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

FINISH:
echo COMPLETED DAXSS Command Test Scripts