declare uart_en dn8

ask "Start UART?" uart_en "0,1"

if $uart_en == 1
  GOTO UART
else
  GOTO UHF
endif

UART:
start setup_for_uart_cmd
GOTO END

UHF:
start setup_for_uhf_cmd
GOTO END

END:
load_dc default.dc
; end of script
