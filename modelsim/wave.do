onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /msg_parser_tb/msg_parser_1/MAX_MSG_BYTES
add wave -noupdate /msg_parser_tb/msg_parser_1/clk10
add wave -noupdate /msg_parser_tb/msg_parser_1/clk
add wave -noupdate /msg_parser_tb/msg_parser_1/rst
add wave -noupdate /msg_parser_tb/msg_parser_1/s_tready
add wave -noupdate /msg_parser_tb/msg_parser_1/s_tvalid
add wave -noupdate /msg_parser_tb/msg_parser_1/s_tlast
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/s_tdata
add wave -noupdate /msg_parser_tb/msg_parser_1/s_tkeep
add wave -noupdate /msg_parser_tb/msg_parser_1/s_tuser
add wave -noupdate /msg_parser_tb/msg_parser_1/msg_valid
add wave -noupdate -radix unsigned /msg_parser_tb/msg_parser_1/msg_length
add wave -noupdate -radix unsigned /msg_parser_tb/msg_parser_1/r_msg_cnt
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/r_msg_cnt_chk
add wave -noupdate /msg_parser_tb/msg_parser_1/msg_error
add wave -noupdate /msg_parser_tb/msg_parser_1/r_wr_clk
add wave -noupdate /msg_parser_tb/msg_parser_1/r_rd_clk
add wave -noupdate /msg_parser_tb/msg_parser_1/r_wr_rstn
add wave -noupdate /msg_parser_tb/msg_parser_1/r_rd_rstn
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/r_tdata
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tkeep
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tvalid
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tkeep_full
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tkeep_almost_full
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tkeep_valid
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tkeep_dout
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tdata_ren
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tdata_valid
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tkeep_ren
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/r_tkeep_cnt
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/r_tdata_dout
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tkeep_almost_empty
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tkeep_empty
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/r_data_cnt
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tdata_full
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tdata_almost_full
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tdata_empty
add wave -noupdate /msg_parser_tb/msg_parser_1/r_tdata_almost_empty
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/r_payload_cnt
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/r2_tdata_dout
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/r_msg_length
add wave -noupdate -radix hexadecimal /msg_parser_tb/msg_parser_1/r_msg_data
add wave -noupdate /msg_parser_tb/msg_parser_1/r_msg_valid
add wave -noupdate /msg_parser_tb/msg_parser_1/r_start_ip
add wave -noupdate /msg_parser_tb/msg_parser_1/fsm_parser
add wave -noupdate /msg_parser_tb/msg_parser_1/C_AXI_WIDTH
add wave -noupdate /msg_parser_tb/msg_parser_1/C_FIELD_LEN_WIDTH
add wave -noupdate /msg_parser_tb/msg_parser_1/C_FIELD_CNT_WIDTH
add wave -noupdate /msg_parser_tb/msg_parser_1/C_FIELD_LEN_POS
add wave -noupdate /msg_parser_tb/msg_parser_1/C_FIELD_CNT_POS
add wave -noupdate /msg_parser_tb/msg_parser_1/C_HDR_LEN_BYTES
add wave -noupdate /msg_parser_tb/msg_parser_1/C_TKEEP_WR_DEPTH
add wave -noupdate /msg_parser_tb/msg_parser_1/C_TKEEP_WR_DATA_W
add wave -noupdate /msg_parser_tb/msg_parser_1/C_TKEEP_RD_DATA_W
add wave -noupdate /msg_parser_tb/msg_parser_1/C_DUAL_CLOCK
add wave -noupdate /msg_parser_tb/msg_parser_1/C_FWFT
add wave -noupdate /msg_parser_tb/msg_parser_1/C_WR_DEPTH
add wave -noupdate /msg_parser_tb/msg_parser_1/C_WR_DATA_W
add wave -noupdate /msg_parser_tb/msg_parser_1/C_RD_DATA_W
add wave -noupdate /msg_parser_tb/msg_parser_1/C_RD_LATENCY
add wave -noupdate /msg_parser_tb/msg_parser_1/C_REN_CTRL
add wave -noupdate /msg_parser_tb/msg_parser_1/C_WEN_CTRL
add wave -noupdate /msg_parser_tb/msg_parser_1/C_ALMOST_EMPTY_LIMIT
add wave -noupdate /msg_parser_tb/msg_parser_1/C_ALMOST_FULL_LIMIT
add wave -noupdate /msg_parser_tb/msg_parser_1/C_SANITY_CHECK
add wave -noupdate /msg_parser_tb/msg_parser_1/C_SIMULATION
add wave -noupdate /msg_parser_tb/msg_parser_1/C_TKEEP_NB
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {647693 ps} 0}
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
WaveRestoreZoom {0 ps} {3150 ns}
