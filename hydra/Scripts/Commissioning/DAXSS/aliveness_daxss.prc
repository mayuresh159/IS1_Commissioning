;DAXSS Aliveness Test
;Purpose: Check that telemetry data from all subsystems are OK
;Outline
;    Power on (manual)
;    Check CDH, EPS, SPS, X123
;
; 13-02-2022: Robert Sewell		Created for IS-1 commissioning

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdCntDaxss dn16l
declare cmdTryDaxss dn16l
declare cmdSucceedDaxss dn16l
declare DaxssNominalRate dn32l
declare X123State dn16l
declare SPSPicoState dn16l
declare waitInterval dn32l

set DaxssNominalRate = 10
set waitInterval = 3500

echo STARTING Aliveness Test
echo Make sure CMD/TLM connections established with IS-1
echo before starting
echo GOTO FINISH if <2 mins until pass end

echo Press GO to run DAXSS aliveness
pause

ROUTE:
echo Routing DAXSS SCI packets over UHF every 3 seconds
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid DAXSS_SCI rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

echo setting DAXSS sci packet rate to 3 seconds
set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
    cmd_daxss_set_sci_pkt_rate time 3
    set cmdTryDaxss = cmdTryDaxss + 1
    wait $waitInterval
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1 

X123_PWR_CHECK:
if daxss_sci_x123_enabled == 1
    echo X123 is enabled 
    set X123State = 1
else
    echo X123 is disabled
    echo Press GO to turn ON or GOTO SPS_PICO_PWR_CHECK
    echo (Turn on recommended for TLM checks)
    pause
    set X123State = 0
    set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
	while daxss_sci_cmd_acpt_count < $cmdCntDaxss
    	cmd_daxss_pwr_x123 pwr ON
    	set cmdTryDaxss = cmdTryDaxss + 1
    	wait $waitInterval
	endwhile
	set cmdSucceedDaxss = cmdSucceedDaxss + 1 
endif

SPS_PICO_PWR_CHECK:
if daxss_sci_sps_enabled == 1
    echo SPS/Picosim are enabled
    set SPSPicoState = 1
else
    echo SPS/Picosim are disabled
    echo Press GO to turn ON or GOTO CHECKOUT
    echo (Turn on recommended for TLM checks)
    pause
    set SPSPicoState = 0
    set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
	while daxss_sci_cmd_acpt_count < $cmdCntDaxss
    	cmd_daxss_pwr_sps pwr ON
    	set cmdTryDaxss = cmdTryDaxss + 1
    	wait $waitInterval
	endwhile
	set cmdSucceedDaxss = cmdSucceedDaxss + 1 
endif


CHECKOUT:
echo Checking DAXSS CDH
call Scripts/Commissioning/DAXSS/cdh_tlm_check_daxss

echo Checking DAXSS EPS
call Scripts/Commissioning/DAXSS/eps_tlm_check_daxss

echo Checking DAXSS SPS
call Scripts/Commissioning/DAXSS/sps_tlm_check_daxss

echo Checking DAXSS X123
call Scripts/Commissioning/DAXSS/x123_tlm_check_daxss

RETURN_PWR_X123:
if daxss_sci_x123_enabled == $X123State
    echo Leaving X123 ON as prior to test
else
    echo Turn X123 OFF as to match state prior to test?
    echo Press GO to turn OFF or GOTO FINISH
    echo (Turn OFF recommended)
    pause
    set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
    while daxss_sci_cmd_acpt_count < $cmdCntDaxss
        cmd_daxss_pwr_x123 pwr OFF
        set cmdTryDaxss = cmdTryDaxss + 1
        wait $waitInterval
    endwhile
    set cmdSucceedDaxss = cmdSucceedDaxss + 1 
endif

RETURN_PWR_SPS_PICO:
if daxss_sci_sps_enabled == $SPSPicoState
    echo Leaving SPS/PicoSIM ON as prior to test
else
    echo Turn SPS/PicoSIM OFF as to match state prior to test?
    echo Press GO to turn OFF or GOTO FINISH
    echo (Turn OFF recommended)
    pause
    set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
    while daxss_sci_cmd_acpt_count < $cmdCntDaxss
        cmd_daxss_pwr_sps pwr OFF
        set cmdTryDaxss = cmdTryDaxss + 1
        wait $waitInterval
    endwhile
    set cmdSucceedDaxss = cmdSucceedDaxss + 1 
endif

FINISH:
echo Setting DAXSS packet production rate to default
set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntDaxss
    cmd_daxss_set_sci_pkt_rate time $DaxssNominalRate
    set cmdTryDaxss = cmdTryDaxss + 1
    wait $waitInterval
endwhile
set cmdSucceedDaxss = cmdSucceedDaxss + 1 

echo Turning off DAXSS SCI UHF routing
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < cmdCnt
    cmd_set_pkt_rate apid DAXSS_SCI rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait $waitInterval
endwhile
set cmdSucceed = cmdSucceed + 1

print cmdTry
print cmdSucceed