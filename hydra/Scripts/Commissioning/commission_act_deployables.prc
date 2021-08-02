; IS-1 Commissioning Scripts
; Purpose: Set deployment flags for all deployables and stop them from deploying further
; Script name: commission_act_deployables
; Outline:
;   1. Route mode_hk packet
;   2. Stop panel 1 deployment
;   3. Stop panel 2 deployment
;   4. Stop antenna deployment
;   5. Stop mode_hk routing

declare cmdCnt dn32l
declare cmdTry dn32l
declare cmdSucceed dn32l


; 1. Route mode_hk packet
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid MODE_HK rate 3 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1


PANEL1:
; Stop deployments
; Set deploy flag states (PANEL1, PANEL2 and ANTENNA) to 1
echo User to verify if PANEL1 currents are nominal
echo Jump to Panel2 if skipping this
pause
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_mode_deploy_flag component 0 state 1
    set cmdTry = cmdTry + 1
    wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
verify mode_deployables[0] == 1
echo Panel 1 deployment acknowledged

PANEL2:
echo User to verify if PANEL2 currents are nominal
echo Jump to ANTENNA if skipping this
pause
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_mode_deploy_flag component 1 state 1
    set cmdTry = cmdTry + 1
    wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
verify mode_deployables[1] == 1
echo Panel 2 deployment acknowledged

ANTENNA:
echo User to verify if ANTENNA is deployed through UHF waterfall plot
pause
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_mode_deploy_flag component 2 state 1
    set cmdTry = cmdTry + 1
    wait 3529
endwhile
set cmdSucceed = cmdSucceed + 1
verify mode_deployables[2] == 1
echo Antenna deployment acknowledged


; 5. Route mode_hk packet
set cmdCnt = beacon_cmd_succ_count + 1
while beacon_cmd_succ_count < $cmdCnt
    cmd_set_pkt_rate apid MODE_HK rate 0 stream UHF
    set cmdTry = cmdTry + 1
    wait 3500
endwhile
set cmdSucceed = cmdSucceed + 1
