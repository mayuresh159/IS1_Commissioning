;DAXSS Aliveness Test
;Purpose: Check that telemetry data from all subsystems are OK
;Outline
;    Power on (manual)
;    Check CDH, EPS, SPS, X123
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14

echo STARTING Aliveness Test

echo Power on DAXSS and Press GO
pause

CHECKOUT:
call Scripts/DAXSS/cdh_tlm_check_daxss

call Scripts/DAXSS/eps_tlm_check_daxss

call Scripts/DAXSS/sps_tlm_check_daxss

call Scripts/DAXSS/x123_tlm_check_daxss

FINISH:
echo COMPLETED Aliveness Test

print cmdTry
print cmdSucceed