-------------------------------------------------------------------------------
-- Title      : msg_parser
-- Project    :
-------------------------------------------------------------------------------
-- File       : msg_parser.vhd
-- Author     : Tran Leon  
-- Company    :
-- Created    : 2023-05-13
-- Last update: 2023-05-21
-- Platform   :
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: Message Parser
-------------------------------------------------------------------------------
-- Copyright (c) 2023
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-05-13  1.0      ltran   Created
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

  -- constants for FIFO
  constant C_AXI_WIDTH       : integer := 64;
  constant C_FIELD_LEN_WIDTH : integer := 16;
  constant C_FIELD_CNT_WIDTH : integer := 16;
  constant C_FIELD_LEN_POS   : integer := 3;
  constant C_FIELD_CNT_POS   : integer := 1;
  constant C_HDR_LEN_BYTES   : integer := 4;

  constant C_TKEEP_WR_DEPTH  : integer := 8;
  constant C_TKEEP_WR_DATA_W : integer := 8;
  constant C_TKEEP_RD_DATA_W : integer := 8;

  constant C_DUAL_CLOCK         : boolean := true;
  constant C_FWFT               : boolean := false;
  constant C_WR_DEPTH           : integer := 8;
  constant C_WR_DATA_W          : integer := 64;
  constant C_RD_DATA_W          : integer := 8;
  constant C_RD_LATENCY         : integer := 1;
  constant C_REN_CTRL           : boolean := true;
  constant C_WEN_CTRL           : boolean := true;
  constant C_ALMOST_EMPTY_LIMIT : integer := 2;
  constant C_ALMOST_FULL_LIMIT  : integer := 2;
  constant C_SANITY_CHECK       : boolean := false;
  constant C_SIMULATION         : integer := 0;

  -- Number of bytes taken by one readen TKEEP
  constant C_TKEEP_NB : integer                          := 2;
  constant C_ZERO     : std_logic_vector(msg_data'range) := (others => '0');

  -- FIFO clk/rst
  signal r_wr_clk  : std_logic;
  signal r_rd_clk  : std_logic;
  signal r_wr_rstn : std_logic;
  signal r_rd_rstn : std_logic;

  -- input FIFOs / output AXI4S
  signal r_tkeep : std_logic_vector(C_TKEEP_WR_DATA_W - 1 downto 0);

  signal wr_tdata_enable : std_logic;
  signal wr_tkeep_enable : std_logic;

  -- tdata FIFO
  signal r_tdata_full         : std_logic;
  signal r_tdata_almost_full  : std_logic;
  signal r_tdata_dout         : std_logic_vector(C_RD_DATA_W - 1 downto 0);
  signal r_tdata_ren          : std_logic;
  signal r_tdata_empty        : std_logic;
  signal r_tdata_almost_empty : std_logic;
  signal r_tdata_valid        : std_logic;

  -- tkeep FIFO
  signal r_tkeep_full         : std_logic;
  signal r_tkeep_almost_full  : std_logic;
  signal r_tkeep_dout         : std_logic_vector(C_TKEEP_RD_DATA_W - 1 downto 0);
  signal r_tkeep_ren          : std_logic;
  signal r_tkeep_empty        : std_logic;
  signal r_tkeep_almost_empty : std_logic;
  signal r_tkeep_valid        : std_logic;

  -- tkeep management
  signal tkeep        : unsigned(7 downto 0);
  signal byte_en      : std_logic;

  -- msg signals
  signal r_msg_length  : unsigned(C_FIELD_LEN_WIDTH-1 downto 0);
  signal r_msg_cnt     : unsigned(C_FIELD_CNT_WIDTH-1 downto 0);
  signal r_msg_data    : std_logic_vector(8*MAX_MSG_BYTES-1 downto 0);
  signal r_msg_cnt_chk : unsigned(C_FIELD_CNT_WIDTH-1 downto 0);
  signal r_msg_valid   : std_logic;

  -- Counters + retrieve length signals
  signal r_data_cnt    : integer;       -- put to unsigned
  signal r_payload_cnt : integer;

  -- fsm to parse msg
  type t_fsm_parser is (CNT, LEN, PAYLOAD);
  signal fsm_parser : t_fsm_parser;

  -- FIFO Component for DATA + TKEEP
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

begin

  s_tready <= not(r_tdata_full);

  -- FIFO : DATA
  wr_tdata_enable <= not(r_tdata_full) and s_tvalid;
  r_tdata_ren     <= not(r_tdata_empty);

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
      wr_clk_i       => r_wr_clk,
      rd_clk_i       => r_rd_clk,
      wr_rst_n_i     => r_wr_rstn,
      rd_rst_n_i     => r_rd_rstn,
      din_i          => s_tdata,
      wen_i          => wr_tdata_enable,
      full_o         => r_tdata_full,
      almost_full_o  => r_tdata_almost_full,
      dout_o         => r_tdata_dout,
      ren_i          => r_tdata_ren,
      empty_o        => r_tdata_empty,
      almost_empty_o => r_tdata_almost_empty,
      valid_o        => r_tdata_valid);

  -- FIFO : TKEEP
  wr_tkeep_enable <= not(r_tkeep_full) and s_tvalid;
  r_tkeep_ren     <= not(r_tkeep_empty);
  
  ces_util_fifo_2 : entity work.ces_util_fifo
    generic map (
      g_dual_clock         => C_DUAL_CLOCK,
      g_fwft               => false,
      g_wr_depth           => C_TKEEP_WR_DEPTH,
      g_wr_data_w          => C_TKEEP_WR_DATA_W,
      g_rd_data_w          => C_TKEEP_RD_DATA_W,
      g_rd_latency         => C_RD_LATENCY,
      g_ren_ctrl           => C_REN_CTRL,
      g_wen_ctrl           => C_WEN_CTRL,
      g_almost_empty_limit => C_ALMOST_EMPTY_LIMIT,
      g_almost_full_limit  => C_ALMOST_FULL_LIMIT,
      g_sanity_check       => C_SANITY_CHECK,
      g_simulation         => C_SIMULATION)
    port map (
      wr_clk_i       => r_wr_clk,
      rd_clk_i       => r_rd_clk,
      wr_rst_n_i     => r_wr_rstn,
      rd_rst_n_i     => r_rd_rstn,
      din_i          => s_tkeep,
      wen_i          => wr_tkeep_enable,
      full_o         => r_tkeep_full,
      almost_full_o  => r_tkeep_almost_full,
      dout_o         => r_tkeep_dout,
      ren_i          => r_tkeep_ren,
      empty_o        => r_tkeep_empty,
      almost_empty_o => r_tkeep_almost_empty,
      valid_o        => r_tkeep_valid);

  --------------------------------------------------------------------------
  -- p_tkeep_mngmt : manage tkeep_ren to read FIFO
  --------------------------------------------------------------------------
  p_tkeep_mngmt : process(clk10)
  begin
    if(rst = '1') then
      tkeep           <= (others => '0');
    elsif rising_edge(clk10) then
      if r_tkeep_ren = '1' then
        tkeep <= unsigned(r_tkeep_dout);
      elsif r_tdata_valid = '1' then
        tkeep <= shift_right(tkeep, 1);
      end if;
    end if;
  end process;

  byte_en      <= tkeep(0);

