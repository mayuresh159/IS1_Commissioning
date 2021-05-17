test reset

CHECK_TLM:
call test_tlmRecv(ccsdsTlmServer)
if $$ret == 0
   goto FINISH
endif

START_TESTS:
call common_test
call custom_test

FINISH:
test groups

sim_kill
wait 3000

exit