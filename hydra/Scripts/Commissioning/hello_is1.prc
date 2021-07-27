; IS-1 Commissioning Scripts
; Purpose: Wait till the latest beacons update
; Script name: hello_is1
; OUTLINE: Keep waiting in a while loop unless there are latest beacon packet updates
;

declare cmdCnt dn32l
declare cmdTry dn32l
declare cmdSucceed dn32l
declare waitInterval dn32l

set cmdTry = 0
set cmdSucceed = 0

declare secNew dn32l
declare secOld dn32l
declare secDiff dn32l

set secDiff = 0
set secOld = 0
set secNew = 0
set waitInterval = 5000

while secDiff == 0
    set secNew = ccsdsTlmHeader_sec_beacon
    set secDiff = $secNew - $secOld
    wait $waitInterval
    set secOld = $secNew
endwhile

; Try a NoOp command to be sure that the command counter increments
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_noop
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

echo Congratulations
echo IS-1 beacons detected successfully and commanding verified !!!
echo Can start other scripts now
