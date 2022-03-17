;DAXSS DISABLE Watchdog Time No Rx
;Purpose: 1) Route the DAXSS table parameter packet
;		  2) Request the table pre-change
;         2) Loop to disable watchdog timer so we don't reset during
;		  during periods withoput commanding
;Outline
;    Send command to set watchdog timer to 0 (disable)
;	 Verify command success
;
; 03-17-2022: Robert Sewell		Created for IS-1 commissioning

declare cmdLoopCnt dn16l
declare cmdLoopMax dn16l
declare waitInterval dn32l
declare cmdDAXSSCnt uint8l
declare cmdDAXSSCntInit uint8l
declare cmdIS1Cnt uint8l
declare cmdIS1CntInit uint8l
declare paramCnt dn16

set waitInterval = 5000
;Send each command 8 times
set cmdLoopCnt = 0
set cmdLoopMax = 8

echo ______________________________________________________
echo STARTING daxss_table_update_watchdog_disable_no_rx
echo This will route the DAXSS Table Paramters and DISABLE
echo the DAXSS CLLT.
echo Requires X123 to be ON before sending this command.
echo Please record the IS-1 and DAXSS Command Success Cnts
echo in the beacon packet before running this script, if 
echo possible and if a beacon has been recieved before 
echo commanding.
echo ______________________________________________________

ROUTE_TABLE:
set cmdIS1Cnt = beacon_cmd_succ_count
set cmdIS1CntInit = beacon_cmd_succ_count
echo Current IS-1 command accepted counter: $cmdIS1Cnt
echo Press GO to ROUTE the DAXSS Table Paramter Packet
echo every 30 seconds
pause

set cmdLoopCnt = 0
while cmdLoopCnt < cmdLoopMax
	cmd_set_pkt_rate apid 177 rate 30 stream UHF
	set cmdLoopCnt = cmdLoopCnt + 1
	wait $waitInterval
endwhile

echo ______________________________________________________
echo Sent the Param ROUTE command $cmdLoopCnt times.
echo If possible, switch back to Rx mode then press GO
echo to verify IS-1 command success. If not possible, then 
echo GOTO DISABLE_WD.
echo ______________________________________________________
pause

set cmdIS1Cnt = beacon_cmd_succ_count
echo Previous IS-1 command accept count: $cmdIS1CntInit
echo Current IS-1 command accept count: $cmdIS1Cnt

echo ______________________________________________________
echo If IS-1 command count incremented then switch to Tx 
echo mode and press GO to disable WD timer.
echo If IS-1 command count did not increment then switch to 
echo TX mode and GOTO ROUTE_TABLE above.
echo ______________________________________________________
pause

DISABLE_WD:
set cmdDAXSSCnt = beacon_daxss_cmd_succ
set cmdDAXSSCntInit = beacon_daxss_cmd_succ
echo Current DAXSS command accepted counter: $cmdDAXSSCnt
echo Press GO to disable the watchdog timer
pause
set cmdLoopCnt = 0
while cmdLoopCnt < cmdLoopMax
    cmd_daxss_set_last_cmd_timeout timeout 0
    set cmdLoopCnt = cmdLoopCnt + 1
    wait $waitInterval
endwhile

echo ______________________________________________________
echo Sent the Watchdog disable command $cmdLoopCnt times.
echo If possible, switch back to Rx mode then press GO
echo to verify DAXSS command success. If not possible, then
echo GOTO DUMP_TABLE below.
echo ______________________________________________________
pause

set cmdDAXSSCnt = beacon_daxss_cmd_succ
echo Previous DAXSS command accepted count: $cmdDAXSSCntInit
echo Current DAXSS command accepted count: $cmdDAXSSCnt

echo ______________________________________________________
echo If DAXSS command count incremented then switch to Tx 
echo mode and press GO to disable DUMP the DAXSS table.
echo If DAXSS command count did not increment then switch to 
echo TX mode and GOTO DISABLE_WD above.
echo ______________________________________________________
pause

DUMP_TABLE:
set cmdDAXSSCnt = beacon_daxss_cmd_succ
set cmdDAXSSCntInit = beacon_daxss_cmd_succ
echo Current DAXSS command accepted counter: $cmdDAXSSCnt
set cmdLoopCnt = 0
while cmdLoopCnt < cmdLoopMax
	cmd_daxss_dump_param set 0
	wait $waitInterval
	set cmdLoopCnt = cmdLoopCnt + 1
endwhile

echo ______________________________________________________
echo Sent the Table Dump command $cmdLoopCnt times.
echo If possible, switch back to Rx mode then press GO
echo to verify DAXSS command success. If not possible, then
echo GOTO DUMP_TABLE below.
echo ______________________________________________________
pause

set cmdDAXSSCnt = beacon_daxss_cmd_succ
echo Previous DAXSS command accepted count: $cmdDAXSSCntInit
echo Current DAXSS command accepted count: $cmdDAXSSCnt

echo ______________________________________________________
echo If DAXSS command count incremented then press GO to 
echo verify Table Paramater change.
echo If DAXSS command count did not increment then switch to 
echo TX mode and GOTO DUMP_TABLE above.
echo ______________________________________________________
pause

set paramCnt = ccsdsTlmHeader_count_daxss_mem 
while ccsdsTlmHeader_count_daxss_mem <= paramCnt
	echo Waiting for updated DAXSS param packet...
	wait 20000
endwhile

echo ______________________________________________________
echo Recieved updated DAXSS Param Packet!
echo Verify timer is now set to 0 (DISABLE)
echo i.e. verify daxss_param_cmd_wdog_time == 0
echo If verify does not pass switch to Tx mode and 
echo GOTO DISABLE_WD if time is left in the pass
echo ______________________________________________________ 

verify daxss_param_cmd_wdog_time == 0

echo ______________________________________________________
echo If verify passed press GO to finish 
echo If verify did not pass switch to Tx mode and 
echo GOTO DISABLE_WD if time is left in the pass
echo ______________________________________________________ 
pause 

FINISH:
echo ____________________________________________________ 
echo Please note the final DAXSS Command Success Cnt in 
echo the beacon packet
echo ____________________________________________________   
pause