;MINXSS Aliveness Test for Commissioning if in Phoenix Mode
;Purpose: Check that telemetry data from all subsystems are OK
;Outline
;	Check for command ability
;	Check CDH, EPS, COMM, SPS
;	Does not check ADCS or X123
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14

echo Press GO when ready to start the Commission_Aliveness_Phoenix script
pause

echo STARTING Commission_Aliveness_Phoenix  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until MinXSS responds
;call Scripts/hello_minxss

SET_ROUTING:
while MINXSSHkRouting != 3
	set cmdTry = cmdTry + 1
	route_hk_pkt Route BOTH
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Wait for Phoenix Mode (1) for 10 sec, else proceed with TLM checks
verify MINXSSCDHMode_Tlm_All == 1

TLM_CHECK:
; Check CDH, EPS, COMM, SPS values that are in HK packets
call Scripts/cdh_tlm_check

call Scripts/eps_tlm_check

call Scripts/comm_tlm_check

FINISH:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_hk_pkt Route CARD_BEACON
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo COMPLETED Commission_Aliveness_Phoenix script

print cmdTry
print cmdSucceed