; NAME:
;   adcs_tlm_check
;
; PURPOSE:
;   Check that all ADCS telemetry is in expected limits
;
;  COMMANDS TESTED
;   None
;
; ISSUES:
;   None
;
; MODIFICATION HISTORY
;   2014/12/01: Matt Cirbo: Made template
;   2014/12/05: James Paul Mason: Populated limit values
;   2014/12/08: James Paul Mason: Incorporated new limits provided by Matt Baumgart via email on todays date
;    2014/12/12: James Paul Mason: Fine tuning and debugging completed.
;    2014/12/29: Seth Folley: Added printing of the CSS data from ADCS Packet 4 and Added Magnetometer check
;                                  Script takes 30 seconds to run depending on how long it takes operator to click continue at a couple points.
;    2016/03/05: James Paul Mason: Updated for flight.
;

declare isFlight dn16
declare isTVACTest dn16

declare cmdCnt dn16l
declare cmdTry dn16l
declare successCnt dn16l
declare failCnt dn16l
declare magneticFieldSquared dn16
declare magnetometer1Squared dn16
declare magnetometer2Squared dn16
declare magnetometer3Squared dn16
declare magnetometerSquareSum dn16

;0 is false/no and 1 is true/yes
; TVAC expands acceptable temperatures and doesn't raise a flag if heaters are enabled
; isFlight uses the same limits as isTVACTest
set isTVACTest = 1
set isFlight = 0

; Set mode to Safe mode if not already safe mode
if beacon_mode != 1
    set cmdCnt = beacon_cmd_succ_count + 1
    while beacon_cmd_succ_count < $cmdCnt
        cmd_noop
        cmd_mode_set mode 1
        set cmdTry = cmdTry + 1
        wait 3529
    endwhile
    set successCnt = successCnt + 1
endif


;route adcs_analogs, adcs_command_tlm, adcs_mag and adcs_rw_drive
; 0/DBG 1/UHF 2/SD 3/SBAND
; adcs_analogs
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 215 rate 10 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1
; adcs_command_tlm
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 200 rate 10 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1
; adcs_mag
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 211 rate 10 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1
; adcs_rw_drive
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 206 rate 10 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1


SUN_SENSOR_STATUS:
; Sun point status - require operator to okay for proceed since this is highly context dependent
if beacon_adcs_sun_pt_state == 2
    echo Coarse Sun Sensor Status Is Initializing Search. Acceptable?
    pause
endif
if beacon_adcs_sun_pt_state == 3
    echo Coarse Sun Sensor Status Is Searching. Acceptable?
    pause
endif
if beacon_adcs_sun_pt_state == 4
    echo Coarse Sun Sensor Status Is Waiting. Acceptable?
    pause
endif
if beacon_adcs_sun_pt_state == 5
    echo Coarse Sun Sensor Status Is Converging. Acceptable?
    pause
endif
if beacon_adcs_sun_pt_state == 6
    echo Coarse Sun Sensor Status Is On Sun. Acceptable?
    pause
endif
if beacon_adcs_sun_pt_state == 7
    echo Coarse Sun Sensor Status Is Not Active. Acceptable?
    pause
endif

VALID_FLAGS:

if beacon_adcs_att_valid == 0
    echo XACT Attitude Is Not Valid
endif
if beacon_adcs_att_valid == 1
    echo XACT Attitude Is Valid
endif

if beacon_adcs_refs_valid == 0
    echo XACT References Are Not Valid
endif
if beacon_adcs_refs_valid == 1
    echo XACT References Are Valid
endif

if beacon_adcs_time_valid == 0
    echo XACT Time Is Not Valid
endif
if beacon_adcs_time_valid == 1
    echo XACT Time Is Valid
endif

if beacon_adcs_mode == 0
    echo XACT Mode Is Sun Point
    set successCnt = successCnt + 1
endif
if beacon_adcs_mode == 1
    echo XACT Mode Is Fine Reference Point
    set successCnt = successCnt + 1
endif

POWER_INPUT: ; 5% tolerance on nominal value

; XACT Voltage 5.0
if beacon_adcs_digi_bus_volt >= 4.75
    set successCnt = successCnt + 1
else
    echo XACT 5V Line Below Low Limit
    set failCnt = failCnt + 1
endif
if beacon_adcs_digi_bus_volt <= 5.25
    set successCnt = successCnt + 1
else
    echo XACT 5V Line Above High Limit
    set failCnt = failCnt + 1
