onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider Operands
add wave -noupdate /paralleladder_tb/cIn
add wave -noupdate -radix hexadecimal -childformat {{/paralleladder_tb/a(7) -radix hexadecimal} {/paralleladder_tb/a(6) -radix hexadecimal} {/paralleladder_tb/a(5) -radix hexadecimal} {/paralleladder_tb/a(4) -radix hexadecimal} {/paralleladder_tb/a(3) -radix hexadecimal} {/paralleladder_tb/a(2) -radix hexadecimal} {/paralleladder_tb/a(1) -radix hexadecimal} {/paralleladder_tb/a(0) -radix hexadecimal}} -radixshowbase 0 -subitemconfig {/paralleladder_tb/a(7) {-radix hexadecimal -radixshowbase 0} /paralleladder_tb/a(6) {-radix hexadecimal -radixshowbase 0} /paralleladder_tb/a(5) {-radix hexadecimal -radixshowbase 0} /paralleladder_tb/a(4) {-radix hexadecimal -radixshowbase 0} /paralleladder_tb/a(3) {-radix hexadecimal -radixshowbase 0} /paralleladder_tb/a(2) {-radix hexadecimal -radixshowbase 0} /paralleladder_tb/a(1) {-radix hexadecimal -radixshowbase 0} /paralleladder_tb/a(0) {-radix hexadecimal -radixshowbase 0}} /paralleladder_tb/a
add wave -noupdate -radix hexadecimal -radixshowbase 0 /paralleladder_tb/b
add wave -noupdate -divider Result
add wave -noupdate -radix hexadecimal -radixshowbase 0 /paralleladder_tb/sum
add wave -noupdate /paralleladder_tb/cOut
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {274 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 197
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
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ns} {500 ns}
