;MINXSS Commissioning Wrapper
;Purpose: Commission MinXSS-2 after deployment
;Outline:
;	
;
declare cmdCnt dn16l

echo Press GO to start MinXSS commissioning
pause

HELLO_MINXSS:
;Wait until MinXSS responds
call hello_minxss

ALIVENESS:
echo Press GO to start spacecraft aliveness checks or GOTO next commissioning activity
pause
if MINXSSCDHMode_Tlm_All == 1
	echo MinXSS is in PHOENIX Mode
	call commission_aliveness_phoenix
else
	if MINXSSCDHMode_Tlm_All == 2
		echo MinXSS is in SAFE Mode
		call commission_aliveness_safe
	else
		if MINXSSCDHMode_Tlm_All == 4
			echo MinXSS is in SCIENCE Mode
			echo GOTO INST_ALIVENESS to check out instruments or continue with wrapper
			pause
		else
			echo MinXSS is in an UNKNOWN Mode!!!
			pause
		endif
	endif
endif

CANCEL_DEPLOY_RETRY:
echo Press GO to cancel deployment retry
echo Verify that solar arrays are deployed before proceeding or jump to next commissioning activity
pause
echo Canceling deployment retry
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	cancel_ant_deploy_retry
	wait 9100
endwhile


SET_TIME:
echo Press GO to set spacecraft time or GOTO next commissioning activity
pause
if MINXSSCDHMode_Tlm_All == 1
	echo MinXSS is in PHOENIX Mode
	echo Setting spacecraft time which will set ADCS time at transition to SAFE
	call commission_set_spacecraft_time
else
	if MINXSSCDHMode_Tlm_All == 2
		echo MinXSS is in SAFE Mode
		echo Setting Spacecraft and ADCS Time
		call commission_set_adcs_time
	else
		if MINXSSCDHMode_Tlm_All == 4
			echo MinXSS is in SCIENCE Mode
			echo Press GO to set S/C and ADCS time if you haven't done so prior
			pause
			call commission_set_adcs_time
		else
			echo MinXSS is in an UNKNOWN Mode!!!
			pause
		endif
	endif
endif

DEPLOYMENT_DATA:
;****playback_deployment_data requires the input of the SD offsets at delivery****
echo Edit the playback_deployment_data script with the delivery SD offsets before proceeding
echo Press go to playback deployment data or GOTO next commissioning activity
pause
call playback_deployment_data

CONFIG_ADCS:
;****commission_set_ephemeris requires the input the spacecraft ephemeris during the pass****
echo Edit the commission_set_ephemeris script with the correct ephemeris before proceeding
echo Press go to load ephemeris or GOTO next commissioning activity
pause
call commission_set_ephemeris

echo Press go to enter FINE POINT
pause
call commission_test_fine_point

INST_ALIVENESS:
echo Press go to checkout insturments or GOTO next commissioning activity
pause
if MINXSSCDHMode_Tlm_All == 1
	echo MinXSS is in PHOENIX Mode
	echo MinXSS Should be in SAFE or SCIENCE and FINE POINT before starting this test
	pause
else
	call commission_instrument_aliveness
endif

SCIENCE:
echo Press GO to goto SCIENCE or GOTO next commissioning activity
pause
if MINXSSCDHMode_Tlm_All == 2
	call commission_science_mode
else
	if MINXSSCDHMode_Tlm_All == 1
		echo MinXSS is in PHOENIX mode
		echo To do this test, run the tests earlier in this wrapper
		pause
	else
		if MINXSSCDHMode_Tlm_All == 4
			echo MinXSS is in SCIENCE mode already
			echo Do you still want to run this test?
			pause
			call commission_science_mode
		else
			echo MinXSS is in an UNKNOWN State!!!
			pause
		endif
	endif
endif

X123_THRESH:
echo Press GO to adjust X123 thresholds or GOTO next commissioning activity
pause
if MINXSSCDHMode_Tlm_All == 4
	call commission_x123_thresholds
else
	echo MinXSS should be in SCIENCE mode to perform this test
	pause
endif

24HR_PLAYBACK:
echo press go to playback last 24hrs or GOTO FINISH
pause
call playback_all_data_last_24_hours

FINISH:
echo COMPLETED commission_minxss


