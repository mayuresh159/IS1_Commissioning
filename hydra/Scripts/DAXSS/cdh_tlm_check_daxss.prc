; MINXSS CDH telemetry check
; Purpose: Checks the CDH tlm for correct values
; Outline:
;     On start up send a noop and check the CDH Tlm
;
; Commands Sent:
;     NOOP
;
; Tlm Check:
;
; ISSUES:
;    Fix how patch version is checked
;    Add telemetry points checked to this header
;    
; MODIFICATION HISTORY: 
;    2014-12-10: Matt Cirbo: Wrote template
;    2014-12-11: Tom Woods?: Populated script
;    2014-12-12: James Paul Mason: Verified functionality of script. Removed heater checks (already covered in eps_tlm_check)
;                                  Added isTVACTest so that temperatures won't fail in TVAC if isTVACTest == 1
;                                  Takes 5 seconds to run this script. 
;    2016-03-05: James Paul Mason: Updated for flight. 
;	 2019-03-28: James Paul Mason: Updated for DAXSS (no ADCS, COMM, batteries, or solar arrays)
;

declare cmdCntdaxss dn16l
declare cmdTrydaxss dn16l
declare cmdSucceeddaxss dn16l
declare successCntdaxss dn8
declare isTVACTest dn16
declare isFlight dn16

; 0 is FALSE/NO and 1 is TRUE/YES
; TVAC expands acceptable temperatures and doesn't raise a flag if heaters are enabled
; isFlight uses the same limits as isTVACTest
set isTVACTest = 1
set isFlight = 0

CDH:
echo STARTING DAXSS CDH tlm checks

set cmdCntdaxss = daxss_sci_cmd_acpt_count + 1
while daxss_sci_cmd_acpt_count < $cmdCntdaxss
    cmd_daxss_dump_param set 0
    set cmdTrydaxss = cmdTrydaxss + 1
    wait 3500
endwhile
set cmdSucceeddaxss = cmdSucceeddaxss + 1 

; Now check that all tlm is in range

; State
if daxss_sci_cdh_state == 0
    echo CDH Sci State Nominal
    set successCntdaxss = successCntdaxss + 1
else
    echo CDH Sci State Non-Nominal
    pause
endif

; FSW Version
if daxss_sci_sw_version >= 160
    echo FSW Version Correct
    set successCntdaxss = successCntdaxss + 1
else
    echo FSW Version Error
    pause
endif

; Patch Version
if daxss_sci_patch_version >= 0
    echo FSW Patch Correct
    set successCntdaxss = successCntdaxss + 1
else
    echo Patch Version Error
    pause
endif

; Last Opcode
if daxss_sci_cmd_opcode >= 0
    set successCntdaxss = successCntdaxss + 1
else
    echo Last Opcode Below Low Limit
    pause
endif

if daxss_sci_cmd_opcode <= 255
    set successCntdaxss = successCntdaxss + 1
else
    echo Last Opcode Above High Limit
    pause
endif

; Last Status
if daxss_sci_cmd_status <= 7
    set successCntdaxss = successCntdaxss + 1
else
    echo Last Status Above High Limit
    pause
endif

if daxss_sci_cmd_status >= 0
    set successCntdaxss = successCntdaxss + 1
else
    echo Last Status Below Low Limit
    pause
endif

; Accept Count
if daxss_sci_cmd_acpt_count >= 0
    set successCntdaxss = successCntdaxss + 1
else
    echo Accept Cnt Below Low Limit
    pause
endif

; Reject Count
if daxss_sci_cmd_rjct_count >= 0
    set successCntdaxss = successCntdaxss + 1
else
    echo Reject Cnt Below Low Limit
    pause
endif

; I2C Error
if daxss_sci_i2c_err == 0
    set successCntdaxss = successCntdaxss + 1
else
    echo I2C Error
    pause
endif

; RTC Error
if daxss_sci_rtc_err == 0
    set successCntdaxss = successCntdaxss + 1
else
    echo RTC Error
    pause
endif

; SPI SD Error
if daxss_sci_spi_sd_err == 0
    set successCntdaxss = successCntdaxss + 1
else
    echo SPI SD Error
    pause
endif

; UART 1 Error
if daxss_sci_uart1_err == 0
    set successCntdaxss = successCntdaxss + 1
else
    echo UART 1 Error
    pause
endif

; UART 2 Error
if daxss_sci_uart2_err == 0
    set successCntdaxss = successCntdaxss + 1
else
    echo UART 2 Error
    pause
endif

; UART 3 Error
if daxss_sci_uart3_err == 0
    set successCntdaxss = successCntdaxss + 1
else
    echo UART 3 Error
    pause
endif

; UART 4 Error
if daxss_sci_uart4_err == 0
    set successCntdaxss = successCntdaxss + 1
else
    echo UART 4 Error
    pause
endif

; 5 volt monitor
if daxss_sci_5v_volt >= 4.8
    set successCntdaxss = successCntdaxss + 1
else
    echo 5 V Monitor Below Low Limit
    pause
endif

if daxss_sci_5v_volt <= 5.2
    set successCntdaxss = successCntdaxss + 1
else
    echo 5 V Monitor Above High Limit
    pause
endif

; 3 volt monitor
if daxss_sci_3v_volt >= 3.2
    set successCntdaxss = successCntdaxss + 1
else
    echo 3 V Monitor Below Low Limit
    pause
endif

if daxss_sci_3v_volt <= 3.5
    set successCntdaxss = successCntdaxss + 1
else
    echo 3 V Monitor Above High Limit
    pause
endif

; CDH Board Temperature
if isTVACTest == 1
    goto IS_TVAC
endif
if isFlight == 1
    goto IS_TVAC
endif

NOT_TVAC:
if daxss_sci_cdh_temp >= 10
    set successCntdaxss = successCntdaxss + 1
else
    echo CDH Temperature Below Low Limit
    pause
endif
if daxss_sci_cdh_temp <= 40
    set successCntdaxss = successCntdaxss + 1
else
    echo CDH Temperature Above High Limit
    pause
endif
if isTVACTest == 1
    GOTO END_TEMPERATURES
endif

IS_TVAC:
if daxss_sci_cdh_temp >= -20
    set successCntdaxss = successCntdaxss + 1
else
    echo CDH Temperature Below Low Limit
    pause
endif
if daxss_sci_cdh_temp <= 60
    set successCntdaxss = successCntdaxss + 1
else
    echo CDH Temperature Above High Limit
    pause
endif
END_TEMPERATURES:

echo See above for any telemetry check error messages
echo COMPLETED CDH Check with successCntdaxss = $successCntdaxss