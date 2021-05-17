; MINXSS change power level for commissioning script
; Purpose: Changes the comm amp level to 150
; Outline:
; 	Send amp level cammand every go
;
; Commands Sent:
; 	enable_dual_command
;	set_comm_amp_level
;
; Tlm Check:
;
; ISSUES:
;
; MODIFICATION HISTORY:
;	2018/12/03	Robert Henry Alexander Sewell	Wrote script
;

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare difftime dn32l

set cmdTry = 0
set cmdSucceed = 0

echo STARTING  commission_comm_amp_level  script
echo GO to set comm amp level to 150
pause

set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 2
	enable_dual_command
	wait 1529
	set_comm_amp_level AmpLevel 150
	wait 3529
	echo Press go to retry setting COMM AMP LEVEL to 150
	pause
endwhile
set cmdSucceed = cmdSucceed + 2

;
;Print critical elements to the screen (for the MinXSS FM-1 Pass sheet)
;
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	query_comm_status
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo C&DH Mode:
print MINXSSCDHMode_Tlm_All

echo XACT mode:
print MINXSSADCSMode_Tlm_All

echo Battery Voltage (V):
print MINXSSEpsFgBatteryV

echo Discharge Current (mA):
print MINXSSEpsBatteryDischarge

echo Charge Current (mA):
print MINXSSEpsBatteryCharge

echo 3.5V Current:
print MINXSSEps3VAmp
echo 5V current:
print MINXSSEps5VAmp

echo Battery Temperature:
print MINXSSEpsBatteryTemp1

echo X123 Det Temperature (K):
print MINXSSX123DetTemp
echo X123 Bd Temperature (C):
print MINXSSX123BrdTemp
echo Radio Temperature (C):
print MINXSSRadioTemp

echo SPS Angle X (not degrees):
print MINXSSSpsXPos
echo SPS Angle Y (not degrees):
print MINXSSSpsYPos
echo SPS Signal:
print MINXSSSpsSum

echo XP Signal:
print MINXSSXpsDataHK
echo Dark Diode signal:
print MINXSSDarkDataHK
echo X123 Slow Count:
print MINXSSX123SlowCountNorm
echo X123 Fast Count:
print MINXSSX123FastCountNorm

START_ROUTING:
;  Set HK Routing to faster 3 sec cadence (route to SD-Card and COMM realtime)
while MINXSSHkRouting != 3
	set cmdCnt = MINXSSCmdAcceptCnt + 1
	while MINXSSCmdAcceptCnt < $cmdCnt
		set cmdTry = cmdTry + 1
		route_hk_pkt Route 3
		wait 3529
	endwhile
	set cmdSucceed = cmdSucceed + 1
endwhile

FINISH:
echo COMPLETED  hello_minxss  script
call pass_report
print cmdTry
print cmdSucceed
echo ...