onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /sinegen_tb/reset
add wave -noupdate /sinegen_tb/clock
add wave -noupdate -format Analog-Step -height 30 -max 1300.0 -radix unsigned -radixshowbase 0 /sinegen_tb/I_DUT/phase
add wave -noupdate -divider {generator signals}
add wave -noupdate -format Analog-Step -height 40 -max 66000.0 -radix unsigned -radixshowbase 0 /sinegen_tb/I_DUT/sawtooth
add wave -noupdate -format Analog-Step -height 40 -max 66000.0 -radix unsigned -radixshowbase 0 /sinegen_tb/I_DUT/square
add wave -noupdate -format Analog-Step -height 40 -max 66000.0 -radix unsigned -radixshowbase 0 /sinegen_tb/I_DUT/triangle
add wave -noupdate -divider sinewave
add wave -noupdate -format Analog-Step -height 80 -max 43200.0 -min -32800.0 -radix decimal -radixshowbase 0 /sinegen_tb/I_DUT/sineSamples
add wave -noupdate /sinegen_tb/I_DUT/newPolynom
add wave -noupdate -radix decimal -radixshowbase 0 /sinegen_tb/I_DUT/a
add wave -noupdate -radix decimal -radixshowbase 0 /sinegen_tb/I_DUT/b
add wave -noupdate -radix decimal -radixshowbase 0 /sinegen_tb/I_DUT/c
add wave -noupdate -radix decimal -radixshowbase 0 /sinegen_tb/I_DUT/d
add wave -noupdate -format Analog-Step -height 80 -max 76000.0 -radix unsigned -radixshowbase 0 /sinegen_tb/I_DUT/sine
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 250
configure wave -valuecolwidth 52
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
WaveRestoreZoom {0 ns} {52589 ns}
run 50 us
