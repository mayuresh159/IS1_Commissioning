;
; NAME:
;   commission_instrument_aliveness
;
; PURPOSE:
;   Make sure the instruments are doing alright now that they are in...
;	...
;	SPAAAAACE spaaaaace spaace aace aace
;
; ISSUES:
;
;
; MODIFICATION HISTORY
;   2015/03/25: James Paul Mason: Initial script
;	2015/08/11: Tom Woods: updates for calling hello_minxss and having FINISH section
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l

echo Press GO when ready to start the Commission_Instrument_Aliveness script
pause

echo STARTING Commission_Instrument_Aliveness  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until MinXSS responds
;call Scripts/hello_minxss

SCIENCE_MODE_CHECK:

; Check if MinXSS is in SCIENCE mode !
if MINXSSCDHMode_Tlm_All >= 3
	echo WARNING!! IN SCIENCE MODE! SHOULD BE RUN IN SAFE! DO YOU WANT TO CONTINUE?
	pause
endif
	

START_ROUTING:

set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_hk_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Start science packet routing
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_sci_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Start adcs packet routing
;set cmdCnt = MINXSSCmdAcceptCnt + 1
;while MINXSSCmdAcceptCnt < $cmdCnt
;	set cmdTry = cmdTry + 1
;	route_adcs_pkt Route 3
;	wait 3529
;endwhile
;set cmdSucceed = cmdSucceed + 1

VERIFICATIONS:

; Verify that the battery voltage is > 7.5 V
verify MINXSSEpsFgBatteryV >= 7.5
	
; If we're in eclipse, suggest skipping this script
if MINXSSCDHEclipse_Tlm_All == 1
	echo Housekeeping indicates we're currently in eclipse. Continuing on to instrument aliveness.
	GOTO INSTRUMENT_ALIVENESS
endif

; Verify that we are in sun-point mode
verify MINXSSADCSMode_Tlm_All == 0

; Verify that our attitude error on the Sun is < 10 degrees
if MINXSSSunPointAngleError <= 10
	echo Present attitude error on sun is < 10 degrees.
	echo You can also confirm that this is TRUE with SPS data (offsets less than 8000)
else
	echo Present attitude error on sun is > 10 degrees.  Do you want to continue?
	pause
endif


INSTRUMENT_ALIVENESS:

; Check out SPS
echo Checking out SPS. This will turn on X123 to get science packets
call sps_tlm_check

; Check out X123
echo Checking out X123.
call x123_tlm_check


echo Decision point. Do you want to turn the X123 back off or not?
pause

; Power off X123 - this is NOT needed if in SCIENCE mode !
if MINXSSCDHMode_Tlm_All < 3
	switch_power_x123 PowerDirection 0
	tlmwait MINXSSX123Enabled == 0
endif

echo MinXSS says, "My payloads be alright, matey"

FINISH:

; Stop science packet routing to RF
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_sci_pkt Route 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Stop adcs packet routing to RF
;set cmdCnt = MINXSSCmdAcceptCnt + 1
;while MINXSSCmdAcceptCnt < $cmdCnt
;	set cmdTry = cmdTry + 1
;	route_adcs_pkt Route 1
;	wait 3529
;endwhile
;set cmdSucceed = cmdSucceed + 1

; hk packet routing to beacon
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_hk_pkt Route 5
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo COMPLETED Commission_Instrument_Aliveness script

print cmdTry
print cmdSucceed