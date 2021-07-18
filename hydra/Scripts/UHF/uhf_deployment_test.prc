;Antenna Deployment Test
;Purpose: Test antenna deployment timeouts
;Hazards: This test can deploy the antenna!  Skip if action is not desired!
;Outline
;  Set deployment timeout to 15 and deploy
;  Set deployment timeout to 30 and deploy

declare cmdCnt dn16l
declare cmdTry dn16l
declare deployTime dn16l
declare cmdSucceed dn16l

echo Press GO to test deployments, 
echo or type GOTO FINISH or RETURN to skip
pause

echo Starting Antenna Deployment Test
	
TIMEOUT_30:
;Set antenna deployment timeout
if mode_launch_delay == 1
	echo Deployments should have already happened
	echo return from this proceedure if they have
	echo or else asses and press go
	pause
endif 

if mode_deployables[0] == 1
	echo Panel 1 deployment flag already set to deployed
	echo To continue press go or goto labels for individual deployments
	pause
endif
if mode_deployables[1] == 1
	echo Panel 2 deployment flag already set to deployed
	echo To continue press go or goto labels for individual deployments
	pause
endif
if mode_deployables[2] == 1
	echo Antenna deployment flag already set to deployed
	echo To continue press go or goto labels for individual deployments
	pause
endif

set deployTime = mode_launch_count + 60
set cmdTry = beacon_cmd_succ_count + 1

echo GO to set launch_delay for T+60
echo or goto ANTENNA/PANEL1/PANEL2 to manually deploy components
pause

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_mode_launch_delay value $deployTime
	set cmdTry = cmdTry + 1
	wait 10500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1

verify mode_launch_flag == 1

echo All deployments will happen in 60 sec
echo or press GO to deploy the Antenna now
echo or goto PANEL1/2 to deploy either panel
pause

ANTENNA:
echo GO to deploy Antenna
pause

if mode_deployables[2] == 1
	echo Antenna deployment flag already set to deployed
	echo press GO to continue or else goto PANEL1/PANEL2/FINISH
	pause
endif

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_eps_deploy component 2 
	set cmdTry = cmdTry + 1
	wait 6500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1

echo Watch for successful Antenna deployment then press go
pause

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_mode_deploy_flag component 2 state 1
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1

echo Goto PANEL1/2 for Panel deployments
echo or goto FINISH
pause

PANEL1:
echo GO to deploy Panel 1
pause

if mode_deployables[0] == 1
	echo Panel 1 deployment flag already set to deployed
	echo press GO to continue or else goto ANTENNA/PANEL2/FINISH
	pause
endif

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_eps_deploy component 0 
	set cmdTry = cmdTry + 1
	wait 6500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1

echo Watch for successful Panel 1 deployment then press go
pause

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_mode_deploy_flag component 0 state 1
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1

echo Goto Antenna or PANEL2 for more deployments
echo or goto FINISH
pause

PANEL2:
echo GO to deploy Panel 2
pause

if mode_deployables[1] == 1
	echo Panel 2 deployment flag already set to deployed
	echo press GO to continue or else goto ANTENNA/PANEL1/FINISH
	pause
endif

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_eps_deploy component 1 
	set cmdTry = cmdTry + 1
	wait 6500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1

echo Watch for successful Panel 2 deployment then press go
pause

set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_mode_deploy_flag component 1 state 1
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1

echo Goto Antenna or PANEL1 for more deployments
echo or goto FINISH
pause

FINISH:
echo Done with All Deployables Test
