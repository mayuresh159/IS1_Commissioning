; IS-1 Commissioning Scripts
; Purpose: Set ADCS time according to system time / UTC time
; Script name: adcs_set_tai_time
; OUTLINE: Use cmd_adcs_Time_SetCurrentTimeTAI command to upload current system time to ADCS
;   1. Send TAI time

declare cmdNumTry dn32l
declare waitInterval dn32l
declare cmdADCSCnt dn32l
declare cmdADCSTry dn32l
declare cmdADCSTryAll dn32l

set waitInterval = 5000
set cmdNumTry = 10
set cmdADCSTryAll = 0

echo This script assumes Tx only mode while sending commands
echo This script will send the ADCS TAI time command $cmdNumTry times
echo Press GO to set ADCS TAI time
pause

ADCS_TIME:
set cmdADCSTry = 0

; 1. Upload the latest time to ADCS and confirm if it updated
set cmdADCSCnt = beacon_adcs_cmd_acpt
echo Current ADCS command accepted counter: $cmdADCSCnt

while cmdADCSTry < cmdNumTry
	print taiTime
    cmd_adcs_Time_SetCurrentTimeTai Time taiTime
    set cmdADCSTry = cmdADCSTry + 1
    set cmdADCSTryAll = cmdADCSTryAll + 1
    wait $waitInterval
endwhile

VERIFY_TIME:
echo Switch back to Rx mode then press GO to verify
echo ADCS time
pause

echo Confirm if ADCS time valid flag is set
set cmdADCSCnt = beacon_adcs_cmd_acpt
echo Current ADCS command accepted counter: $cmdADCSCnt
verify beacon_adcs_time_valid == 1


echo Confirm if the ADCS time is valid
echo If not, GOTO ADCS_TIME to send the command again
echo If time is valid GOTO finish and proceed with
echo ephemeris load, if there is extra time in the pass 
pause

FINISH:
echo Set ADCS time finished with
echo Tries - $cmdADCSTryAll
