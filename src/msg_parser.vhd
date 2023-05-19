-------------------------------------------------------------------------------
-- Title      : msg_parser
-- Project    :
-------------------------------------------------------------------------------
-- File       : msg_parser.vhd
-- Author     : Tran Leon  
-- Company    :
-- Created    : 2023-05-04
-- Last update: 2023-05-19
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Message Parser
-------------------------------------------------------------------------------
-- Copyright (c) 2023
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-05-04  1.0      ltran   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity msg_parser is
  generic
    (
      MAX_MSG_BYTES : integer := 32
      );
  port
    (
      clk10 : in std_logic;
      clk : in std_logic;
      rst : in std_logic;

      s_tready : out std_logic;
      s_tvalid : in std_logic;
      s_tlast : in std_logic;
      s_tdata : in std_logic_vector(63 downto 0);
      s_tkeep : in std_logic_vector(7 downto 0);
      s_tuser : in std_logic;

      msg_valid : out std_logic;
      msg_length : out std_logic_vector(15 downto 0);
      msg_data : out std_logic_vector(8*MAX_MSG_BYTES-1 downto 0);
      msg_error : out std_logic

      );
end msg_parser;


architecture rtl of msg_parser is

  constant C_AXI_WIDTH : integer := 64;
  constant C_FIELD_LEN_WIDTH : integer := 16;
  constant C_FIELD_CNT_WIDTH : integer := 16;
  constant C_FIELD_LEN_POS : integer := 3;
  constant C_FIELD_CNT_POS : integer := 1;
  constant C_HDR_LEN_BYTES : integer := 4;

  constant C_TKEEP_WR_DEPTH : integer := 32;
  constant C_TKEEP_WR_DATA_W : integer := 8;
  constant C_TKEEP_RD_DATA_W : integer := 2;

  constant C_DUAL_CLOCK : boolean := true;
  constant C_FWFT : boolean := false;
  constant C_WR_DEPTH : integer := 32;
  constant C_WR_DATA_W : integer := 64;
  constant C_RD_DATA_W : integer := 8;
  constant C_RD_LATENCY : integer := 1;
  constant C_REN_CTRL : boolean := true;
  constant C_WEN_CTRL : boolean := true;
  constant C_ALMOST_EMPTY_LIMIT : integer := 2;
  constant C_ALMOST_FULL_LIMIT : integer := 2;
  constant C_SANITY_CHECK : boolean := false;
  constant C_SIMULATION : integer := 0;

  -- Number of bytes taken by one readen TKEEP
  constant C_TKEEP_NB : integer := 3;

  -- component dp_fifo is
  --   generic (
  --     G_DATA_WIDTH : positive;
  --     G_WRITE_SIZE : positive;
  --     G_READ_SIZE  : positive;
  --     G_FIFO_DEPTH : positive);
  --   port (
  --     i_clk_write : in  std_logic;
  --     i_clk_read  : in  std_logic;
  --     i_reset     : in  std_logic;
  --     i_wr_data   : in  std_logic_vector(G_DATA_WIDTH - 1 downto 0);
  --     i_wr_enable : in  std_logic;
  --     o_wr_full   : out std_logic;
  --     o_rd_data   : out std_logic_vector(G_DATA_WIDTH - 1 downto 0);
  --     i_rd_enable : in  std_logic;
  --     o_rd_empty  : out std_logic);
  -- end component dp_fifo;

  component dp_fifo is
    generic (
      G_FIFO_DEPTH : positive;
      G_WR_DATA_WIDTH : positive;
      G_RD_DATA_WIDTH : positive);
    port (
      i_clk_write : in std_logic;
      i_clk_read : in std_logic;
      i_reset : in std_logic;
      i_wr_data : in std_logic_vector(G_WR_DATA_WIDTH - 1 downto 0);
      i_wr_enable : in std_logic;
      o_wr_full : out std_logic;
      o_rd_data : out std_logic_vector(G_RD_DATA_WIDTH - 1 downto 0);
      i_rd_enable : in std_logic;
      o_rd_empty : out std_logic);
  end component dp_fifo;


  component ces_util_fifo is
    generic (
      g_dual_clock : boolean;
      g_fwft : boolean;
      g_wr_depth : natural;
      g_wr_data_w : natural;
      g_rd_data_w : natural;
      g_rd_latency : natural;
      g_ren_ctrl : boolean;
      g_wen_ctrl : boolean;
      g_almost_empty_limit : integer;
      g_almost_full_limit : integer;
      g_sanity_check : boolean;
      g_simulation : integer);
    port (
      wr_clk_i : in std_logic;
      rd_clk_i : in std_logic;
      wr_rst_n_i : in std_logic;
      rd_rst_n_i : in std_logic;
      din_i : in std_logic_vector(C_WR_DATA_W - 1 downto 0);
      wen_i : in std_logic;
      full_o : out std_logic;
      almost_full_o : out std_logic;
      dout_o : out std_logic_vector(C_RD_DATA_W - 1 downto 0);
      ren_i : in std_logic;
      empty_o : out std_logic;
      almost_empty_o : out std_logic;
      valid_o : out std_logic);
  end component ces_util_fifo;


  signal r_wr_clk : std_logic;
  signal r_rd_clk : std_logic;
  signal r_wr_rstn : std_logic;
  signal r_rd_rstn : std_logic;

  signal r_tdata : std_logic_vector(C_WR_DATA_W - 1 downto 0);
  signal r_tkeep : std_logic_vector(C_TKEEP_WR_DATA_W - 1 downto 0);
  signal r_tvalid : std_logic;

  -- tdata FIFO
  signal r_tdata_full : std_logic;
  signal r_tdata_almost_full : std_logic;
  signal r_tdata_dout : std_logic_vector(C_RD_DATA_W - 1 downto 0);
  signal r_tdata_ren : std_logic;
  signal r_tdata_empty : std_logic;
  signal r_tdata_almost_empty : std_logic;
  signal r_tdata_valid : std_logic;

  -- tkeep FIFO
  signal r_tkeep_full : std_logic;
  signal r_tkeep_almost_full : std_logic;
  signal r_tkeep_dout : std_logic_vector(C_TKEEP_RD_DATA_W - 1 downto 0);
  signal r_tkeep_ren : std_logic;
  signal r_tkeep_empty : std_logic;
  signal r_tkeep_almost_empty : std_logic;
  signal r_tkeep_valid : std_logic;

  -- tkeep management
  signal r_tkeep_cnt : std_logic_vector(7 downto 0);

  signal r_msg_length : std_logic_vector(C_FIELD_LEN_WIDTH-1 downto 0);
  signal r_msg_cnt : std_logic_vector(C_FIELD_CNT_WIDTH-1 downto 0);
  signal r_msg_data : std_logic_vector(8*MAX_MSG_BYTES-1 downto 0);
  signal r_msg_cnt_chk : std_logic_vector(C_FIELD_CNT_WIDTH-1 downto 0);
  signal r_msg_valid : std_logic;

  signal r_data_cnt : integer;
  signal r_payload_cnt : integer;
  signal r2_tdata_dout : std_logic_vector(C_RD_DATA_W-1 downto 0);

  signal r2_tdata_ren : std_logic;

  signal r_start_ip : std_logic;

  type t_fsm_parser is (CNT, LEN, PAYLOAD);
  signal fsm_parser : t_fsm_parser;