--------------------------------------------------------------------------

-- p_parser : manage parsing FSM

--------------------------------------------------------------------------
  p_parser : process(clk10)
    -- concat depending loaded_len 
    function concat (
      reg         : std_logic_vector;
      concat_with : std_logic_vector;
      loaded_len  : integer;
      full_len    : unsigned
      ) return std_logic_vector is

      variable ret : std_logic_vector(reg'range);
    begin
      for i in 0 to reg'length-1 loop
        if i >= loaded_len*8 and i < concat_with'length+loaded_len*8 then
          ret(i) := concat_with(i-loaded_len*8);
        elsif i > (full_len*8)-1 then
          ret(i) := '0';
        else
          ret(i) := reg(i);
        end if;
      end loop;
      return ret;
    end function concat;

  begin
    if(rst = '1') then
      r_msg_cnt     <= (others => '0');
      r_data_cnt    <= 0;
      r_payload_cnt <= 0;
      --
      r_msg_data    <= (others => '0');
      r_msg_cnt_chk <= (others => '0');
      r_msg_valid   <= '0';
      r_msg_length  <= (others => '0');
      --
      fsm_parser    <= CNT;
    elsif rising_edge(clk10) then
      
      r_msg_valid <= '0';

      if r_tdata_valid = '1' and byte_en = '1' then

        r_data_cnt <= r_data_cnt + 1;

        -- FSM to parse data
        case fsm_parser is
          -- Retrieve MSG_CNT
          when CNT =>
            if r_data_cnt = C_FIELD_CNT_POS-1 then
              r_msg_cnt(7 downto 0) <= unsigned(r_tdata_dout);
            end if;

            if r_data_cnt = C_FIELD_CNT_POS then
              r_msg_cnt(15 downto 8) <= unsigned(r_tdata_dout);
              fsm_parser             <= LEN;
            end if;

          -- Retrieve MSG_LEN
          when LEN =>
            if r_data_cnt = C_FIELD_LEN_POS-1 then
              r_msg_length(7 downto 0) <= unsigned(r_tdata_dout);
            end if;

            if r_data_cnt = C_FIELD_LEN_POS then
              r_msg_length(15 downto 8) <= unsigned(r_tdata_dout);
              fsm_parser                <= PAYLOAD;
            end if;

          -- MSG_PAYLOAD FIELD
          when PAYLOAD =>
            r_msg_data <= concat(r_msg_data, r_tdata_dout, r_payload_cnt, r_msg_length);

            if r_payload_cnt >= r_msg_length-1 then
              r_msg_valid   <= '1';
              r_payload_cnt <= 0;
              if r_msg_cnt_chk >= r_msg_cnt-1 then  -- for end packet
                r_data_cnt    <= 0;
                r_msg_cnt_chk <= (others => '0');
                fsm_parser    <= CNT;
              else                                  -- for end msg
                r_msg_cnt_chk <= r_msg_cnt_chk + 1;
                r_data_cnt    <= 2;
                fsm_parser    <= LEN;
              end if;
            else                                    -- concatenate data
              r_payload_cnt <= r_payload_cnt + 1;
            end if;
        end case;
      end if;
    end if;
  end process;

  msg_data   <= r_msg_data;
  msg_valid  <= r_msg_valid;
  msg_length <= std_logic_vector(r_msg_length);
  msg_error  <= '0';
  r_wr_clk   <= clk;
  r_rd_clk   <= clk10;
  r_wr_rstn  <= not(rst);
  r_rd_rstn  <= not(rst);

end rtl;
