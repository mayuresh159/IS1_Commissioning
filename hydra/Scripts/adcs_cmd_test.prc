;
; NAME:
;   adcs_cmd_test
;
; PURPOSE:
;   Verify many of the ADCS commands
;
;  COMMANDS TESTED - Based on XACT Box Level Test Procedure Rev D from Jake Beckner
;   adcs_SetWheelMode Wheel 0 Mode EXTERNAL
;   adcs_SetWheelSpeed Speed_1 1250 Speed_2 2500 Speed_3 3750 Wheel 0
;
;   HK PACKET TELEMETRY POINTS VERIFIED
;       None beyond whats necessary to verify that commanding worked
;
; ISSUES:
;   Consider idling wheels between speed changes to reduce wear and tear on wheels
;
; MODIFICATION HISTORY
;   2014/11/23: James Paul Mason: Initial script
;   2014/12/12: James Paul Mason: Finished debugging, testing, and fine tuning. Still occasionally get an instantaneous telemetry check failure, but always pass if operator looks at hk for a few seconds
;								  It takes about 4.5 minutes to complete this script. 
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdCntADCS dn16
declare cmdTryADCS dn16l
declare cmdSucceedADCS dn16l
declare gpsTimeStamp1 dn32
declare timeInterval dn32
declare numberOfWheelsAtSpeed dn16
declare eclipsethresh dn32
declare eclipsecount dn32
declare writeADCSstart dn32l
declare writeADCSnum dn32l

pause 
echo Starting ADCS Command Test

SETUP:
if beacon_mode != 1
	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		cmd_mode_set mode 1
		set cmdTry = cmdTry + 1
		wait 3529
	endwhile
	set cmdSucceed = cmdSucceed + 1 
endif

;ADCS aliveness
call Scripts/adcs_tlm_check

set writeADCSstart = beacon_sd_write_adcs

;route adcs_analogs, adcs_command_tlm, and adcs_mag
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 215 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 200 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 211 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 206 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 43 rate 3 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 215 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 200 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 211 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 206 rate 1 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 43 rate 3 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

; Establish a power baseline
SWITCH_POWER_OFF:

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_eps_pwr_off component 2 override 1
	set cmdTry = cmdTry + 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1 

verify beacon_pwr_status_adcs == 0
; if caught with no radio transmit
verify beacon_adcs_curr == 0

; Can now make sure that XACT power level is in range
SWITCH_POWER_ON:

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_eps_pwr_on component 2 override 0
	set cmdTry = cmdTry + 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1 

tlmwait beacon_pwr_status_adcs == 1
wait 8000
;verify beacon_adcs_curr > 3

;route what we need from ADCS
;set cmdCnt = beacon_cmd_succ_count + 1
;while beacon_cmd_succ_count < $cmdCnt
;	set cmdTry = cmdTry + 1
;	route_adcs_pkt Route BOTH
;	wait 3529
;endwhile
;set cmdSucceed = cmdSucceed + 1

REACTION_WHEELS:
echo Beginning reaction wheel tests

; Command the wheels to external mode e.g., speed set by command
;wait 3529
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 2
	set cmdTryADCS = cmdTryADCS + 1
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1 

COMMAND_SPEEDS:
; 1250 RPM = 6250 DN * 0.2 DN/RPM, 2500 RPM = 12500 DN * 0.2 DN/RPM, 3750 RPM = 18750 DN * 0.2 DN/RPM, 6000 RPM = 30000 DN

; Command the wheels to specified positive speeds (unique to each wheel)
wait 8000
echo Commanding to unique positive speeds for reaction wheels
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000

wait 3529
cmd_adcs_Wheel_SetWheelSpeed4 Wheel 0 Speed_1 6250 Speed_2 12500 Speed_3 18750 Speed_4 0
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

; milliseconds
;wait 5000 
tlmwait beacon_adcs_wheel_sp1 >= 1187.5 ? 5000
tlmwait beacon_adcs_wheel_sp2 >= 2375.0 ? 5000
tlmwait beacon_adcs_wheel_sp3 >= 3571.5 ? 5000

