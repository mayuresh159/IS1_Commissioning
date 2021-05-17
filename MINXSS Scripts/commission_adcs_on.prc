;
;	commission_adcs_on
;
;Purpose: Turn on ADCS and turn off Log routing
;
;		  The I2C bus hang on June 5, 2016 is motivation for this script to turn on ADCS in Phoenix Mode
;
;		  Other factors / options in this script are:
;		  *  atuo-demote Params need to be set to zero 
;		  *  set ephemeris and get some ADCS data
;
;Outline
;	Check for command ability
;
;	Turn on ADCS
;	
;	OPTION to set auto-demote Params to zero
;
;	OPTION to Set Ephemeris and route ADCS 
;
;History
;	2016/06/06   Tom Woods, original code
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14
declare xactCmdCnt dn16
declare adcsState trueFalse1

echo STARTING Commission_ADCS_On script

echo PRESS GO when Ready to Turn On ADCS (wait for Beacons and elevation > 30deg) 
pause

; Dummy command that will get skipped as soon as any packet gets through
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	issue_realtime_hk_packet
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

;	Turn on ADCS and also route LOG to SD-Card only and issue HK Packet as well
;
POWER:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_log_pkt Route 1
	wait 1400
	route_log_pkt Route 1
	wait 1400
	switch_power_adcs PowerDirection 1
	wait 1400
	issue_realtime_hk_packet
	wait 1400
	issue_realtime_hk_packet
	echo PRESS GO to attempt turning on ADCS again or GoTo PARAMS
	pause
endwhile
set cmdSucceed = cmdSucceed + 1


;	OPTION to set auto-demote Params to zero
;			set_safe_to_phoenix_soc
;			set_science_to_safe_soc
;			dump_param_set 
PARAMS:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	set_safe_to_phoenix_soc SOC 0
	wait 2900
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	set_science_to_safe_soc SOC 0 
	wait 2900
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	dump_param_set SetNumber 0 
	wait 2900
endwhile
set cmdSucceed = cmdSucceed + 1

echo  Verify Science-to-Safe and Safe-to-Phoenix values are now zero, then Press GO
pause

;	OPTION to Set Ephemeris 
;			be SURE that this has been updated with correct ephemeris value
;
LOAD:
call commission_fast_ephemeris

;	OPTION to Route ADCS data
;
ROUTE:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_adcs_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Cancel deployment retry
NO_RETRY:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	cancel_ant_deploy_retry
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

FINISH:
echo COMPLETED Commission_ADCS_On script

print cmdTry
print cmdSucceed
