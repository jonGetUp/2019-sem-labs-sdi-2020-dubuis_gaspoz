onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /dac_tb/reset
add wave -noupdate /dac_tb/clock
add wave -noupdate -divider {parallel to serial}
add wave -noupdate -format Analog-Step -height 100 -max 66000.0 -radix unsigned -subitemconfig {/dac_tb/parallelin(15) {-radix unsigned} /dac_tb/parallelin(14) {-radix unsigned} /dac_tb/parallelin(13) {-radix unsigned} /dac_tb/parallelin(12) {-radix unsigned} /dac_tb/parallelin(11) {-radix unsigned} /dac_tb/parallelin(10) {-radix unsigned} /dac_tb/parallelin(9) {-radix unsigned} /dac_tb/parallelin(8) {-radix unsigned} /dac_tb/parallelin(7) {-radix unsigned} /dac_tb/parallelin(6) {-radix unsigned} /dac_tb/parallelin(5) {-radix unsigned} /dac_tb/parallelin(4) {-radix unsigned} /dac_tb/parallelin(3) {-radix unsigned} /dac_tb/parallelin(2) {-radix unsigned} /dac_tb/parallelin(1) {-radix unsigned} /dac_tb/parallelin(0) {-radix unsigned}} /dac_tb/parallelin
add wave -noupdate -format Analog-Step -height 100 -max 32000.0 -min -32000.0 -radix decimal /dac_tb/i_dut/parallelin1
add wave -noupdate -format Analog-Step -height 50 -max 1000000.0 -min -1000000.0 -radix decimal -subitemconfig {/dac_tb/i_dut/acc1(23) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(22) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(21) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(20) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(19) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(18) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(17) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(16) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(15) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(14) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(13) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(12) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(11) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(10) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(9) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(8) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(7) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(6) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(5) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(4) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(3) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(2) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(1) {-height 15 -radix decimal} /dac_tb/i_dut/acc1(0) {-height 15 -radix decimal}} /dac_tb/i_dut/acc1
add wave -noupdate -format Analog-Step -height 50 -max 1000000.0 -min -1000000.0 -radix decimal -subitemconfig {/dac_tb/i_dut/acc2(23) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(22) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(21) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(20) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(19) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(18) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(17) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(16) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(15) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(14) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(13) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(12) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(11) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(10) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(9) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(8) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(7) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(6) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(5) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(4) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(3) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(2) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(1) {-height 15 -radix decimal} /dac_tb/i_dut/acc2(0) {-height 15 -radix decimal}} /dac_tb/i_dut/acc2
add wave -noupdate /dac_tb/serialout
add wave -noupdate -divider {serial to parallel}
add wave -noupdate -format Analog-Step -height 100 -max 65500.000000000007 -radix unsigned /dac_tb/lowpassout
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
configure wave -namecolwidth 175
configure wave -valuecolwidth 63
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
WaveRestoreZoom {0 ps} {105 us}
run 100 us

