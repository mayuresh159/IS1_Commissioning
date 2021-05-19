;DAXSS Aliveness Test
;Purpose: Check that telemetry data from all subsystems are OK
;Outline
;    Power on (manual)
; 	 Issue beacon pkt to UHF and Debug Streams
;    Check CDH, EPS, SPS, X123
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14

set cmdTry = 0

echo STARTING Aliveness Test

echo Power on InspireSat-1 and Press GO
pause

;Get beacon packet to debug every 3 seconds
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 1 rate 3 stream 0
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

;Issue one becon pkt to UHF
set cmdTry = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_issue_pkt apid 1 stream 0 
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

CHECKOUT:
call Scripts/cdh_tlm_check

call Scripts/eps_tlm_check

call Scripts/comm_tlm_check

call Scripts/adcs_tlm_check

if beacon_pwr_status_cip == 1
	call Scripts/cip_tlm_check
else
	echo CIP is OFF
endif

if beacon_pwr_status_daxss == 1
	call Scripts/DAXSS/aliveness_daxss
else
	echo DAXSS is off
endif

FINISH:
echo COMPLETED Aliveness Test

print cmdTry
print cmdSucceed