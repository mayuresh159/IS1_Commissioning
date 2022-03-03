;Commission DAXSS THSL No Rx
;Purpose: Loop to change X123 slow threshold
;         in safe mode with no Rx (due to command difficulties)
;Outline
;    Send command to change THSL 
;
; 03-03-2022: Robert Sewell		Created for IS-1 commissioning

declare cmdLoopCnt dn16l
declare cmdLoopMax dn16l
declare setTHSL float32
declare waitInterval dn32l

;Set to 1.5% (THSL=1.5) per email with Woods and Caspi on 03/03/2022
;Typically we loop over THSL values until slow_count<10 in dark
;But we can't currently do this without ADCS being able to off point
;and with current IIST mode of uplink only 
;Ground default value for DAXSS (FM4) is THSL=0.622   

set setTHSL = 1.5
set waitInterval = 10000
set cmdLoopCnt = 0
set cmdLoopMax = 8

echo ______________________________________________________
echo STARTING commission_daxss_thsl_no_rx
echo This will change DAXSS X123 slow threshold to $setTHSL
echo Requires X123 to be ON before sending this command
echo Please record the IS-1 SCI-D write pointer before 
echo running this script
echo ______________________________________________________

SET_THSL:
echo Press GO to change the slow threshold
pause
while cmdLoopCnt < cmdLoopMax
    cmd_daxss_send_x123 cmd "THSL= $setTHSL ;"
    set cmdLoopCnt = cmdLoopCnt + 1
    wait $waitInterval
endwhile

FINISH:
echo THSL Command set for THSL=$setTHSL
echo ____________________________________________________ 
echo Please do a playback of IS-1 SCI-D partition 
echo at the soonest convenient pass to so this change can
echo be verified  
echo ____________________________________________________   
pause