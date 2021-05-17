hydra_seq_output_enable
hydra_cmd_output_disable

;cmd_hw seqOutFile rollover
hydra_seq_close_file

cmd_noop
cmd_seq_suspend_rel time 2
cmd_seq_call buffId 1
cmd_seq_start buffId 1
cmd_noop

hydra_seq_set_id 42
hydra_seq_write_file

hydra_cmd_output_enable
hydra_seq_output_disable

wait 1000
hydra_seq_load_file buffId 0

wait 3000

hydra_seq_output_enable
hydra_cmd_output_disable

hydra_seq_close_file

cmd_noop
cmd_noop
cmd_noop
cmd_noop

hydra_seq_set_id 34
hydra_seq_write_file

hydra_cmd_output_enable
hydra_seq_output_disable

wait 1000

hydra_seq_load_file buffId 1

wait 3000

cmd_seq_init engineId 0 buffId 0