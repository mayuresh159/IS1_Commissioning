; IS-1 Commissioning Scripts
; Purpose: Reduce launch delay and confirm setting of launch flag
; Script name: commission_reduce_launch_delay
; Outline:
;   1. Route mode_hk packets for verification
;   2. Set launch delay value and verify
;   3. Set launch flag and verify

declare cmdCnt dn32l
declare cmdTry dn32l
declare cmdSucceed dn32l

; First Route mode_hk_packet to UHF, to verify launch delay, launch flag, and status of deployments
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid MODE_HK rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

; Set launch delay to value 10
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
		cmd_mode_launch_delay value 10
		set cmdTry = cmdTry + 1
		wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

verify mode_launch_delay == 10
echo Launch delay reduced to 10 seconds

; Set launch flag to 1
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
		cmd_mode_launch_set_flag state 1
		set cmdTry = cmdTry + 1
		wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

verify mode_launch_flag == 1
echo Launch flag set to 1

; Finish up by removing mode_hk routing
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid MODE_HK rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
