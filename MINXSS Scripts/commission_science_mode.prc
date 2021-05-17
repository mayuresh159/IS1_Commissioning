;
; NAME:
;   commission_science_mode
;
; PURPOSE:
;   Go to science mode and checkout instruments.
;
; ISSUES:
;
; MODIFICATION HISTORY
;   2015/03/25: James Paul Mason: Initial script
;	2015/08/11: Tom Woods: updates for calling hello_minxss and having FINISH section
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l

echo Press GO when ready to start the Commission_Science_Mode script
pause

echo STARTING Commission_Science_Mode  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until MinXSS responds
;call Scripts/hello_minxss

START_ROUTING:

; Start science packet routing - no Science packets yet, so skip this one
;set cmdCnt = MINXSSCmdAcceptCnt + 1
;while MINXSSCmdAcceptCnt < $cmdCnt
;	set cmdTry = cmdTry + 1
;	route_sci_pkt Route 3
;	wait 3529
;endwhile
;set cmdSucceed = cmdSucceed + 1

; Start adcs packet routing
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_adcs_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

VERIFICATIONS:

; If we're in eclipse, suggest skipping this script
if MINXSSCDHEclipse_Tlm_All == 1
	echo Housekeeping indicates we're currently in eclipse. Are you sure you want to run this script?
	pause
endif

; Verify that we are in fine reference mode
if MINXSSADCSMode_Tlm_All != 1
	echo XACT ADCS is not in Fine Point. Are you sure you want to run this script?
	pause
endif

; Verify that our attitude error on the Sun is < 5 degrees
if MINXSSSunPointAngleError <= 5
	echo Present attitude error on sun is < 5 degrees.
	echo You can also confirm that this is TRUE with SPS data (offsets less than 4000)
else
	echo Present attitude error on sun is > 5 degrees.  Do you want to continue?
	pause
endif

; Verify that the battery voltage is > 7.5 V
verify MINXSSEpsFgBatteryV >= 7.5

SCIENCE_MODE:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	set_mode_sci
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

;  verify that Mode is SCIENCE now
tlmwait MINXSSCDHMode_Tlm_All == 4

; Start HK packet routing (setting Science mode turns off COMM routing)
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_hk_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Start adcs packet routing (setting Science mode turns off COMM routing)
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_adcs_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

;	note that sps_tlm_check will start up SCI routing

INSTRUMENT_CHECKOUT:
call sps_tlm_check
call x123_tlm_check

echo MinXSS is now at least 90% successful!
echo Prepare the champagne!!

FINISH:

echo COMPLETED Commission_Science_Mode  script

print cmdTry
print cmdSucceed