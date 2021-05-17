;MINXSS Deploy Solar Arrays
;Purpose: Deploy solar arrays for Commissioning
;Outline
;	Check for command ability (route HK and ADCS packets to BOTH)
;	Deploy solar array
;	Verify that current went up
;	Check EPS tlm
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14
declare preCurrent1  EPS_Batt_Discharge    ; MINXSSEpsBatteryDischarge
;  ERROR so comment out
; declare preCurrent2  EPS_SA_I5			   ; MINXSSEpsBatteryAmp

echo Press GO when ready to start the Commission_Deploy_Arrays script
pause

echo STARTING Commission_Deploy_Arrays  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until MinXSS responds
call Scripts/hello_minxss

SET_ROUTING:

set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_adcs_pkt Route BOTH
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

CHECK_MODE_VALID:
; Wait for Safe Mode (2)
verify MINXSSCDHMode_Tlm_All == 2

; Wait for Sun Point angle less than 10 degrees
echo  NOTE that you may have to GO at this point if just doing GROUND test.
verify MINXSSSunPointAngleError <= 10

; check that solar X panel has power (in sunlight) before deploying
;  *****  Is this SA 1, 2, or 3 ? *****
verify MINXSSEpsSa2Amp >= 200.
verify MINXSSEpsSa2Volt >= 5.0

echo Press GO when ready to DEPLOY the solar arrays
echo NOTE that only 60% of commands get through when ADCS packets are transmitted.
pause

DEPLOY_ARRAYS:
;  assume current will go up by 35 mA (factor of 2 margin)
set preCurrent1 = MINXSSEpsBatteryDischarge + 15
;   ERROR so comment out
; set preCurrent2 = MINXSSEpsBatteryAmp + 15

set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	deploy_solar_arrays
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

;		Works OK but not reliable timing
tlmwait MINXSSEpsBatteryDischarge >= preCurrent1 ? 20000
;		Works BEST for waiting until arrays are deployed
tlmwait MINXSSSADeployEnabled == 0 ? 20000

if MINXSSEpsSa1Amp <= 200. 
	echo WARNING: Solar array 1 (-Y) still not getting current
	echo Press GO to command deploy again
	pause
	goto DEPLOY_ARRAYS
endif
if MINXSSEpsSa3Amp <= 200. 
	echo WARNING: Solar array 3 (+Y) still not getting current
	echo Press GO to command deploy again
	pause
	goto DEPLOY_ARRAYS
endif

TLM_CHECK:
; Check EPS values that are in HK packets
call Scripts/eps_tlm_check

FINISH:

echo COMPLETED Commission_Deploy_Arrays script

print cmdTry
print cmdSucceed