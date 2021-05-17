test reset

call test_tlmRecv(usb)
if $$ret == 0
   goto FINISH
endif

call common_test
call custom_test

FINISH:
test groups
exit
