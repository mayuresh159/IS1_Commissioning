; IS-1 Commissioning Scripts
; Purpose: Playback deployment data
; Script name: commission_playback_dep_data
; Outline:
; *  After satellite deployment from PSLV, beacon packets will be routed to SD card at rate of 1 sec
; *  The write pointer for the SD card will have to be known BEACON partition of the SD card from the CPT before shipping to SHAR
;   After confirming aliveness of the spacecraft subsystems and finishing PHASE-1 scripts from IS-1 commissioning, the immediate next thing to do would be download beacon data since the satellite deployment
; *  Considering a delay of 1 day before the first ground pass and completion of aliveness scripts before, only one partition data may be downloaded in one ground pass
;   A playback command will be commenced through UHF depending on the amount of data accummulated
; *  SBand likely may not be used at this stage as the pointing of the satellite will not have been verified yet
;   ADCS in coarse point as soon as in safe mode
;   If ADCS is in coarse point, it can go to Nadir for SBand downlink
;
;   1. Note down the latest beacon write pointer
;   2. Check the difference between the previous write pointer and the latest write pointer and decide on number of blocks to be run for playback
;   3. Start playback while asking user to check for confirmation on beginning of playback
;   4. Repeat the playback for n number of times each time downloading 300 packets from SD Card
;   5. Close out

declare partition_id dn8l
declare launchWritePtr dn32l

; Declaring variables
declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSuccess dn16l
declare waitInterval dn16l

; Burst mode settings
declare burstTimeout dn16l
declare totNumPkts dn32l
declare dwnldBurstSize dn32l

; Initial variable defines
set waitInterval = 4000

; Remember to change to the latest write pointer before shipping to SHAR
set cmdTry = 0
set cmdSuccess = 0
set dwnldBurstSize = 180
set burstTimeout = 180
set launchWritePtr = 2685052
set partition_id = 04

; SD_HK packet 1
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_issue_pkt apid SD_HK stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

; Playback operation for 3 minutes
echo Keep an Eye on the GNU waterfall for the data dump
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_sd_playback stream UHF start $launchWritePtr num $dwnldBurstSize timeout $burstTimeout partition $partition_id decimation 1
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

echo Press GO once the UHF dump has been completed
pause


; SD_HK packet 2
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_issue_pkt apid SD_HK stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

echo COMPLETED Radios tlm checks with Successes = $cmdSuccess and Trails = $cmdTry
