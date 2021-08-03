; MINXSS Radios telemetry check
; Purpose: Checks the UHF tlm for correct values andn that SBAND is OFF
; Outline:
;     On start up check the Radio Tlm before deployments
;
; Commands Sent:
;     NOOP
;
; EXPECTED CONFIGURATION:
;   PHOENIX or SAFE
;
; ISSUES:
;
; MODIFICATION HISTORY:
;    2020-3-12: Robert Sewell -- Created
;

declare cmdCnt dn16
declare seqCnt dn14
declare cmdTry dn16
declare successCnt dn8
declare failCnt dn8
declare SBANDpwr dn8

set successCnt = 0
set failCnt = 0
set SBANDpwr = 1

; Turn on SBAND if currently off
if beacon_pwr_status_sband == 0
    set SBANDpwr = 0
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_eps_pwr_on component SBAND override 1
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set successCnt = successCnt + 1
endif

verify beacon_alive_uhf == 1
verify beacon_alive_sband == 1

; All packets stream to UHF and not DBG
; Issue UHF_HK packet to UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_issue_pkt apid UHF_HK stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

; Issue SBAND_HK packet to UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_issue_pkt apid SBAND_HK stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1


UHF_TLM_CHECKS:
if uhf_tx_count >= 0
    set successCnt = successCnt + 1
else
    echo UHF TX Count invalid
    set failCnt = failCnt + 1
    pause
endif

if uhf_rx_discard == 0
    set successCnt = successCnt + 1
else
    echo UHF RX Discarded bytes
    set failCnt = failCnt + 1
    pause
endif

if uhf_sbe_count == 0
    set successCnt = successCnt + 1
else
    echo UHF has Single Bit Errors
    set failCnt = failCnt + 1
    pause
endif

; Why check == 2?
if uhf_mbe_count >= 2
    set successCnt = successCnt + 1
else
    echo UHF has Multi Bit Errors
    set failCnt = failCnt + 1
    pause
endif

if uhf_cmd_ready == 1
    set successCnt = successCnt + 1
else
    echo UHF not Command Ready
    set failCnt = failCnt + 1
    pause
endif

if uhf_pass_err_cnt == 0
    set successCnt = successCnt + 1
else
    echo UHF has Passthrough Packet Response Errors
    set failCnt = failCnt + 1
    pause
endif

if uhf_uart_drop_cnt == 0
    set successCnt = successCnt + 1
else
    echo UHF has bytes dropped by UART
    set failCnt = failCnt + 1
    pause
endif

if uhf_uart_fra_err == 0
    set successCnt = successCnt + 1
else
    echo UHF has UART Framing Errors
    set failCnt = failCnt + 1
    pause
endif

if uhf_uart_par_err == 0
    set successCnt = successCnt + 1
else
    echo UHF has UART Parity Errors
    set failCnt = failCnt + 1
    pause
endif

if uhf_uart_ovr_err == 0
    set successCnt = successCnt + 1
else
    echo UHF has UART Overrun Errors
    set failCnt = failCnt + 1
    pause
endif

if uhf_trap_count == 0
    set successCnt = successCnt + 1
else
    echo UHF has Trap Counts
    set failCnt = failCnt + 1
    pause
endif

if uhf_PLL_count == 0
    set successCnt = successCnt + 1
else
    echo UHF has PLL Counts
    set failCnt = failCnt + 1
    pause
endif

if uhf_watchdog_count == 0
    set successCnt = successCnt + 1
else
    echo UHF has Watchdog Counts
    set failCnt = failCnt + 1
    pause
endif

;UHF Locked
if uhf_locked == 0
    set successCnt = successCnt + 1
else
    echo UHF Mode Locked
    set failCnt = failCnt + 1
    pause
endif

;UHF Readback
if uhf_read_mode == 0x4E
    set successCnt = successCnt + 1
else
    echo UHF in Readback not N
    set failCnt = failCnt + 1
    pause
endif

;UHF SWD
if uhf_swd_mode == 0x56
    set successCnt = successCnt + 1
