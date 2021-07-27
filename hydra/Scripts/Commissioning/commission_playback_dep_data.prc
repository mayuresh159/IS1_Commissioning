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
;   1. Route Beacon packets on UHF at faster rate - 3 seconds
;   2. Note down the latest beacon write pointer
;   3. Check the difference between the previous write pointer and the latest write pointer and decide on number of blocks to be run for playback
;   4. Start playback while asking user to check for confirmation on beginning of playback
;   5. Repeat the playback for n number of times each time downloading 300 packets from SD Card
;   6. Close out

argument partition_id dn8l
argument launchWritePtr dn32l

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSuccess dn16l

declare waitInterval dn16l

declare currWritePtr dn32l
declare burstWritePtr dn32l
declare currPbkPtr dn32l

declare writePtrStr varString
declare sizeStr varString
declare pbkPtrStr varString

set writePtrStr = sd_partition_write
set sizeStr = sd_partition_size
set pbkPtrStr = sd_partition_pbk

declare totNumPkts dn32l
declare remNumPkts dn32l

declare dwnldBurstSize dn32l
declare burstTimeout dn16l
declare singleBurstTimeout dn32l

; Initial variable defines
set waitInterval = 4000
; Remember to change to the latest write pointer before shipping to SHAR
set cmdTry = 0
set cmdSuccess = 0
set dwnldBurstSize = 300
set burstTimeout = 10
set singleBurstTimeout = 300


; 1. Route beacon and sd_hk packets
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_set_pkt_rate apid SW_STAT rate 3 stream UHF
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



; 2-5. Note down latest beacon partition write pointer from sd_hk packet and calculate number of packets needed for download
set currWritePtr = $writePtrStr$partition_id
if $launchWritePtr == $currWritePtr
  echo Check beacon updates again and wait till packets start updating on page
  pause
endif

; Determine number of packets to download
if $currWritePtr > $launchWritePtr
    set totNumPkts = $currWritePtr - $launchWritePtr
else
    set totNumPkts = $sizeStr$partition_id - $launchWritePtr + $currWritePtr
endif

echo Current write pointer = $currWritePtr
echo Total expected number of packets = $totNumPkts
echo Press Go for download in small bursts
echo Else Jump to SINGLE_BURST
pause

SMALL_BURSTS:
set remNumPkts = $totNumPkts
set burstWritePtr = $launchWritePtr

; Start repeating playback reads in bursts of dwnldBurstSize
while $remNumPkts > $dwnldBurstSize
    set cmdCnt = beacon_cmd_succ_count + 1
    ; Send playback command
    cmd_sd_playback stream UHF start $burstWritePtr num $dwnldBurstSize timeout $burstTimeout partition $partition_id decimation 1
    echo Check whether playback started or resend command
    echo Also check if sufficient time to download additional packets or Jump to FINISH after this download
    pause
    ; Increment burstWritePtr
    set burstWritePtr = $burstWritePtr + $dwnldBurstSize
    ; Wait till the playback completes
    tlmwait $pbkPtrStr$partition_id >= $burstWritePtr - 1 ? $burstTimeout
    ; Set new variables for re-running the loop
    set remNumPkts = $remNumPkts - $dwnldBurstSize
endwhile

; Download remaining packets after integer number of short bursts
cmd_sd_playback stream UHF start $burstWritePtr num $remNumPkts timeout $burstTimeout partition $partition_id decimation 1
echo Check whether playback started or resend command
pause

goto VERIFY


SINGLE_BURST:
; Download Beacon packets from beacon partition
cmd_sd_playback stream UHF start $launchWritePtr num $totNumPkts timeout $singleBurstTimeout partition $partition_id decimation 1
echo Check whether playback started or resend command
pause


VERIFY:
tlmwait $pbkPtrStr$partition_id >= $currWritePtr - 1 ? 300000
timeout
  echo All packets not downloaded
  echo Press GO if playback is complete
  pause

  set currPbkPtr = $pbkPtrStr$partition_id

  if $currPbkPtr > $launchWritePtr
      set totNumPkts = $currPbkPtr - $launchWritePtr
  else
      set totNumPkts = $sizeStr$partition_id - $launchWritePtr + $currPbkPtr
  endif

  echo Curr playback pointer = $currPbkPtr
  echo Total downloaded number of Packets = $totNumPkts
endtimeout


FINISH:
; 6. Reset beacon and sd_hk packet routine
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_Set_pkt_rate apid SD_HK rate 0 stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    set cmdTry = $cmdTry + 1
    cmd_set_pkt_rate apid SW_STAT rate 10 stream UHF
    wait $waitInterval
endwhile
set cmdSuccess = $cmdSuccess + 1

echo Playback deployment data from partition $partition_id completed
