;
; NAME:
;   commission_test_fine_point
;
; PURPOSE:
;   Command into fine sun point and do basic check out of performance
;	Do this as fast as possible with minimal checks / dependence on beacons
;
; ISSUES:
;
;
; MODIFICATION HISTORY
;   2015/03/24: James Paul Mason: Initial script
;	2015/08/11: Tom Woods: updates for calling hello_minxss and having FINISH section
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare xactCmdCnt dn16

echo Press GO when ready to start the Commission_Fast_Fine_Point script
pause

echo STARTING Commission_Fast_Fine_Point  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until MinXSS responds
;call Scripts/hello_minxss

START_ROUTING:
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
	echo WARNING:  Housekeeping indicates we're currently in eclipse.
	pause
endif

; Verify that we are in sun-point mode
if MINXSSADCSMode_Tlm_All != 0
	echo WARNING:  ADCS is not in Sun-Point (safe) mode.
endif

; Verify that our attitude error on the Sun is < 10 degrees
if MINXSSSunPointAngleError <= 10
	echo Present attitude error on sun is < 10 degrees.
	echo You can also confirm that this is TRUE with SPS data (offsets less than 8000)
else
	echo WARNING:  Present attitude error on sun is > 10 degrees
	echo Do you want to continue?
	pause
endif

; Verify that ADCS time is valid
if MINXSSADCSTimeValid_ADCS1 == 1
	echo ADCS time is valid... continuing onward! 
else
	echo ADCS time is not valid! 
	echo You should not proceed because ADCS can't get to fine refernece
	pause
endif

; Verify that ADCS ephemeris is valid
if MINXSSADCSRefsValid_ADCS1 == 1
	echo ADCS ephemeris is valid.. continuing onward!
else
	echo ADCS ephemeris is not valid!
	echo You should not proceed because ADCS can't get to fine reference
	pause
endif

; Verify that ADCS star tracker attitude is valid
if MINXSSADCSAttitudeValid_ADCS1 == 1
	echo ADCS star tracker attitude is valid.. continuing onward!
else
	echo WARNING: ADCS star tracker attitude is not valid!
	echo You should not proceed because ADCS can't get to fine reference
	pause
endif

; Verify that total system momentum is < 0.008 Nms (which is 64 [milli-Nms]^2 for our ISIS variable)
if TotalMomentum2 <= 64.0
	echo According to ADCS, total system momentum is acceptable at this time.. continuing onward! 
else
	echo WARNING: ADCS says total system momentum is too high. 
	echo Recommend aborting process to go to fine point. Consult BCT. 
	pause
endif

COMMAND_TO_FINE_POINT:
echo WARNING: Commanding to Fine Sun Point now
echo Ready to command to fine sun point? Press GO
echo Note that this command is also sent by FSW when going to science
pause
set xactCmdCnt = MINXSSXactCmdAccept + 1
while MINXSSXactCmdAccept < $xactCmdCnt
	set cmdTry = cmdTry + 1
	adcs_GotoFineSunPoint VelAber ENABLE SecRefDir 6:Pos PriCmdDir 1:[1,0,0] SecCmdDir 2:[0,1,0] YawAngle 0
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Wait until in fine reference point
tlmwait MINXSSADCSMode_Tlm_All == 1

echo Fine sun pointing achieved. Recommend downlinking performance data on next pass.
echo Performance data would be SPS position in hk and MINXSSSunPointAngleError in ADCS Page 4

FINISH:

echo COMPLETED Commission_Fast_Fine_Point script

print cmdTry
print cmdSucceed