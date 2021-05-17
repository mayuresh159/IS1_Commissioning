declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdCntADCS dn16
declare cmdTryADCS dn16l
declare cmdSucceedADCS dn16l
declare launchDelay dn16l

set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0
	set cmdTryADCS = cmdTryADCS + 1
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1 

wait 10000

verify beacon_adcs_wheel_sp1 >= -10
verify beacon_adcs_wheel_sp1 <= 10
verify beacon_adcs_wheel_sp2 >= -10
verify beacon_adcs_wheel_sp2 <= 10
verify beacon_adcs_wheel_sp3 >= -10 
verify beacon_adcs_wheel_sp3 <= 10

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 53 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

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

verify mode_deployables[0] == 1
verify mode_deployables[1] == 1
verify mode_deployables[2] == 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 53 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

echo End quick_start_bench with success = $cmdSucceed and ADCS success = $cmdSucceedADCS
echo cmdTry = $cmdTry and ADCS cmdTry = $cmdTryADCS