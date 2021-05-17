;MINXSS Commissioning script to set BCT XACT ADCS time
;Purpose: SetADCS time
;Outline
;	Check for command ability
;	Set ADCS Time using its SetCurrentTimeUtc command
;	Also has option to set Spacecraft (CDH) time (recommended)
;
;	****  CRITICAL -  edit the UTC time during the pass to start this script before running this script
;	****              This UTC time is listed on Lines 30-35 below
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14
declare xactCmdCnt dn16
declare adcsState trueFalse1

; variables for setting time for ADCS
;declare gpsTimeNow dn32
;declare nowYear dn16
;declare nowMonth dn16
;declare nowDay dn16
;declare nowHour dn16
;declare nowMinute dn16
;declare nowSecond dn16

; Use UTC time instead as Ephemeris also needs UTC time
;	*****  Lines 30-35 MUST be edited as Time During Pass when you will click GO button *****
;set nowYear = 16
;set nowMonth = 4
;set nowDay = 29
;set nowHour = 15
;set nowMinute = 35
;set nowSecond = 0

echo Press GO when ready to start the Commission_Set_ADCS_Time script
;echo WARNING !!!!!  You have to edit this script before running it to ;set the near-future UTC time
pause

echo STARTING Commission_Set_Spacecraft_Time  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until MinXSS responds
;call Scripts/hello_minxss

; note ADCS state before setting time
set adcsState = MINXSSADCSEnabled

; Start hk packet routing
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_hk_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Start adcs packet routing
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_adcs_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

;echo MinXSS Communication has been established.
;echo Press GO at two seconds prior to the UTC time that you edited in this script.
;echo WARNING!!!!!!!!! if you miss the Script TIME, then  re-edit Script and re-run it.
;pause

SET_TIME:
if adcsState == trueFalse(TRUE)
	;  set ADCS UTC time now if ADCS is actually on

	set xactCmdCnt = MINXSSXactCmdAccept + 1
	set cmdTry = cmdTry + 1
	while MINXSSXactCmdAccept < $xactCmdCnt
		adcs_SetCurrentTimeGPS Period gpsTime
		wait 5000
	endwhile
	set cmdSucceed = cmdSucceed + 1
	wait 3529
	if MINXSSADCSTimeValid_ADCS1 == 1
		echo ADCS time is valid
	else
		echo ADCS time is invalid!
		echo GOTO SET_TIME to try setting the time again
		pause
	endif
else
	echo ERROR in setting ADCS Time because ADCS unit is OFF !
endif

;
;	Also send the command to Reinitialize Tracker every 5 minutes (Period=1500)
;
echo Sending ADCS command to reinitialize Star Tracker every 5 minutes
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	adcs_TrackerCtrlAutoSoftReinit Period 1500
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo Press GO if you want to set the Spacecraft (CDH) time now.  Else goto FINISH.
pause

set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	set_spacecraft_time_now
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

FINISH:

echo COMPLETED Commission_Set_ADCS_Time script

print cmdTry
print cmdSucceed
