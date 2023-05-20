-------------------------------------------------------------------------------
-- Title      : Testbench for design "msg_parser"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : msg_parser_tb.vhd
-- Author     :   <ltran@WDPHY064Z>
-- Company    : 
-- Created    : 2023-05-11
-- Last update: 2023-05-20
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2023 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2023-05-11  1.0      ltran   Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work;
use work.csv_file_reader_pkg.all;

-------------------------------------------------------------------------------

entity msg_parser_tb is

end entity msg_parser_tb;

-------------------------------------------------------------------------------

architecture bench of msg_parser_tb is

  component msg_parser is
    generic (
      MAX_MSG_BYTES : integer);
    port (

      clk10      : in  std_logic;
      clk        : in  std_logic;
      rst        : in  std_logic;
      s_tready   : out std_logic;
      s_tvalid   : in  std_logic;
      s_tlast    : in  std_logic;
      s_tdata    : in  std_logic_vector(63 downto 0);
      s_tkeep    : in  std_logic_vector(7 downto 0);
      s_tuser    : in  std_logic;
      msg_valid  : out std_logic;
      msg_length : out std_logic_vector(15 downto 0);
      msg_data   : out std_logic_vector(8*MAX_MSG_BYTES-1 downto 0);
      msg_error  : out std_logic);
  end component msg_parser;

  constant C_MAX_MSG_BYTES : integer := 32;

  signal clk        : std_logic;
  signal clk10      : std_logic;
  signal rst        : std_logic;
  signal s_tready   : std_logic;
  signal s_tvalid   : std_logic;
  signal s_tlast    : std_logic;
  signal s_tdata    : std_logic_vector(63 downto 0);
  signal s_tkeep    : std_logic_vector(7 downto 0);
  signal s_tuser    : std_logic;
  signal msg_valid  : std_logic;
  signal msg_length : std_logic_vector(15 downto 0);
  signal msg_data   : std_logic_vector(8*C_MAX_MSG_BYTES-1 downto 0);
  signal msg_error  : std_logic;

  signal clk_period     : time := 100 ns;
  signal clk10_period   : time := 10 ns;
  signal stop_the_clock : boolean;

begin  -- architecture bench

  -- map msg_parser
  msg_parser_1 : entity work.msg_parser
    generic map (
      MAX_MSG_BYTES => C_MAX_MSG_BYTES)
    port map (
      clk10      => clk10,
      clk        => clk,
      rst        => rst,
      s_tready   => s_tready,
      s_tvalid   => s_tvalid,
      s_tlast    => s_tlast,
      s_tdata    => s_tdata,
      s_tkeep    => s_tkeep,
      s_tuser    => s_tuser,
      msg_valid  => msg_valid,
      msg_length => msg_length,
      msg_data   => msg_data,
      msg_error  => msg_error);

  stimulus : process

    procedure read_test_file is
      variable csv_file : csv_file_reader_type;
    begin
      csv_file.initialize("../../sim/sample_inputs.csv");
      while csv_file.end_of_file = false loop
        csv_file.readline;
        s_tvalid <= csv_file.read_std_logic;
        s_tlast  <= csv_file.read_std_logic;
        s_tdata  <= csv_file.read_hex(s_tdata'length);
        s_tkeep  <= csv_file.read_std_logic_vector(s_tkeep'length)(s_tkeep'range);
        s_tuser  <= csv_file.read_std_logic;
        wait until rising_edge(clk);
      end loop;
    end procedure read_test_file;

  begin

    rst      <= '1';
    wait until rising_edge(clk);
    rst      <= '0';
    wait until rising_edge(clk);
    s_tlast  <= '1';
    wait until rising_edge(clk);
    s_tvalid <= '0';
    s_tlast  <= '0';
    wait until rising_edge(clk);

    read_test_file;
    s_tvalid <= '0';
    s_tlast  <= '0';
    s_tdata  <= (others => '0');
    s_tkeep  <= (others => '0');
    s_tuser  <= '0';
    wait;

 
  end process;


  clocking_clk : process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clk_period / 2;
      wait for clk_period;
    end loop;
    wait;
  end process;

  clocking_clk10 : process
  begin
    while not stop_the_clock loop
      clk10 <= '0', '1' after clk10_period / 2;
      wait for clk10_period;
    end loop;
    wait;
  end process;

end architecture bench;
