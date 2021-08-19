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
	cmd_set_pkt_rate apid SW_STAT rate 3 stream UHF
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
call Scripts/Commissioning/commission_cdh_tlm_check

; Call eps_tlm_check in flight context
call Scripts/Commissioning/commission_eps_tlm_check

; Call comm_tlm_check in flight context
call Scripts/Commissioning/commission_comm_tlm_check


REDUCE_LAUNCH_DELAY:
; Zero launch delay table parameter to avoid recurring launch delay after spacecraft reset
echo To cancel launch delay press GO
echo Else jump to CANCEL_DEPLOYMENTS
pause

call Scripts/Commissioning/commission_reduce_launch_delay


CANCEL_DEPLOYMENTS:
; Cancel all deployments commands
echo To cancel Panel deployments press GO
echo Else jump to REDUCE_BEACON_RATE
pause

call Scripts/Commissioning/commission_act_deployables


REDUCE_BEACON_RATE:
; Reduce beacon rate to SD card to avoid beacon partition overflow before deployment data download
echo To reduce beacon rate to SD card press GO
echo Else jump to FINISH
pause

; Reduce beacon rate to SD card to avoid beacon partition overflow before deployment data download
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid SW_STAT rate 3 stream SD
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1



wait 3500

; Finish up aliveness test tasks
FINISH:
; Set beacons back to UHF stream with default rate of 30 seconds
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid SW_STAT rate 10 stream UHF
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1


; Report completion of script
echo COMPLETED Commission aliveness phoenix test with Tries = $cmdTry and Success = $cmdSucceed
