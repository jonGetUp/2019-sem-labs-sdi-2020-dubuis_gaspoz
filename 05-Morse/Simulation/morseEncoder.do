onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -expand -group {Reset and clock} /morseencoder_tb/reset
add wave -noupdate -expand -group {Reset and clock} /morseencoder_tb/clock
add wave -noupdate -expand -group UART /morseencoder_tb/RxD
add wave -noupdate -expand -group UART /morseencoder_tb/I_DUT/characterValid
add wave -noupdate -expand -group UART -radix ascii /morseencoder_tb/I_DUT/characterReg
add wave -noupdate -expand -group UART -radix hexadecimal /morseencoder_tb/I_DUT/characterReg
add wave -noupdate -expand -group Encoder /morseencoder_tb/I_DUT/I_enc/startCounter
add wave -noupdate -expand -group Encoder -radix unsigned /morseencoder_tb/I_DUT/I_enc/unitNb
add wave -noupdate -expand -group Encoder /morseencoder_tb/I_DUT/I_enc/done
add wave -noupdate -expand -group Encoder /morseencoder_tb/morseCode
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 290
configure wave -valuecolwidth 40
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
WaveRestoreZoom {0 ns} {37800 us}
run -all
