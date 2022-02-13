;
; Name: 
;         sps_tlm_check
;         MINXSS SPS Aliveness Script
; Purpose: script checks aliveness of the SPS and XRS by dumping parameters and checking telemetry 
; Telemetry points verified in the aliveness script
    ;3.5V                            MINXSSSpsXpsPwr3V                499
    ;5V digital                        MINXSSSpsXsPwrD5V                591
    ;5V analog                        MINXSSSpsXsPwrA5V                589
    ;DACV                            MINXSSSpsXpsDAC1                307                            
    ;SPS temperature                MINXSSSpsXpsSpsTemp
    ;XPS temperature                MINXSSSpsXpsXpsTemp
    ;XPS                            MINXSSXpsDataHK                    84                            
    ;Dark                            MINXSSDarkDataHK                97
    ;Sps0                            MINXSSSpsData0                    117
    ;Sps1                            MINXSSSpsData1                    122
    ;Sps2                            MINXSSSpsData2                    123
    ;Sps3                            MINXSSSpsData3                    127
    ;SpS/Xps Count                    MINXSSSpsXpsCount                3
    ;Sum                            MINXSSSpsSum                    49
    ;XPos                            MINXSSpsXPos                    0
    ;YPos                            MINXSSSpsYPos                    0
    ;SPS asic Offset 0                MINXSSSpsAsicOffsets1            16000
    ;SPS asic Offset 1                MINXSSSpsAsicOffsets2            15500
    ;SPS asic Offset 2                MINXSSSpsAsicOffsets3            15700
    ;SPS asic Offset 3                MINXSSSpsAsicOffsets4            15700
    ;SPS asic Offset 4                MINXSSSpsAsicOffsets5            7985
    ;SPS asic Offset 5                MINXSSSpsAsicOffsets6            7790
        
; Outline
    ;1. Power SPS on
    ;2. Verify SPS is enabled
    ;3. Perform automated limit checking on SPS telemetry
    ;4. Perform automated verification of ASIC settings
;
; MODIFICATION HISTORY: 
;    2014-12-10: Tom Woods: Script written
;    2014-12-12: James Paul Mason: Debugged, tested, fine tuned. 
;                                  Script takes 5 seconds to run. 
;    2015-01-07: Seth Folley: changed lines 102 and 106 so that the upper limit is now 250 on both
;    2016-03-05: James Paul Mason: Updated for flight. 
;	 2019-03-28: James Paul Mason: Updated for DAXSS
;

declare FM_number dn8
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdCnt dn16
declare isTVACTest dn16
declare isFlight dn16
; 0 is FALSE/NO and 1 is TRUE/YES
; TVAC expands acceptable temperatures and doesn't raise a flag if heaters are enabled
; isFlight uses the same limits as isTVACTest
set isTVACTest = 1
set isFlight = 0

ROUTE:

SPS:
echo STARTING  SPS  tlm checks
echo NOTE that X123 has to be on to get SCI packets 


; Switch on SPS if it is Off
if daxss_sci_sps_enabled == 0
    set cmdCnt = daxss_sci_cmd_acpt_count + 1
    while daxss_sci_cmd_acpt_count < $cmdCnt
        cmd_daxss_pwr_sps pwr 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set cmdSucceed = cmdSucceed + 1 
endif

; Check flight model number
set FM_number = daxss_sci_fm

; Ricks CubeSat version of TQSM
SPS_AUTOMATED_TELEMETRY_CHECK:

; Dump current MinXSS parameters stored in RAM
call Scripts\DAXSS\dump_parameters        

TELEMETRY_CHECKS:

;verify param offsets
if $FM_number == 4
    ;SPS ASIC Offset 0 in PARAM=0 packet: checks that offsets are what they should be
    verify daxss_param_sps_asic_off[0] == 30948

    ;SPS ASIC Offset 1: checks that offsets are what they should be
    verify daxss_param_sps_asic_off[1] == 30948

    ;SPS ASIC Offset 2: checks that offsets are what they should be
    verify daxss_param_sps_asic_off[2] == 30948

    ;SPS ASIC Offset 3: checks that offsets are what they should be
    verify daxss_param_sps_asic_off[3] == 30948

    ;SPS ASIC Offset 4: checks that offsets are what they should be
    verify daxss_param_sps_asic_off[4] == 30948

    ;SPS ASIC Offset 5: checks that offsets are what they should be
    verify daxss_param_sps_asic_off[5] == 30948
