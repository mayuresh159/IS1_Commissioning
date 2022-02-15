; IS-1 Commissioning Scripts
; Purpose: Wait till the latest beacons update
; Script name: hello_is1
; OUTLINE: Keep waiting in a while loop unless there are latest beacon packet updates
;
; 13-02-2022:	Robert Sewell	Edited to send beacon instead of noop (check mode)
;								route to 3 second beacons, sends sd card packet 
;								(checks status) and clears sd error counter 

declare cmdCnt dn32l
declare cmdTry dn32l
declare cmdSucceed dn32l
declare waitInterval dn32l
declare pktRateNew dn32l
declare pktRateDefault dn32l
declare modeError dn32l
declare sdError dn32l

set sdError = 0
set cmdTry = 0
set cmdSucceed = 0

declare secNew dn32l
declare secOld dn32l
declare secDiff dn32l

set secDiff = 0
set secOld = 0
set secNew = 0
set pktRateNew = 5 ;in seconds
set pktRateDefault = 10 ;in seconds
set waitInterval = 5500 ;in miliseconds

echo STARTING hello_is1
echo sending hk packet every 5 seconds

ISSUE_HK:

while secDiff == 0
    cmd_issue_pkt apid SW_STAT stream UHF
    set cmdTry = cmdTry + 1
    set secNew = ccsdsTlmHeader_sec_beacon
    set secDiff = $secNew - $secOld
    wait $waitInterval
    set secOld = $secNew
endwhile
set cmdSucceed = cmdSucceed + 1

wait $waitInterval
if beacon_mode == 0
    echo IS1 in PHOENIX Mode!!! Need to diagnose
    set modeError = 1
endif

INCREASE_RATE:
; We got a beacon, so now route beacons every 5 seconds
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid SW_STAT rate $pktRateNew stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

ISSUE_SD_HK:
; Send the command to get sd card hk
set cmdCnt = beacon_cmd_succ_count + 1
set secDiff = 0
set secOld = 0
set secNew = 0
while secDiff == 0
    set cmdTry = cmdTry + 1
    cmd_issue_pkt apid SD_HK stream UHF
    set secNew = ccsdsTlmHeader_sec_sd_hk
    set secDiff = $secNew - $secOld
    wait $waitInterval
    set secOld = $secNew
endwhile
set cmdSucceed = cmdSucceed + 1

;If flash is selected, notify operator that cards need to be recovered

if sd_card_sel == 2
    echo FLASH SELECTED!!! Need to recover SD cards
    set sdError = 1
endif

CLEAR_FDRI:
;clear sd fdri counter
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_sd_fdri_reset
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

echo IS-1 beacons detected successfully and commanding verified 

if modeError == 1
    echo IS1 in PHOENIX!!!
    echo Consider diagnosing before starting other scripts
endif 
if sdError == 1
    echo SD cards are in ERROR!!!
    echo Consider recovering from FLASH before starting other scripts
endif

echo If you are running other scripts this pass:
echo GOTO finish or return from this script
echo Else we will set the beacon rate to 10 seconds after 1 min
wait 60000

RETURN_RATE:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid SW_STAT rate $pktRateDefault stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

FINISH:
print cmdTry
print cmdSucceed
