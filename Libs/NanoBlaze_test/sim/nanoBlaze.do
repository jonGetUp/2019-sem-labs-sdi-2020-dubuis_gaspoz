onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /nanoblaze_tb/reset
add wave -noupdate /nanoblaze_tb/clock
add wave -noupdate /nanoblaze_tb/en
add wave -noupdate -divider Program
add wave -noupdate -format Analog-Step -height 30 -max 100.0 -radix hexadecimal /nanoblaze_tb/i_dut/programcounter
add wave -noupdate -radix hexadecimal /nanoblaze_tb/i_dut/programcounter
add wave -noupdate -radix hexadecimal /nanoblaze_tb/i_dut/instruction
add wave -noupdate /nanoblaze_tb/i_dut/i_up/instrstring
add wave -noupdate -divider Controller
add wave -noupdate /nanoblaze_tb/i_dut/i_up/opcode
add wave -noupdate /nanoblaze_tb/i_dut/i_up/tworeginstr
add wave -noupdate /nanoblaze_tb/i_dut/i_up/instrdatasel
add wave -noupdate /nanoblaze_tb/i_dut/i_up/registerfilesel
add wave -noupdate /nanoblaze_tb/i_dut/i_up/portinsel
add wave -noupdate /nanoblaze_tb/i_dut/i_up/scratchpadsel
add wave -noupdate /nanoblaze_tb/i_dut/i_up/regwrite
add wave -noupdate /nanoblaze_tb/i_dut/i_up/scratchpadwrite
add wave -noupdate -divider ALU
add wave -noupdate -radix hexadecimal /nanoblaze_tb/i_dut/i_up/instrdata
add wave -noupdate /nanoblaze_tb/i_dut/i_up/alucode
add wave -noupdate -radix unsigned /nanoblaze_tb/i_dut/i_up/addra
add wave -noupdate -radix unsigned /nanoblaze_tb/i_dut/i_up/addrb
add wave -noupdate /nanoblaze_tb/i_dut/i_up/cin
add wave -noupdate -radix hexadecimal /nanoblaze_tb/i_dut/i_up/i_alu/opa
add wave -noupdate -radix hexadecimal /nanoblaze_tb/i_dut/i_up/i_alu/opb
add wave -noupdate -radix hexadecimal /nanoblaze_tb/i_dut/i_up/i_alu/aluout
add wave -noupdate /nanoblaze_tb/i_dut/i_up/cout
add wave -noupdate /nanoblaze_tb/i_dut/i_up/zero
add wave -noupdate -divider {Register file}
add wave -noupdate -radix hexadecimal -subitemconfig {/nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(0) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(1) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(2) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(3) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(4) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(5) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(6) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(7) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(8) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(9) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(10) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(11) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(12) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(13) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(14) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray(15) {-radix hexadecimal}} /nanoblaze_tb/i_dut/i_up/i_alu/i_regs/registerarray
add wave -noupdate -divider I/O
add wave -noupdate -radix hexadecimal -subitemconfig {/nanoblaze_tb/dataaddress(7) {-radix hexadecimal} /nanoblaze_tb/dataaddress(6) {-radix hexadecimal} /nanoblaze_tb/dataaddress(5) {-radix hexadecimal} /nanoblaze_tb/dataaddress(4) {-radix hexadecimal} /nanoblaze_tb/dataaddress(3) {-radix hexadecimal} /nanoblaze_tb/dataaddress(2) {-radix hexadecimal} /nanoblaze_tb/dataaddress(1) {-radix hexadecimal} /nanoblaze_tb/dataaddress(0) {-radix hexadecimal}} /nanoblaze_tb/dataaddress
add wave -noupdate /nanoblaze_tb/readstrobe
add wave -noupdate /nanoblaze_tb/writestrobe
add wave -noupdate -radix hexadecimal /nanoblaze_tb/datain
add wave -noupdate -radix hexadecimal /nanoblaze_tb/dataout
add wave -noupdate -divider Scratchpad
add wave -noupdate -radix hexadecimal -subitemconfig {/nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(0) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(1) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(2) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(3) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(4) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(5) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(6) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(7) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(8) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(9) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(10) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(11) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(12) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(13) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(14) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray(15) {-radix hexadecimal}} /nanoblaze_tb/i_dut/i_up/g_scratchpad/i_spad/memoryarray
add wave -noupdate -divider Branch
add wave -noupdate /nanoblaze_tb/i_dut/i_up/branchcond
add wave -noupdate /nanoblaze_tb/i_dut/i_up/incpc
add wave -noupdate /nanoblaze_tb/i_dut/i_up/loadinstraddress
add wave -noupdate -radix hexadecimal /nanoblaze_tb/i_dut/i_up/instraddress
add wave -noupdate /nanoblaze_tb/i_dut/i_up/loadstoredpc
add wave -noupdate -radix hexadecimal /nanoblaze_tb/i_dut/i_up/storedprogcounter
add wave -noupdate /nanoblaze_tb/i_dut/i_up/progcounter
add wave -noupdate -divider Stack
add wave -noupdate /nanoblaze_tb/i_dut/i_up/storepc
add wave -noupdate /nanoblaze_tb/i_dut/i_up/prevpc
add wave -noupdate /nanoblaze_tb/i_dut/i_up/progcounter
add wave -noupdate -radix hexadecimal -subitemconfig {/nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(0) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(1) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(2) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(3) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(4) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(5) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(6) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(7) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(8) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(9) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(10) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(11) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(12) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(13) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(14) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(15) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(16) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(17) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(18) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(19) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(20) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(21) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(22) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(23) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(24) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(25) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(26) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(27) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(28) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(29) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(30) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(31) {-radix hexadecimal} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray(32) {-radix hexadecimal}} /nanoblaze_tb/i_dut/i_up/i_br/progcounterarray
add wave -noupdate -radix hexadecimal /nanoblaze_tb/i_dut/i_up/storedprogcounter
add wave -noupdate -divider Interrupts
add wave -noupdate /nanoblaze_tb/int
add wave -noupdate /nanoblaze_tb/intack
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {923600 ps} 0}
configure wave -namecolwidth 260
configure wave -valuecolwidth 73
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
WaveRestoreZoom {0 ps} {1050 ns}
