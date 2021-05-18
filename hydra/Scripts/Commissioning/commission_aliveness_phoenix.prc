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
; call hello_is1

; Get beacon packet to debug every 3 seconds
; Should the beacon be set to DBG or UHF? The beacon packet update when in orbit will happen over UHF and no hardline exists!
; Set beacons to DBG stream
set cmdCnt = beacon_cmd_succ_count + 1
; repeat until command is accepted by SC
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 1 rate 3 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1


; confirm phoenix mode
; wait to check if the satellite is in phoenix mode for atleast 10 sec, else proceed with TLM checks
tlmwait beacon_mode == 1 ? 10000
timeout
  echo Spacecraft not in Phoenix Mode
  goto FINISH
endtimeout



CHECKOUT:
; Decided to keep all parameter checks
; Call cdh_tlm_check in flight context
call cdh_tlm_check(1,0)

; Call eps_tlm_check in flight context
call eps_tlm_check(1,0)

; Call comm_tlm_check in flight context
call comm_tlm_check(1,0)



; Finish up aliveness test tasks
FINISH:
; Set beacons back to UHF stream with default rate of 30 seconds
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid 1 rate 30 stream 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1


; Report completion of script
echo COMPLETED Commission aliveness phoenix test
print cmdTry
print cmdSucceed
