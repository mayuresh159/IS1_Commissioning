; IS-1 Commissioning Scripts
; Purpose: Set ADCS time according to system time / UTC time
; Script name: commission_set_adcs_time
; OUTLINE: Use cmd_adcs_Time_SetCurrentTimeUtc command to upload current system time to ADCS
;   1. Route fast beacon packets
;   2. Route ADCS packets: adcs_hk, adcs_time
;   3. Show adcs_hk and adcs_time pages
;   4. Grab system time
;   5. Send UTC time

declare cmdCnt dn32l
declare cmdTry dn32l
declare cmdSucceed dn32l
declare waitInterval dn32l
declare cmdADCSCnt dn32l
declare cmdADCSTry dn32l
declare cmdADCSSucceed dn32l

; Define time variables
declare currTimemSec dn32b
declare currTimeDay dn32b
declare currTimeSecJ2000 dn32b

declare ephYear dn32b
declare ephMonth dn32b
declare ephDay dn32b
declare ephHour dn32b
declare ephMinute dn32b
declare ephSecond dn32b

; extra variables
declare ephMinuteexcess dn32b
declare ephSecexcess dn32b
declare ephTotSec dn32b

; Change these variables depending on the month and year
set ephYear = 21
set ephMonth = 08

set cmdTry = 0
set cmdADCSTry = 0
set cmdSucceed = 0
set cmdADCSSucceed = 0
set waitInterval = 3500

; Check visibility of satellite
call hello_is1

; 1. Increase beacon rate
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid SW_STAT rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

; 2. Route ADCS packets
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid ADCS_HK rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid ADCS_TIME rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

; 3. Open ADCS_TIME page
show_page adcs_hk
show_page adcs_time
echo Open ADCS_HK and ADCS_TIME pages to verify if the time value is old
pause

; 4. Grab the current system time
; Stamp current time and day
set currTimemSec = systemTimemSec
set currTimeDay = systemTimeDay
set currTimeSecJ2000 = systemTimeSecJ2000

echo Select the method of programming time
echo If using UTC jump to UTC, else press GO
pause

TAI:
echo Current TAI time - $currTimeSecJ2000
echo Confirm and press GO to program
pause
; 5. Upload the latest time to ADCS and confirm if it updated
set cmdADCSCnt = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < cmdADCSCnt
    cmd_adcs_Time_SetCurrentTimeTai Time $currTimeSecJ2000
    set cmdADCSTry = cmdADCSTry + 1
    wait $waitInterval
endwhile
set cmdADCSSucceed = cmdADCSSucceed + 1

echo Confirm if ADCS time valid flag is set
verify beacon_adcs_time_valid == 1

echo Confirm if the ADCS time follows the system UTC time
echo If not, send the command again
pause

GOTO FINISH


UTC:
; Convert current time into ephemeris time
set ephDay = currTimeDay + 1

set ephTotSec =  currTimemSec / 1000
set ephHour = ephTotSec / 3600

set ephMinuteexcess = ephTotSec % 3600
set ephMinute = ephMinuteexcess / 60
; Compensate for UTC time by substracting 5:30 from IST
; Compensate minutes
if ephMinute < 30
    set ephMinute = ephMinute + 30
    if ephHour < 1
        set ephHour = ephHour + 23
    else
        set ephHour = ephHour - 1
    endif
else
    set ephMinute = ephMinute - 30
endif
; Compensate hours
if ephHour < 5
    set ephHour = ephHour + 19
    set ephDay = ephDay - 1
else
    set ephHour = ephHour - 5
endif

set ephSecond = ephTotSec % 60

echo Current UTC time - $ephYear, $ephMonth, $ephDay, $ephHour, $ephMinute , $ephSecond
echo Confirm and press GO to program
pause

; 5. Upload the latest time to ADCS and confirm if it updated
set cmdADCSCnt = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < cmdADCSCnt
    cmd_adcs_Time_SetCurrentTimeUtc year $ephYear mon $ephMonth day $ephDay hour $ephHour min $ephMinute sec $ephSecond
    set cmdADCSTry = cmdADCSTry + 1
    wait $waitInterval
endwhile
set cmdADCSSucceed = cmdADCSSucceed + 1

echo Confirm if the ADCS time valid flag is set
verify beacon_adcs_time_valid == 1

echo Confirm if the ADCS time follows the system UTC time
echo If not, send the command again
pause


FINISH:
; 6. Unroute ADCS packets
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid ADCS_HK rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid ADCS_TIME rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

; Set beacon packets to 10 seconds
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid SW_STAT rate 10 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

echo Set ADCS time succeeded with
echo Tries - $cmdTry + $cmdADCSTry
echo Success - $cmdSucceed + $cmdADCSSucceed
