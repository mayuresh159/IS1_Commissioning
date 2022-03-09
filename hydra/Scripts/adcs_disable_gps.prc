; IS-1 Commissioning Scripts
; Purpose: Disable ADCS GPS
; Script name: adcs_disable_gps
; OUTLINE: Use cmd_adcs_GPS_GpsEnable command to diable ADCS 
; (GPS is non-functional since before flight)
;   1. Send cmd_adcs_GPS_GpsEnable Setting 0 

declare cmdNumTry dn32l
declare waitInterval dn32l
declare cmdADCSCnt dn32l
declare cmdADCSTry dn32l
declare cmdADCSTryAll dn32l

set waitInterval = 5000
set cmdNumTry = 10
set cmdADCSTryAll = 0

echo This script assumes Tx only mode while sending commands
echo This script will send the ADCS cmd_adcs_GPS_GpsEnable command 
echo with Setting 0 to DISABLE GPS
echo Press GO to DISABLE GPS
pause

ADCS_GPS_DISABLE:
set cmdADCSTry = 0

; 1. disable GPS
set cmdADCSCnt = beacon_adcs_cmd_acpt
echo Current ADCS command accepted counter: $cmdADCSCnt

while cmdADCSTry < cmdNumTry
    cmd_adcs_GPS_GpsEnable Setting 0
    set cmdADCSTry = cmdADCSTry + 1
    set cmdADCSTryAll = cmdADCSTryAll + 1
    wait $waitInterval
endwhile

VERIFY_DISABLE:
echo Switch back to Rx mode then press GO to verify
echo GPS DISABLE
pause

echo Confirm if ADCS command counter has incremented
set cmdADCSCnt = beacon_adcs_cmd_acpt
echo Current ADCS command accepted counter: $cmdADCSCnt
pause


echo Confirm if the ADCS GPS is DISABLED
echo If not, GOTO ADCS_GPS_DISABLE to send the command again
echo If commands were accepted proceed with and if there is 
echo extra time in the pass, press GO and proceed 
echo with the next planned activity
pause

FINISH:
echo Set ADCS time finished with
echo Tries - $cmdADCSTryAll
