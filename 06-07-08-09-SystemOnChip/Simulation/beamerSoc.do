onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -group {Reset and clock} /beamersoc_tb/reset
add wave -noupdate -group {Reset and clock} /beamersoc_tb/clock
add wave -noupdate -divider SOC
add wave -noupdate -group Microprocessor -radix hexadecimal /beamersoc_tb/I_DUT/programCounter
add wave -noupdate -group Microprocessor /beamersoc_tb/I_DUT/I_up/instrString
add wave -noupdate -group Microprocessor /beamersoc_tb/I_DUT/I_up/I_ctrl/discardOpCode
add wave -noupdate -group Microprocessor -radix hexadecimal /beamersoc_tb/I_DUT/I_up/I_alu/I_regs/registerArray
add wave -noupdate -group Microprocessor /beamersoc_tb/I_DUT/upReadStrobe
add wave -noupdate -group Microprocessor /beamersoc_tb/I_DUT/upWriteStrobe
add wave -noupdate -group {AMBA bus} -radix hexadecimal -radixshowbase 0 /beamersoc_tb/I_DUT/hAddr
add wave -noupdate -group {AMBA bus} -radixshowbase 0 /beamersoc_tb/I_DUT/hTrans
add wave -noupdate -group {AMBA bus} -radixshowbase 0 /beamersoc_tb/I_DUT/hWrite
add wave -noupdate -group {AMBA bus} -radix hexadecimal -radixshowbase 0 /beamersoc_tb/I_DUT/hWData
add wave -noupdate -group {AMBA bus} -radix hexadecimal -radixshowbase 0 /beamersoc_tb/I_DUT/hRData
add wave -noupdate -group {AMBA bus} /beamersoc_tb/I_DUT/hReady
add wave -noupdate -group {AMBA bus} /beamersoc_tb/I_DUT/hResp
add wave -noupdate -radix hexadecimal /beamersoc_tb/io
add wave -noupdate -group UART -radix hexadecimal -radixshowbase 0 /beamersoc_tb/I_tester/uartRxData
add wave -noupdate -group UART -radixshowbase 0 /beamersoc_tb/RxD
add wave -noupdate -group UART -radixshowbase 0 /beamersoc_tb/TxD
add wave -noupdate -group UART -radix hexadecimal -radixshowbase 0 /beamersoc_tb/I_tester/uartTxData
add wave -noupdate -divider {Beamer registers}
add wave -noupdate -group {Processor bus} -radixshowbase 0 /beamersoc_tb/I_DUT/hSelV
add wave -noupdate -group {Processor bus} -radixshowbase 0 /beamersoc_tb/I_DUT/hSelBeamer
add wave -noupdate -group {Processor bus} -radix hexadecimal -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_regs/addr
add wave -noupdate -group {Processor bus} -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_regs/selControl
add wave -noupdate -group {Processor bus} -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_regs/selSpeed
add wave -noupdate -group {Processor bus} -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_regs/selX
add wave -noupdate -group {Processor bus} -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_regs/selY
add wave -noupdate -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/run
add wave -noupdate -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_regs/updatePattern
add wave -noupdate -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/interpolateLin
add wave -noupdate -radix unsigned -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_regs/patternSize
add wave -noupdate -radix unsigned -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/updatePeriod
add wave -noupdate -divider Waveforms
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_op/samplesX
add wave -noupdate -format Analog-Step -height 50 -max 32000.0 -min -32000.0 -radix decimal -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_op/samplesY
add wave -noupdate -format Analog-Step -height 50 -max 65500.0 -radix unsigned -radixshowbase 0 /beamersoc_tb/I_DUT/I_beamer/I_op/unsignedY
add wave -noupdate -format Analog-Step -height 50 -max 48000.0 -min 16000.0 -radix unsigned -radixshowbase 0 /beamersoc_tb/lowpassOutY
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ns} 0}
quietly wave cursor active 1
configure wave -namecolwidth 381
configure wave -valuecolwidth 55
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
WaveRestoreZoom {0 ns} {1575 us}
