;
; NAME:
;   adcs_change_css_threshold
;
; PURPOSE:
;   Change the coarse sun sensor thresholds in the adcs. On reboot of the adcs, the defaults will be read in again.
;   Thus, if a reboot occurs, this script must be run again.
;
; INPUT: 
;	threshold [dn16]: This unsigned integer is the thredhold to use for all 4 diodes. 
;					  At this time, no advantage to having separate values can be seen. 
;					  The default value for the air bearing tests is 600. 
;
; ISSUES:
;   
; MODIFICATION HISTORY
;   2015/03/03: James Paul Mason: Initial script
;	2015/07/31: James Paul Mason: From Matt Baumgart (BCT) - WordOffset for CSS is now 16 instead of 8
;

; Below is the basic process for changing values in the ADCS tables
; 1. write to holding table
;   	adcs_HoldingTableInsert1FLOAT32 WordOffset ## WordLengthShouldBe1 1 rawFloat0 ##
; 2. copy holding table to target table
;		adcs_TableCommit TableNum # WordOffset ## WordLength #
; 3. read from target table to verify
;    	adcs_TableExtract TableNum # WordOffset ## WordLength #
;		read_xact_image Offset 0 Number 1

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdCntADCS dn16
declare cmdTryADCS dn16l
declare cmdSucceedADCS dn16l
declare seqCnt dn14
declare threshold float32
declare error float32
declare successCnt dn16l

set cmdSucceed = 0
set cmdSucceedADCS = 0
set cmdCnt = 0
set cmdTry = 0
set cmdCntADCS = 0
set cmdTryADCS = 0
set successCnt = 0

; Hard code changes to the threshold here
ask "What value for CSS thresholds? Default for air bearing is 600." threshold

; Route housekeeping 3 sec to UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid 1 rate 3 stream 0
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500

; Route adcs cmd tlm 3 sec to UHF
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid 200 rate 3 stream 0
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500

; Route image data
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	set cmdTry = cmdTry + 1
	cmd_set_pkt_rate apid 216 rate 3 stream 0
	wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
wait 3500


FIRST_THRESHOLD:
; First CSS threshold write to holding table
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 0 WordLengthShouldBe1 1 rawFloat0 $threshold
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

SECOND_THRESHOLD:
; Second CSS threshold write to holding table
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 1 WordLengthShouldBe1 1 rawFloat0 $threshold
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

THIRD_THRESHOLD:
; Third CSS threshold write to holding table
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 2 WordLengthShouldBe1 1 rawFloat0 $threshold
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

FOURTH_THRESHOLD:
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 3 WordLengthShouldBe1 1 rawFloat0 $threshold
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

FIFTH_THRESHOLD:
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 4 WordLengthShouldBe1 1 rawFloat0 $threshold
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

SIXTH_THRESHOLD:
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 5 WordLengthShouldBe1 1 rawFloat0 $threshold
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

SEVENTH_THRESHOLD:
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 6 WordLengthShouldBe1 1 rawFloat0 $threshold
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

EIGHTH_THRESHOLD:
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_HoldingTableInsert1FLOAT32 WordOffset 7 WordLengthShouldBe1 1 rawFloat0 $threshold
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

; Copy from holding table to general table 11
set cmdCntADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdCntADCS
	set cmdTryADCS = cmdTryADCS + 1
	cmd_adcs_Tables_TableCommit TableNum 11 WordOffset 32 WordLength 8
	wait 3529
endwhile
set cmdSucceedADCS = cmdSucceedADCS + 1

; Read back table 11 into video line buffer
;set cmdCntADCS = beacon_adcs_cmd_acpt + 1
;while beacon_adcs_cmd_acpt < $cmdCntADCS
;	set cmdTryADCS = cmdTryADCS + 1
;	cmd_adcs_Tables_TableExtract TableNum 11 WordOffset 16 WordLength 8
;	wait 3529
;endwhile
;set cmdSucceedADCS = cmdSucceedADCS + 1

; User verify that the values copied to table 11
;set seqCnt = MINXSSSeqCnt_Image + 1
;while MINXSSSeqCnt_Image < $seqCnt
;	set cmdTry = cmdTry + 1
;	read_xact_image Offset 0 Number 1
;	wait 3529
;endwhile

; Verify that the thresholds were stored
;if MINXSSADCS_Image_Data_Float[0] == [$threshold]
;	echo threshold 1 successfully loaded
;	set successCnt = 1
;else 
;	echo threshold 1 not successfully loaded
;	pause
;endif
;if MINXSSADCS_Image_Data_Float[1] == [$threshold]
;	echo threshold 2 successfully loaded
;	set successCnt = 2
;else 
;	echo threshold 2 not successfully loaded
;	pause
;endif
;if MINXSSADCS_Image_Data_Float[2] == [$threshold]
;	echo threshold 3 successfully loaded
;	set successCnt = 3
;else 
;	echo threshold 3 not successfully loaded
;	pause
;endif
;if MINXSSADCS_Image_Data_Float[3] == [$threshold]
;	echo threshold 4 successfully loaded
;	set successCnt = 4
;else 
;	echo threshold 4 not successfully loaded
;	pause
;endif

echo ADCS CSS thresholds successfully changed
print cmdTry
print cmdSucceed
print cmdSucceedADCS
print cmdTryADCS