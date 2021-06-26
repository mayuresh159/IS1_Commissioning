; MINXSS "hello world" script
; Purpose: Checks that MinXSS is communicating
; Outline:
; 	Ask for a HK packet every 10 seconds
;
; Commands Sent:
; 	issue_realtime_hk_packet
;
; Tlm Check:
;
; ISSUES:
;	Fix how patch version is checked
;	Add telemetry points checked to this header
;
; MODIFICATION HISTORY:
;	2015/03/24: Tom Woods	Original script intended for Commissioning
;							It will loop for about 20 minutes sending issue_realtime_hk_packet every 5 seconds
;   2015/10/19: Colden Rouleau	Substituted GOTO for while loop, can now use this structure throughout the rest of the code.
;
;	2018/11/19: Bennet Schwab	Fixed cmdSucceed counter and added command retries when Routing HK
;								Added pass_report script to be called at end of hello_minxss
;								Fixed noop bug with wait10 between declare cmdTry and declare cmdSucceed
;

declare cmdCnt dn16l
declare cmdTry dn16l
;This wait was added because without it, HYDRA was sending a noop command. Not sure why...
wait 10
declare cmdSucceed dn16l
declare difftime dn32l

set cmdTry = 0
set cmdSucceed = 0

;DO NOT HAVE PAUSE in hello_minxss.prc !!!
;echo Press GO to start a sending issue_realtime_hk_packet every 3 seconds
;pause

echo STARTING  hello_minxss  script

set difftime = gpsTime - MINXSSTimeGS_Tlm_All
if difftime < 0
	difftime = difftime * (-1)
endif

if difftime < 20 
	goto START_ROUTING
endif

set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	issue_realtime_hk_packet
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

;
;Print critical elements to the screen (for the MinXSS FM-1 Pass sheet)
;

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