endif

; XACT 12 V Line for Reaction Wheels
if adcs_analogs_motor_bus_v >= 11.4
    set successCnt = successCnt + 1
else
    echo XACT 12 V Line for Reaction Wheels Below Low Limit
    set failCnt = failCnt + 1
endif
if adcs_analogs_motor_bus_v <= 12.6
    set successCnt = successCnt + 1
else
    echo XACT 12 V Line for Reaction Wheels Above High Limit
    set failCnt = failCnt + 1
endif

; XACT 12 V Line for Rods
if adcs_analogs_rod_bus_v >= 11.4
    set successCnt = successCnt + 1
else
    echo XACT 12 V Line for Rods Below Low Limit
    set failCnt = failCnt + 1
endif
if adcs_analogs_rod_bus_v <= 12.6
    set successCnt = successCnt + 1
else
    echo XACT 12 V Line for Rods Above High Limit
    set failCnt = failCnt + 1
endif

TEMPERATURES:

if isTVACTest == 1
    goto IS_TVAC
endif
if isFlight == 1
    goto NOT_TVAC
endif

NOT_TVAC:
    ; Tracker Det Temp
    if beacon_adcs_star_temp >= 15
        set successCnt = successCnt + 1
    else
        echo Star Tracker Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if beacon_adcs_star_temp <= 30
        set successCnt = successCnt + 1
    else
        echo Star Tracker Temp Above High Limit
        set failCnt = failCnt + 1
    endif

    ;IMU temp
    if adcs_analogs_imu_temp >= 15
        set successCnt = successCnt + 1
    else
        echo ADCS IMU Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if adcs_analogs_imu_temp <= 30
        set successCnt = successCnt + 1
    else
        echo ADCS IMU Temp Above High Limit
        set failCnt = failCnt + 1
    endif

    ; Wheel Temps
    if beacon_adcs_wheel_temp1 >= 15
        set successCnt = successCnt + 1
    else
        echo Wheel 1 Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if beacon_adcs_wheel_temp1 <= 30
        set successCnt = successCnt + 1
    else
        echo Wheel 1 Temp Above High Limit
        set failCnt = failCnt + 1
    endif

    if beacon_adcs_wheel_temp2 >= 15
        set successCnt = successCnt + 1
    else
        echo Wheel 2 Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if beacon_adcs_wheel_temp2 <= 30
        set successCnt = successCnt + 1
    else
        echo Wheel 2 Temp Above High Limit
        set failCnt = failCnt + 1
    endif

    if beacon_adcs_wheel_temp3 >= 15
        set successCnt = successCnt + 1
    else
        echo Wheel 3 Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if beacon_adcs_wheel_temp3 <= 30
        set successCnt = successCnt + 1
    else
        echo Wheel 3 Temp Above High Limit
        set failCnt = failCnt + 1
    endif
    goto END_TEMPERATURES

IS_TVAC:
    ; Tracker Det Temp
    if beacon_adcs_star_temp >= -15
        set successCnt = successCnt + 1
    else
        echo Star Tracker Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if beacon_adcs_star_temp <= 40
        set successCnt = successCnt + 1
    else
        echo Star Tracker Temp Above High Limit
        set failCnt = failCnt + 1
    endif

    ;IMU temp
    if adcs_analogs_imu_temp >= -15
        set successCnt = successCnt + 1
    else
        echo ADCS IMU Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if adcs_analogs_imu_temp <= 40
        set successCnt = successCnt + 1
    else
        echo ADCS IMU Temp Above High Limit
        set failCnt = failCnt + 1
    endif

    ; Wheel Temps
    if beacon_adcs_wheel_temp1 >= -15
        set successCnt = successCnt + 1
    else
        echo Wheel 1 Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if beacon_adcs_wheel_temp1 <= 40
        set successCnt = successCnt + 1
    else
        echo Wheel 1 Temp Above High Limit
        set failCnt = failCnt + 1
    endif

    if beacon_adcs_wheel_temp2 >= -15
        set successCnt = successCnt + 1
    else
        echo Wheel 2 Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if beacon_adcs_wheel_temp2 <= 40
        set successCnt = successCnt + 1
    else
        echo Wheel 2 Temp Above High Limit
        set failCnt = failCnt + 1
    endif

    if beacon_adcs_wheel_temp3 >= -15
        set successCnt = successCnt + 1
    else
        echo Wheel 3 Temp Below Low Limit
        set failCnt = failCnt + 1
    endif
    if beacon_adcs_wheel_temp3 <= 40
        set successCnt = successCnt + 1
    else
        echo Wheel 3 Temp Above High Limit
        set failCnt = failCnt + 1
    endif
