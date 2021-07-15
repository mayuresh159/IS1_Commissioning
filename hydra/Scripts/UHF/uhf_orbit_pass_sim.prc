; Program to simulate a 90 minute orbit and ground operations around the orbit for IS-1
; OUTLINE:
; 1. Perform aliveness test before starting the orbit
; 2. Note down the write pointers at the beginning of the orbit
; 3. Route packets to SD card and slow beacons at 30 seconds to UHF
;   a. beacon_hk - beacon, 5 seconds
;   b. SD_HK - misc, 5 seconds
;   c. mode_hk - misc, 5 seconds
;   d. tlm_hk - misc, 5 seconds
;   e. uhf_hk - misc, 5 seconds
;   f. cmd_hk - misc, 5 seconds
;   g. ana_hk - misc, 5 seconds
;   h. adcs_hk - misc, 5 seconds
;   i. adcs_analogs - adcs, 5 seconds
;  Expected playback packets after 90 minutes:
;    a. BEACON - 1080 packets (roughly 240 seconds)
;    b. MISC - 7560 packets (roughly 600 seconds)
;    c. ADCS - 1080 packets (roughly 240 seconds)
;    d. LOG - 1080 packets (roughly 240 seconds)
; 4. Wait for 90 minutes till the orbit completes
; 5. Detect the latest beacon and read current write pointers for each partition
; 6. Start the ground pass to download the accummulated data
; 7. Note the time required to transfer the complete data to ground station through UHF

; Before starting the experiment remember the following:
; 1. Select SD card for experiment
; 2. Route Beacon and SD card packets on DBG for 1 second rate

; Command sending requirements
declare cmdCnt      dn16l
declare cmdTry      dn16l
declare cmdSucceed  dn16l
; Playback pointers for each partition
declare sdpbkMisc   dn32l
declare sdpbkADCS   dn32l
declare sdpbkBeacon dn32l
declare sdpbkLog    dn32l
; Write pointers for each partition
declare sdWriteMisc_1   dn32l
declare sdWriteADCS_1   dn32l
declare sdWriteBeacon_1 dn32l
declare sdWriteLog_1    dn32l
declare sdWriteMisc_2   dn32l
declare sdWriteADCS_2   dn32l
declare sdWriteBeacon_2 dn32l
declare sdWriteLog_2    dn32l
; Number of packets in each Partition
declare sdNumPktsMisc   dn32l
declare sdNumPktsMiscAct dn32l
declare sdNumPktsADCS   dn32l
declare sdNumPktsADCSAct   dn32l
declare sdNumPktsBeacon dn32l
declare sdNumPktsBeaconAct dn32l
declare sdNumPktsLog    dn32l
declare sdNumPktsLogAct    dn32l



test start name="90minOrbitSim" group="is1_iist_tg"

; Default beacon timing of 10 seconds before pass starts
; Start this code only after atleast 1 beacon packet decodes allowing to populate item beacon_cmd_succ_count

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	enable_uhf_beacon
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

echo Starting 90 min Orbit Simulation Test
echo Press GO
pause



ALIVENESS:
; Aliveness Test
call Scripts/UHF/uhf_aliveness

echo Aliveness complete, Press GO
pause



TAKE_PTRS:
; Start sd_hk packet routing to fetch the current write pointers
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid SD_HK rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

; Note down write pointers before orbit begins
set sdWriteMisc_1 = sd_partition_write0
set sdWriteADCS_1 = sd_partition_write3
set sdWriteBeacon_1 = sd_partition_write4
set sdWriteLog_1 = sd_partition_write5

set sdpbkMisc = $sdWriteMisc_1
set sdpbkADCS = $sdWriteADCS_1
set sdpbkBeacon = $sdWriteBeacon_1
set sdpbkLog = $sdWriteLog_1

echo Current write pointers are
print sdWriteMisc_1
print sdWriteADCS_1
print sdWriteBeacon_1
print sdWriteLog_1

pause



ROUTE_PKTS:
; Route packets to SD Card and slow beacon at 30 seconds thus starting the orbit
; Beacon packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid SW_STAT rate 5 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Beacon packet routed to SD
echo If only beacon packets are needed jump to START_ORBIT
pause

; SD_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid SD_HK rate 5 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo SD_Hk packet routed to SD

; Mode_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid MODE_HK rate 5 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Mode_Hk packet routed to SD

; Tlm_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid TLM_HK rate 5 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Tlm_HK packet routed to SD

; Uhf_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid UHF_HK rate 5 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Uhf_HK packet routed to SD

; Cmd_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid CMD_HK rate 5 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Cmd_HK packet routed to SD

; Ana_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid ANA_HK rate 5 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Ana_HK packet routed to SD

; ADCS_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid ADCS_HK rate 5 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo ADCS_HK packet routed to SD

; ADCS_Analogs packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid ADCS_ANALOGS rate 5 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo ADCS_Analogs packet routed to SD




START_ORBIT:
; Reduce beacon time and start orbit
; Turn off SD_HK on UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid SD_HK rate 0 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid SW_STAT rate 30 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Beacons slowed and orbit started
pause



