;
; NAME:
;   cpt
;
; PURPOSE:
;   cpt = comprehensive performance test. This test runs through all telemetry and tests most commands and expected responses.
;   See InspireSAT_1_CPT_Log.docx
;   Each unique test should make a copy of the document template and populate it. Not everything required is covered in these scripts.
;
;  COMMANDS TESTED
;   See subscripts
;
;	HK PACKET TELEMETRY POINTS VERIFIED
;    All
;
; ISSUES:
;   None
;
; MODIFICATION HISTORY
;	2020-03-03: Robert Sewell -- Created for InspireSat-1 from MinXSS template
;

; NOTE: This script prompts the operator to populate the Inspire CPT document with echos and pauses

; 1. Metadata
echo Populate Section 1. Metadata
pause

; 2. CubeSat Configuration
echo Populate Section 2. CubeSat Configuration
pause

; 3. Test Configuration
echo Populate Section 3. Test Configuration
pause

; 4. Telemetry Status - OK to Proceed
echo Populate Section 4. Telemetry Status - OK to Proceed
pause

; 5. Full Telemetry Verification
echo Starting Scripts for Section 5. Full Telemetry Verification
call aliveness
echo Populate Section 5. Full Telemetry Verification (mostly just check boxes)
pause

; 6. Ground Commands Via Hydra Verification
; Start beacon packets routing through UHF for succ_cmd
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
	cmd_noop
    cmd_set_pkt_rate apid SW_STAT rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1

echo Starting Scripts for Section 6. Ground Commands Via ISIS Verification
call Scripts/UHF/uhf_eps_cmd_test
call Scripts/UHF/uhf_comm_cmd_test
call Scripts/UHF/uhf_daxss_cmd_test
call Scripts/UHF/uhf_test_cip
call Scripts/UHF/uhf_adcs_cmd_test
call Scripts/UHF/uhf_cdh_cmd_test

echo Populate Section 6. Ground Commands Via ISIS Verification
pause

; 7. Stimulated Responses
echo Populate Section 7. Stimulated Responses
pause

; 8. Closeout
echo Populate Section 8. Closeout
pause

FINISH:
echo COMPLETED Comprehensive Performance Test Scripts