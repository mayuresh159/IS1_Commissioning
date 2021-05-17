;MINXSS Commissioning script to set spacecraft time
;Purpose: Set spacecraft time
;Outline
;	Check for command ability
;	Power off ADCS
;	Set Spacecraft Time
;	Power on ADCS so it will get the CDH time
;
;	Edited Jan 18, 2016 so ADCS is NOT power cycled, so only CDH time is set (T. Woods, BCT recommendation)

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14
declare adcsState trueFalse1
declare difftime dn32

echo Press GO when ready to start the Commission_Set_Spacecraft_Time script
; echo WARNING!!!!!!!!! This will power off the ADCS while setting time
pause

echo STARTING Commission_Set_Spacecraft_Time  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until MinXSS responds
;call Scripts/hello_minxss

; remember ADCS state before setting time
set adcsState = MINXSSADCSEnabled

SET_TIME:
;if adcsState == trueFalse(TRUE)
		;  turn off ADCS before setting Time
;	while MINXSSADCSEnabled == trueFalse(TRUE)
;		set cmdTry = cmdTry + 1
;		switch_power_adcs PowerDirection 0
;		wait 3529
;	endwhile
;	set cmdSucceed = cmdSucceed + 1
;endif

set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	set_spacecraft_time_now
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

;if adcsState == trueFalse(TRUE)
	;  turn on ADCS after setting Time if it was on before setting time
;	while MINXSSADCSEnabled == trueFalse(FALSE)
;		set cmdTry = cmdTry + 1
;		switch_power_adcs PowerDirection 1
;		wait 3529
;	endwhile
;	set cmdSucceed = cmdSucceed + 1
;endif

set difftime = gpsTime - MINXSSTimeGS_Tlm_All
if difftime < 0 
	difftime = difftime * (-1) 
endif

if difftime < 20
	echo Spacecraft Time has been successfully set.
else 
	echo Spacecraft Time Set Failed
	pause
endif

FINISH:

echo COMPLETED Commission_Set_Spacecraft_Time script

print cmdTry
print cmdSucceed
