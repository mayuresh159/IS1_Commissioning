;cdh_cmd_test Procedure
;Purpose: Test CDH functionality
; MODIFICATION HISTORY: 
;
declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare startMode dn8
declare launchDelay dn16l
declare launchDelayNew dn16l
declare launchCount dn16l
declare deployInt dn16l
declare deployIntNew dn16l
declare cltThresh dn32l
declare cltThreshNew dn32l
declare eclipseMeth dn8
declare PHX2SAFE dn32l
declare SAFE2PHX dn32l
declare SAFE2SCI dn32l
declare SCI2SAFE dn32l
declare PHX2SAFEnew dn32l
declare SAFE2PHXnew dn32l
declare SAFE2SCInew dn32l
declare SCI2SAFEnew dn32l

CHECKOUT:

if beacon_mode == 0
	echo S/C Should not be in Phoenix Mode for this test
	pause
endif

; Call UHF operated cdh telemetry check
call Scripts/UHF/uhf_cdh_tlm_check

COMMAND_STATUS:

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

SD_PLAYBACK:

MODE:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_set_pkt_rate apid MODE_HK rate 3 stream UHF
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

;set cltThresh = clt_threshold
;set cltThreshNew = 20

;set cmdCnt = beacon_cmd_succ_count + 1
;while beacon_cmd_succ_count < $cmdCnt
;	set cmdTry = cmdTry + 1
;	cmd_clt_threshold value $cltThreshNew
;	wait 3500
;endwhile
;set cmdSucceed = cmdSucceed + 1

;wait 3500
;verify clt_threshold == $cltThreshNew
;tlmwait clt_triggered == 1

;set cmdCnt = beacon_cmd_succ_count + 1
;while beacon_cmd_succ_count < $cmdCnt
;	set cmdTry = cmdTry + 1
;	cmd_clt_clear
;	wait 3500
;endwhile
;set cmdSucceed = cmdSucceed + 1
;tlmwait clt_triggered == 0

;set cmdCnt = beacon_cmd_succ_count + 1
;while beacon_cmd_succ_count < $cmdCnt
;	set cmdTry = cmdTry + 1
;	cmd_clt_threshold value $cltThresh
;	wait 3500
;endwhile
;set cmdSucceed = cmdSucceed + 1

;wait 3500
;verify clt_threshold == $cltThresh

if mode_launch_flag == 0
	echo The launch timer needs to expire before this test
	pause
else
	set launchDelay = mode_launch_delay
	set launchDelayNew = mode_launch_delay + 50

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_noop
		cmd_mode_launch_delay value $launchDelayNew
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1
	wait 3500
	verify mode_launch_delay == $launchDelayNew

	set launchCount = mode_launch_count

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_noop
		cmd_mode_launch_set_flag state 0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1
	wait 3500
	verify mode_launch_flag == 0

	echo Verifying launch counter increments
	tlmwait mode_launch_count >= $launchCount + 10

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_noop
		cmd_mode_launch_set_flag state 1
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1
	wait 3500
	verify mode_launch_flag == 1

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_noop
		cmd_mode_launch_delay value $launchDelay
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1
	wait 3500
	verify mode_launch_delay == $launchDelay
endif

