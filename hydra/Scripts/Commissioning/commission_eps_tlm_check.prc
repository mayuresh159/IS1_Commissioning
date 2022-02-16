; IS-1 CDH telemetry check
; PURPOSE:
;   Run through all EPS related housekeeping (HK) elements and verify that they are in expected range or have expected value
; Outline:
;     On start up check the EPS Tlm values
; NAME:
;   eps_tlm_check
; EXPECTED CONFIGURATION:
;   PHOENIX or SAFE
;
; MODIFICATION HISTORY
;   2020-03-13 : Robert Sewell - Created
;
; MANAGEMENT:
; 1. Hydra Operator (Commander): Dhruva Anantha Datta (IIST)
; 2. GNU radio Operator; Murala Aman Naveen (IIST)
; 3. GS Superviser; Raveendranath Sir (IIST) and Joji Sir (IIST)
; 4. QA, Arosish Priyadarshan (IIST)
; 

declare cmdCnt      dn16
declare seqCnt      dn14
declare successCnt  dn8
declare failCnt     dn8

set successCnt = 0
set failCnt = 0

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
if beacon_eps_temp <= 30
    if beacon_eps_temp >= 15
        set successCnt = successCnt + 1
    else
        echo EPS temp outside of limits
        print beacon_eps_temp
        set failCnt = failCnt + 1
        pause
    endif
else
    echo EPS temp outside of limits
    print beacon_eps_temp
    set failCnt = failCnt + 1
endif

if beacon_obc_temp <= 30
    if beacon_obc_temp >= 15
        set successCnt = successCnt + 1
    else
        echo OBC temp outside of limits
        print beacon_obc_temp
        set failCnt = failCnt + 1
        pause
    endif
else
    echo OBC temp outside of limits
    print beacon_obc_temp
    set failCnt = failCnt + 1
    pause
endif

if beacon_int_temp <= 30
    if beacon_int_temp >= 15
        set successCnt = successCnt + 1
    else
        echo Interface card temp outside of limits
        print beacon_int_temp
        set failCnt = failCnt + 1
        pause
    endif
else
    echo Interface card temp outside of limits
    print beacon_int_temp
    set failCnt = failCnt + 1
    pause
endif


VOLTAGE_AND_CURRENTS:
; 3.3 current monitor
if beacon_cdh_curr >= .22
    set successCnt = successCnt + 1
else
    echo 3.3 A Monitor Below Low Limit
    print beacon_cdh_curr
    set failCnt = failCnt + 1
    pause
endif

if beacon_cdh_curr <= .28
    set successCnt = successCnt + 1
else
    echo 3.3 A Monitor Above High Limit
    print beacon_cdh_curr
    set failCnt = failCnt + 1
    pause
endif

;Battery Voltage (Update with actual values)
if beacon_pwr_status_htr == 1
    if beacon_bat_volt >= 7.6
        set successCnt = successCnt + 1
    else
        echo Battery Voltage Below Low Limit
        print beacon_bat_volt
        set failCnt = failCnt + 1
        pause
    endif
    if beacon_bat_volt <= 8.2
        set successCnt = successCnt + 1
    else
        echo Battery Voltage Above High Limit
        print beacon_bat_volt
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
