declare cmdCnt dn16l

;If state is already nominal, nothing to do 
if MINXSSCDHState_Tlm_All == CDHState(NOMINAL)
	return
endif

;If state is not RETRY, wait for it to be
if MINXSSCDHState_Tlm_All != CDHState(RETRY)
	tlmwait MINXSSCDHState_Tlm_All == CDHState(RETRY)
	tlmwait MINXSSCDHMode_Tlm_All == ModeStatus(SAFE)
endif

;In RETRY state, so cancel retry so we can move to NOMINAL state
if MINXSSCDHState_Tlm_All == CDHState(RETRY)

	tlmwait MINXSSCDHMode_Tlm_All == ModeStatus(SAFE)
	
	set cmdCnt = MINXSSCmdAcceptCnt + 1
	
	cancel_ant_deploy_retry
	
	tlmwait MINXSSCmdAcceptCnt >= $cmdCnt
	
	tlmwait MINXSSCDHState_Tlm_All == CDHState(NOMINAL)
endif

