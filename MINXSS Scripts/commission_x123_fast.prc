;
; NAME:
;   commission_x123_fast
;
; PURPOSE:
;   Test the X123 fast threshold
;	Note that we should be in eclipse for this so that the outside environment is dark.
;
; OUTLINE
;	Turn on SCI routing
;	Set Beacon Rate to 21 sec
;	Wait for 2 minutes
;	Change Fast Threshold
;	Wait for 2 minutes
;
; ISSUES:
;	
;
; MODIFICATION HISTORY
;   2016/06/07: Tom Woods: Initial script
;	2016/06/08: Tom Woods: Updated with more FAST and SLOW Threshold options
;
declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare sciCnt dn16
declare thfa float32
declare thsl float32

echo STARTING Commission_X123_Fast  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

echo GoTo Options in this script are BEACON, QUERY, FAST16, FAST17, FAST18, FAST19, FAST20
echo             and SLOW18, SLOW19, SLOW20, SLOW21
pause

START:
; wait until MinXSS responds
call Scripts/hello_minxss_noprints

VERIFICATIONS:
; If we're in sunlight, suggest skipping this script
; This Eclipse name should really be called "Sunlight"
if MINXSSCDHEclipse_Tlm_All == 0 
	echo Housekeeping indicates we're currently in sunlight. Are you sure you want to run this script?
	pause
endif

BEACON:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	set_beacon_tlm_rate Rate 21
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set Beacon Rate succeeded.  Pausing for next GoTo Option.
pause

QUERY:
;  wait 2 minutes
set cmdCnt = cmdTry + 24
loop 24
	set cmdTry = cmdTry + 1
	query_x123_status Query "THFA; THSL;"
	wait 5000
endloop
set cmdSucceed = cmdSucceed + 1
echo Query X123 succeeded.  Pausing for next GoTo Option.
pause

FAST16:
; SET THE NEW THFA VALUE
; Ground Testing THFA=18.0 is good, but after getting hot, THFA=22.0 is better
; FM-2 X123 Fast, had THFA = 12.00 and THSL - 1.904 were optimal
set thfa = 16.0
set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THFA= $thfa ;"
	wait 2100
	issue_realtime_hk_packet
	wait 1300
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set THFA=16 succeeded.  Pausing for next GoTo Option.
pause

FAST17:
; SET THE NEW THFA VALUE
; Ground Testing THFA=18.0 is good, but after getting hot, THFA=22.0 is better
; FM-2 X123 Fast, had THFA = 12.00 and THSL - 1.904 were optimal
set thfa = 17.0
set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THFA= $thfa ;"
	wait 2100
	issue_realtime_hk_packet
	wait 1300
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set THFA=17 succeeded.  Pausing for next GoTo Option.
pause

FAST18:
; SET THE NEW THFA VALUE
; Ground Testing THFA=18.0 is good, but after getting hot, THFA=22.0 is better
; FM-2 X123 Fast, had THFA = 12.00 and THSL - 1.904 were optimal
set thfa = 18.0
set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THFA= $thfa ;"
	wait 2100
	issue_realtime_hk_packet
	wait 1300
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set THFA=18 succeeded.  Pausing for next GoTo Option.
pause

FAST19:
; SET THE NEW THFA VALUE
; Ground Testing THFA=18.0 is good, but after getting hot, THFA=22.0 is better
; FM-2 X123 Fast, had THFA = 12.00 and THSL - 1.904 were optimal
set thfa = 19.0
set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THFA= $thfa ;"
	wait 2100
	issue_realtime_hk_packet
	wait 1300
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set THFA=19 succeeded.  Pausing for next GoTo Option.
pause

FAST20:
; SET THE NEW THFA VALUE
; Ground Testing THFA=18.0 is good, but after getting hot, THFA=22.0 is better
; FM-2 X123 Fast, had THFA = 12.00 and THSL - 1.904 were optimal
set thfa = 20.0
set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THFA= $thfa ;"
	wait 2100
	issue_realtime_hk_packet
	wait 1300
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set THFA=20 succeeded.  Pausing for next GoTo Option.
pause

SLOW18:
; SET THE NEW THSL VALUE, THSL = 1.904 is optimal
set thsl = 1.80
set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THSL= $thsl ;"
	wait 2100
	issue_realtime_hk_packet
	wait 1300
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set THSL=1.80 succeeded.  Pausing for next GoTo Option.
pause

SLOW19:
; SET THE NEW THSL VALUE, THSL = 1.904 is optimal
set thsl = 1.90
set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THSL= $thsl ;"
	wait 2100
	issue_realtime_hk_packet
	wait 1300
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set THSL=1.90 succeeded.  Pausing for next GoTo Option.
pause

SLOW20:
; SET THE NEW THSL VALUE, THSL = 1.904 is optimal
set thsl = 2.00
set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THSL= $thsl ;"
	wait 2100
	issue_realtime_hk_packet
	wait 1300
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set THSL=2.00 succeeded.  Pausing for next GoTo Option.
pause

SLOW21:
; SET THE NEW THSL VALUE, THSL = 1.904 is optimal
set thsl = 2.10
set cmdCnt = MINXSSCmdAcceptCnt + 2
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THSL= $thsl ;"
	wait 2100
	issue_realtime_hk_packet
	wait 1300
endwhile
set cmdSucceed = cmdSucceed + 1
echo Set THSL=2.10 succeeded.  Pausing for next GoTo Option.
pause

echo COMPLETED Commission_X123_Fast script

print cmdTry
print cmdSucceed