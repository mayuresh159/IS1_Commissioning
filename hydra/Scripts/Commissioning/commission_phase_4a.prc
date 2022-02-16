; IS-1 Commissioning Scripts
; Purpose: Check for aliveness in safe Mode
; Script name: commission_aliveness_safe
; Main subsystems: CDH, EPS, UHF, SBand, ADCS (+GPS), CIP, DAXSS
; Safe mode: No Payloads, No SBand | Just CDH, EPS, UHF, ADCS, DAXSS (electronics would be on but instrument off)
; Outline:
;   Check for command ability
; 	Check CDH, EPS, UHF
;	  Does not check ADCS, DAXSS and CIP
;
; MANAGEMENT:
; 1. Hydra Operator (Commander): Dhruva Anantha Datta (IIST)
; 2. GNU radio Operator; Murala Aman Naveen (IIST)
; 3. GS Superviser; Raveendranath Sir (IIST) and Joji Sir (IIST)
; 4. QA, Arosish Priyadarshan (IIST)
; 5. QC, Unnati (IIST)
;
; OTHER DEPENDENT SCRIPTS:
; hello_is1
; Scripts/Commissioning/commission_cdh_tlm_check
; Scripts/Commissioning/commission_eps_tlm_check
; Scripts/Commissioning/commission_comm_tlm_check
; Scripts/Commissioning/commission_adcs_tlm_check

declare cmdCnt dn16l
declare cmdTry dn16l
declare cmdSucceed dn16l
declare seqCnt dn14

echo Press GO when ready to start the script
pause

echo STARTING Commission aliveness safe test
echo NOTE that one should GOTO FINISH when less than 2 minutes from the pass end time

; wait until IS-1 responds
call hello_is1

; Get beacon packet to debug every 3 seconds
; Should the beacon be set for UHF? The beacon packet update when in orbit will happen over UHF and no hardline exists!
; Set beacons to UHF stream
; 0/DBG 1/UHF 2/SD 3/SBAND

; Using the 10 second beacon itself !

; confirm safe mode
; wait to check if the satellite is in safe mode for atleast 10 sec, else proceed with TLM checks
; 0/PHOENIX 1/SAFE 2/SCID 3/SCIC
tlmwait beacon_mode == 1 ? 10000
timeout
  echo Spacecraft not in Safe Mode
	echo Running the wrong script
	echo Check if the S/C is in nominal/ science modes
	pause
endtimeout

; Zero launch delay table parameter to avoid recurring launch delay after spacecraft reset
echo To proceed for checkout of various systems press GO
pause

CHECKOUT:
; Decided to keep all parameter checks
; Call comm_tlm_check
; S-Band will be turned ON, and needs to be turned off before the pass.

echo Press GO if you want to perfrom Comm. tlm checks.
echo Else GOTO FINISH
pause
call Scripts/Commissioning/commission_comm_tlm_check

; Call cdh_tlm_check
echo Press GO if you want to perfrom CDH tlm checks.
echo Else GOTO FINISH
pause
call Scripts/Commissioning/commission_cdh_tlm_check

; Call eps_tlm_check
echo Press GO if you want to perfrom EPS tlm checks.
echo Else GOTO FINISH
pause
call Scripts/Commissioning/commission_eps_tlm_check

; Call adcs_tlm_check
echo Press GO if you want to perfrom ADCS tlm checks.
echo Else GOTO FINISH
pause
call Scripts/Commissioning/commission_adcs_tlm_check

; Report completion of script
echo COMPLETED Commission aliveness safe test with Tries = $cmdTry and Success = $cmdSucceed
