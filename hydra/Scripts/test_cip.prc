;Few commands are mixed up in Hydra
;RPA is RPAS
;RPT is RPA
;PRT is PRI
;PRI is PRIS

cmd_set_pkt_rate apid CIP_HK rate 1 stream DBG
wait 2sec

cmd_set_pkt_rate apid CIP_SOH rate 1 stream DBG
wait 2sec

cmd_set_pkt_rate apid CIP_SCI_1 rate 1 priority HIGH stream DBG
wait 2sec

cmd_set_pkt_rate apid CIP_SCI_2 rate 1 priority HIGH stream DBG
wait 2sec

cmd_eps_pwr_on component CIP override 0
wait 15sec

cmd_cip_pass opcode CIP_OPCODE_NORMAL
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_SAFE
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_FAST
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_SAFE
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_PLP
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_NORMAL
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_SAFE
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_RPA
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_NORMAL
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_SAFE
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_RPAS
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_NORMAL
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_SAFE
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_IDM
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_NORMAL
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_SAFE
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_IT
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_NORMAL
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_SAFE
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_PRI
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_NORMAL
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_SAFE
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_PRIS
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_NORMAL
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_SAFE
wait 10sec

cmd_cip_pass opcode CIP_OPCODE_FAST
wait 10000sec