; Verify wheel speed rad/sec
verify beacon_adcs_wheel_sp1 >= 1187.5 
verify beacon_adcs_wheel_sp1 <= 1312.5
verify beacon_adcs_wheel_sp2 >= 2375.0
verify beacon_adcs_wheel_sp2 <= 2625.0 
verify beacon_adcs_wheel_sp3 >= 3571.5  
verify beacon_adcs_wheel_sp3 <= 3937.5

; Verify power consumption
;verify beacon_adcs_curr >= 4 
;verify beacon_adcs_curr <= 6

; Verify temperature performance Degrees C
verify beacon_adcs_wheel_temp1 >= 15
verify beacon_adcs_wheel_temp1 <= 40
verify beacon_adcs_wheel_temp2 >= 15
verify beacon_adcs_wheel_temp2 <= 40
verify beacon_adcs_wheel_temp3 >= 15
verify beacon_adcs_wheel_temp3 <= 40

; Command torques to zero
echo Commanding torques to zero
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
cmd_adcs_Wheel_SetWheelTorque32 Wheel 0 Torque_1 0 Torque_2 0 Torque_3 0 Torque_4 0
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

wait 5000
; Verify speeds have not changed
verify beacon_adcs_wheel_sp1 >= 1187.5 
verify beacon_adcs_wheel_sp1 <= 1312.5
verify beacon_adcs_wheel_sp2 >= 2375.0
verify beacon_adcs_wheel_sp2 <= 2625.0 
verify beacon_adcs_wheel_sp3 >= 3571.5  
verify beacon_adcs_wheel_sp3 <= 3937.5
wait 8000

; Command the wheels to specified negative speeds (unique to each wheel)
echo Commanding to unique negative speeds for reaction wheels
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; Speeds in RPM
cmd_adcs_Wheel_SetWheelSpeed4 Wheel 0 Speed_1 -12500 Speed_2 -18750 Speed_3 -6250 Speed_4 0
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

; milliseconds
tlmwait beacon_adcs_wheel_sp1 <= -2375.0 ? 5000
tlmwait beacon_adcs_wheel_sp2 <= -3571.5 ? 5000
tlmwait beacon_adcs_wheel_sp3 <= -1187.5 ? 5000
; Verify wheel speed rad/sec
verify beacon_adcs_wheel_sp1 >= -2625.0
verify beacon_adcs_wheel_sp1 <= -2375.0
verify beacon_adcs_wheel_sp2 >= -3937.5
verify beacon_adcs_wheel_sp2 <= -3571.5
verify beacon_adcs_wheel_sp3 >= -1312.5 
verify beacon_adcs_wheel_sp3 <= -1187.5

; Verify power consumption
;verify beacon_adcs_curr >= 4  
;verify beacon_adcs_curr <= 6 

; Verify temperature performance degrees C
verify beacon_adcs_wheel_temp1 >= 15
verify beacon_adcs_wheel_temp1 <= 40
verify beacon_adcs_wheel_temp2 >= 15
verify beacon_adcs_wheel_temp2 <= 40
verify beacon_adcs_wheel_temp3 >= 15
verify beacon_adcs_wheel_temp3 <= 40
wait 8000

; Command all wheels to +6000 RPM
echo Commanding all wheels to +6000 RPM
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; Speeds in RPM
cmd_adcs_Wheel_SetWheelSpeed4 Wheel 0 Speed_1 30000 Speed_2 30000 Speed_3 30000 Speed_4 0
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

tlmwait beacon_adcs_wheel_sp1 >= 5700.0 ? 8000
tlmwait beacon_adcs_wheel_sp2 >= 5700.0 ? 8000
tlmwait beacon_adcs_wheel_sp3 >= 5700.0 ? 8000

