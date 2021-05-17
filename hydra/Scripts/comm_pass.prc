;MINXSS COMM_PASS Procedure
;Purpose: Test COMM (Li-1 Radio) related FSW functions (commands and telemetry)
;Outline
;
;COMM Telemetry Points are Verified in Scripts\comm_tlm_check
;
; ISSUES:
;
; MODIFICATION HISTORY:
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare sdpbkMisc dn32l
declare sdpbkSciC dn32l
declare sdpbkSciD dn32l
declare sdpbkADCS dn32l
declare sdpbkBeacon dn32l
declare sdpbkLog dn32l
declare sdWriteMisc dn32l
declare sdWriteSciC dn32l
declare sdWriteSciD dn32l
declare sdWriteADCS dn32l
declare sdWriteBeacon dn32l
declare sdWriteLog dn32l
declare numPlayback dn32l

SETUP:
if beacon_mode == 0
	echo SC Mode Phoenix is unexpected
	echo Conitnue?
	pause
endif

if beacon_pwr_status_sband == 0
	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
	    cmd_eps_pwr_on component SBAND override 0
	    set cmdTry = cmdTry + 1
	    wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1 
endif

; Route SBAND and UHF HK for 3-sec rate
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 40 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 40 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 52 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 52 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 42 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 42 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set sdpbkMisc = sd_partition_pbk0
set sdpbkSciC = sd_partition_pbk1
set sdpbkSciD = sd_partition_pbk2
set sdpbkADCS = sd_partition_pbk3
set sdpbkBeacon = sd_partition_pbk4
set sdpbkLog = sd_partition_pbk5
set sdWriteMisc = beacon_sd_write_misc
set sdWriteSciC = beacon_sd_write_scic
set sdWriteSciD = beacon_sd_write_scid
set sdWriteADCS = beacon_sd_write_adcs
set sdWriteBeacon = beacon_sd_write_beacon
set sdWriteLog = beacon_sd_write_log

UHF_PLAYBACK:
if $sdWriteMisc != $sdpbkMisc
    if $sdpbkMisc > $sdWriteMisc
        set numPlayback = sd_partition_size0 - $sdpbkMisc + $sdWriteMisc
    else
        set numPlayback = $sdWriteMisc - $sdpbkMisc
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkMisc num $numPlayback timeout 300 partition 0 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk0 >= $sdWriteMisc - 1 ? 300000
echo Verify MISC playback finished over UHF
pause

if $sdWriteSciC != $sdpbkSciC
    if $sdpbkSciC > $sdWriteSciC
        set numPlayback = sd_partition_size1 - $sdpbkSciC + $sdWriteSciC
    else
        set numPlayback = $sdWriteSciC - $sdpbkSciC
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkSciC num $numPlayback timeout 300 partition 1 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk1 >= $sdWriteSciC - 1 ? 300000
echo Verify SCI-C playback finished over UHF
pause

if $sdWriteSciD != $sdpbkSciD
    if $sdpbkSciD > $sdWriteSciD
        set numPlayback = sd_partition_size2 - $sdpbkSciD + $sdWriteSciD
    else
        set numPlayback = $sdWriteSciD - $sdpbkSciD
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkSciD num $numPlayback timeout 300 partition 2 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk2 >= $sdWriteSciD - 1 ? 300000
echo Verify SCI-D playback finished over UHF
pause

if $sdWriteADCS != $sdpbkADCS
    if $sdpbkADCS > $sdWriteADCS
        set numPlayback = sd_partition_size3 - $sdpbkADCS + $sdWriteADCS
    else
        set numPlayback = $sdWriteADCS - $sdpbkADCS
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkADCS num $numPlayback timeout 300 partition 3 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk3 >= $sdWriteADCS - 1 ? 300000
echo Verify ADCS playback finished over UHF
pause

if $sdWriteBeacon != $sdpbkBeacon
    if $sdpbkBeacon > $sdWriteBeacon
        set numPlayback = sd_partition_size4 - $sdpbkBeacon + $sdWriteBeacon
    else
        set numPlayback = $sdWriteBeacon - $sdpbkBeacon
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkBeacon num $numPlayback timeout 300 partition 4 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk4 >= $sdWriteBeacon - 1 ? 300000
echo Verify Beacon playback finished over UHF
pause

