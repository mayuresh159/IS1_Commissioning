; IS-1 Commissioning Scripts
; Purpose: Check for aliveness in safe Mode
; Script name: commission_aliveness_safe
; Main subsystems: CDH, EPS, UHF, SBand, ADCS (+GPS), CIP, DAXSS
; Safe mode: No Payloads, No SBand | Just CDH, EPS, UHF, ADCS, DAXSS (electronics would be on but instrument off)
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

echo STARTING Commission aliveness safe test
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until IS-1 responds
; call hello_is1

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


; confirm safe mode
; wait to check if the satellite is in safe mode for atleast 10 sec, else proceed with TLM checks
; 0/PHOENIX 1/SAFE 2/SCID 3/SCIC
tlmwait beacon_mode == 1 ? 10000
timeout
  echo Spacecraft not in Safe Mode
	; Set mode to safe manually
	cmd_mode_set mode 1
	wait 3000
	;goto FINISH
endtimeout


;route adcs_analogs, adcs_command_tlm, adcs_mag and adcs_rw_drive
; New definition of beacon packet includes critical ADCS data and we do not need the additional ADCS packets to be routed
; Streams - 0/DBG 1/UHF 2/SD 3/SBAND

; adcs_analogs
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 215 rate 10 stream 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

; adcs_command_tlm
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 200 rate 10 stream 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

; adcs_mag
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 211 rate 10 stream 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

; adcs_rw_drive
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 206 rate 10 stream 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1




CHECKOUT:
; Decided to keep all parameter checks
; Call cdh_tlm_check
call commission_cdh_tlm_check

; Call eps_tlm_check
call commission_eps_tlm_check

; Call comm_tlm_check
call commission_comm_tlm_check

; Call sband_tlm_check

; Call adcs_tlm_check
call commission_adcs_tlm_check


; TODO: Cancel all deployments commands put over here
; Keep a pause first before confirming 
pause

; First Route mode_hk_packet to UHF, to verify status of deployments
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 53 rate 10 stream 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

; Stop deployments 
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

; Disable mode_hk_packet routing
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 53 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

; Finish up aliveness test tasks
FINISH:

; Turn off routing of adcs_analogs, adcs_command_tlm, adcs_mag and adcs_rw_drive
; adcs_analogs
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 215 rate 0 stream 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

; adcs_command_tlm
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 200 rate 0 stream 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

; adcs_mag
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 211 rate 0 stream 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

; adcs_rw_drive
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 206 rate 0 stream 1
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1


; Set beacons back to UHF stream with default rate of 30 seconds
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid 1 rate 30 stream 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1


; Report completion of script
echo COMPLETED Commission aliveness safe test
print cmdTry
print cmdSucceed