if mode_deployables[0] == 1
	if mode_deployables[1] == 1
		if mode_deployables[2] == 1
			set deployInt = mode_deploy_int
			set deployIntNew = mode_deploy_int + 100

			set cmdCnt = beacon_cmd_succ_count + 1
			while beacon_cmd_succ_count < $cmdCnt
				set cmdTry = cmdTry + 1
				cmd_noop
				cmd_mode_deploy_interval value $deployIntNew
				wait 3500
			endwhile
			set cmdSucceed = cmdSucceed + 1
			wait 3500
			verify mode_deploy_int == $deployIntNew

			set cmdCnt = beacon_cmd_succ_count + 1
			while beacon_cmd_succ_count < $cmdCnt
				set cmdTry = cmdTry + 1
				cmd_noop
				cmd_mode_deploy_flag component 0 state 0
				wait 3500
			endwhile
			set cmdSucceed = cmdSucceed + 1
			wait 3500
			verify mode_deployables[0] == 0

			set cmdCnt = beacon_cmd_succ_count + 1
			while beacon_cmd_succ_count < $cmdCnt
				set cmdTry = cmdTry + 1
				cmd_noop
				cmd_mode_deploy_flag component 0 state 1
				wait 3500
			endwhile
			set cmdSucceed = cmdSucceed + 1
			wait 3500
			verify mode_deployables[0] == 1

			set cmdCnt = beacon_cmd_succ_count + 1
			while beacon_cmd_succ_count < $cmdCnt
				set cmdTry = cmdTry + 1
				cmd_noop
				cmd_mode_deploy_flag component 1 state 0
				wait 3500
			endwhile
			set cmdSucceed = cmdSucceed + 1
			wait 3500
			verify mode_deployables[1] == 0

			set cmdCnt = beacon_cmd_succ_count + 1
			while beacon_cmd_succ_count < $cmdCnt
				set cmdTry = cmdTry + 1
				cmd_noop
				cmd_mode_deploy_flag component 1 state 1
				wait 3500
			endwhile
			set cmdSucceed = cmdSucceed + 1
			wait 3500
			verify mode_deployables[1] == 1

			set cmdCnt = beacon_cmd_succ_count + 1
			while beacon_cmd_succ_count < $cmdCnt
				set cmdTry = cmdTry + 1
				cmd_noop
				cmd_mode_deploy_flag component 2 state 0
				wait 3500
			endwhile
			set cmdSucceed = cmdSucceed + 1
			wait 3500
			verify mode_deployables[2] == 0

			set cmdCnt = beacon_cmd_succ_count + 1
			while beacon_cmd_succ_count < $cmdCnt
				set cmdTry = cmdTry + 1
				cmd_noop
				cmd_mode_deploy_flag component 2 state 1
				wait 3500
			endwhile
			set cmdSucceed = cmdSucceed + 1
			wait 3500
			verify mode_deployables[2] == 1
		else
			echo All components need to be deployed for this test
			pause
		endif
	else
		echo All components need to be deployed for this test
		pause
	endif
else
	echo All components need to be deployed for this test
	pause
endif

if beacon_mode != 0
	set startMode = beacon_mode
	echo Press go to start mode change test
	echo This will change the mode to PHOENIX
	echo After 20 seconds the mode should autopromote back to MODE=$startMode
	pause

	echo Disabling auto mode transitions
	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_noop
		cmd_mode_auto_dis timeout 20
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify mode_auto_state == 0

	echo Commanding to PHOENIX

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_noop
		cmd_mode_set mode 0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify beacon_mode == 0
	echo 20 second wait until auto disable mode timer expires
	tlmwait mode_auto_state == 1 ? 20000
	wait 3500
	echo Verifying starting test mode is recovered
	verify beacon_mode == $startMode

	set startMode = beacon_mode

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_noop
		cmd_mode_avoid mode $startMode
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	if startMode == 1
		verify beacon_mode == 0
	else
		verify beacon_mode == 1
	endif

	while beacon_adcs_wheel_sp1 != 0
		cmd_noop
		cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_noop
		cmd_mode_avoid_clear mode $startMode
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify beacon_mode == $startMode

	while beacon_adcs_wheel_sp1 != 0
		cmd_noop
		cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	if mode_eclipse_method == 1

		set cmdCnt = beacon_cmd_succ_count + 1
		while beacon_cmd_succ_count < $cmdCnt
			set cmdTry = cmdTry + 1
			cmd_noop
			cmd_mode_eclipse_method method 0
			wait 3500
		endwhile
		set cmdSucceed = cmdSucceed + 1
		wait 3500
		verify mode_eclipse_method == 0

		set cmdCnt = beacon_cmd_succ_count + 1
		while beacon_cmd_succ_count < $cmdCnt
			set cmdTry = cmdTry + 1
			cmd_noop
			cmd_mode_eclipse_method method 1
			wait 3500
		endwhile
		set cmdSucceed = cmdSucceed + 1
		wait 3500
		verify mode_eclipse_method == 1
	else
		set cmdCnt = beacon_cmd_succ_count + 1
		while beacon_cmd_succ_count < $cmdCnt
			set cmdTry = cmdTry + 1
			cmd_noop
			cmd_mode_eclipse_method method 1
			wait 3500
		endwhile
		set cmdSucceed = cmdSucceed + 1
		wait 3500
		verify mode_eclipse_method == 1

		set cmdCnt = beacon_cmd_succ_count + 1
		while beacon_cmd_succ_count < $cmdCnt
			set cmdTry = cmdTry + 1
			cmd_noop
			cmd_mode_eclipse_method method 0
			wait 3500
		endwhile
		set cmdSucceed = cmdSucceed + 1
		wait 3500
		verify mode_eclipse_method == 0
	endif
