argument card dn32

cmd_sd_select card 0xFF
wait 1sec

cmd_sd_init card $card
tlmwait sd_card$card_state == SDCardState(GOOD)

cmd_sd_select card $card
