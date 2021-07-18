;EPS_CMD_TEST Procedure
;Purpose: Test EPS related FSW functions (commands and telemetry)
;Outline
;		Verify EPS Telemetry
;		Verify Heater Control - Battery and Payload
;
;		OPTIONAL:  Test Deployments
;
;  Commands Tested
;
;		OPTIONAL:  deploy_antenna    deploy_solar_arrays
;
;	EPS Telemetry Points are Verified in Scripts\eps_tlm_check
;
; MODIFICATION HISTORY: 
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare epsWriteStart dn32l
declare epsWriteNum dn32l
declare eclipseThresh dn16l
declare eclipseThreshNew dn16l

echo Press GO to test EPS commands (power cycle, heaters)
pause

START:
echo Starting EPS Command Test

set epsWriteStart = beacon_sd_write_misc
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid 2 rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 2 rate 1 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

;Get beacon packet to debug every 3 seconds
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 1 rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

;Issue one becon pkt to UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_issue_pkt apid 1 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

PKT_CHECK:
;  Verify that EPS HK Packet telemetry items are correct
call Scripts\UHF\uhf_eps_tlm_check

;*****NEEDS UPDATING AFTER BATTERY SETPOINT IS MADE*****
BATTERY:
call Scripts\UHF\uhf_battHtr_test

SD_CARDS:
call Scripts\UHF\uhf_eps_sd_card_power_test

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid 2 rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

echo EPS primary tests are complete
echo ****It is recommended to wait for deployment to happen
echo automatically after launch timer expires if doing a CPT****
echo Or select GO if you want to manually DEPLOY components
echo Or select GOTO ECLIPSE_THRESH to skip Deployment tests
pause

MANUAL:
call Scripts\UHF\uhf_deployment_test

ECLIPSE_THRESH:
set eclipseThresh = eps_eclipse_threshold / 0.0005
set eclipseThreshNew = eps_eclipse_threshold / 0.0005 + 10

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_eps_eclipse_thresh threshold $eclipseThreshNew
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
wait 3500
verify eps_eclipse_threshold == eclipseThreshNew * 0.0005

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_eps_eclipse_thresh threshold $eclipseThresh
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
wait 3500
verify eps_eclipse_threshold == eclipseThresh * 0.0005

CLOSEOUT:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
    cmd_set_pkt_rate apid SD_HK rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set epsWriteNum = beacon_sd_write_misc - $epsWriteStart
set epsWriteNum = $epsWriteNum % sd_partition_size0
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_sd_playback stream UHF start $epsWriteStart num $epsWriteNum timeout 600 partition 0 decimation 1
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
tlmwait sd_partition_pbk0 == ( $epsWriteStart + $epsWriteNum ) % sd_partition_size0 ? 600000
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

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid 2 rate 0 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
FINISH:
echo EPS test complete

print cmdTry
print cmdSucceed