else
	echo IS-1 must not be in PHOENIX for this test
	pause
endif

echo Disabling auto mode transitions
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_auto_dis timeout 200
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

wait 3500
verify mode_auto_state == 0

echo Re-enabling auto mode transitions
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_auto_ena
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

wait 3500
verify mode_auto_state == 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_auto_ena
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set PHX2SAFE = mode_thresholds[0] * 1000
set SAFE2PHX = mode_thresholds[1] * 1000
set SAFE2SCI = mode_thresholds[2] * 1000
set SCI2SAFE = mode_thresholds[3] * 1000

set PHX2SAFEnew = mode_thresholds[0] * 1000 + 100
set SAFE2PHXnew = mode_thresholds[1] * 1000 + 400
set SAFE2SCInew = mode_thresholds[2] * 1000 + 300
set SCI2SAFEnew = mode_thresholds[3] * 1000 + 200

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_set_threshold threshold PHX_TO_SAFE value $PHX2SAFEnew
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_set_threshold threshold SAFE_TO_PHX value $SAFE2PHXnew
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_set_threshold threshold SAFE_TO_SCI value $SAFE2SCInew
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_set_threshold threshold SCI_TO_SAFE value $SCI2SAFEnew
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3000

verify mode_thresholds[0] == PHX2SAFEnew * .001
verify mode_thresholds[1] == SAFE2PHXnew * .001
verify mode_thresholds[2] == SAFE2SCInew * .001
verify mode_thresholds[3] == SCI2SAFEnew * .001

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_set_threshold threshold PHX_TO_SAFE value $PHX2SAFE
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_set_threshold threshold SAFE_TO_PHX value $SAFE2PHX
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_set_threshold threshold SAFE_TO_SCI value $SAFE2SCI
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_mode_set_threshold threshold SCI_TO_SAFE value $SCI2SAFE
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

wait 3000

verify mode_thresholds[0] == PHX2SAFE * 0.001
verify mode_thresholds[1] == SAFE2PHX * 0.001
verify mode_thresholds[2] == SAFE2SCI * 0.001
verify mode_thresholds[3] == SCI2SAFE * 0.001

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_adcs_wheel_sp1 != 0
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

RESET:
echo Do you wish to proceed and reset the S/C?
echo Press go to proceed or else GOTO FINISH
echo Reset takes 5 mins
pause

set cmdCnt = beacon_cmd_succ_count + 1
set cmdTry = cmdTry + 1
cmd_noop
cmd_mode_reset_sc
tlmwait beacon_cmd_succ_count >= cmdCnt

echo Wait 5 mins for reset
wait 303000

verify beacon_cmd_recv_count == 0
echo Reset successful!

call Scripts/quick_start_bench

while beacon_adcs_wheel_sp1 != 0
	cmd_noop
	cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
FINISH:
echo Finished cdh_cmd_test.prc with cmdTry = $cmdTry and cmdSucceed = $cmdSucceed