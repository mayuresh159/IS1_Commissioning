;eps_sd_card_power_test Procedure
;Purpose: Test EPS cmds to power cycle the sd cards
; MODIFICATION HISTORY: 
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare sdSel dn8
declare beaconWrite dn32l
set cmdTry = 0
set cmdSucceed = 0
set sdSel = 255

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid 42 rate 3 stream DBG
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

;SD cards, atleast one should be initialized
if beacon_pwr_status_sd0 == 0
	verify sd_card1_state == 1
	verify beacon_pwr_status_sd1 == 1
	verify sd_card_sel == 1
	set sdSel = 1
else
	if sd_card0_state == 0
		verify sd_card1_state == 1
		verify beacon_pwr_status_sd1 == 1
		verify sd_card_sel == 1
		set sdSel = 1
	else
		verify sd_card0_state == 1
		verify beacon_pwr_status_sd0 == 1
		if sd_card_sel == 0
			set sdSel = 0
		else
			verify sd_card1_state == 1
			verify beacon_pwr_status_sd1 == 1
			verify sd_card_sel == 1
			set sdSel = 1
		endif
	endif
endif

if sdSel == 255
	echo Unexpected SD card states
	pause
endif

SWITCH_SD:
if $sdSel == 0
	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_init card CARD_1
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1
	
	wait 3500
	verify beacon_pwr_status_sd1 == 1

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_select card CARD_1
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify sd_card_sel == 1

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_pwr_off card CARD_0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify beacon_pwr_status_sd0 == 0

	;Back on
	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_init card CARD_0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify beacon_pwr_status_sd0 == 1

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_select card CARD_0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify sd_card_sel == 0

	;Don't turn off CARD 1 or CARD 0 will fail
	;set cmdCnt = beacon_cmd_succ_count + 1
	;while beacon_cmd_succ_count < $cmdCnt
		;set cmdTry = cmdTry + 1
		;cmd_sd_pwr_off card CARD_1
		;wait 3500
	;endwhile
	;set cmdSucceed = cmdSucceed + 1

	;wait 3500
	;verify beacon_pwr_status_sd1 == 0;
endif
if $sdSel == 1
	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_init card CARD_0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1
	
	wait 3500
	verify beacon_pwr_status_sd0 == 1

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_select card CARD_0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify sd_card_sel == 0

	;Don't turn off CARD 1 or CARD 0 will fail
	;set cmdCnt = beacon_cmd_succ_count + 1
	;while beacon_cmd_succ_count < $cmdCnt
		;set cmdTry = cmdTry + 1
		;cmd_sd_pwr_off card CARD_1
		;wait 3500
	;endwhile
	;set cmdSucceed = cmdSucceed + 1

	;wait 3500
	;verify beacon_pwr_status_sd1 == 0;

	;;Back on
	;set cmdCnt = beacon_cmd_succ_count + 1
	;while beacon_cmd_succ_count < $cmdCnt
		;set cmdTry = cmdTry + 1
		;cmd_sd_init card CARD_1
		;wait 3500
	;endwhile
	;set cmdSucceed = cmdSucceed + 1

	;wait 3500
	;verify beacon_pwr_status_sd1 == 1

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_select card CARD_1
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify sd_card_sel == 1

	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_pwr_off card CARD_0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1

	wait 3500
	verify beacon_pwr_status_sd0 == 0
endif

DISABLE:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_sd_write_state state 0
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500
set beaconWrite = beacon_sd_write_beacon
wait 9000
verify beacon_sd_write_beacon == $beaconWrite

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_sd_write_state state 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500
set beaconWrite = beacon_sd_write_beacon
wait 9000
verify beacon_sd_write_beacon != $beaconWrite

SELECT_FLASH:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_sd_select card FLASH
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

wait 3500
verify sd_card_sel == 2

echo Press go to start SD Card Playback over UHF else GOTO FINISH
pause
wait 120000

set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_sd_read stream UHF timeout 120 partition BEACON decimation 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

wait 120000
echo Verify playback finished
pause

FINISH:
if $sdSel == 0
	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_select card CARD_0
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1
else
	set cmdCnt = beacon_cmd_succ_count + 1
	while beacon_cmd_succ_count < $cmdCnt
		set cmdTry = cmdTry + 1
		cmd_sd_select card CARD_1
		wait 3500
	endwhile
	set cmdSucceed = cmdSucceed + 1
endif

print cmdTry
print cmdSucceed