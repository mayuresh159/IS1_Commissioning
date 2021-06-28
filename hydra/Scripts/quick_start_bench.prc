declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdCntADCS dn16
declare cmdTryADCS dn16l
declare cmdSucceedADCS dn16l
declare launchDelay dn16l

; Start beacon packet?

; Set reaction wheels to idling mode
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0
	set cmdTryADCS = cmdTryADCS + 1
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

wait 10000

; Verify that the reaction wheels have stopped or below 10rpm
verify beacon_adcs_wheel_sp1 >= -10
verify beacon_adcs_wheel_sp1 <= 10
verify beacon_adcs_wheel_sp2 >= -10
verify beacon_adcs_wheel_sp2 <= 10
verify beacon_adcs_wheel_sp3 >= -10
verify beacon_adcs_wheel_sp3 <= 10

; Route mode_hk_packet to debug UART
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 53 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

; Set deploy flag states (PANEL1, PANEL2 and ANTENNA) to 1
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_mode_deploy_flag component 0 state 1
	set cmdTry = cmdTry + 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_mode_deploy_flag component 1 state 1
	set cmdTry = cmdTry + 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_mode_deploy_flag component 2 state 1
	set cmdTry = cmdTry + 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

wait 3500

; Verify that the deployable states have been set
verify mode_deployables[0] == 1
verify mode_deployables[1] == 1
verify mode_deployables[2] == 1

;Here should we read the launch_delay value as follows:
;echo Launch Delay Value = $mode_launch_delay?
;This could be helpful if we want to know when to expect the first beacon
;also, what exactly does launch_flag do? 
;(do we need to set it to 1, declaring that the wait is over)

; Disable mode_hk_packet routing
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 53 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

echo End quick_start_bench with success = $cmdSucceed and ADCS success = $cmdSucceedADCS
echo cmdTry = $cmdTry and ADCS cmdTry = $cmdTryADCS
