onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ahbuart_tb/I_tester/testInformation
add wave -noupdate /ahbuart_tb/hReset_n
add wave -noupdate /ahbuart_tb/hClk
add wave -noupdate -divider {AMBA bus}
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbuart_tb/hAddr
add wave -noupdate -radixshowbase 0 /ahbuart_tb/hTrans
add wave -noupdate -radixshowbase 0 /ahbuart_tb/hSel
add wave -noupdate -radixshowbase 0 /ahbuart_tb/hWrite
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbuart_tb/hWData
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbuart_tb/hRData
add wave -noupdate -radixshowbase 0 /ahbuart_tb/hReady
add wave -noupdate -radixshowbase 0 /ahbuart_tb/hResp
add wave -noupdate -divider {Tester info}
add wave -noupdate -divider UART
add wave -noupdate -radix hexadecimal /ahbuart_tb/TxD
add wave -noupdate -radix hexadecimal /ahbuart_tb/RxD
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 255
configure wave -valuecolwidth 55
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1000
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ps} {4200 ns}
run 4 us