END_TEMPERATURES:

SUN_BODY_VECTOR: ; 5% tolerance on unit vector
declare sunBodyVectorSum float32

set sunBodyVectorSum = beacon_adcs_sun_vec1 + beacon_adcs_sun_vec2 + beacon_adcs_sun_vec3
if sunBodyVectorSum >= 0.95
    set successCnt = successCnt + 1
else
    echo XACT Sun Body Vector Does Not Sum To Unity
    set failCnt = failCnt + 1
endif
if sunBodyVectorSum <= 1.05
    set successCnt = successCnt + 1
else
    echo XACT Sun Body Vector Does Not Sum To Unity
    set failCnt = failCnt + 1
endif

COMMANDING:

; Command Status
if adcs_command_tlm_cmd_status == 0
    echo XACT Command Status OK.
endif
if adcs_command_tlm_cmd_status == 1
    echo XACT Command Status = Bad APID. Acceptable?
    pause
endif
if adcs_command_tlm_cmd_status == 2
    echo XACT Command Status = Bad OpCode. Acceptable?
    pause
endif
if adcs_command_tlm_cmd_status == 3
    echo XACT Command Status = Bad Data. Acceptable?
    pause
endif
if adcs_command_tlm_cmd_status == 8
    echo XACT Command Status = Command Service Overrun. Acceptable?
    pause
endif
if adcs_command_tlm_cmd_status == 9
    echo XACT Command Status = Command APID Overrun. Acceptable?
    pause
endif

; Accept Count
if adcs_command_tlm_cmd_accept_count >= 0
    set successCnt = successCnt + 1
else
    echo XACT Command Accept Counter Below Zero
    set failCnt = failCnt + 1
endif

; Command Reject Status
if adcs_command_tlm_cmd_reject_status == 0
    echo XACT Command Reject Status OK.
endif
if adcs_command_tlm_cmd_reject_status == 1
    echo XACT Command Reject Status = Bad APID. Acceptable?
    pause
endif
if adcs_command_tlm_cmd_reject_status == 2
    echo XACT Command Reject Status = Bad OpCode. Acceptable?
    pause
endif
if adcs_command_tlm_cmd_reject_status == 3
    echo XACT Command Reject Status = Bad Data. Acceptable?
    pause
endif
if adcs_command_tlm_cmd_reject_status == 8
    echo XACT Command Reject Status = Command Service Overrun. Acceptable?
    pause
endif
if adcs_command_tlm_cmd_reject_status == 9
    echo XACT Command Reject Status = Command APID Overrun. Acceptable?
    pause
endif

; Reject Count
if adcs_command_tlm_cmd_reject_count >= 0
    set successCnt = successCnt + 1
else
    echo XACT Command Reject Counter Below Zero
    set failCnt = failCnt + 1
endif

DRAGS:

; Wheel 1 Est Drag
if adcs_rw_drive_drag_est1 >= -40
    set successCnt = successCnt + 1
else
    echo XACT Wheel 1 Drag Less Than Lower Limit. Wheels cold?
    set failCnt = failCnt + 1
endif
if adcs_rw_drive_drag_est1 <= 40
    set successCnt = successCnt + 1
else
    echo XACT Wheel 1 Drag Greater Than Upper Limit. Wheels cold?
    set failCnt = failCnt + 1
endif

; Wheel 2 Est Drag
if adcs_rw_drive_drag_est2 >= -40
    set successCnt = successCnt + 1
else
    echo XACT Wheel 2 Drag Less Than Lower Limit. Wheels cold?
    set failCnt = failCnt + 1
endif
if adcs_rw_drive_drag_est2 <= 40
    set successCnt = successCnt + 1
else
    echo XACT Wheel 2 Drag Greater Than Upper Limit. Wheels cold?
    set failCnt = failCnt + 1
endif

; Wheel 3 Est Drag
if adcs_rw_drive_drag_est3 >= -40
    set successCnt = successCnt + 1
else
    echo XACT Wheel 3 Drag Less Than Lower Limit. Wheels cold?
    set failCnt = failCnt + 1
endif
if adcs_rw_drive_drag_est3 <= 40
    set successCnt = successCnt + 1
