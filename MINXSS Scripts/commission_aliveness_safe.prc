;MINXSS Aliveness Test for Commissioning if in Safe Mode
;Purpose: Check that telemetry data from all subsystems are OK
;Outline
;	Check for command ability
;	Check CDH, EPS, COMM, ADCS, SPS
;	Does not check X123
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14

echo Press GO when ready to start the Commission_Aliveness_Safe script
pause

echo STARTING Commission_Aliveness_Safe  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until MinXSS responds
;call Scripts/hello_minxss

SET_ROUTING:
if MINXSSHkRouting != 3 
	set cmdCnt = MINXSSCmdAcceptCnt + 1
	while MINXSSCmdAcceptCnt < $cmdCnt
		set cmdTry = cmdTry + 1
		route_hk_pkt Route BOTH
		wait 3529
	endwhile
	set cmdSucceed = cmdSucceed + 1
endif

; Wait for Safe Mode (2) for 10 sec, else proceed with TLM checks
tlmwait MINXSSCDHMode_Tlm_All == 2 ? 10000

TLM_CHECK:
; Check CDH, EPS, COMM, ADCS, SPS values that are in HK packets
call Scripts/cdh_tlm_check

call Scripts/eps_tlm_check

call Scripts/comm_tlm_check

if MINXSSSPSEnabled == trueFalse(TRUE)
	call Scripts/sps_hk_tlm_check
endif

ADCS_PKT_CHECK:
; Wait for ADCS being on and then check ADCS packets
tlmwait MINXSSADCSEnabled == trueFalse(TRUE)

call Scripts/adcs_aliveness

FINISH:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_hk_pkt Route CARD_BEACON
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo COMPLETED Commission_Aliveness_Safe script
print cmdTry
print cmdSucceed