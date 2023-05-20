onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /msg_parser_tb/msg_parser_1/MAX_MSG_BYTES
add wave -noupdate -expand -group clk/rst /msg_parser_tb/msg_parser_1/clk10
add wave -noupdate -expand -group clk/rst /msg_parser_tb/msg_parser_1/clk
add wave -noupdate -expand -group clk/rst /msg_parser_tb/msg_parser_1/rst
add wave -noupdate -expand -group {AXI4S Input} -color {Green Yellow} /msg_parser_tb/msg_parser_1/s_tready
add wave -noupdate -expand -group {AXI4S Input} -color {Green Yellow} /msg_parser_tb/msg_parser_1/s_tvalid
add wave -noupdate -expand -group {AXI4S Input} -color {Green Yellow} /msg_parser_tb/msg_parser_1/s_tlast
add wave -noupdate -expand -group {AXI4S Input} -color {Green Yellow} -radix hexadecimal /msg_parser_tb/msg_parser_1/s_tdata
add wave -noupdate -expand -group {AXI4S Input} -color {Green Yellow} -radix hexadecimal /msg_parser_tb/msg_parser_1/s_tkeep
add wave -noupdate -expand -group {AXI4S Input} -color {Green Yellow} /msg_parser_tb/msg_parser_1/s_tuser
add wave -noupdate -expand -group {AXI4S Input} -color {Green Yellow} -radix hexadecimal /msg_parser_tb/msg_parser_1/r_tdata
add wave -noupdate -expand -group {AXI4S Input} -color {Green Yellow} -radix hexadecimal /msg_parser_tb/msg_parser_1/r_tkeep
add wave -noupdate -expand -group {AXI4S Input} -color {Green Yellow} /msg_parser_tb/msg_parser_1/r_tvalid
add wave -noupdate -color {Medium Aquamarine} /msg_parser_tb/msg_parser_1/fsm_parser
add wave -noupdate -expand -group {Output Payload} -color Cyan /msg_parser_tb/msg_parser_1/msg_valid
add wave -noupdate -expand -group {Output Payload} -color Cyan -radix hexadecimal /msg_parser_tb/msg_parser_1/msg_data
add wave -noupdate -expand -group {Output Payload} -color Cyan -radix hexadecimal /msg_parser_tb/msg_parser_1/msg_length
add wave -noupdate -expand -group {Output Payload} -color Cyan /msg_parser_tb/msg_parser_1/msg_error
add wave -noupdate -expand -group {FIFO : TDATA} -color {Violet Red} -radix hexadecimal /msg_parser_tb/msg_parser_1/r_tdata_dout
add wave -noupdate -expand -group {FIFO : TDATA} -color {Violet Red} /msg_parser_tb/msg_parser_1/r_tdata_ren
add wave -noupdate -expand -group {FIFO : TDATA} -color {Violet Red} /msg_parser_tb/msg_parser_1/r_tdata_valid
add wave -noupdate -expand -group {FIFO : TDATA} -color {Violet Red} -radix hexadecimal /msg_parser_tb/msg_parser_1/r_data_cnt
add wave -noupdate -expand -group {FIFO : TDATA} -color {Violet Red} /msg_parser_tb/msg_parser_1/r_tdata_full
add wave -noupdate -expand -group {FIFO : TDATA} -color {Violet Red} /msg_parser_tb/msg_parser_1/r_tdata_almost_full
add wave -noupdate -expand -group {FIFO : TDATA} -color {Violet Red} /msg_parser_tb/msg_parser_1/r_tdata_empty
add wave -noupdate -expand -group {FIFO : TDATA} -color {Violet Red} /msg_parser_tb/msg_parser_1/r_tdata_almost_empty
add wave -noupdate -expand -group {FIFO : TKEEP} -color {Blue Violet} /msg_parser_tb/msg_parser_1/r_tkeep_full
add wave -noupdate -expand -group {FIFO : TKEEP} -color {Blue Violet} /msg_parser_tb/msg_parser_1/r_tkeep_almost_full
add wave -noupdate -expand -group {FIFO : TKEEP} -color {Blue Violet} /msg_parser_tb/msg_parser_1/r_tkeep_valid
add wave -noupdate -expand -group {FIFO : TKEEP} -color {Blue Violet} -radix binary /msg_parser_tb/msg_parser_1/r_tkeep_dout
add wave -noupdate -expand -group {FIFO : TKEEP} -color {Blue Violet} /msg_parser_tb/msg_parser_1/r_tkeep_ren
add wave -noupdate -expand -group {FIFO : TKEEP} -color {Blue Violet} -radix hexadecimal /msg_parser_tb/msg_parser_1/r_tkeep_cnt
add wave -noupdate -expand -group {FIFO : TKEEP} -color {Blue Violet} /msg_parser_tb/msg_parser_1/r_tkeep_almost_empty
add wave -noupdate -expand -group {FIFO : TKEEP} -color {Blue Violet} /msg_parser_tb/msg_parser_1/r_tkeep_empty
add wave -noupdate -expand -group Controllers -color {Light Blue} -radix hexadecimal /msg_parser_tb/msg_parser_1/r2_tdata_dout
add wave -noupdate -expand -group Controllers -color {Light Blue} -radix unsigned /msg_parser_tb/msg_parser_1/r_msg_cnt
add wave -noupdate -expand -group Controllers -color {Light Blue} -radix hexadecimal /msg_parser_tb/msg_parser_1/r_msg_cnt_chk
add wave -noupdate -expand -group Controllers -color {Light Blue} -radix hexadecimal /msg_parser_tb/msg_parser_1/r_payload_cnt
add wave -noupdate -expand -group Controllers -color {Light Blue} /msg_parser_tb/msg_parser_1/r_start_ip
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_AXI_WIDTH
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_FIELD_LEN_WIDTH
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_FIELD_CNT_WIDTH
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_FIELD_LEN_POS
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_FIELD_CNT_POS
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_HDR_LEN_BYTES
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_TKEEP_WR_DEPTH
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_TKEEP_WR_DATA_W
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_TKEEP_RD_DATA_W
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_DUAL_CLOCK
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_FWFT
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_WR_DEPTH
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_WR_DATA_W
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_RD_DATA_W
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_RD_LATENCY
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_REN_CTRL
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_WEN_CTRL
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_ALMOST_EMPTY_LIMIT
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_ALMOST_FULL_LIMIT
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_SANITY_CHECK
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_SIMULATION
add wave -noupdate -color Gray55 /msg_parser_tb/msg_parser_1/C_TKEEP_NB
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {750357 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 293
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ns
update
WaveRestoreZoom {0 ps} {4200 ns}
