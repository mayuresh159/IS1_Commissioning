;
; NAME:
;   adcs_cruciform_scan
;
; PURPOSE:
;   Do Cruciform Scan using BCT XACT
;
;  COMMAND:
;	adcs_GotoTarget
;
; ISSUES:
;   This will offset XACT on the Sun
;
; MODIFICATION HISTORY
;   2016/04/25: Tom Woods: Initial script
;	2023/01/13: Robert Sewell: Modified for IS-1
;

declare cmdCntInit dn16l
declare cmdCntFinal dn16l
declare cmdTry dn16l
declare cmdSuccess dn16l
declare cmdInc dn16l
declare cmdRepeat dn16l
declare xactCmdCnt dn16l
declare xOffset float32
declare xOffsetStep float32
declare xOffsetStart float32
declare xOffsetEnd float32
declare yOffset float32
declare yOffsetStep float32
declare yOffsetStart float32
declare yOffsetEnd float32
declare timeOffset float32
declare timeOffsetWait dn16l
declare timeTotal float32
declare loopCount dn16l
declare midstep float32

set cmdTry = 0
set cmdRepeat = 3

echo STARTING  adcs_cruciform_scan  script

;  define X scan parameters that will be centered on average of yOffsetStart & yOffsetEnd
;  xOffsetStep needs to have non-zero value to do a X scan
set xOffsetStart = 0.0
set xOffsetEnd = 0.0
set xOffsetStep = 0.0

;  define Y scan parameters that will be centered on average of xOffsetStart & xOffsetEnd
;  yOffsetStep needs to have non-zero value to do a Y scan
set yOffsetStart = 0.0
set yOffsetEnd = -3.0
set yOffsetStep = 0.75

;  define time to wait in seconds between offset points
;  XACT simulations suggest 30-sec per degree of movement to stabilize
set timeOffset = 60.0
set timeOffsetWait = timeOffset * 1000

set timeTotal = 0.0
if xOffsetStep != 0.0
  set xOffset = xOffsetEnd - xOffsetStart
  set xOffset =  timeOffset * xOffset 
  set xOffset = xOffset / xOffsetStep
  set timeTotal = timeTotal + xOffset
endif
if yOffsetStep != 0.0
  set yOffset = yOffsetEnd - yOffsetStart
  set yOffset = timeOffset * xOffset 
  set yOffset = yOffset / yOffsetStep
  set timeTotal = timeTotal + yOffset
endif
; convert to minutes
set timeTotal = timeTotal / 60.

echo Total Time needed for the cruciform scans is $timeTotal minutes
echo Press GO after you verify we have recieved a BEACON packet 
echo and have verified this scripts Offset parameters
echo *****
echo NOTE that one should GOTO FINISH when less than 3 minutes from the pass end time
echo *****
pause

echo *****
echo Record the SCI-D, BEACON and ADCS pointers before continuing 
echo *****
pause

;
;	Start routing necissary ADCS packets to SD card for playback later
;
;*****ADCS Packet Route to SD Card*****
set cmdInc = 0
while cmdInc < 8
	set cmdInc = cmdInc + 1
	cmd_set_pkt_rate apid ADCS_CSS rate 3 stream SD
	set cmdTry = cmdTry + 1 
	wait 3529
endwhile

