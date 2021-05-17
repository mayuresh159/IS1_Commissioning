test start name="startup" group="cmd"

argument deviceName varString
declare pktCount dn32
declare status dn32

set pktCount = $deviceName_bytesRecv


tlmwait $deviceName_bytesRecv != $pktCount ? 20000
timeout
	test fail No bytes received from $deviceName
	set status = 0
	goto FINISH
endtimeout

set status = 1

FINISH:
test end

return $status
