;
; NAME:
;   eps_tlm_check
;
; PURPOSE:
;   Run through all EPS related housekeeping (HK) elements and verify that they are in expected range or have expected value
;
;  COMMANDS TESTED
;   None
;
;    HK PACKET TELEMETRY POINTS VERIFIED
;       MINXSSX123Enabled
;       MINXSSSPSEnabled
;       MINXSSSdCard
;       MINXSSPayloadHeaterEnabled
;       MINXSSMbTemp1
;       MINXSSMbTemp2
;       MINXSSEpsFgSoC
;       MINXSSEps3VAmp
;       MINXSSEps3VVolt
;       MINXSSEps5VAmp
;       MINXSSEps5VVolt
;       MINXSSEpsTemp1
;       MINXSSEpsTemp2
;
; ISSUES:
;   None
;
; MODIFICATION HISTORY
;   2014-11-23: James Paul Mason: Initial script with limits
;   2014-12-08: James Paul Mason: Added solar array labeling and merged Tom's edits to get the script to run
;   2014-12-12: James Paul Mason: Fine tuning and debugging completed.
;                                 Takes 4 seconds to run this script. 
;   2016-03-05: James Paul Mason: Updated for flight.
;   2019-03-28: James Paul Mason: Updated for DAXSS (no ADCS, COMM, batteries, or solar arrays)
;

declare cmdCnt dn16
declare seqCnt dn14
declare isTVACTest dn16
declare isFlight dn16

; 0 is FALSE/NO and 1 is TRUE/YES
; TVAC expands acceptable temperatures and doesn't raise a flag if heaters are enabled
; isFlight uses the same limits as isTVACTest
set isTVACTest = 1
set isFlight = 0

echo STARTING EPS tlm checks

ENABLES:

if daxss_sci_x123_enabled == 1
    echo X123 is enabled
else
    echo X123 is disabled
    pause
endif

if daxss_sci_sps_enabled == 1
    echo SPS Is Enabled
else
    echo SPS Is Disabled
    pause
endif

TEMPERATURES:

if isTVACTest == 1
    goto IS_TVAC
endif
if isFlight == 1
    goto IS_TVAC
endif

NOT_TVAC:
    verify daxss_sci_mb_temp1 <= 30 
    verify daxss_sci_mb_temp1 >= 15

    verify daxss_sci_mb_temp2 <= 30 
    verify daxss_sci_mb_temp2 >= 15 
    
    verify daxss_sci_eps_temp1 <= 30 
    verify daxss_sci_eps_temp1 >= 15 

    verify daxss_sci_eps_temp2 <= 30 
    verify daxss_sci_eps_temp2 >= 15 

goto VOLTAGE_AND_CURRENTS

IS_TVAC:
    verify daxss_sci_mb_temp1 <= 60
    verify daxss_sci_mb_temp1 >= -30

    verify daxss_sci_mb_temp2 <= 60
    verify daxss_sci_mb_temp2 >= -30

    verify daxss_sci_eps_temp1 <= 60
    verify daxss_sci_eps_temp1 >= -30

    verify daxss_sci_eps_temp2 <= 60
    verify daxss_sci_eps_temp2 >= -30


VOLTAGE_AND_CURRENTS:

; checking range between 80mA and 250mA
verify daxss_sci_3v_curr >= 80 
verify daxss_sci_3v_curr <= 250 

; checking range between 3.33V (5% of nominal) and 3.68V (5% of nominal)
verify daxss_sci_3v_volt >= 3.33
verify daxss_sci_3v_volt <= 3.68

; checking range between 0mA and 1000mA
verify daxss_sci_5v_curr >= 0
verify daxss_sci_5v_curr <= 1000

; checking range between 4.75V (5% of nominal) and 5.25V (5% of nominal)
verify daxss_sci_5v_volt >= 4.75
verify daxss_sci_5v_volt <= 5.25

FINISH:
echo COMPLETED  EPS  tlm checks