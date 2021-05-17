argument card dn32

cmd_sd_select card 0xFF
wait 1sec

cmd_sd_init card $card
tlmwait sd_card$card_state == SDCardState(GOOD) ? 10sec
timeout
	echo Could not initialize card $card
	return
endtimeout

cmd_sd_select card $card
