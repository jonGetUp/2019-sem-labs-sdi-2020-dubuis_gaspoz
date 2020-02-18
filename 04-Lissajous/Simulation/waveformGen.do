onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /waveformgen_tb/reset
add wave -noupdate /waveformgen_tb/clock
add wave -noupdate /waveformgen_tb/en
add wave -noupdate -divider {generator signals}
add wave -noupdate -format Analog-Step -height 70 -max 66000.0 -radix unsigned -radixshowbase 0 /waveformgen_tb/I_DUT/sawtooth
add wave -noupdate -format Analog-Step -height 70 -max 66000.0 -radix unsigned -radixshowbase 0 /waveformgen_tb/I_DUT/square
add wave -noupdate -format Analog-Step -height 70 -max 66000.0 -radix unsigned -radixshowbase 0 /waveformgen_tb/I_DUT/triangle
add wave -noupdate -format Analog-Step -height 70 -max 66000.0 -radix unsigned -radixshowbase 0 /waveformgen_tb/I_DUT/polygon
add wave -noupdate -format Analog-Step -height 70 -max 66000.0 -radix unsigned -radixshowbase 0 /waveformgen_tb/I_DUT/sine
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 0
configure wave -namecolwidth 272
configure wave -valuecolwidth 89
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
WaveRestoreZoom {0 ns} {525 us}
run 500 us
