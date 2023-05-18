-------------------------------------------------------------------------------
-- Title      : msg_parser
-- Project    :
-------------------------------------------------------------------------------
-- File       : msg_parser.vhd
-- Author     : Tran Leon  
-- Company    :
-- Created    : 2023-05-04
-- Last update: 2023-05-17
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
      clk   : in std_logic;
      rst   : in std_logic;

      s_tready : out std_logic;
      s_tvalid : in  std_logic;
      s_tlast  : in  std_logic;
      s_tdata  : in  std_logic_vector(63 downto 0);
      s_tkeep  : in  std_logic_vector(7 downto 0);
      s_tuser  : in  std_logic;

      msg_valid  : out std_logic;
      msg_length : out std_logic_vector(15 downto 0);
      msg_data   : out std_logic_vector(8*MAX_MSG_BYTES-1 downto 0);
      msg_error  : out std_logic

      );
end msg_parser;


architecture rtl of msg_parser is

  constant C_AXI_WIDTH       : integer := 64;
  constant C_FIELD_LEN_WIDTH : integer := 16;
  constant C_FIELD_CNT_WIDTH : integer := 16;
  constant C_FIELD_LEN_POS   : integer := 3;
  constant C_FIELD_CNT_POS   : integer := 1;
  constant C_HDR_LEN_BYTES   : integer := 4;

  constant C_DUAL_CLOCK         : boolean := true;
  constant C_FWFT               : boolean := false;
  constant C_WR_DEPTH           : integer := 32;
  constant C_WR_DATA_W          : integer := 64;
  constant C_RD_DATA_W          : integer := 8;
  constant C_RD_LATENCY         : integer := 1;
  constant C_REN_CTRL           : boolean := true;
  constant C_WEN_CTRL           : boolean := true;
  constant C_ALMOST_EMPTY_LIMIT : integer := 2;
  constant C_ALMOST_FULL_LIMIT  : integer := 2;
  constant C_SANITY_CHECK       : boolean := false;
  constant C_SIMULATION         : integer := 0;

  component ces_util_fifo is
    generic (
      g_dual_clock         : boolean;
      g_fwft               : boolean;
      g_wr_depth           : natural;
      g_wr_data_w          : natural;
      g_rd_data_w          : natural;
      g_rd_latency         : natural;
      g_ren_ctrl           : boolean;
      g_wen_ctrl           : boolean;
      g_almost_empty_limit : integer;
      g_almost_full_limit  : integer;
      g_sanity_check       : boolean;
      g_simulation         : integer);
    port (
      wr_clk_i       : in  std_logic;
      rd_clk_i       : in  std_logic;
      wr_rst_n_i     : in  std_logic;
      rd_rst_n_i     : in  std_logic;
      din_i          : in  std_logic_vector(C_WR_DATA_W - 1 downto 0);
      wen_i          : in  std_logic;
      full_o         : out std_logic;
      almost_full_o  : out std_logic;
      dout_o         : out std_logic_vector(C_RD_DATA_W - 1 downto 0);
      ren_i          : in  std_logic;
      empty_o        : out std_logic;
      almost_empty_o : out std_logic;
      valid_o        : out std_logic);
  end component ces_util_fifo;


  signal wr_clk_i       : std_logic;
  signal rd_clk_i       : std_logic;
  signal wr_rst_n_i     : std_logic;
  signal rd_rst_n_i     : std_logic;
  signal din_i          : std_logic_vector(C_WR_DATA_W - 1 downto 0);
  signal wen_i          : std_logic;
  signal full_o         : std_logic;
  signal almost_full_o  : std_logic;
  signal dout_o         : std_logic_vector(C_RD_DATA_W - 1 downto 0);
  signal ren_i          : std_logic;
  signal empty_o        : std_logic;
  signal almost_empty_o : std_logic;
  signal valid_o        : std_logic;

  signal r_data_cnt : integer;
  signal r_payload_cnt : integer;
  signal r_dout     : std_logic_vector(C_RD_DATA_W-1 downto 0);

  signal r_msg_length : std_logic_vector(C_FIELD_LEN_WIDTH-1 downto 0);
  signal r_msg_cnt    : std_logic_vector(C_FIELD_CNT_WIDTH-1 downto 0);
  signal r_msg_data   : std_logic_vector(8*MAX_MSG_BYTES-1 downto 0);

  signal r_max_cnt : integer;

  signal r_start_ip : std_logic;

begin

  ces_util_fifo_1 : entity work.ces_util_fifo
    generic map (
      g_dual_clock         => C_DUAL_CLOCK,
      g_fwft               => C_FWFT,
      g_wr_depth           => C_WR_DEPTH,
      g_wr_data_w          => C_WR_DATA_W,
      g_rd_data_w          => C_RD_DATA_W,
      g_rd_latency         => C_RD_LATENCY,
      g_ren_ctrl           => C_REN_CTRL,
      g_wen_ctrl           => C_WEN_CTRL,
      g_almost_empty_limit => C_ALMOST_EMPTY_LIMIT,
      g_almost_full_limit  => C_ALMOST_FULL_LIMIT,
      g_sanity_check       => C_SANITY_CHECK,
      g_simulation         => C_SIMULATION)
    port map (
      wr_clk_i       => wr_clk_i,
      rd_clk_i       => rd_clk_i,
      wr_rst_n_i     => wr_rst_n_i,
      rd_rst_n_i     => rd_rst_n_i,
      din_i          => din_i,
      wen_i          => wen_i,
      full_o         => full_o,
      almost_full_o  => almost_full_o,
      dout_o         => dout_o,
      ren_i          => ren_i,
      empty_o        => empty_o,
      almost_empty_o => almost_empty_o,
      valid_o        => valid_o);



  wr_clk_i <= clk;
  rd_clk_i <= clk10;

  p_input_data : process(clk)
  begin
    if(rst = '1') then
    elsif rising_edge(clk) then

      if(r_start_ip = '1') then
        din_i <= s_tdata;
        wen_i <= s_tvalid;
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

      r_max_cnt <= 0;
      r_data_cnt <= 0;
      r_payload_cnt <= 0;
      r_msg_data <= (others => '0');


    elsif rising_edge(clk10) then



      -- pipeline d_out
      r_dout <= dout_o;

      if(empty_o = '0') then
        ren_i <= '1';
      end if;

      -- if(r_data_cnt = (r_msg_length+C_HDR_LEN_BYTES)) then
      --   r_msg_cnt <= std_logic_vector(unsigned(r_msg_cnt) - 1);
      -- end if;

      --if(r_data_cnt = (to_integer(unsigned(r_msg_length)) + C_HDR_LEN_BYTES)) then
      -- r_data_cnt <= 0;

      -- check word of 64 bits (8 bytes)
      -- take into acuont msg_count

      if (valid_o = '1') then
        r_data_cnt <= r_data_cnt + 1;
        r_max_cnt <= r_max_cnt + 8;
     -- elsif( r_data > (unsigned(r_msg_length)+1) ) then
       -- r_data_cnt <= 0;     
      end if;

      if(r_data_cnt = C_FIELD_CNT_POS) then
        r_msg_cnt <= dout_o & r_dout;
      end if;

      if(r_data_cnt = C_FIELD_LEN_POS) then
        r_msg_length <= dout_o & r_dout;
        
      end if;

      if(r_data_cnt > C_FIELD_LEN_POS and r_payload_cnt < (unsigned(r_msg_length)+1)) then
        r_payload_cnt <= r_payload_cnt + 1;
        r_msg_data <= dout_o & r_msg_data(255 downto 8);
      end if;

    end if;
  end process;



end rtl;
