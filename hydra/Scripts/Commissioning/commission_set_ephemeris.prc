; IS-1 Commissioning Scripts
; Purpose: Set ephemeris to provide suitable fine point solution to ADCS
; Script name: commission_set_ephemeris
;
; PURPOSE:
;   Set the ephemeris necessary for ADCS to do fine pointing
;
;	*****  CRITICAL - you have to edit the ephemeris values appropriate for this pass
;	*****	The ephemeris values are in lines 57-69 and should be calculated with time during pass
;	*****   Ideally, this ephemeris time should be within 120 sec of current ADCS time when script is run
;
; ISSUES:
;   Is there a recommend fine reference point telemetry item?
;
; MODIFICATION HISTORY
;   2015/03/24: James Paul Mason: Initial script
;	2015/08/11: Tom Woods: updates for calling hello_minxss and having FINISH section
;	2016/01/18: Tom Woods: provided comments that give instructions on how to calculate the ephemeris values
;	2016/05/24: Tom Woods: fast version of commission_set_ephemeris without any Pauses or setup commands

;

declare cmdCnt dn16
declare cmdTry dn16l
declare cmdSucceed dn16l
declare cmdTryADCS dn16
declare cmdTryExit dn16l
declare cmdTryNumber dn16l

; variables for setting ephemeris for ADCS
declare ephYear dn8
declare ephMonth dn8
declare ephDay dn8
declare ephHour dn8
declare ephMinute dn8
declare ephSecond dn8
declare ephPosX double64
declare ephPosY double64
declare ephPosZ double64
declare ephVelX double64
declare ephVelY double64
declare ephVelZ double64
declare cont dn8

declare ephRAAN double64
declare ephIncl double64
declare ephArgP double64
declare ephTruAnom double64
declare ephAlt double64
declare ephEcc double64

; Set Ephemeris UTC time, Position in km, and Velocity in km/sec in J2000 format
;	On MinXSS Processing Mac computer do the following to get the Ephemeris Values
;		; YEAR is format like 2016, but ephYear format below is YEAR - 2000
;	IDL> minxss_satellite_pass, /verbose    ; this will update the latest TLE (takes several seconds)
;	IDL> time = ymd2jd( YEAR, MONTH, DAY + HOUR/24.D0 + MINUTE/(24.*60.D0) + SECOND/(24.*3600.D0) )
;	IDL> spacecraft_location, time, location, sunlight, eci_pv=pv
;	IDL> print, 'Position X-Y-Z (km)     = ', pv[0:2]
;	IDL> print, 'Velocity X-Y-Z (km/sec) = ', pv[3:5]
; Then you can sanity check those numbers by entering them into the ECEF row of https://www.oc.nps.edu/oc2902w/coord/llhxyz.htm
; And you should get a latitude/longitude/height corresponding to Boulder and the expected altitude of your spacecraft.
;
;	*****  Lines 64 - 77 MUST be edited as Time During Pass when you will click GO button *****
set ephYear = 2020
set ephMonth = 11
set ephDay = 18
set ephHour = 13
set ephMinute = 52
set ephSecond = 47

set ephPosX =  -5322.2444
set ephPosY = 1882.4751
set ephPosZ = 4050.4271
set ephVelX = 4.5410236
set ephVelY = -0.27376452
set ephVelZ = 6.0618905
set cont = 1

; ****** Lines 79 - 84 MUST be edited before updating to the satellite *****
set ephRAAN =
set ephIncl =
set ephArgP =
set ephTrueAnom =
set ephAlt =
set ephEcc =

; Route ADCS Refs pkt to UHF, why is this routing needed? 
ROUTE:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid ADCS_REFS rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1


SET_EPHEMERIS:
;	Load ephemeris and wait until Refs Valid = 1 = YES = TRUE
LOAD_EPHEMERIS:
set cmdTryADCS = beacon_adcs_cmd_acpt + 1
while beacon_adcs_cmd_acpt < $cmdTryADCS
	set cmdTry = cmdTry + 1
	cmd_adcs_Refs_InitPosVelUtcGreg year $ephYear mon $ephMonth day $ephDay hour $ephHour min $ephMinute sec $ephSecond millisec 0 PosX $ephPosX PosY $ephPosY PosZ $ephPosZ VelX $ephVelX VelY $ephVelY VelZ $ephVelZ
;  cmd_adcs_Refs_InitKeplerUtcGreg year $ephYear mon $ephMonth day $ephDay hour $ephHour min $ephMinute sec $ephSecond millisec 0 RAAN $ephRAAN Incl $ephIncl ArgP $ephArgP TrueAnom $ephTrueAnom Alt $ephAlt Ecc $ephEcc
	wait 4200
endwhile
set cmdSucceed = cmdSucceed + 1

echo Ephemeris has been successfully loaded.
echo Check if beacon_adcs_refs_valid, beacon_adcs_time_valid, and beacon_adcs_att_valid is true
pause
verify beacon_adcs_refs_valid == 1
verify beacon_adcs_time_valid == 1
verify beacon_adcs_att_valid == 1


FINISH:
UNROUTE:
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid ADCS_REFS rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
echo COMPLETED setting ephemeris in ADCS