; Verify wheel speed rad/sec
verify beacon_adcs_wheel_sp1 >= 5700.0
verify beacon_adcs_wheel_sp1 <= 6300.0 
verify beacon_adcs_wheel_sp2 >= 5700.0
verify beacon_adcs_wheel_sp2 <= 6300.0 
verify beacon_adcs_wheel_sp3 >= 5700.0
verify beacon_adcs_wheel_sp3 <= 6300.0 

; Verify power consumption
;verify beacon_adcs_curr >= 4  
;verify beacon_adcs_curr <= 6

; Verify temperature performance degrees C
verify beacon_adcs_wheel_temp1 >= 15
verify beacon_adcs_wheel_temp1 <= 40
verify beacon_adcs_wheel_temp2 >= 15
verify beacon_adcs_wheel_temp2 <= 40
verify beacon_adcs_wheel_temp3 >= 15
verify beacon_adcs_wheel_temp3 <= 40
wait 8000

; Command all wheels to -6000 RPM
echo Commanding all wheels to -6000 RPM
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; Speeds in RPM
cmd_adcs_Wheel_SetWheelSpeed4 Wheel 0 Speed_1 -30000 Speed_2 -30000 Speed_3 -30000 Speed_4 0
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

tlmwait beacon_adcs_wheel_sp1 <= -5700.0 ? 15000
tlmwait beacon_adcs_wheel_sp2 <= -5700.0 ? 15000
tlmwait beacon_adcs_wheel_sp3 <= -5700.0 ? 15000
; Verify wheel speed rad/sec
verify beacon_adcs_wheel_sp1 <= -5700.0
verify beacon_adcs_wheel_sp1 >= -6300.0 
verify beacon_adcs_wheel_sp2 <= -5700.0
verify beacon_adcs_wheel_sp2 >= -6300.0 
verify beacon_adcs_wheel_sp3 <= -5700.0
verify beacon_adcs_wheel_sp3 >= -6300.0 

; Verify power consumption
;wait 15000
;verify beacon_adcs_curr >= 4  
;verify beacon_adcs_curr <= 6

; Verify temperature performance degrees C
verify beacon_adcs_wheel_temp1 >= 15
verify beacon_adcs_wheel_temp1 <= 40
verify beacon_adcs_wheel_temp2 >= 15
verify beacon_adcs_wheel_temp2 <= 40
verify beacon_adcs_wheel_temp3 >= 15
verify beacon_adcs_wheel_temp3 <= 40
wait 8000

; Command wheels to IDLE
echo Commanding all wheels to IDLE
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; Wheel mode is not included in HK so no way to verify without dumping XACT parameters
cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

echo Waiting for wheels to spin down for 40 seconds
; milliseconds
;wait 40000
tlmwait beacon_adcs_wheel_sp1 >= -10 ? 40000
tlmwait beacon_adcs_wheel_sp2 >= -10 ? 40000
tlmwait beacon_adcs_wheel_sp3 >= -10 ? 40000

; Verify wheel speed rad/sec
verify beacon_adcs_wheel_sp1 >= -10
verify beacon_adcs_wheel_sp1 <= 10
verify beacon_adcs_wheel_sp2 >= -10
verify beacon_adcs_wheel_sp2 <= 10
verify beacon_adcs_wheel_sp3 >= -10 
verify beacon_adcs_wheel_sp3 <= 10
wait 8000

; Command the wheels to external mode e.g., speed set by command
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; Wheel mode is not included in HK so no way to verify without dumping XACT parameters
cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 2 
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

; Command all wheels to 0 RPM
echo Commanding all wheels to 0 RPM
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; Speeds in RPM
cmd_adcs_Wheel_SetWheelSpeed4 Wheel 0 Speed_1 0 Speed_2 0 Speed_3 0 Speed_4 0
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

; milliseconds
wait 5000

COMMAND_TORQUES:

; Command all wheel torques to 0.0003
echo Commanding all torques to +0.0003
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; 0.0003 (desired) * 1.5E7 (conversion) = 4500 DN for command
cmd_adcs_Wheel_SetWheelTorque32 Wheel 0 Torque_1 4500 Torque_2 4500 Torque_3 4500 Torque_4 0
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

