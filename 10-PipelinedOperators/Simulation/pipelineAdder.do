onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /pipelineadder_tb/reset
add wave -noupdate /pipelineadder_tb/clock
add wave -noupdate -divider Operands
add wave -noupdate -radix hexadecimal -radixshowbase 0 /pipelineadder_tb/a
add wave -noupdate -radix hexadecimal -radixshowbase 0 /pipelineadder_tb/b
add wave -noupdate -radixshowbase 0 /pipelineadder_tb/cIn
add wave -noupdate -divider Tester
add wave -noupdate -radix hexadecimal -radixshowbase 0 /pipelineadder_tb/I_tester/sumNoPipe
add wave -noupdate -radix hexadecimal -radixshowbase 0 /pipelineadder_tb/I_tester/sumArray(3)
add wave -noupdate -divider Result
add wave -noupdate -radix hexadecimal -radixshowbase 0 /pipelineadder_tb/sum
add wave -noupdate /pipelineadder_tb/cOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 293
configure wave -valuecolwidth 80
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
WaveRestoreZoom {0 ns} {309 ns}