else
    echo This script should only be run for FM4 with PicoSIM (DAXSS)
    pause
endif

; check tlm monitors against upper and lower limit

; 3.5V Power: checks range between 3.5V with a 5% tolerance
verify daxss_sci_3v_volt > 3.3
verify daxss_sci_3v_volt < 3.7

; 5V Power Digital: checks range between 5V with a 5% tolerance
verify daxss_sci_5v_volt > 4.75
verify daxss_sci_5v_volt < 5.25

; SPS temperature: checks range between 5°C and 50°C 
if isTVACTest == 1
    verify daxss_sci_sps_board_temp > -25
    verify daxss_sci_sps_board_temp < 50
else 
    verify daxss_sci_sps_board_temp > 15
    verify daxss_sci_sps_board_temp < 35
endif

; PSIM temperature: checks range between 5°C and 50°C
if isTVACTest == 1
    verify daxss_sci_pico_sim_temp > -25
    verify daxss_sci_pico_sim_temp < 50
else
    verify daxss_sci_pico_sim_temp > -25
    verify daxss_sci_pico_sim_temp < 50
endif

; SPS Signal in HK Packet: checks that it is greater than offsets in sunlight 
if daxss_sci_cdh_eclipse == 0 
    echo Housekeeping indicates that MinXSS is in sunlight so SPS diodes should be bright
    verify daxss_sci_sps_data1 < daxss_param_sps_asic_off[0]
    verify daxss_sci_sps_data2 < daxss_param_sps_asic_off[1]
    verify daxss_sci_sps_data3 < daxss_param_sps_asic_off[2]
    verify daxss_sci_sps_data4 < daxss_param_sps_asic_off[3]
    verify daxss_sci_sps_sum > 4000
else
    echo Housekeeping indicate that MinXSS is in eclipse so SPS diodes should be dark (with some tolerance for temperature)
    verify daxss_sci_sps_data1 >= daxss_param_sps_asic_off[0] - 200
    verify daxss_sci_sps_data2 >= daxss_param_sps_asic_off[1] - 200 
    verify daxss_sci_sps_data3 >= daxss_param_sps_asic_off[2] - 200
    verify daxss_sci_sps_data4 >= daxss_param_sps_asic_off[3] - 200
    verify daxss_sci_sps_sum < 4000
endif

; Sps sum in HK: checks range between 0 and 4000
verify daxss_sci_sps_sum >= 0
if daxss_sci_cdh_eclipse == 0 
    echo Housekeeping indicates that DAXSS is in sunlight so SPS diodes should be bright
    verify daxss_sci_sps_sum > 4000
else
    echo Housekeeping indicate that MinXSS is in eclipse so SPS diodes should be dark
    verify daxss_sci_sps_sum < 4000
endif

; SPS XPos: checks range between -10000 and 10000
verify daxss_sci_sps_xpos > -10000
verify daxss_sci_sps_xpos < 10000

 ;SPS YPos: checks range between -10000 and 10000
verify daxss_sci_sps_ypos > -10000
verify daxss_sci_sps_ypos < 10000

; PSIM count Signal
wait 2000
if daxss_sci_cdh_eclipse == 0 
    echo Housekeeping indicates that DAXSS is in sunlight so PSIM count should be bright
    verify daxss_sci_pico_sim_data1 > 0
    verify daxss_sci_pico_sim_data2 > 0
    verify daxss_sci_pico_sim_data3 > 0
    verify daxss_sci_pico_sim_data4 > 0
    verify daxss_sci_pico_sim_data5 > 0
    verify daxss_sci_pico_sim_data6 > 0   
else
    echo Housekeeping indicate that DAXSS is in eclipse so PSIM count should be dark
    verify daxss_sci_pico_sim_data1 == 0
    verify daxss_sci_pico_sim_data2 == 0
    verify daxss_sci_pico_sim_data3 == 0
    verify daxss_sci_pico_sim_data4 == 0
    verify daxss_sci_pico_sim_data5 == 0
    verify daxss_sci_pico_sim_data6 == 0
endif

echo COMPLETED SPS tlm checks