VERIFICATIONS:
; If we're in eclipse, suggest skipping this script
if beacon_eclipse_state == 1
	echo Housekeeping indicates we're currently in eclipse. Are you sure you want to run this script?
	echo (Nominally we won't run this if in eclipse)
	pause
endif

; Verify that we are in sun-point mode, on-sun, and taking DAXSS data
verify beacon_adcs_sun_pt_state == 6 ;ON_SUN
verify beacon_adcs_mode == 1 ;FINE
verify beacon_mode == 2 ;SCID
set cmdCntInit = beacon_cmd_succ_count

X_SCAN_START:
;
;	Do X scan if xOffsetStep is non-zero
;
if xOffsetStep != 0.0
  set midstep = xOffsetEnd - xOffsetStart
  set midstep = midstep / xOffsetStep
  if midstep < 0
  	set loopCount = -1 * midstep + 1
  	set xOffsetStep = -1 * xOffsetStep
  else
	set loopCount = midstep + 1
  endif
  set xOffset = xOffsetStart - xOffsetStep
  set yOffset = yOffsetStart + yOffsetEnd
  set yOffset = yOffset / 2.
  print loopCount
  loop $loopCount
    ; increment X offset
    set xOffset = xOffset + xOffsetStep
    echo MOVING for X Offset
	print xOffset

	;
	;	Send the ADCS command to move to offset point
	;	GotoTarget command (APID=6, Opcode=3) with the following parameters:
	;		VelAber = 1    // enable
	;		PriRefDir = 6  // 6=Sun; want +X direction to Sun
	;		SecRefDir = 2  // 2=Pos; want Star Tracker towards Zenith
	;		TargX = 0
	;		TargY = 0
	;		TargZ = 0
	;		Angle = 0
	;		PriCmdDir = 1   // +X
	;		SecCmdDir = 2   //  +Y
	;		AttInterp = 0
	;		qTARGETwrtREF1 = SCAN_OFFSET_Y    // Roll Angle (deg) if AttInterp = 0
	;		qTARGETwrtREF2 = -SCAN_OFFSET_X   // Pitch Angle (deg) if AttInterp = 0
	;		qTARGETwrtREF3 = 0                // Yaw Angle (deg) if AttInterp = 0
	;		qTARGETwrtREF4 = 0                // 0 if AttInterp = 0
	;		RateInterp = 1
	;		CmdRateX = 0    // slew rate X (deg/sec)
	;		CmdRateY = 0    // slew rate Y
	;		CmdRateZ = 0    // slew rate Z
	;		Time = 0        // TAI time for CmdRate not equal to zero
	;		EndCycle = 0    // ADCS time cycle for CmdRate and Time
	;
	set cmdInc = 0
	while cmdInc < $cmdRepeat
		set cmdInc = cmdInc + 1
		cmd_adcs_AttCmd_GotoTarget VelAber 1 PriRefDir 6 SecRefDir 2 TargX 0 TargY 0 TargZ 0 spare 0 PriCmdDir 1 SecCmdDir 2 AttInterp 0 qTARGETwrtREF1 $yOffset qTARGETwrtREF2 $xOffset qTARGETwrtREF3 0 qTARGETwrtREF4 0 RateInterp 1 CmdRate_X 0 CmdRate_Y 0 CmdRate_Z 0 Time 0 EndCycle 0
		set cmdTry = cmdTry + 1 
		wait 3529
	endwhile

	wait $timeOffsetWait

  endloop
  echo COMPLETED  X Scan
endif

Y_SCAN_START:
;
;	Do Y scan if xOffsetStep is non-zero
;
if yOffsetStep != 0.0
  set midstep = yOffsetEnd - yOffsetStart
  set midstep = midstep / yOffsetStep
  if midstep < 0
  	set loopCount = -1 * midstep + 1
  	set yOffsetStep = -1 * yOffsetStep
  else
	set loopCount = midstep + 1
  endif
  set yOffset = yOffsetStart - yOffsetStep
  set midstep = xOffsetStart + xOffsetEnd
  set xOffset = midstep / 2
  
  loop $loopCount
    ; increment Y offset
    set yOffset = yOffset + yOffsetStep
    echo MOVING for Y Offset
	print yOffset

	;
	;	Send the ADCS command to move to offset point
	;
	set cmdInc = 0
	while cmdInc < $cmdRepeat
		set cmdInc = cmdInc + 1
		cmd_adcs_AttCmd_GotoTarget VelAber 1 PriRefDir 6 SecRefDir 2 TargX 0 TargY 0 TargZ 0 spare 0 PriCmdDir 1 SecCmdDir 2 AttInterp 0 qTARGETwrtREF1 $yOffset qTARGETwrtREF2 $xOffset qTARGETwrtREF3 0 qTARGETwrtREF4 0 RateInterp 1 CmdRate_X 0 CmdRate_Y 0 CmdRate_Z 0 Time 0 EndCycle 0
		set cmdTry = cmdTry + 1 
		wait 3529
	endwhile


	;  wait to settle in for new offset point and take data
	; TODO: Really we want to wait a duration of timeOffset, but wait cannot accept floats, only integers
	wait $timeOffsetWait

  endloop
  echo COMPLETED  Y Scan
endif

FINISH:
;
;	switch back to normal solar fine mode at the end
;
set cmdInc = 0
while cmdInc < 8
	set cmdInc = cmdInc + 1
	cmd_adcs_fine_point
	set cmdTry = cmdTry + 1 
	wait 3529
endwhile

set cmdInc = 0
while cmdInc < 8
	set cmdInc = cmdInc + 1
	cmd_set_pkt_rate apid ADCS_CSS rate 0 stream SD
	set cmdTry = cmdTry + 1 
	wait 3529
endwhile

echo Switch back to Rx Mode and GO once you recieve a beacon_adcs_mode
pause
; Verify that we are in sun-point mode, on-sun, and taking DAXSS data
verify beacon_adcs_sun_pt_state == 6 ;ON_SUN
verify beacon_adcs_mode == 1 ;FINE
verify beacon_mode == 2 ;SCID
set cmdCntFinal = beacon_cmd_succ_count

set cmdSuccess = cmdCntFinal - cmdCntInit
echo COMPLETED  adcs_cruciform_scan  script
echo Number of command tries:
print cmdTry
echo Number of command successes:
print cmdSuccess

