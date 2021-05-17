; MINXSS CDH telemetry check
; Purpose: Checks the CDH tlm for correct values
; Outline:
;     On start up check the CDH Tlm before deployments
;
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
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare successCnt dn8
declare failCnt dn8
declare isTVACTest dn16
declare isFlight dn16

set successCnt = 0
set failCnt = 0

;Change to 0 if in TVAC
set isFlight = 0

;Change to 1 if in TVAC
set isTVACTest = 1 

CDH:
echo STARTING CDH tlm checks

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
    pause
endif

; Eclipse Flag (NEEDS UPDATING for tlm name)
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

; Last Opcode
if beacon_cmd_succ_op >= 0
    set successCnt = successCnt + 1
else
    echo Last Success Opcode Below Low Limit
    set failCnt = failCnt + 1
    pause
endif

if beacon_cmd_succ_op <= 255
    set successCnt = successCnt + 1
else
    echo Last Success Opcode Above High Limit
    set failCnt = failCnt + 1
    pause
endif

if beacon_cmd_fail_op >= 0
    set successCnt = successCnt + 1
else
    echo Last Fail Opcode Below Low Limit
    set failCnt = failCnt + 1
    pause
endif

if beacon_cmd_fail_op <= 255
    set successCnt = successCnt + 1
else
    echo Last Fail Opcode Above High Limit
    set failCnt = failCnt + 1
    pause
endif

; Last Command Fail Code 
if beacon_cmd_fail_code <= 7
    set successCnt = successCnt + 1
else
    echo Last Command Fail Code Above High Limit
    set failCnt = failCnt + 1
    pause
endif

if beacon_cmd_fail_code >= 0
    set successCnt = successCnt + 1
else
    echo Last Command Fail Code Below Low Limit
    set failCnt = failCnt + 1
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

; Temperatures
if isTVACTest == 1
    goto IS_TVAC
endif
if isFlight == 1
    goto IS_TVAC
endif

NOT_TVAC:

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

GOTO END_TEMPERATURES


IS_TVAC:
if beacon_obc_temp >= -30
    set successCnt = successCnt + 1
else
    echo CDH Temperature Below Low Limit
endif
if beacon_obc_temp <= 60
    set successCnt = successCnt + 1
else
    echo CDH Temperature Above High Limit
    set failCnt = failCnt + 1
    pause
endif

if beacon_int_temp >= -30
    set successCnt = successCnt + 1
else
    echo CDH Temperature Below Low Limit
endif
if beacon_int_temp <= 60
    set successCnt = successCnt + 1
else
    echo Interface Temperature Above High Limit
    set failCnt = failCnt + 1
    pause
endif

GOTO END_TEMPERATURES

END_TEMPERATURES:

echo See above for any telemetry check error messages
echo COMPLETED CDH Check with Successes = $successCnt and Failures = $failCnt
pause