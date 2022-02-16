; IS-1 Commissioning Scripts
; Purpose: UHF Power levels at various points in the orbit to be determined.
; Script name: uhf_power_test
; Outline:
; *  We try to send the cmd_uhf_pass to detect the RSSI values for the same.
;
;   1. Issue a uhf_pass packet
;   2. send command cmd_uhf_pass with the requirement 
;   3. Issue a uhf_pass packet and this will contain the required RSSI data, continuously

; Declaring variables
declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSuccess dn16l
declare waitInterval dn16l

; Initial variable defines
set waitInterval = 3700

; Remember to change to the latest write pointer before shipping to SHAR
set cmdTry = 0
set cmdSuccess = 0

; Issue uhf_pass packet
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_issue_pkt apid UHF_PASS stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

; Adding the required payload data for the uhf_pass packet
echo Keep an Eye on the GNU waterfall for the data dump
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_uhf_pass len 1 data S
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

; Issue uhf_pass packets
echo Operate again if needed.
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_issue_pkt apid UHF_PASS stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

echo COMPLETED Radios tlm checks with Successes = $cmdSuccess and Trails = $cmdTry