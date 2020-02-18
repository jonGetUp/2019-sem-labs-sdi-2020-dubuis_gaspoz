onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /morsedecoder_tb/reset
add wave -noupdate /morsedecoder_tb/clock
add wave -noupdate /morsedecoder_tb/RxD
add wave -noupdate -radix ascii /morsedecoder_tb/I_enc/characterReg
add wave -noupdate /morsedecoder_tb/morseCode
add wave -noupdate /morsedecoder_tb/morseEnvelope
add wave -noupdate /morsedecoder_tb/TxD
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {30477 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 198
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
WaveRestoreZoom {0 ns} {12762570 ns}
run -all
