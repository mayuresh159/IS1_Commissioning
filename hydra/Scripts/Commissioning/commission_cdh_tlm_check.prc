; IS-1 CDH telemetry check
; Purpose: Checks the CDH tlm for correct values
; Outline:
;     On start up check the CDH Tlm before deployments
;     Pause only if fatal error or else no point in waiting for operator input
; Commands Sent:
;     NOOP
;
; Tlm Check:
;
; EXPECTED CONFIGURATION:
;   PHOENIX or SAFE
;
; ISSUES:
;
; MODIFICATION HISTORY:
;    2020-3-12: Robert Sewell -- Created
;    2021-5-18: Mayuresh -- Converted variables isFlight and isTVACTest to arguments
;

declare cmdCnt      dn16l
declare cmdTry      dn16l
declare cmdSucceed  dn16l
declare successCnt  dn8
declare failCnt     dn8

set successCnt = 0
set failCnt = 0


CDH:
echo STARTING CDH telemetry checks

; Now check that all tlm is in range

; State
if beacon_mode == 0
    echo CDH State is PHOENIX
    set successCnt = successCnt + 1
else if beacon_curr_mode == 1
    echo CDH State is SAFE
    set successCnt = successCnt + 1
else
    echo CDH in Unexpected State (not Safe or Phoenix)
    set failCnt = failCnt + 1
    ; Break because fatal error
    pause
endif

; Eclipse Flag
if beacon_eclipse_state == 0
    echo InspireSAT-1 believes it is in sunlight
else if beacon_eclipse_state == 1
    echo InspireSAT-1 believes it is in eclipse
    set failCnt = failCnt + 1
    pause
else
    echo Unknown eclipse state!
    pause
endif

; Recieved Count
if beacon_cmd_recv_count >= 0 && beacon_cmd_recv_count <= 255
    set successCnt = successCnt + 1
else
    echo CMD Recieved Count outside of Limits
    set failCnt = failCnt + 1
    pause
endif

;Success Count
if beacon_cmd_succ_count >= 0 && beacon_cmd_succ_count <= 255
    set successCnt = successCnt + 1
else
    echo CMD Success Count outside of Limits
    set failCnt = failCnt + 1
    pause
endif

; Fail Count
if beacon_cmd_fail_count >= 0 && beacon_cmd_fail_count <= 255
    set successCnt = successCnt + 1
else
    echo CMD Fail Count outside of Limits
    set failCnt = failCnt + 1
    pause
endif

; CLT Fault
if beacon_clt_state == 0
    set successCnt = successCnt + 1
else
    echo Command Loss Timer Fault
    set failCnt = failCnt + 1
    pause
endif

; SD Card Power State
if beacon_pwr_status_sd1 == 1
    set successCnt = successCnt + 1
else
    if beacon_pwr_status_sd0 == 1
        set successCnt = successCnt + 1
    else
        echo Neither SD card is on
        set failCnt = failCnt + 1
        pause
    endif
endif

; 3.3 volt monitor
if beacon_cdh_volt >= 3.2
    set successCnt = successCnt + 1
else
    echo CDH V Monitor Below Low Limit
    set failCnt = failCnt + 1
    pause
endif

if beacon_cdh_volt <= 3.5
    set successCnt = successCnt + 1
else
    echo CDH V Monitor Above High Limit
    set failCnt = failCnt + 1
    pause
endif

; 3.3 current monitor (NEEDS UPDATING for value)
if beacon_cdh_curr >= .22
    set successCnt = successCnt + 1
else
    echo CDH A Monitor Below Low Limit
    set failCnt = failCnt + 1
    pause
endif

if beacon_cdh_curr <= .28
    set successCnt = successCnt + 1
else
    echo CDH A Monitor Above High Limit
    set failCnt = failCnt + 1
    pause
endif


TEMPERATURES:
;OBC Temp
if beacon_obc_temp >= 15
    set successCnt = successCnt + 1
else
    echo CDH Temperature Below Low Limit
endif
if beacon_obc_temp <= 35
    set successCnt = successCnt + 1
else
    echo CDH Temperature Above High Limit
    set failCnt = failCnt + 1
    pause
endif

;Interface Temp
if beacon_int_temp >= 15
    set successCnt = successCnt + 1
else
    echo CDH Temperature Below Low Limit
endif
if beacon_int_temp <= 35
    set successCnt = successCnt + 1
else
    echo Interface Temperature Above High Limit
    set failCnt = failCnt + 1
    pause
endif

FINISH:
echo See above for any telemetry check error messages
echo COMPLETED CDH Check with Successes = $successCnt and Failures = $failCnt
