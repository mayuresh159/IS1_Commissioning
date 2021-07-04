declare cmdCnt dn8

set cmdCnt = 0

while cmdCnt < 200
    cmd_noop
    set cmdCnt = cmdCnt + 1
    wait 5000
endwhile
