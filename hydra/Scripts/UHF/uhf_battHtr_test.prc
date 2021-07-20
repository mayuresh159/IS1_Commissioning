;MINXSS Battery Heater Test
;Purpose: Test battery heater setpoints
;Outline
;  Set setpoint to 2 degrees warmer than current temperature
;	and watch that battery heater comes on initially and then turns off when gets 2 degrees warmer
;  Enable/disable heaters and Set Point commands are tested

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare setpoint_original_low int16b
declare setpoint_new_low int16b
declare setpoint_original_high int16b
declare setpoint_new_high int16b
declare sample_original dn16

echo Select GO when ready to test Battery Heater
pause ; press GO to test Battery Heater

BATTERY_HEATER:
echo Starting Battery Heater Test

; first get EPS packet to verify that Battery Heater Set Point
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid ANA_HK rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

;UPDATE FOR WHAT THESE ACTUALLY ARE
verify eps_batt_set_low == 5
verify eps_batt_set_high == 7
verify beacon_pwr_status_htr == 0

set setpoint_original_low = eps_batt_set_low
set setpoint_original_high = eps_batt_set_high
set setpoint_new_low = eps_bat0_temp_conv + 2
set setpoint_new_high = eps_bat0_temp_conv + 4

BEGIN:

echo Setting Battery Heater Set Point Low to +2 C warmer than current Temperature
echo Battery Heater should automatically turn on after new temperature is set
echo Select GO when you're ready for this test
pause
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_eps_htr_setpoint low $setpoint_new_low high $setpoint_new_high
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500

verify eps_batt_set_low == $setpoint_new_low
verify eps_batt_set_high == $setpoint_new_high
verify beacon_pwr_status_htr == 1

echo Check if heater is ON and wait till the temperature rises above the high set point
tlmwait eps_bat0_temp_conv >= $setpoint_new_high

DISABLE:
;  Turn off Heater and reset Set Points back to original value
echo Disabling Battery Heater
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_eps_pwr_off component 4
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

verify beacon_pwr_status_htr == 0

echo Select GO after you verify that Battery Heater power is off
pause

;set setpoint_new_low = eps_bat0_temp_conv + 2
;set setpoint_new_high = eps_bat0_temp_conv + 4
;THIS DOESN"T WORK -- Currently no way to disble heater without
;just setting the setpoints extremely low
;set cmdCnt = beacon_cmd_succ_count + 1
;while beacon_cmd_succ_count < $cmdCnt
	;set cmdTry = cmdTry + 1
	;cmd_eps_htr_setpoint low $setpoint_new_low high $setpoint_new_high
	;wait 3529
;endwhile
;set cmdSucceed = cmdSucceed + 1

;echo Verify heater does not engage while off.
;pause

echo Returning Batter Heater back to it's original state

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_eps_htr_setpoint low $setpoint_original_low high $setpoint_original_high
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

;set cmdCnt = beacon_cmd_succ_count + 1
;while beacon_cmd_succ_count < $cmdCnt
;	set cmdTry = cmdTry + 1
;	cmd_eps_pwr_on component 4
;	wait 3529
;endwhile
;set cmdSucceed = cmdSucceed + 1
wait 3500

verify eps_batt_set_low == setpoint_original_low
verify eps_batt_set_high == setpoint_original_high
verify beacon_pwr_status_htr == 0

set sample_original = eps_batt_samples

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_eps_htr_samples samples 20
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500
verify eps_batt_samples == 20

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_noop
	cmd_eps_htr_samples samples $sample_original
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500
verify eps_batt_samples == $sample_original

echo Done with Battery Heater Test

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
	cmd_set_pkt_rate apid ANA_HK rate 0 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

print cmdTry
print cmdSucceed
