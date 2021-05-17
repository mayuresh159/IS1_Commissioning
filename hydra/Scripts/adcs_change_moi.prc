;
; NAME:
;   adcs_change_moi
;
; PURPOSE:
;   Change the moments of inertia in the adcs. On reboot of the adcs, the defaults will be read in again.
;   Thus, if a reboot occurs, this script must be run again.
;	There are 9 values in the MOI matrix, but only the 3 diagonal terms are significant.
;	Thus, we will ignore the off diagonals and only write to the diagonals. 
;
; INPUT: 
;	moi1, moi2, moi3 [float32]: Prompted values 
;	The air bearing defaults are 0.092, 0.10333, 0.03105. 
;	These are based on SolidWorks analysis that James did with the help of Steve Steg and BCT. 
;
; ISSUES:
;   The float32 type cuts off at 2 decimal places e.g., 0.092 gets cut off to 0.09. 
;
; MODIFICATION HISTORY
;   2015/03/03: James Paul Mason: Initial script
;	2015/07/31: James Paul Mason: From Matt Baumgart (BCT) - WordOffset for MOIs now starts at 45 instead of 35
;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdCntADCS dn16
declare cmdTryADCS dn16l
declare cmdSucceedADCS dn16l
declare seqCnt dn14
declare Ixx float32
declare Iyx float32
declare Izx float32
declare Ixy float32
declare Iyy float32
declare Izy float32
declare Ixz float32
declare Iyz float32
declare Izz float32
declare error float32
declare successCnt dn16l

set cmdSucceed = 0
set cmdSucceedADCS = 0
set cmdCnt = 0
set cmdTry = 0
set cmdCntADCS = 0
set cmdTryADCS = 0
set successCnt = 0

; Route housekeeping 3 sec to UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid 1 rate 3 stream 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500

; Route adcs cmd tlm 3 sec to UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid 200 rate 3 stream 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500

; Route image data
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid 216 rate 3 stream 1
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500

; Lengthen contact timeout
;I don't think IS-1 has this option
;set cmdCnt = MINXSSCmdAcceptCnt + 1
;while MINXSSCmdAcceptCnt < $cmdCnt
;	set cmdTry = cmdTry + 1
;	set_contact_tx_timeout Timeout 7200
;	wait 3529
;endwhile
;set cmdSucceed = cmdSucceed + 1

; Reset the contact timeout
;set cmdCnt = MINXSSCmdAcceptCnt + 1
;while MINXSSCmdAcceptCnt < $cmdCnt
;	set cmdTry = cmdTry + 1
;	reset_counters Group Contact
;	wait 3529
;endwhile
;set cmdSucceed = cmdSucceed + 1

IXX:
ask "What value for Ixx? " Ixx
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 0 WordLengthShouldBe1 1 rawFloat0 $Ixx
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

IYX:
ask "What value for Iyx? " Iyx
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 1 WordLengthShouldBe1 1 rawFloat0 $Iyx
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

IZX:
ask "What value for Izx? " Izx
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 2 WordLengthShouldBe1 1 rawFloat0 $Izx
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

IXY:
ask "What value for Ixy? " Ixy
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 3 WordLengthShouldBe1 1 rawFloat0 $Ixy
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

IYY:
ask "What value for Iyy? " Iyy
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 4 WordLengthShouldBe1 1 rawFloat0 $Iyy
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

IZY:
ask "What value for Izy? " Izy
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 5 WordLengthShouldBe1 1 rawFloat0 $Izy
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

IXZ:
ask "What value for Ixz? " Ixz
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 6 WordLengthShouldBe1 1 rawFloat0 $Ixz
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

IYZ:
ask "What value for Iyz? " Iyz
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 7 WordLengthShouldBe1 1 rawFloat0 $Iyz
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

IZZ:
ask "What value for Izz? " Izz
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 8 WordLengthShouldBe1 1 rawFloat0 $Izz
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

; Copy from holding table to general table
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_TableCommit TableNum 2 WordOffset 37 WordLength 9
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

echo ADCS MOI successfully changed
print cmdTry
print cmdSucceed
print cmdSucceedADCS
print cmdTryADCS