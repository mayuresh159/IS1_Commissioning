; IS-1 Commissioning Scripts
; Purpose: Set DAXSS time according to system time / UTC time
; Script name: commission_set_daxss_time
; OUTLINE: Use cmd_daxss_set_time command to upload current system time to DAXSS
;          The time has to be uploaded in seconds from J2000 epoch/ GPS seconds
;   1. Route fast beacon packets
;   2. Route DAXSS packets - no need, daxss time visible in beacon detailed packet
;   3. Grab system time
;   4. Send DAXSS time
;   5. Reduce beacon packet rate


declare cmdCnt dn32l
declare cmdTry dn32l
declare cmdSucceed dn32l
declare waitInterval dn32l

; Define time variables
declare currTimeSec dn32b

set cmdTry = 0
set cmdSucceed = 0
set waitInterval = 3500

; Check visibility of satellite
; call hello_is1

; 1. Increase beacon rate
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid SW_STAT rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

; 2. Route DAXSS packets
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid DAXSS_HK rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

; 3. Grab system time
set currTimeSec = systemTimeSecJ2000
echo Seconds since J2000 - $currTimeSec
echo Confirm and press GO to program
pause

; 4. Set DAXSS GPS time
set cmdCnt = daxss_cmd_succ + 1
while daxss_cmd_succ < cmdCnt
    cmd_daxss_set_time time $currTimeSec
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1
echo Command for DAXSS time update sent
echo Confirm if the DAXSS time has been set correctly from beacon page
pause


FINISH:
; 5. Stop daxss packet routing and reduce beacon rate
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid DAXSS_HK rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid SW_STAT rate 10 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

echo Set DAXSS time succeeded with Tries = $cmdTry, Success = $cmdSucceed