; Start timer
set gpsTimeStamp1 = gpsTime

; Determine time when each wheel reaches 200 and 400 rad/min
declare wheel1At200 dn16
declare wheel2At200 dn16
declare wheel3At200 dn16
while numberOfWheelsAtSpeed < 5
	; Wheel 1
	if wheel1At200 == 1 
		goto SKIP_WHEEL1_200_POSITIVE
	endif
    if beacon_adcs_wheel_sp1 >= 200
		set wheel1At200 = 1
		echo 0.003 torque command - Time for wheel 1 to reach +200 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
	endif
SKIP_WHEEL1_200_POSITIVE:
	if beacon_adcs_wheel_sp1 >= 400
        echo 0.003 torque command - Time for wheel 1 to reach +400 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
    endif
	
    ; Wheel 2
	if wheel2At200 == 1 
		goto SKIP_WHEEL2_200_POSITIVE
	endif
    if beacon_adcs_wheel_sp2 >= 200
		set wheel2At200 = 1
		echo 0.003 torque command - Time for wheel 2 to reach +200 rad/min was
        set timeInterval = gpsTime - $gpsTimeStamp1
		print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
	endif
SKIP_WHEEL2_200_POSITIVE:
	if beacon_adcs_wheel_sp2 >= 400
        echo 0.003 torque command - Time for wheel 2 to reach +400 rad/min was
        set timeInterval = gpsTime - $gpsTimeStamp1
		print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
    endif

    ; Wheel 3
	if wheel3At200 == 1 
		goto SKIP_WHEEL3_200_POSITIVE
	endif
    if beacon_adcs_wheel_sp3 >= 200
		set wheel3At200 = 1
		echo 0.003 torque command - Time for wheel 3 to reach +200 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
	endif
SKIP_WHEEL3_200_POSITIVE:
	if beacon_adcs_wheel_sp3 >= 400
        echo 0.003 torque command - Time for wheel 3 to reach +400 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
    endif
endwhile

; Command wheels to IDLE
echo Commanding all wheels to IDLE
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; Wheel mode is not included in HK so no way to verify without dumping XACT parameters
cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0 
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

echo Waiting for wheels to spin down for 40 seconds
; milliseconds
;wait 40000
tlmwait beacon_adcs_wheel_sp1 <= 10 ? 40000
tlmwait beacon_adcs_wheel_sp2 <= 10 ? 40000
tlmwait beacon_adcs_wheel_sp3 <= 10 ? 40000

; Verify wheel speed rad/sec
verify beacon_adcs_wheel_sp1 >= -10
verify beacon_adcs_wheel_sp1 <= 10
verify beacon_adcs_wheel_sp2 >= -10
verify beacon_adcs_wheel_sp2 <= 10
verify beacon_adcs_wheel_sp3 >= -10 
verify beacon_adcs_wheel_sp3 <= 10
wait 8000

; Command the wheels to external mode e.g., speed set by command
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 2 
; Wheel mode is not included in HK so no way to verify without dumping XACT parameters
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1
wait 5000

; Command all wheels torque to -0.0003
echo Commanding all torques to -0.0003
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; -0.0003 (desired) * 1.5E7 (conversion) = -4500 for command
cmd_adcs_Wheel_SetWheelTorque32 Wheel 0 Torque_1 -4500 Torque_2 -4500 Torque_3 -4500 Torque_4 0
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

; Reset timer and counter
set gpsTimeStamp1 = gpsTime
set numberOfWheelsAtSpeed = 0

; Determine time when each wheel reaches -200 and -400 rad/min
declare wheel1AtNeg200 dn16
declare wheel2AtNeg200 dn16
declare wheel3AtNeg200 dn16
while numberOfWheelsAtSpeed < 5
	; Wheel 1
	if wheel1AtNeg200 == 1 
		goto SKIP_WHEEL1_200_NEGATIVE
	endif
    if beacon_adcs_wheel_sp1 <= -200
		set wheel1AtNeg200 = 1
		echo -0.003 torque command - Time for wheel 1 to reach -200 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
	endif