ORBIT_WAIT:
; Wait for 90 minutes
; Try first for only 10 minutes
;wait 5400000
wait 600000
pause




GP_START:
; Print system time now
call show_time

; Detect beacon and start sd_hk packet routing
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid SW_STAT rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Fast Beacon restarted and ground pass started

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid SD_HK rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo SD_HK started to read sd card write and playback pointers
pause



GP_STOP_PKT_ROUTE:
; Turn off packet routing to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid SW_STAT rate 0 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Beacon packet stopped routing to SD
echo If only beacon packets are needed jump to GP_BEACON_DWNLD
pause

; SD_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid SD_HK rate 0 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo SD_Hk packet stopped routing to SD

; Mode_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid MODE_HK rate 0 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Mode_Hk packet stopped routing to SD

; Tlm_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid TLM_HK rate 0 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Tlm_HK packet stopped routing to SD

; Uhf_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid UHF_HK rate 0 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Uhf_HK packet stopped routing to SD

; Cmd_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid CMD_HK rate 0 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Cmd_HK packet stopped routing to SD

; Ana_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid ANA_HK rate 0 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Ana_HK packet stopped routing to SD

; ADCS_HK packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid ADCS_HK rate 0 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo ADCS_HK packet stopped routing to SD

; ADCS_Analogs packet to SD card
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid ADCS_ANALOGS rate 0 stream SD
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo ADCS_Analogs packet stopped routing to SD



GP_BEACON_DWNLD:
; Start ground pass and download data using cmd_sd_playback
set sdWriteBeacon_2 = sd_partition_write4
if $sdWriteBeacon_2 != $sdpbkBeacon
    if $sdpbkBeacon > $sdWriteBeacon_2
        set sdNumPktsBeacon = sd_partition_size4 - $sdpbkBeacon + $sdWriteBeacon_2
    else
        set sdNumPktsBeacon = $sdWriteBeacon_2 - $sdpbkBeacon
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkBeacon num $sdNumPktsBeacon timeout 300 partition 4 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1
endif
tlmwait sd_partition_pbk4 >= $sdWriteBeacon_2 - 1 ? 300000
set sdNumPktsBeaconAct = sd_partition_pbk4 - $sdpbkBeacon
echo Verify Beacon playback finished over UHF
echo Expected packets
print sdNumPktsBeacon
echo Actual packets
print sdNumPktsBeaconAct
echo If only beacon packets go to CLOSEOUT
pause

; Start playback misc partition
set sdWriteMisc_2 = sd_partition_write0
if $sdWriteMisc_2 != $sdpbkMisc
    if $sdpbkMisc > $sdWriteMisc_2
        set sdNumPktsMisc = sd_partition_size0 - $sdpbkMisc + $sdWriteMisc_2
    else
        set sdNumPktsMisc = $sdWriteMisc_2 - $sdpbkMisc
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkMisc num $sdNumPktsMisc timeout 700 partition 4 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1
endif
tlmwait sd_partition_pbk0 >= $sdWriteMisc_2 - 1 ? 700000
set sdNumPktsMiscAct = sd_partition_pbk0 - $sdpbkMisc
echo Verify Misc playback finished over UHF
echo Expected packets
print sdNumPktsMisc
echo Actual packets
print sdNumPktsMiscAct
pause

; Start playback ADCS partition
set sdWriteADCS_2 = sd_partition_write3
if $sdWriteADCS_2 != $sdpbkADCS
    if $sdpbkADCS > $sdWriteADCS_2
        set sdNumPktsADCS = sd_partition_size3 - $sdpbkADCS + $sdWriteADCS_2
    else
        set sdNumPktsADCS = $sdWriteADCS_2 - $sdpbkADCS
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkADCS num $sdNumPktsADCS timeout 300 partition 4 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1
endif
tlmwait sd_partition_pbk3 >= $sdWriteADCS_2 - 1 ? 300000
set sdNumPktsADCSAct = sd_partition_pbk3 - $sdpbkADCS
echo Verify ADCS playback finished over UHF
echo Expected packets
print sdNumPktsADCS
echo Actual packets
print sdNumPktsADCSAct
pause

; Start playback LOG partition
set sdWriteLog_2 = sd_partition_write5
if $sdWriteLog_2 != $sdpbkLog
    if $sdpbkLog > $sdWriteLog_2
        set sdNumPktsLog = sd_partition_size5 - $sdpbkLog + $sdWriteLog_2
    else
        set sdNumPktsLog = $sdWriteLog_2 - $sdpbkLog
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkLog num $sdNumPktsLog timeout 300 partition 4 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1
endif
tlmwait sd_partition_pbk5 >= $sdWriteLog_2 - 1 ? 300000
set sdNumPktsLogAct = sd_partition_pbk5 - $sdpbkLog
echo Verify Log playback finished over UHF
echo Expected packets
print sdNumPktsLog
echo Actual packets
print sdNumPktsLogAct
pause






CLOSEOUT:
call show_time
echo Note down ground pass time between time stamps

echo 1 orbit completed with
print cmdSucceed
print cmdTry
print cmdCnt

test end
