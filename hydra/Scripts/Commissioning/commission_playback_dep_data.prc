; IS-1 Commissioning Scripts
; Purpose: Playback deployment data
; Script name: commission_playback_dep_data
; Outline:
;   After satellite deployment from PSLV, beacon packets will be routed to SD card at rate of 1 sec
;   The estimated write pointer for the SD card will have to be noted down for BEACON partition of the SD card before shipping to SHAR
;   After confirming aliveness of the spacecraft subsystems and finishing PHASE-1 scripts from IS-1 commissioning, the immediate next thing to do would be download beacon data since the satellite deployment
;   A playback command will be commenced through UHF depending on the amount of data accummulated
;   SBand likely may not be used at this stage as the pointing of the satellite will not have been verified yet
;   1. Route Beacon packets on UHF at faster rate - 3 seconds
;   2. Note down the latest beacon write pointer
;   3. Check the difference between the previous write pointer and the latest write pointer and decide on number of blocks to be run for playback
;   4. Start playback while asking user to check for confirmation on beginning of playback
;   5. Repeat the playback for n number of times each time downloading 300 packets from SD Card
;   6. Close out


declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSuccess dn16l

declare waitInterval dn16l

declare currWritePtr dn32l
declare launchWritePtr dn32l
declare burstWritePtr dn32l

declare totNumPkts dn32l
declare remNumPkts dn32l

declare dwnldBurstSize dn32l
declare burstTimeout dn16l

; Initial variable defines
set waitInterval = 4000
; Remember to change to the latest write pointer before shipping to SHAR
set launchWritePtr = 413111
set cmdTry = 0
set cmdSuccess = 0
set dwnldBurstSize = 300
set burstTimeout = 10


; 1. Route beacon and sd_hk packets
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_Set_pkt_rate apid SW_STAT rate 3 stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_Set_pkt_rate apid SD_HK rate 3 stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1



; 2-5. Note down latest beacon partition write pointer from beacon packet
set currWritePtr = beacon_sd_write_beacon

if $launchWritePtr == $currWritePtr
  echo Check beacon updates again and wait till packets start updating on page
  pause
endif

; Determine number of packets to download
if $currWritePtr > $launchWritePtr
    set totNumPkts = $currWritePtr - $launchWritePtr
else
    set totNumPkts = sd_partition_size4 - $launchWritePtr + $currWritePtr
endif

set remNumPkts = $totNumPkts
set burstWritePtr = $launchWritePtr

; Start repeating playback reads in bursts of dwnldBurstSize
while $remNumPkts > $dwnldBurstSize
    set cmdCnt = beacon_cmd_succ_count + 1
    ; Send playback command
    cmd_sd_playback stream UHF start $burstWritePtr num $dwnldBurstSize timeout $burstTimeout partition 4 decimation 1
    echo Check whether playback started or resend command
    echo Also check if sufficient time to download additional packets or Jump to FINISH after this download
    pause
    ; Increment burstWritePtr
    set burstWritePtr = $burstWritePtr + $dwnldBurstSize
    ; Wait till the playback completes
    tlmwait sd_partition_pbk4 >= $burstWritePtr - 1 ? 10000
    ; Set new variables for re-running the loop
    set remNumPkts = $remNumPkts - $dwnldBurstSize
endwhile

; Download remaining packets after integer number of short bursts
cmd_sd_playback stream UHF start $burstWritePtr num $remNumPkts timeout $burstTimeout partition 4 decimation 1
echo Check whether playback started or resend command
pause

tlmwait sd_partition_pbk4 >= $currWritePtr - 1 ? 10000
timeout
  echo All packets not downloaded
  echo Curr Write pointer = $currWritePtr
  echo Total Num Packets = $totNumPkts
endtimeout


FINISH:
; 6. Reset beacon and sd_hk packet routing
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_Set_pkt_rate apid SW_STAT rate 30 stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_Set_pkt_rate apid SD_HK rate 0 stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1