if $sdWriteLog != $sdpbkLog
    if $sdpbkLog > $sdWriteLog
        set numPlayback = sd_partition_size4 - $sdpbkLog + $sdWriteLog
    else
        set numPlayback = $sdWriteLog - $sdpbkLog
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkLog num $numPlayback timeout 300 partition 5 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk5 >= $sdWriteLog - 1 ? 300000
echo Verify Log playback finished over UHF
pause

SBAND_PLAYBACK:
if $sdWriteMisc != $sdpbkMisc
set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sband_sync_on timeout 350
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 

    verify sband_status == 3
    verify sband_control == 130

    if $sdpbkMisc > $sdWriteMisc
        set numPlayback = sd_partition_size0 - $sdpbkMisc + $sdWriteMisc
    else
        set numPlayback = $sdWriteMisc - $sdpbkMisc
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkMisc num $numPlayback timeout 300 partition 0 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk0 >= $sdWriteMisc - 1 ? 300000
echo Verify MISC playback finished over UHF
pause

if $sdWriteSciC != $sdpbkSciC
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sband_sync_on timeout 350
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 

    verify sband_status == 3
    verify sband_control == 130

    if $sdpbkSciC > $sdWriteSciC
        set numPlayback = sd_partition_size1 - $sdpbkSciC + $sdWriteSciC
    else
        set numPlayback = $sdWriteSciC - $sdpbkSciC
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkSciC num $numPlayback timeout 300 partition 1 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk1 >= $sdWriteSciC - 1 ? 300000
echo Verify SCI-C playback finished over UHF
pause

if $sdWriteSciD != $sdpbkSciD
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sband_sync_on timeout 350
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 

    verify sband_status == 3
    verify sband_control == 130

    if $sdpbkSciD > $sdWriteSciD
        set numPlayback = sd_partition_size2 - $sdpbkSciD + $sdWriteSciD
    else
        set numPlayback = $sdWriteSciD - $sdpbkSciD
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkSciD num $numPlayback timeout 300 partition 2 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk2 >= $sdWriteSciD - 1 ? 300000
echo Verify SCI-D playback finished over UHF
pause

if $sdWriteADCS != $sdpbkADCS
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sband_sync_on timeout 350
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 

    verify sband_status == 3
    verify sband_control == 130

    if $sdpbkADCS > $sdWriteADCS
        set numPlayback = sd_partition_size3 - $sdpbkADCS + $sdWriteADCS
    else
        set numPlayback = $sdWriteADCS - $sdpbkADCS
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkADCS num $numPlayback timeout 300 partition 3 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk3 >= $sdWriteADCS - 1 ? 300000
echo Verify ADCS playback finished over UHF
pause

if $sdWriteBeacon != $sdpbkBeacon
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sband_sync_on timeout 350
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 

    verify sband_status == 3
    verify sband_control == 130

    if $sdpbkBeacon > $sdWriteBeacon
        set numPlayback = sd_partition_size4 - $sdpbkBeacon + $sdWriteBeacon
    else
        set numPlayback = $sdWriteBeacon - $sdpbkBeacon
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkBeacon num $numPlayback timeout 300 partition 4 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk4 >= $sdWriteBeacon - 1 ? 300000
echo Verify Beacon playback finished over UHF
pause

if $sdWriteLog != $sdpbkLog
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sband_sync_on timeout 350
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 

    verify sband_status == 3
    verify sband_control == 130

    if $sdpbkLog > $sdWriteLog
        set numPlayback = sd_partition_size4 - $sdpbkLog + $sdWriteLog
    else
        set numPlayback = $sdWriteLog - $sdpbkLog
    endif
    set cmdCnt = beacon_cmd_succ_count + 1
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_sd_playback stream UHF start $sdpbkLog num $numPlayback timeout 300 partition 5 decimation 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif
tlmwait sd_partition_pbk5 >= $sdWriteLog - 1 ? 300000
echo Verify Log playback finished over UHF
pause

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_sband_set_mode mode 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

ClOSEOUT:

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SD_HK rate 0 stream DBG
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

FINISH:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 40 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 52 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 42 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 40 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 52 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 42 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo Done with COMM Command Test

print cmdTry
print cmdSucceed