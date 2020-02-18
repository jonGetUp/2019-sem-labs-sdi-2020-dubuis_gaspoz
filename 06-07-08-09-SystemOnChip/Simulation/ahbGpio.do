onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ahbgpio_tb/I_tester/testInformation
add wave -noupdate /ahbgpio_tb/hReset_n
add wave -noupdate /ahbgpio_tb/hClk
add wave -noupdate -divider {AMBA bus}
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbgpio_tb/hAddr
add wave -noupdate -radixshowbase 0 /ahbgpio_tb/hTrans
add wave -noupdate -radixshowbase 0 /ahbgpio_tb/hSel
add wave -noupdate -radixshowbase 0 /ahbgpio_tb/hWrite
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbgpio_tb/hWData
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbgpio_tb/hRData
add wave -noupdate -radixshowbase 0 /ahbgpio_tb/hReady
add wave -noupdate -radixshowbase 0 /ahbgpio_tb/hResp
add wave -noupdate -divider GPIO
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbgpio_tb/ioEn
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbgpio_tb/ioOut
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbgpio_tb/ioIn
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbgpio_tb/io
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {900414 ps} 0}
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {868661 ps}
run 800 ns
