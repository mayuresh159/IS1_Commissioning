;
; NAME:
;   commission_fast_fine_point_with_extras
;
; PURPOSE:
;   Command into fine sun point and do basic check out of performance
;	Do this as fast as possible with minimal checks / dependence on beacons
;
; ISSUES:
;
;
; MODIFICATION HISTORY
;   2015/03/24: James Paul Mason: Initial script
;	2015/08/11: Tom Woods: updates for calling hello_minxss and having FINISH section
;	2016/05/24: Tom Woods:  modified version of commission_test_fine_point.prc
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare xactCmdCnt dn16

echo STARTING Commission_Fast_Fine_Point_with_extras script

; PRESS GO HERE ONCE YOU GET A BEACON
pause

LOAD:
;  set ephemeris - be SURE that this has been updated with correct ephemeris value
call commission_fast_ephemeris

POINT:
set xactCmdCnt = MINXSSXactCmdAccept + 1
while MINXSSXactCmdAccept < $xactCmdCnt
	set cmdTry = cmdTry + 1
	adcs_GotoFineSunPoint VelAber ENABLE SecRefDir 6:Pos PriCmdDir 1:[1,0,0] SecCmdDir 2:[0,1,0] YawAngle 0
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

X123:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	switch_power_x123 PowerDirection 0
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

ECHO:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	set_cmd_echo_packet_enable EnableFlag 0 
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

DONE:
echo COMPLETED Commission_Fast_Fine_Point_with_extra script

print cmdTry
print cmdSucceed