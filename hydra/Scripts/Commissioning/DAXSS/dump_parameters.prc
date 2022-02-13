; get PARAM=0 block packet
declare cmdCntDaxss dn16
declare cmdCnt dn16
declare paramCnt dn16
declare cmdSucceed dn16l
declare cmdTry dn16l
declare cmdSucceedDaxss dn16l
declare cmdTryDaxss dn16l

set paramCnt = ccsdsTlmHeader_count_daxss_mem + 1 
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 3 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

while ccsdsTlmHeader_count_daxss_mem < paramCnt
	set cmdCntDaxss = daxss_sci_cmd_acpt_count + 1
	while daxss_sci_cmd_acpt_count < $cmdCntDaxss
		set cmdTryDaxss = cmdTryDaxss + 1
		cmd_daxss_dump_param set 0
		wait 5029
	endwhile
	set cmdSucceedDaxss = cmdSucceedDaxss + 1
endwhile

while beacon_cmd_succ_count < $cmdCnt
	cmd_set_pkt_rate apid 177 rate 0 stream UHF
	set cmdTry = cmdTry + 1
	wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1 

