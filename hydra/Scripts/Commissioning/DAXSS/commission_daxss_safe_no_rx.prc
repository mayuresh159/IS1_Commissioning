;Commission DAXSS Safe No Rx
;Purpose: Loop to commission DAXSS (X123 and SPS/PicoSIM)
;         in safe mode with no Rx (due to command difficulties)
;Outline
;    Route DAXSS Sci Pkt 60 seconds
;    Power on X123
;    Power SPS/PicoSIM
;    If in Rx mode, check power state
;
; 26-02-2022: Robert Sewell		Created for IS-1 commissioning

declare cmdLoopCnt dn16l
declare cmdLoopMax dn16l
declare DAXSSSciUHFRate dn32l
declare waitInterval dn32l

set DAXSSSciUHFRate = 60
set waitInterval = 5000
set cmdLoopCnt = 0
set cmdLoopMax = 5

echo STARTING commission_daxss_safe_no_rx
echo This will route DAXSS Science packets and turn
echo ON X123 and SPS/PicoSIM
echo This Script assumes IIST GS in Tx only mode

echo Press GO to commission DAXSS
pause

;Route DAXSS SCI every 60 seconds over UHF
ROUTE_DAXSS_SCI:
echo Press GO to route DAXSS Sci over UHF every $DAXSSSciUHFRate seconds
pause
while cmdLoopCnt < cmdLoopMax
    cmd_set_pkt_rate apid DAXSS_SCI rate $DAXSSSciUHFRate stream UHF
    set cmdLoopCnt = cmdLoopCnt + 1
    wait $waitInterval
endwhile

set cmdLoopCnt = 0

POWER_X123:
echo Press GO to power ON X123
pause
while cmdLoopCnt < cmdLoopMax
    cmd_daxss_pwr_x123 pwr ON
    set cmdLoopCnt = cmdLoopCnt + 1
    wait $waitInterval
endwhile

set cmdLoopCnt = 0

POWER_SPS_PICOSIM:
echo Press GO to power ON SPS/PicoSIM
pause
while cmdLoopCnt < cmdLoopMax
    cmd_daxss_pwr_sps pwr ON
    set cmdLoopCnt = cmdLoopCnt + 1
    wait $waitInterval
endwhile

set cmdLoopCnt = 0

echo If switching to Rx mode press GO to check
echo DAXSS state to verify commissioning
pause

CHECKOUT:
echo Checking DAXSS CDH
call Scripts/Commissioning/DAXSS/cdh_tlm_check_daxss

echo Checking DAXSS EPS
call Scripts/Commissioning/DAXSS/eps_tlm_check_daxss

echo Checking DAXSS SPS
call Scripts/Commissioning/DAXSS/sps_tlm_check_daxss

echo Checking DAXSS X123
call Scripts/Commissioning/DAXSS/x123_tlm_check_daxss

FINISH:
echo If X123 or SPS/PicoSIM not powered on in CHECKOUT:
echo Switch to Tx mode and GOTO ROUTE_DAXSS_SCI or POWER_X123
echo Else if checkout passed DAXSS is now in Science Mode
echo Press GO to FINISH DAXSS commissioning
pause