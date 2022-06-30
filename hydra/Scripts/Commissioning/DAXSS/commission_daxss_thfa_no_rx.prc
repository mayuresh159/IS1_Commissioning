;Commission DAXSS No Rx
;Purpose: Loop to change X123 fast threshold
;          and playback last 3 minutes with changes
;		  commanding done with no Rx (due to command difficulties)
;	
;Outline
;	 Send command to change THFA
;	 Wait 3 minutes to collect data in new config
;	 Playback last 4 minutes of data
;
; 06-30-2022: Robert Sewell		Created for IS-1 commissioning

declare cmdLoopCnt dn16l
declare cmdLoopMax dn16l
declare setTHFA float32
declare waitInterval dn32l
declare secStart dn32l
declare secNow dn32l
declare secDiff dn32l
declare playbackOffset dn32l
declare cmdCnt dn32l
declare cmdTry dn32l
declare counter dn32l

set secDiff = 0
set counter = 0
set secStart = beacon_daxss_time_sec
set waitInterval = 3500

while secDiff == 0
    set secNow = beacon_daxss_time_sec
    echo DAXSS Beacon time: $secNow
    set secDiff = $secNow - $secStart
    wait $waitInterval
endwhile
echo Ensure we have recieved a beacon in HYDRA before starting the pass
pause

;Initially set THSL to 1.5% (THSL=1.5) per email with Woods and Caspi on 03-03-2022
;Never changed the THFA
;Analysis by Woods on 27-06-2022 showed THFA needed increasing
;On 6/29 THSL was increased to to 2.5% (THSL=2.5) 
;This script is used to set the THFA to 12.8 (~2.5%)
;Typically we loop over THSL values until slow_count<10 in dark
;But we can't currently do this without ADCS being able to off point
;and with current IIST mode of uplink only 
;Ground default value for DAXSS (FM4) is THSL=0.622 THFA=8.0

set setTHFA = 12.8
set waitInterval = 10000
set cmdLoopCnt = 0
set cmdLoopMax = 8
set playbackOffset = beacon_sd_write_scid

echo ____________________________________________________________
echo STARTING commission_daxss_thfa_no_rx
echo This will change DAXSS X123 fast threshold to THFA=$setTHFA
echo Requires X123 to be ON before sending this command
echo Please record the IS-1 SCI-D write pointer before 
echo running this script
echo ____________________________________________________________

SET_THFA:
set cmdLoopCnt = 0
echo Press GO to change the fast threshold
pause
while cmdLoopCnt < cmdLoopMax
    cmd_daxss_send_x123 cmd "THFA= $setTHFA ;"
    set cmdLoopCnt = cmdLoopCnt + 1
    wait $waitInterval
endwhile

PLAYBACK:
echo Press GO to start 3 minute data collection and SCID playback
pause
echo waiting 3 minutes to collect data
wait 180000

echo Press go to play back last 5 minutes
pause
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_sd_playback stream UHF start $playbackOffset num 240 timeout 600 partition 2 decimation 1
	set cmdTry = cmdTry + 1
	wait 3500
endwhile

FINISH:
echo THFA Command sent for THFA=$setTHFA
echo Data playback from SCID offset=$playbackOffset 
echo Press GO to finish
pause