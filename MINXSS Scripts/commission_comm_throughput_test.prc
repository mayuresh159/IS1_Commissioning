;
; NAME:
;   commission_comm_throughput_test
;
; PURPOSE:
;   Send a bunch of route_log_pkt commands and count up how many actually got through (accepted or rejected). 
;   noop's in scripts don't seem to work. Not sure if issue_realtime_hk_packet would increment command counter.
;   Don't want to use route_hk_pkt since we may want to keep that at the 9 second beacon for this test. 
;
; ISSUES:
;   
;
; MODIFICATION HISTORY
;   2016/03/06: James Paul Mason: Initial script based on ground version: comm_throughput_test
;

; Declarations
declare cmdCnt dn16
declare failCnt dn16

print MINXSSCmdAcceptCnt
set cmdCnt = MINXSSCmdAcceptCnt
print MINXSSCmdRejectCnt
set failCnt = MINXSSCmdRejectCnt

echo In the ISIS command prompt, type note followed by the radio frequency
echo Then press GO button to send 10 commands
pause

loop 10
	route_log_pkt Route BOTH
	wait 1029
endloop

; Wait for most recent beacon (HK) packet to come down
wait 8000

print MINXSSCmdAcceptCnt
set cmdCnt = MINXSSCmdAcceptCnt - $cmdCnt
echo Number of successful commands (expected 10)
print cmdCnt

print MINXSSCmdRejectCnt
set failCnt = MINXSSCmdRejectCnt - $failCnt
echo Number of failed commands (hoped for 0)
print failCnt

echo Manually change ground radio frequency and run this script again