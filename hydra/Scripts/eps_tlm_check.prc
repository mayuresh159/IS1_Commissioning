;
; NAME:
;   eps_tlm_check
;
; PURPOSE:
;   Run through all EPS related housekeeping (HK) elements and verify that they are in expected range or have expected value
;
; EXPECTED CONFIGURATION:
;   PHOENIX or SAFE
;
;  COMMANDS TESTED
;   None
;
; ISSUES:
;   None
;
; MODIFICATION HISTORY
;   2020-03-13

declare cmdCnt dn16
declare seqCnt dn14
declare isTVACTest dn16
declare isFlight dn16
declare successCnt dn8
declare failCnt dn8

set successCnt = 0
set failCnt = 0

; 0 is FALSE/NO and 1 is TRUE/YES
; TVAC expands acceptable temperatures and doesn't raise a flag if heaters are enabled
; isFlight uses the same limits as isTVACTest
set isTVACTest = 1
set isFlight = 0

echo STARTING EPS tlm checks

ENABLES:

;Heater
if beacon_pwr_status_htr == 0
    echo Heater is disabled
    set successCnt = successCnt + 1
else
    echo Heater is enabled. Check temperature.
    set failCnt = failCnt + 1
    pause
endif

;SBAND
if beacon_pwr_status_sband == 0
    echo SBAND is disabled
    set successCnt = successCnt + 1
else
    echo SBAND is enabled
    set failCnt = failCnt + 1
    pause
endif

;ADCS
if beacon_pwr_status_adcs == 1 && beacon_mode == 1
    echo ADCS is enabled in SAFE
    if beacon_alive_adcs == 1
        echo and Alive
        set successCnt = successCnt + 1
    else
        echo but not Alive
        set failCnt = failCnt + 1
        pause
    endif
else if beacon_pwr_status_adcs == 0 && beacon_mode == 1
    echo ADCS is disable in SAFE is unexpected
    set failCnt = failCnt + 1
    pause
else if beacon_pwr_status_adcs == 0 && beacon_mode == 0
    echo ADCS is disabled in PHOENIX
    set successCnt = successCnt + 1
else if beacon_pwr_status_adcs == 1 && beacon_mode == 0
    echo ADCS is enabled in PHOENIX is unexpected
    set failCnt = failCnt + 1
    pause
else
    echo Unexpected mode and/or ADCS configuration
    set failCnt = failCnt + 1
    pause
endif

;CIP
if beacon_pwr_status_cip == 0
    echo CIP is disabled
    set successCnt = successCnt + 1
else
    echo CIP is enabled is unexpected
    set failCnt = failCnt + 1
    pause
endif

;DAXSS
if beacon_pwr_status_daxss == 0
    echo DAXSS is disabled
    set successCnt = successCnt + 1
else
    echo DAXSS is enabled is unexpected
    set failCnt = failCnt + 1
    pause
endif

TEMPERATURES:

if isTVACTest == 1
    goto IS_TVAC
endif
if isFlight == 1
    goto NOT_TVAC
endif

NOT_TVAC:
if beacon_eps_temp <= 30 
    if beacon_eps_temp >= 15
        set successCnt = successCnt + 1
    else
        echo EPS temp outside of limits
        set failCnt = failCnt + 1
        pause
    endif
else
    echo EPS temp outside of limits
    set failCnt = failCnt + 1
    pause
endif

if beacon_obc_temp <= 30 
    if beacon_obc_temp >= 15 
        set successCnt = successCnt + 1
    else
        echo OBC temp outside of limits
        set failCnt = failCnt + 1
        pause
    endif
else
    echo OBC temp outside of limits
    set failCnt = failCnt + 1
    pause
endif

if beacon_int_temp <= 30
    if beacon_int_temp >= 15 
        set successCnt = successCnt + 1
    else
        echo Interface card temp outside of limits
        set failCnt = failCnt + 1
        pause
    endif
else
    echo Interface card temp outside of limits
    set failCnt = failCnt + 1
    pause
endif

goto VOLTAGE_AND_CURRENTS

IS_TVAC:
if beacon_eps_temp <= 60
    if beacon_eps_temp >= -30
        set successCnt = successCnt + 1
    else
        echo EPS temp outside of limits
        set failCnt = failCnt + 1
        pause
    endif
else
    echo EPS temp outside of limits
    set failCnt = failCnt + 1
    pause
endif

if beacon_obc_temp <= 60
    if beacon_obc_temp >= -30
        set successCnt = successCnt + 1
    else
        echo OBC temp outside of limits
        set failCnt = failCnt + 1
        pause
    endif
else
    echo OBC temp outside of limits
    set failCnt = failCnt + 1
    pause
endif

if beacon_int_temp <= 60
    if beacon_int_temp >= -30
        set successCnt = successCnt + 1
    else
        echo Interface card temp outside of limits
        set failCnt = failCnt + 1
        pause
    endif
else
    echo Interface card temp outside of limits
    set failCnt = failCnt + 1
    pause
endif

goto VOLTAGE_AND_CURRENTS

VOLTAGE_AND_CURRENTS:
; 3.3 current monitor 
if beacon_cdh_curr >= .22
    set successCnt = successCnt + 1
else
    echo 3.3 A Monitor Below Low Limit
    set failCnt = failCnt + 1
    pause
endif

if beacon_cdh_curr <= .28
    set successCnt = successCnt + 1
else
    echo 3.3 A Monitor Above High Limit
    set failCnt = failCnt + 1
    pause
endif

;Battery Voltage (Update with actual values)
if beacon_pwr_status_htr == 1
    if beacon_bat_volt >= 7.6
        set successCnt = successCnt + 1
    else
        echo Battery Voltage Below Low Limit
        set failCnt = failCnt + 1
        pause
    endif   
    if beacon_bat_volt <= 8.2
        set successCnt = successCnt + 1
    else
        echo Battery Voltage Above High Limit
        set failCnt = failCnt + 1
        pause
    endif

;Battery Current(Update with actual values)
    if beacon_bat_curr >= .1
        set successCnt = successCnt + 1
    else
        echo Battery Current Below Low Limit
            set failCnt = failCnt + 1
    pause
    endif
    if beacon_bat_volt <= .2
        set successCnt = successCnt + 1
    else
        echo Battery Current Above High Limit
            set failCnt = failCnt + 1
    pause
    endif
endif

FINISH:
echo COMPLETED  EPS  tlm checks with Successes = $successCnt and Failures = $failCnt
pause