begin

  -- dp_fifo_1: entity work.dp_fifo
  --   generic map (
  --     G_FIFO_DEPTH    => C_WR_DEPTH,
  --     G_WR_DATA_WIDTH => C_WR_DATA_W,
  --     G_RD_DATA_WIDTH => C_RD_DATA_W)
  --   port map (
  --     i_clk_write => clk,
  --     i_clk_read  => clk10,
  --     i_reset     => rst,
  --     i_wr_data   => s_tdata,
  --     i_wr_enable => s_tvalid,
  --     o_wr_full   => r_tdata_full,
  --     o_rd_data   => r_tdata_dout,
  --     i_rd_enable => r_tdata_ren,
  --     o_rd_empty  => r_tdata_empty);


  ces_util_fifo_1 : entity work.ces_util_fifo
    generic map (
      g_dual_clock => C_DUAL_CLOCK,
      g_fwft => C_FWFT,
      g_wr_depth => C_WR_DEPTH,
      g_wr_data_w => C_WR_DATA_W,
      g_rd_data_w => C_RD_DATA_W,
      g_rd_latency => C_RD_LATENCY,
      g_ren_ctrl => C_REN_CTRL,
      g_wen_ctrl => C_WEN_CTRL,
      g_almost_empty_limit => C_ALMOST_EMPTY_LIMIT,
      g_almost_full_limit => C_ALMOST_FULL_LIMIT,
      g_sanity_check => C_SANITY_CHECK,
      g_simulation => C_SIMULATION)
    port map (
      wr_clk_i => r_wr_clk,
      rd_clk_i => r_rd_clk,
      wr_rst_n_i => r_wr_rstn,
      rd_rst_n_i => r_rd_rstn,
      din_i => r_tdata,
      wen_i => r_tvalid,
      full_o => r_tdata_full,
      almost_full_o => r_tdata_almost_full,
      dout_o => r_tdata_dout,
      ren_i => r_tdata_ren,
      empty_o => r_tdata_empty,
      almost_empty_o => r_tdata_almost_empty,
      valid_o => r_tdata_valid);

  ces_util_fifo_2 : entity work.ces_util_fifo
    generic map (
      g_dual_clock => C_DUAL_CLOCK,
      g_fwft => false,
      g_wr_depth => C_TKEEP_WR_DEPTH,
      g_wr_data_w => C_TKEEP_WR_DATA_W,
      g_rd_data_w => C_TKEEP_RD_DATA_W,
      g_rd_latency => C_RD_LATENCY,
      g_ren_ctrl => C_REN_CTRL,
      g_wen_ctrl => C_WEN_CTRL,
      g_almost_empty_limit => C_ALMOST_EMPTY_LIMIT,
      g_almost_full_limit => C_ALMOST_FULL_LIMIT,
      g_sanity_check => C_SANITY_CHECK,
      g_simulation => C_SIMULATION)
    port map (
      wr_clk_i => r_wr_clk,
      rd_clk_i => r_rd_clk,
      wr_rst_n_i => r_wr_rstn,
      rd_rst_n_i => r_rd_rstn,
      din_i => r_tkeep,
      wen_i => r_tvalid,
      full_o => r_tkeep_full,
      almost_full_o => r_tkeep_almost_full,
      dout_o => r_tkeep_dout,
      ren_i => r_tkeep_ren,
      empty_o => r_tkeep_empty,
      almost_empty_o => r_tkeep_almost_empty,
      valid_o => r_tkeep_valid);




  p_input_data : process(clk)
  begin
    if(rst = '1') then
    elsif rising_edge(clk) then

      if(r_start_ip = '1') then
        r_tdata <= s_tdata;
        r_tvalid <= s_tvalid;
        r_tkeep <= s_tkeep;
      end if;

      -- wait end of frame before starting IP
      if(s_tlast = '1') then
        r_start_ip <= '1';
      end if;

    end if;
  end process;

  p_read_fifo : process(clk10)
  begin
    if(rst = '1') then

      r_data_cnt <= 0;
      r_payload_cnt <= 0;
      r_msg_data <= (others => '0');
      r_tkeep_cnt <= x"00";

      r_msg_cnt_chk <= (others => '0');

    elsif rising_edge(clk10) then

      -- pipeline d_out
      r2_tdata_dout <= r_tdata_dout;
      r2_tdata_ren <= r_tdata_ren;

      if(r_tdata_empty = '0') then
        r_tdata_ren <= '1';
      else
        r_tdata_ren <= '0';
      end if;

      -- activate tkeep and cnt
      if (r_tdata_ren = '1') then
        r_tkeep_cnt <= std_logic_vector(unsigned(r_tkeep_cnt) + 1);
        r_tkeep_ren <= r_tkeep_cnt(0);
      else
        r_tkeep_ren <= '0';
      end if;





      if (r_tdata_valid = '1' and r_tkeep_dout = b"11") then
        r_data_cnt <= r_data_cnt + 1;
      end if;

      case fsm_parser is

        when CNT =>

          if(r_data_cnt = C_FIELD_CNT_POS and (r_tkeep_dout = b"11")) then
            r_msg_cnt <= r_tdata_dout & r2_tdata_dout;
            fsm_parser <= LEN;
          end if;

        when LEN =>

          if(r_data_cnt = C_FIELD_LEN_POS and (r_tkeep_dout = b"11")) then
            r_msg_length <= r_tdata_dout & r2_tdata_dout;
            fsm_parser <= PAYLOAD;
          end if;

        when PAYLOAD =>

          if((r_payload_cnt = unsigned(r_msg_length)) and (r_tdata_valid = '1') and (unsigned(r_msg_cnt_chk) = unsigned(r_msg_cnt)-1)) then
            r_payload_cnt <= 0;
            r_data_cnt <= 0;
            r_msg_cnt_chk <= (others => '0');
            r_msg_data <= (others => '0');

            msg_length <= r_msg_length;
            msg_data <= r_msg_data;
            r_msg_valid <= '1';
            fsm_parser <= CNT;

          elsif(r_payload_cnt = unsigned(r_msg_length) and (r_tdata_valid = '1') and (unsigned(r_msg_cnt_chk) < unsigned(r_msg_cnt)-1)) then

            r_msg_cnt_chk <= std_logic_vector(unsigned(r_msg_cnt_chk) + 1);
            
            r_payload_cnt <= 0;
            r_data_cnt <= C_FIELD_LEN_POS;
            r_msg_data <= (others => '0');

            msg_length <= r_msg_length;
            msg_data <= r_msg_data;
            r_msg_valid <= '1';
            fsm_parser <= LEN;

          elsif((r_tdata_valid = '1') and (r_tkeep_dout = b"11")) then
            r_payload_cnt <= r_payload_cnt + 1;
            r_msg_data <= r_tdata_dout & r_msg_data(255 downto 8);
          end if;
      end case;


      -- msg_valid pulse
      if(r_msg_valid = '1') then
        r_msg_valid <= '0';
      end if;
    end if;

  end process;

  msg_valid <= r_msg_valid;
  r_wr_clk <= clk;
  r_rd_clk <= clk10;

end rtl;
