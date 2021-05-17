
; Bad watchpoints
cmd_fp_set_watch_values id 0xFFFF msgId FP mask 0xFFFFFFFF threshold 1 offset 0 size 4 state DISABLED op EQ response 2 persistence 3
wait 2sec

cmd_fp_set_watch_values id 0 msgId 0xFFFF mask 0xFFFFFFFF threshold 1 offset 0 size 4 state DISABLED op EQ response 2 persistence 3
wait 2sec

cmd_fp_set_watch_values id 0 msgId FP  mask 0xFFFFFFFF threshold 1 offset 0 size 8 state DISABLED op EQ response 2 persistence 3
wait 2sec

cmd_fp_set_watch_values id 0 msgId FP  mask 0xFFFFFFFF threshold 1 offset 0 size 4 state DISABLED op 0xFF response 2 persistence 3
wait 2sec

cmd_fp_set_watch_values id 0 msgId FP  mask 0xFFFFFFFF threshold 1 offset 0 size 4 state 0xFF op EQ response 2 persistence 3
wait 2sec

; Set some watchpoints

cmd_fp_set_watch_values id 0 msgId FP mask 0xFFFFFFFF threshold 1 offset 0 size 4 state DISABLED op EQ response 2 persistence 3