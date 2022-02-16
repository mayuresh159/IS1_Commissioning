; IS-1 Commissioning Scripts
; Purpose: First pass of INSPIRESat-1
; Script name: hello_is1_pass_1_IIST
;
; MANAGEMENT:
; 1. Hydra Operator (Commander): Dhruva Anantha Datta (IIST)
; 2. GNU radio Operator; Murala Aman Naveen (IIST)
; 3. GS Superviser; Raveendranath Sir (IIST) and Joji Sir (IIST)
; 4. QA, Arosish Priyadarshan (IIST)
; 5. Script Lead; Mayuresh (Dhruva Space, NTU)
;
; OUTLINE:
; 1. We wait for a beacon packet update
; 2. We command cmd_noop see increment in command count


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
set waitInterval = 4000

while secDiff == 0
    set secNew = ccsdsTlmHeader_sec_beacon
    set secDiff = $secNew - $secOld
    wait $waitInterval
    set secOld = $secNew
endwhile
pause

; Try a NoOp command to be sure that the command counter increments
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_noop
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1
pause

echo Congratulations
echo IS-1 beacons detected successfully and commanding verified !!!
echo Can start other scripts now
