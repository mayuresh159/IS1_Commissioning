test start name="desCmds" group="des"

test description Test commands to modify the DES
test author Alex Reynolds

; Get the current task count, set expected value to count + 1
declare expected_task_cnt int32
cmd_issue_pkt apid DES_TASK
wait 2000
set expected_task_cnt = des_task_count + 1

; Add a task to the des
cmd_des_add_task taskID TLM slice 39

; Check if the des now has one more task - fail if not
wait 1000
cmd_issue_pkt apid DES_TASK
wait 2000
if des_task_count != expected_task_cnt
	test fail Unable to add task to DES
	goto FINISH
endif

; Get current task count, set expected value to count - 1
set expected_task_cnt = des_task_count - 1

; Take away the task we just added
cmd_des_sub_task slice 39

; Check if the des now has one less task - fail if not
wait 1000
cmd_issue_pkt apid DES_TASK
wait 2000
if des_task_count != expected_task_cnt
	test fail Unable to subtract task from DES
	goto FINISH
endif

; Get the current des cycle count
wait 5000
declare cycle_cnt int32
set cycle_cnt = desCycleCount

; Reset the des statistics
cmd_des_reset

; check the des cycle count after command - should be less than old count
if desCycleCount > cycle_cnt
	test fail Unable to reset DES statistics
	goto FINISH
endif

FINISH:
test summary
test end