else
    echo UHF Mode SWD not V
    set failCnt = failCnt + 1
    pause
endif

;UHF AFC
if uhf_afc_mode == 0x46
    set successCnt = successCnt + 1
else
    echo UHF Mode not F
    set failCnt = failCnt + 1
    pause
endif

;UHF ECHO
if uhf_echo_mode == 0x45
    set successCnt = successCnt + 1
else
    echo UHF Mode ECHO not E
    set failCnt = failCnt + 1
    pause
endif

;UHF Channel
if uhf_channel == 0x41
    set successCnt = successCnt + 1
else
    echo UHF Channel not A
    set failCnt = failCnt + 1
    pause
endif



SBAND_TLM_CHECKS:
if sband_sent_count >= 0
    set successCnt = successCnt + 1
else
    echo SBAND Sent Count Invalid
    set failCnt = failCnt + 1
    pause
endif

if sband_idle_count >= 0
    set successCnt = successCnt + 1
else
    echo SBAND Idle Count Invalid
    set failCnt = failCnt + 1
    pause
endif

if sband_power == 0x3
    set successCnt = successCnt + 1
else
    echo SBAND Power not at -30 DB
    set failCnt = failCnt + 1
    pause
endif

if sband_synth_offset == 4
    set successCnt = successCnt + 1
else
    echo Incorrect Synth Offset
    set failCnt = failCnt + 1
    pause
endif

if sband_control == 0 || 128
    set successCnt = successCnt + 1
else
    echo Incorrect SBAND Control register
    set failCnt = failCnt + 1
    pause
endif

if sband_encoder == 0
    set successCnt = successCnt + 1
else
    echo Incorrect SBAND Encoder register
    set failCnt = failCnt + 1
    pause
endif

if sband_underrun == 0
    set successCnt = successCnt + 1
else
    echo SBAND buffer underruns
    set failCnt = failCnt + 1
    pause
endif

if sband_overruns == 0
    set successCnt = successCnt + 1
else
    echo SBAND buffer overruns
    set failCnt = failCnt + 1
    pause
endif

if sband_underrun == 0
    set successCnt = successCnt + 1
else
    echo SBAND buffer underruns
    set failCnt = failCnt + 1
    pause
endif

if sband_tx_ready == 1
    set successCnt = successCnt + 1
else
    echo SBAND TX not Ready
    set failCnt = failCnt + 1
    pause
endif

if sband_hk_valid == 1
    set successCnt = successCnt + 1
else
    echo SBAND HK not Valid
    set failCnt = failCnt + 1
    pause
endif

if sband_i2c_timeout == 0
    set successCnt = successCnt + 1
else
    echo SBAND i2c not running
    set failCnt = failCnt + 1
    pause
endif

if sband_i2c_fail == 0
    set successCnt = successCnt + 1
else
    echo SBAND i2c failed
    set failCnt = failCnt + 1
    pause
endif

VOLTAGES_CURRENTS:

;UHF Voltage
if beacon_uhf_volt >= 5.75
    set successCnt = successCnt + 1
else
    echo UHF Voltage outside low limit
    print beackon_uhf_volt
    set failCnt = failCnt + 1
    pause
endif

if beacon_uhf_volt <= 6.25
    set successCnt = successCnt + 1
else
    echo UHF Voltage outside high limit
    print beacon_uhf_volt
    set failCnt = failCnt + 1
    pause
endif

if beacon_uhf_curr >= .03
    set successCnt = successCnt + 1
else
    echo UHF Current outside of low limit
    print beacon_uhf_curr
    set failCnt = failCnt + 1
    pause
endif

if beacon_uhf_curr <= .05
    set successCnt = successCnt + 1
else
    echo UHF Current outside of high limit
    print beacon_uhf_curr
    set failCnt = failCnt + 1
    pause
endif


