onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider {Clock and reset}
add wave -noupdate /chartomorsecontroller_tb/reset
add wave -noupdate /chartomorsecontroller_tb/clock
add wave -noupdate -divider {FIFO interface}
add wave -noupdate -radix hexadecimal -radixshowbase 0 /chartomorsecontroller_tb/char
add wave -noupdate -radix ascii -radixshowbase 0 /chartomorsecontroller_tb/char
add wave -noupdate /chartomorsecontroller_tb/charNotReady
add wave -noupdate /chartomorsecontroller_tb/readChar
add wave -noupdate -divider {Duration counter}
add wave -noupdate /chartomorsecontroller_tb/unitNb
add wave -noupdate /chartomorsecontroller_tb/startCounter
add wave -noupdate /chartomorsecontroller_tb/done
add wave -noupdate -divider {Morse Code}
add wave -noupdate /chartomorsecontroller_tb/morseOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 249
configure wave -valuecolwidth 40
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits us
update
WaveRestoreZoom {0 ns} {2556473 ns}
