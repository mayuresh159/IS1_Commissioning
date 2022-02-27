; DAXSS X123 FSW Test
; Purpose: Check X123 telemetry items
; Outline
;        Verify X123 Science Packets
;
;    HK Packet Telemetry Points Verified
;        MINXSSX123Enabled
;        MINXSSSdx123Comp     PARAM
;        MINXSSSciRate         PARAM
;        MINXSSX123FastCountNorm
;        MINXSSX123SlowCountNorm
;        MINXSSX123DetTemp
;        MINXSSX123BrdTemp
;        MINXSSSciRouting
;        MINXSSSdSciWriteOffset
;   Sci Packet Telemetry Points Verified
;        MINXSSSeqCnt_Sci_All
;        MINXSSX123FastCount
;        MINXSSX123SlowCount
;        X123_GP_Count
;        X123_Accum_Time
;        X123_Live_Time
;        X123_Real_Time
;        X123_HV
;        X123_Det_Temp
;        X123_Brd_Temp
;        X123_Flags1
;        X123_Flags2
;        X123_Flags3
;        X123_Read_Errors
;        X123_Write_Errors
;        X123_Cmp_Info
;        X123_Spect_Len
;
; MODIFICATION HISTORY: 
;    2014-12-09: Tom Woods: Wrote script
;    2014-12-12: James Paul Mason: Script checked and tested. 
;                                  Script takes 
;    2015-01-07: Seth Folley: inserted wait at line 108
;    2016-03-05: James Paul Mason: Updated for flight.
;	 2019-03-28: James Paul Mason: Updated for DAXSS
;    2022-02-13: Robert Sewell:    Updated for IS-1 commissioning
;    2022-02-27: Dhruva Anantha Datta: Updated for manual PTT mode

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdCntDaxss dn16l
declare cmdTryDaxss dn16l
declare cmdSucceedDaxss dn16l
declare FM_number dn8
declare isTVACTest dn16
declare isFlight dn16
declare initState dn16l
declare DaxssNominalRate dn32l
; 0 is FALSE/NO and 1 is TRUE/YES
; TVAC expands acceptable temperatures and doesn't raise a flag if heaters are enabled
; isFlight uses the same limits as isTVACTest
set isTVACTest = 0
set isFlight = 1
set DaxssNominalRate = 10

X123:
echo STARTING X123 tlm checks

;set rates to what this script expects for integration time
;set cmdCnt = daxss_sci_cmd_acpt_count + 1
;while daxss_sci_cmd_acpt_count < $cmdCnt
;    cmd_daxss_set_sci_pkt_rate time 3
;    set cmdTry = cmdTry + 1
;    wait 3500
;endwhile
;set cmdSucceed = cmdSucceed + 1 

; Switch on X123 if it is off
if daxss_sci_x123_enabled == 1
    echo X123 is enabled is expected
    set initState = 1
else
    echo X123 is disabled
    echo Press GO to turn ON or GOTO SPS_PICO_CHECK
    echo (Turn on recommended for TLM checks)
    pause
    set initState = 0
    set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
    while daxss_sci_cmd_acpt_count < $cmdCntDaxss
        cmd_daxss_pwr_x123 pwr ON
        set cmdTryDaxss = cmdTryDaxss + 1
        wait 3500
    endwhile
    set cmdSucceedDaxss = cmdSucceedDaxss + 1 
endif

; Check flight model number
set FM_number = daxss_sci_fm

;call Scripts/Commissioning/DAXSS/dump_parameters
; check PARAM for compression is turned on
;verify daxss_param_sd_x123_comp == 1   

echo Waiting for X123 detector to cool down below 240 K
tlmwait daxss_sci_x123_det_temp < 240

verify daxss_sci_x123_fast_count < 100

verify daxss_sci_x123_slow_count < 100

; check X123 Detector Temperature range between 220 and 240 K
verify daxss_sci_x123_det_temp > 220
verify daxss_sci_x123_det_temp < 240

; check X123 Board Temperature range between -20 and 50 ºC
if isTVACTest == 1
	verify daxss_sci_x123_brd_temp > -20
	verify daxss_sci_x123_brd_temp < 50
else
	verify daxss_sci_x123_brd_temp > 15
	verify daxss_sci_x123_brd_temp < 35
endif

; Check count rate, allows up to 30 sec integrations
verify daxss_sci_x123_fast_count < 30000

verify daxss_sci_x123_slow_count < 30000

verify daxss_sci_x123_gp_count < 30000

; Integration time can range from 2500 to 30500 msec
verify daxss_sci_x123_accum_time > 2500
verify daxss_sci_x123_accum_time < 30500

verify daxss_sci_x123_live_time > 2500
verify daxss_sci_x123_live_time < 30500

verify daxss_sci_x123_real_time > 2500
verify daxss_sci_x123_real_time < 30500

; Check X123 HV to be in range between -145 and -125 V
verify daxss_sci_x123_hv > -145
verify daxss_sci_x123_hv < -120

; check X123 flags
; TODO: Update the else case for DAXSS
if FM_number == 4
	verify daxss_sci_x123_flags1 == 0x2E
else
	echo Expected DAXSS FM 4
	pause
endif

verify daxss_sci_x123_flags2 == 0x2

verify daxss_sci_x123_flags3 == 0x80

; check X123 Errors
verify daxss_sci_x123_read_err == 0

verify daxss_sci_x123_write_err == 0

; Check that X123 data compression is on
verify daxss_sci_x123_cmp_info != 0

; Check X123 data length is in range between 0 and 3072
verify daxss_sci_x123_spect_len > 0
verify daxss_sci_x123_spect_len <= 3072

;if daxss_sci_sps_enabled == $initState
;    echo Leaving SPS/PicoSIM ON as prior to test
;else
;    echo Turning SPS/PicoSIM OFF as to match state prior to test
;    echo Press GO to turn OFF or GOTO FINISH
;    echo (Turn OFF recommended)
;    pause
;    set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
;     while daxss_sci_cmd_acpt_count < $cmdCntDaxss
;        cmd_daxss_pwr_sps pwr OFF
;        set cmdTryDaxss = cmdTryDaxss + 1
;        wait 3500
;    endwhile
;    set cmdSucceedDaxss = cmdSucceedDaxss + 1 
;endif

RETURN_PWR:
;if daxss_sci_x123_enabled == $initState
;    echo Leaving X123 ON as prior to test
;else
;    echo Turn X123 OFF as to match state prior to test?
;    echo Press GO to turn OFF or GOTO FINISH
;    echo (Turn OFF recommended)
;    pause
;    set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
;    while daxss_sci_cmd_acpt_count < $cmdCntDaxss
;        cmd_daxss_pwr_x123 pwr OFF
;        set cmdTryDaxss = cmdTryDaxss + 1
;        wait 3500
;    endwhile
;    set cmdSucceedDaxss = cmdSucceedDaxss + 1 
;endif

FINISH:
;echo Setting back to nominal DAXSS sci rate production
;set cmdCnt = daxss_sci_cmd_acpt_count + 1
;while daxss_sci_cmd_acpt_count < $cmdCnt
;    cmd_daxss_set_sci_pkt_rate time $DaxssNominalRate
;    set cmdTry = cmdTry + 1
;    wait 3500
;endwhile
;set cmdSucceed = cmdSucceed + 1 
echo COMPLETED  X123  tlm checks
;echo cmdSucceedDaxss = $cmdSucceedDaxss