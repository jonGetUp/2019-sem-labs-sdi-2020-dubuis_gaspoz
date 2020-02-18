onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /lissajousgenerator_test/reset
add wave -noupdate /lissajousgenerator_test/clock
add wave -noupdate -divider Sinewaves
add wave -noupdate -format Analog-Step -height 100 -max 65000.0 -radix unsigned -radixshowbase 0 /lissajousgenerator_test/I_DUT/sineX
add wave -noupdate -format Analog-Step -height 100 -max 65000.0 -radix unsigned -radixshowbase 0 /lissajousgenerator_test/I_DUT/sineY
add wave -noupdate -divider Sigma-delta
add wave -noupdate /lissajousgenerator_test/xSerial
add wave -noupdate /lissajousgenerator_test/ySerial
add wave -noupdate -divider {Lowpass outputs}
add wave -noupdate -format Analog-Step -height 100 -max 65000.0 -radix unsigned -childformat {{/lissajousgenerator_test/xLowapss(15) -radix unsigned} {/lissajousgenerator_test/xLowapss(14) -radix unsigned} {/lissajousgenerator_test/xLowapss(13) -radix unsigned} {/lissajousgenerator_test/xLowapss(12) -radix unsigned} {/lissajousgenerator_test/xLowapss(11) -radix unsigned} {/lissajousgenerator_test/xLowapss(10) -radix unsigned} {/lissajousgenerator_test/xLowapss(9) -radix unsigned} {/lissajousgenerator_test/xLowapss(8) -radix unsigned} {/lissajousgenerator_test/xLowapss(7) -radix unsigned} {/lissajousgenerator_test/xLowapss(6) -radix unsigned} {/lissajousgenerator_test/xLowapss(5) -radix unsigned} {/lissajousgenerator_test/xLowapss(4) -radix unsigned} {/lissajousgenerator_test/xLowapss(3) -radix unsigned} {/lissajousgenerator_test/xLowapss(2) -radix unsigned} {/lissajousgenerator_test/xLowapss(1) -radix unsigned} {/lissajousgenerator_test/xLowapss(0) -radix unsigned}} -radixshowbase 0 -subitemconfig {/lissajousgenerator_test/xLowapss(15) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(14) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(13) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(12) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(11) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(10) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(9) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(8) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(7) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(6) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(5) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(4) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(3) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(2) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(1) {-height 17 -radix unsigned -radixshowbase 0} /lissajousgenerator_test/xLowapss(0) {-height 17 -radix unsigned -radixshowbase 0}} /lissajousgenerator_test/xLowapss
add wave -noupdate -format Analog-Step -height 100 -max 65000.0 -radix unsigned -radixshowbase 0 /lissajousgenerator_test/yLowpass
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {101600 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 274
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
configure wave -timelineunits ms
update
WaveRestoreZoom {0 ns} {2100 us}
run 2 ms
