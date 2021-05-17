;
; NAME:
;   cdh_cmd_test
;
; PURPOSE:
;   Runs through CDH commands and makes sure the expected responses are received
;
;  COMMANDS TESTED
;   None
;
;
; MODIFICATION HISTORY
;   2014-12-12: James Paul Mason: Wrote this wrapper script for Matt Cirbos subscripts, but need Matt to figure out the order
;	2014-12-12: Matt Cirbo: Added subscripts
;	2016-08-16: James Paul Mason: Changed subscript from sdcard_cmd_test, eeprom_cmd_test, phoenix_cmd_test, misc_fsw_test, and stress_test to 
;								  command_nonparam_test and command_param_test. 
;	2019-03-28: James Paul Mason: Updated for DAXSS

declare cmdCnt dn16

echo Starting cdh_cmd_test script
echo Click GO when ready to test the PARAM set commands
echo This will end with power cycle tests
pause

call Scripts/DAXSS/command_param_test

echo Click GO when ready to test the non-PARAM commands
pause

call Scripts/DAXSS/command_nonparam_test


DONE:

echo End of cdh_cmd_test script
