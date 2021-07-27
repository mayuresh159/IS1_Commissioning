; IS-1 Commissioning Scripts
; Purpose: Check for aliveness in phoenix Mode
; Script name: commission_aliveness_phoenix
; Main subsystems: CDH, EPS, UHF, SBand, ADCS (+GPS), CIP, DAXSS
; Phoenix mode: No ADCS, No Payloads, No SBand | Just CDH, EPS, UHF
; Outline:
;   Check for command ability
; 	Check CDH, EPS, UHF
;	  Does not check ADCS, DAXSS and CIP

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14

echo Press GO when ready to start the script
pause

echo STARTING Commission aliveness phoenix test
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until IS-1 responds
call hello_is1

; wait for beacon packets at the normal cadence
; verify that the command counter increments
; NoOp command and incrementing command counter should confirm the hello_is1
;set cmdCnt = beacon_cmd_succ_count + 1
;while beacon_cmd_succ_count < $cmdCnt
;	NoOp
;	set cmdTry = cmdTry + 1
;	wait 3500
;endwhile


; Get beacon packet to debug every 3 seconds
; Should the beacon be set to DBG or UHF? The beacon packet update when in orbit will happen over UHF and no hardline exists!
; Set beacons to DBG/UHF stream
; 0/DBG 1/UHF 2/SD 3/SBAND
set cmdCnt = beacon_cmd_succ_count + 1
; repeat until command is accepted by SC
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 1 rate 3 stream 1
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1


; confirm phoenix mode
; wait to check if the satellite is in phoenix mode for atleast 10 sec, else proceed with TLM checks
; 0/PHOENIX 1/SAFE 2/SCID 3/SCIC
tlmwait beacon_mode == 0 ? 10000
timeout
  echo Spacecraft not in Phoenix Mode
  echo Do you wish to continue in Phoenix mode?
	echo Jump to FINISH if not
  pause
endtimeout



CHECKOUT:
; Decided to keep all parameter checks
; Call cdh_tlm_check
call commission_cdh_tlm_check

; Call eps_tlm_check in flight context
call commission_eps_tlm_check

; Call comm_tlm_check in flight context
call commission_comm_tlm_check


; Zero launch delay table parameter to avoid recurring launch delay after spacecraft reset
echo To cancel launch delay press GO
echo Else jump to CANCEL_DEPLOYMENTS
pause

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

; Set launch flag to 1
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
		cmd_mode_launch_set_flag state 1
		set cmdTry = cmdTry + 1
		wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

verify mode_launch_flag == 1


CANCEL_DEPLOYMENTS:
; Cancel all deployments commands
echo To cancel Panel deployments press GO
echo Else jump to FINISH
pause

PANEL1:
; Stop deployments
; Set deploy flag states (PANEL1, PANEL2 and ANTENNA) to 1
echo User to verify if PANEL1 currents are nominal
echo Jump to PANEL2 if skipping this
pause
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_mode_deploy_flag component 0 state 1
    set cmdTry = cmdTry + 1
    wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
verify mode_deployables[0] == 1

PANEL2:
echo User to verify if PANEL2 currents are nominal
echo Jump to ANTENNA if skipping this
pause
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_mode_deploy_flag component 1 state 1
    set cmdTry = cmdTry + 1
    wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
verify mode_deployables[1] == 1

ANTENNA:
echo User to verify if ANTENNA is deployed through signal strength in UHF waterfall plot
pause
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_mode_deploy_flag component 2 state 1
    set cmdTry = cmdTry + 1
    wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
verify mode_deployables[2] == 1

wait 3500



; Finish up aliveness test tasks
FINISH:
; Disable mode_hk_packet routing
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid MODE_HK rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1


; Set beacons back to UHF stream with default rate of 30 seconds
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid SW_STAT rate 10 stream UHF
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1


; Report completion of script
echo COMPLETED Commission aliveness phoenix test
print cmdTry
print cmdSucceed
