;
; NAME:
;   commission_x123_thresholds
;
; PURPOSE:
;   Step up the X123 slow and fast thresholds until the normalized slow and fast counts are below 10 counts/sec.
;	Note that we should be in eclipse for this so that the outside environment is dark.
;
; ISSUES:
;	
;
; MODIFICATION HISTORY
;   2015/03/25: James Paul Mason: Initial script
;	2015/08/11: Tom Woods: updates for calling hello_minxss and having FINISH section
;	2016/02/11: James Paul Mason: Changed fast and slow count verification point from 50 to 10 according to feedback from Amir

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare sciCnt dn16
declare thfa float32
declare thsl float32

echo Press GO when ready to start the Commission_X123_Thresholds script
pause

echo STARTING Commission_X123_Thresholds  script
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until MinXSS responds
;call Scripts/hello_minxss

START_ROUTING:

; Start hk packet routing
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_hk_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Start science packet routing
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_sci_pkt Route 3
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1


VERIFICATIONS:

; If we're in sunlight, suggest skipping this script
; This Eclipse name should really be called "Sunlight"
if MINXSSCDHEclipse_Tlm_All == 0 
	echo Housekeeping indicates we're currently in sunlight. Are you sure you want to run this script?
	pause
endif

; Verify that the battery voltage is > 7.5 V
verify MINXSSEpsFgBatteryV >= 7.5

QUERY_X123:
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	query_x123_status Query "THFA; THSL;"
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
echo Record the initial FAST and SLOW Threshold values. RE-RUN if values are not printed to the screen!
pause

FAST_COUNTS:
; SET THE STARTING VALUE BEFORE RUNNING THE SCRIPT ****
; Ground Testing THFA=18.0 is good, but after getting hot, THFA=22.0 is better
; FM-2 X123 Fast, had THFA = 12.00 and THSL - 1.904 were optimal
set thfa = 12.0

set sciCnt = MINXSSSeqCnt_Sci_All + 2
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THFA= $thfa ;"
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
;  wait for 2 SCI packets to come in
tlmwait MINXSSSeqCnt_Sci_All >= $sciCnt

while MINXSSX123FastCountNorm >= 10
	set thfa = thfa + 0.5

	set sciCnt = MINXSSSeqCnt_Sci_All + 2
	set cmdCnt = MINXSSCmdAcceptCnt + 1
	; repeat until command is accepted
	while MINXSSCmdAcceptCnt < $cmdCnt
		set cmdTry = cmdTry + 1
		send_x123_cmd Cmd "THFA= $thfa ;"
		wait 3529
	endwhile
	set cmdSucceed = cmdSucceed + 1
	
	;  wait for 2 SCI packets to come in
	tlmwait MINXSSSeqCnt_Sci_All >= $sciCnt
endwhile

query_x123_status Query "THFA;"
echo Record the new FAST Threshold value.
pause 

SLOW_COUNTS:
; SET THE STARTING VALUE BEFORE RUNNING THE SCRIPT ****
; Ground Testing THSL=1.293 is good, but after getting hot, THSL=1.25 is better
; FM2 was optimized at THSL=1.904
set thsl = 1.4

set sciCnt = MINXSSSeqCnt_Sci_All + 2
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	send_x123_cmd Cmd "THSL= $thsl ;"
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
;  wait for 2 SCI packets to come in
tlmwait MINXSSSeqCnt_Sci_All >= $sciCnt

while MINXSSX123SlowCountNorm >= 10
	set thsl = thsl + 0.1

	set sciCnt = MINXSSSeqCnt_Sci_All + 2
	set cmdCnt = MINXSSCmdAcceptCnt + 1
	; repeat until command is accepted
	while MINXSSCmdAcceptCnt < $cmdCnt
		set cmdTry = cmdTry + 1
		send_x123_cmd Cmd "THSL= $thsl ;"
		wait 3529
	endwhile
	set cmdSucceed = cmdSucceed + 1

;	tlmwait MINXSSCmdAcceptCnt >= $cmdCnt
	
	;  wait for 2 SCI packets to come in
	tlmwait MINXSSSeqCnt_Sci_All >= $sciCnt
endwhile

query_x123_status Query "THSL;"
echo Record the new SLOW Threshold value.
pause 

echo Enter GO to disable routing if desired. Else it will be automatically disabled by FSW when contact timer expires.
pause

FINISH:
; Stop Sci packet routing to RF
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_sci_pkt Route 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; Stop adcs packet routing to RF
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_adcs_pkt Route 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

; hk packet routing to beacon
set cmdCnt = MINXSSCmdAcceptCnt + 1
while MINXSSCmdAcceptCnt < $cmdCnt
	set cmdTry = cmdTry + 1
	route_hk_pkt Route 5
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1

echo COMPLETED Commission_X123_Thresholds script

print cmdTry
print cmdSucceed