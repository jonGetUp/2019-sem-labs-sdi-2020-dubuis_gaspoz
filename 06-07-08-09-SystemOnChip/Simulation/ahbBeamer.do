onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /ahbbeamer_tb/I_tester/testInformation
add wave -noupdate /ahbbeamer_tb/hReset_n
add wave -noupdate /ahbbeamer_tb/hClk
add wave -noupdate /ahbbeamer_tb/selSinCos
add wave -noupdate -divider {AMBA bus}
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbbeamer_tb/hAddr
add wave -noupdate -radixshowbase 0 /ahbbeamer_tb/hTrans
add wave -noupdate -radixshowbase 0 /ahbbeamer_tb/hSel
add wave -noupdate -radixshowbase 0 /ahbbeamer_tb/hWrite
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbbeamer_tb/hWData
add wave -noupdate -radix hexadecimal -radixshowbase 0 /ahbbeamer_tb/hRData
add wave -noupdate /ahbbeamer_tb/hReady
add wave -noupdate /ahbbeamer_tb/hResp
add wave -noupdate -divider Registers
add wave -noupdate /ahbbeamer_tb/I_DUT/run
add wave -noupdate /ahbbeamer_tb/I_DUT/I_regs/updatePattern
add wave -noupdate /ahbbeamer_tb/I_DUT/interpolateLin
add wave -noupdate -radix unsigned -radixshowbase 0 /ahbbeamer_tb/I_DUT/I_regs/patternSize
add wave -noupdate -radix unsigned -radixshowbase 0 /ahbbeamer_tb/I_DUT/updatePeriod
add wave -noupdate -divider Internals
add wave -noupdate /ahbbeamer_tb/I_DUT/I_op/interpolationEnable
add wave -noupdate /ahbbeamer_tb/I_DUT/newPolynom
add wave -noupdate -divider Waveforms
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /ahbbeamer_tb/I_DUT/I_op/samplesX
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /ahbbeamer_tb/I_DUT/I_op/samplesY
add wave -noupdate -format Analog-Step -height 50 -max 65000.0 -radix unsigned -radixshowbase 0 /ahbbeamer_tb/I_DUT/I_op/unsignedX
add wave -noupdate -format Analog-Step -height 50 -max 65500.0 -radix unsigned -radixshowbase 0 /ahbbeamer_tb/I_DUT/I_op/unsignedY
add wave -noupdate /ahbbeamer_tb/outY
add wave -noupdate -format Analog-Step -height 50 -max 65500.0 -radix unsigned -radixshowbase 0 /ahbbeamer_tb/lowpassOutY
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 342
configure wave -valuecolwidth 105
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
WaveRestoreZoom {0 ps} {1050 us}