else
    echo XACT Wheel 3 Drag Greater Than Upper Limit. Wheels cold?
    set failCnt = failCnt + 1
endif

WHEEL_SPEEDS:

; Wheel 1 Meas Speed
if beacon_adcs_wheel_sp1 >= -800
    set successCnt = successCnt + 1
else
    echo XACT Wheel 1 Speed Below Lower Limit
    set failCnt = failCnt + 1
endif
if beacon_adcs_wheel_sp1 <= 800
    set successCnt = successCnt + 1
else
    echo XACT Wheel 1 Speed Above Upper Limit
    set failCnt = failCnt + 1
endif

; Wheel 2 Meas Speed
if beacon_adcs_wheel_sp2 >= -800
    set successCnt = successCnt + 1
else
    echo XACT Wheel 2 Speed Below Lower Limit
    set failCnt = failCnt + 1
endif
if beacon_adcs_wheel_sp2 <= 800
    set successCnt = successCnt + 1
else
    echo XACT Wheel 2 Speed Above Upper Limit
    set failCnt = failCnt + 1
endif

; Wheel 3 Meas Speed
if beacon_adcs_wheel_sp3 >= -800
    set successCnt = successCnt + 1
else
    echo XACT Wheel 3 Speed Below Lower Limit
    set failCnt = failCnt + 1
endif
if beacon_adcs_wheel_sp3 <= 800
    set successCnt = successCnt + 1
else
    echo XACT Wheel 3 Speed Above Upper Limit
    set failCnt = failCnt + 1
endif

; Assuming stable spacecraft: ≤ 0.1 rad/sec
BODY_FRAME_RATE:

; Body Frame Rate 1
if beacon_adcs_body_rt1 >= -0.1
    set successCnt = successCnt + 1
else
    echo XACT Body Frame Rate 1 Above Stable Pointing Limit
    set failCnt = failCnt + 1
endif
if beacon_adcs_body_rt1 <= 0.1
    set successCnt = successCnt + 1
else
    echo XACT Body Frame Rate 1 Above Stable Pointing Limit
    set failCnt = failCnt + 1
endif

; Body Frame Rate 2
if beacon_adcs_body_rt2 >= -0.1
    set successCnt = successCnt + 1
else
    echo XACT Body Frame Rate 2 Above Stable Pointing Limit
    set failCnt = failCnt + 1
endif
if beacon_adcs_body_rt2 <= 0.1
    set successCnt = successCnt + 1
else
    echo XACT Body Frame Rate 2 Above Stable Pointing Limit
    set failCnt = failCnt + 1
endif

; Body Frame Rate 3
if beacon_adcs_body_rt3 >= -0.1
    set successCnt = successCnt + 1
else
    echo XACT Body Frame Rate 3 Above Stable Pointing Limit
    set failCnt = failCnt + 1
endif
if beacon_adcs_body_rt3 <= 0.1
    set successCnt = successCnt + 1
else
    echo XACT Body Frame Rate 3 Above Stable Pointing Limit
    set failCnt = failCnt + 1
endif

;check magnetic field magnitude to be between 0 and 75 uTesla(magnetic field of the earth)
;use x, y, and z fields to calculate magnitude

set magnetometer1Squared = adcs_mag_mag_vector_body1 * adcs_mag_mag_vector_body1
set magnetometer2Squared = adcs_mag_mag_vector_body2 * adcs_mag_mag_vector_body2
set magnetometer3Squared = adcs_mag_mag_vector_body3 * adcs_mag_mag_vector_body3
set magnetometerSquareSum = magnetometer1Squared + magnetometer2Squared
set magnetometerSquareSum = magnetometerSquareSum + magnetometer3Squared

;check the sum of the squares against 0 and 5625(75 squared)
verify magnetometerSquareSum >= 0
verify magnetometerSquareSum <= 5625

CLOSEOUT:
echo Success count = $successCnt expected many (40?)
echo Fail count = $failCnt
if $failCnt > 0
    echo ADCS Tlm Check: FAIL!
    echo Look at ECHO statements to see ADCS failures
    pause
else
    echo ADCS Tlm Check: SUCCESS!
endif

;turn off routing of adcs_analogs, adcs_command_tlm, and adcs_mag
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 215 rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 200 rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 211 rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_noop
    cmd_set_pkt_rate apid 206 rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set successCnt = successCnt + 1

FINISH:
echo COMPLETED  ADCS  tlm checks with Successes = $successCnt and Failures = $failCnt
; End adcs_tlm_check
