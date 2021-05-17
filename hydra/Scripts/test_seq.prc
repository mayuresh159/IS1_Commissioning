cmd_seq_output_enable
cmd_cmd_output_disable

cmd_hw seqOutFile rollover

cmd_noop
cmd_seq_suspend_rel time 2
cmd_seq_call buffId 1
cmd_seq_start buffId 1
cmd_noop

set seqContainer_id = 42
seqContainer

cmd_cmd_output_enable
cmd_seq_output_disable

wait 1000
start_sender seqSender buffId 0 length 128 offset 0 filename seqOutFile

wait 3000

cmd_seq_output_enable
cmd_cmd_output_disable

cmd_hw seqOutFile rollover

cmd_noop
cmd_noop
cmd_noop
cmd_noop

set seqContainer_id = 34
seqContainer

cmd_cmd_output_enable
cmd_seq_output_disable

wait 1000

start_sender seqSender buffId 1 length 128 offset 0 filename seqOutFile

wait 3000

cmd_seq_init engineId 0 buffId 0