SKIP_WHEEL1_200_NEGATIVE:
	if beacon_adcs_wheel_sp1 <= -400
        echo -0.003 torque command - Time for wheel 1 to reach -400 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
    endif
	
    ; Wheel 2
	if wheel2AtNeg200 == 1 
		goto SKIP_WHEEL2_200_NEGATIVE
	endif
    if beacon_adcs_wheel_sp2 <= -200
		set wheel2AtNeg200 = 1
		echo -0.003 torque command - Time for wheel 2 to reach -200 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
	endif
SKIP_WHEEL2_200_NEGATIVE:
	if beacon_adcs_wheel_sp2 <= -400
        echo -0.003 torque command - Time for wheel 2 to reach -400 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
    endif

    ; Wheel 3
	if wheel3AtNeg200 == 1 
		goto SKIP_WHEEL3_200_NEGATIVE
	endif
    if beacon_adcs_wheel_sp3 <= -200
		set wheel3AtNeg200 = 1
		echo -0.003 torque command - Time for wheel 3 to reach -200 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
	endif
SKIP_WHEEL3_200_NEGATIVE:
	if beacon_adcs_wheel_sp3 <= -400
        echo -0.003 torque command - Time for wheel 3 to reach -400 rad/min was
		set timeInterval = gpsTime - $gpsTimeStamp1
        print timeInterval
        echo Seconds
        set numberOfWheelsAtSpeed = numberOfWheelsAtSpeed + 1
    endif
endwhile

; Command wheels to IDLE
echo Commanding all wheels to IDLE
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
set cmdCntADCS = $cmdCntADCS % 0x10000
; Wheel mode is not included in HK so no way to verify without dumping XACT parameters
cmd_adcs_Wheel_SetWheelMode Wheel 0 Mode 0 
set cmdTryADCS = cmdTryADCS + 1
tlmwait beacon_adcs_cmd_acpt >= $cmdCntADCS
set cmdSucceedADCS = cmdSucceedADCS + 1

echo Waiting for wheels to spin down for 40 seconds
; milliseconds
;wait 40000
tlmwait beacon_adcs_wheel_sp1 >= -10 ? 40000
tlmwait beacon_adcs_wheel_sp2 >= -10 ? 40000
tlmwait beacon_adcs_wheel_sp3 >= -10 ? 40000

; Verify wheel speed rad/sec
verify beacon_adcs_wheel_sp1 >= -10
verify beacon_adcs_wheel_sp1 <= 10
verify beacon_adcs_wheel_sp2 >= -10
verify beacon_adcs_wheel_sp2 <= 10
verify beacon_adcs_wheel_sp3 >= -10 
verify beacon_adcs_wheel_sp3 <= 10

set eclipsethresh = adcs_eclipse_threshold
set eclipsecount = adcs_eclipse_count
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_adcs_eclipse_update threshold 2500 count 3
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

wait 3500
verify adcs_eclipse_threshold == 2500
verify adcs_eclipse_count == 3

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_adcs_eclipse_update threshold $eclipsethresh count $eclipsecount
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
wait 3500
verify adcs_eclipse_threshold == $eclipsethresh
verify adcs_eclipse_count == $eclipsecount

CLOSEOUT:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SD_HK rate 3 stream DBG
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set writeADCSnum = beacon_sd_write_adcs - $writeADCSstart
set writeADCSnum = $writeADCSnum % sd_partition_size3
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_sd_playback stream UHF start $writeADCSstart num $writeADCSnum timeout 600 partition 3 decimation 1
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
tlmwait sd_partition_pbk3 == ( $writeADCSstart + $writeADCSnum ) % sd_partition_size3 ? 600000
echo Verify UHF playback complete
pause

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid SD_HK rate 0 stream DBG
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 215 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 200 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 211 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 206 rate 0 stream 0
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 215 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 200 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 211 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid 206 rate 0 stream SD
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

FINISH:
echo ADCS command test complete. Returned wheels to IDLE.


print cmdTry
print cmdSucceed