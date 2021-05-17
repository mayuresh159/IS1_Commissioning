test start name="noop" group="cmd"

declare cmdCnt dn8

set cmdCnt = cmdSuccCount + 1

cmd_noop

tlmwait cmdSuccCount == $cmdCnt ? 10000
timeout
	test fail Noop command not accepted
	goto FINISH
endtimeout

FINISH:
test summary
test end