if beacon_sband_volt >= 5.75
    if beacon_sband_volt <= 6.25
        set successCnt = successCnt + 1
    else
        echo SBAND Voltage outside of high limit
        print beacon_sband_volt
        set failCnt = failCnt + 1
        pause
    endif
else
    echo SBAND Voltage outside of low limit
    print beacon_sband_volt
    set failCnt = failCnt + 1
    pause
endif

if sband_status == 1
    if sband_bat_cur >= 0.05
        if sband_bat_cur <= 0.15
            set successCnt = successCnt + 1
        else
            echo SBAND Current outside of high limit
            print sband_bat_cur
            set failCnt = failCnt + 1
            pause
        endif
    else
        echo SBAND Current outside of low limit
        print sband_bat_cur
        set failCnt = failCnt + 1
        pause
    endif
endif

if sband_status == 3
    if sband_bat_cur >= 0.63
        if sband_bat_cur <= 0.7
            set successCnt = successCnt + 1
        else
            echo SBAND Current outside of high limit
            print sband_bat_cur
            set failCnt = failCnt + 1
            pause
        endif
    else
        echo SBAND Current outside of low limit
        print sband_bat_cur
        set failCnt = failCnt + 1
        pause
    endif
    if sband_pa_volt >= 5.0
        if sband_pa_volt <= 5.5
            set successCnt = successCnt + 1
        else
            echo SBAND PA Voltage outside of high limit
            print sband_pa_volt
            set failCnt = failCnt + 1
            pause
        endif
    else
        echo SBAND PA Voltage outside of low limit
        print sband_pa_volt
        set failCnt = failCnt + 1
        pause
    endif

    if sband_pa_curr >= 0.0
        if sband_pa_curr <= 0.15
            set successCnt = successCnt + 1
        else
            echo SBAND Current outside of high limit
            print sband_pa_curr
            set failCnt = failCnt + 1
            pause
        endif
    else
        echo SBAND Current outside of low limit
        print sband_pa_curr
        set failCnt = failCnt + 1
        pause
    endif
endif

TEMPERATURES:
if beacon_sband_top_temp >= 15
    if beacon_sband_top_temp <= 30
        set successCnt = successCnt + 1
    else
        echo SBAND Top Temp outside of high limit
        print beacon_sband_top_temp
        set failCnt = failCnt + 1
        pause
    endif
else
    echo SBAND Top Temp outside of low limit
    print beacon_sband_top_temp
    set failCnt = failCnt + 1
    pause
endif

if sband_bdb_temp >= 15
    if sband_bdb_temp <= 30
        set successCnt = successCnt + 1
    else
        echo SBAND Bottom Temp outside of high limit
        print sband_bdb_temp
        set failCnt = failCnt + 1
        pause
    endif
else
    echo SBAND Bottom Temp outside of low limit
    print sband_bdb_temp
    set failCnt = failCnt + 1
    pause
endif

if sband_pa_temp >= 15
    if sband_pa_temp <= 30
        set successCnt = successCnt + 1
    else
        echo SBAND PA Temp outside of high limit
        print sband_pa_temp
        set failCnt = failCnt + 1
        pause
    endif
else
    echo SBAND PA Temp outside of low limit
    print sband_pa_temp
    set failCnt = failCnt + 1
    pause
endif

if beacon_uhf_temp >= 15
    if beacon_uhf_temp <= 30
        set successCnt = successCnt + 1
    else
        echo UHF Temp outside of high limit
        print beacon_uhf_temp
        set failCnt = failCnt + 1
        pause
    endif
else
    echo UHF Temp outside of low limit
    print beacon_uhf_temp
    set failCnt = failCnt + 1
    pause
endif


FINISH:

if $SBANDpwr == 0
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_eps_pwr_off component SBAND override 0
        set cmdTry = cmdTry + 1
        wait 3500
    endwhile
    set successCnt = successCnt + 1
endif

; Unroute packets from UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid UHF_HK rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

; Issue SBAND_HK packet to UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SBAND_HK rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1


echo COMPLETED Radios tlm checks with Successes = $successCnt and Failures = $failCnt
