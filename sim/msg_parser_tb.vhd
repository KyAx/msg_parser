-------------------------------------------------------------------------------
-- Title      : Testbench for design "msg_parser"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : msg_parser_tb.vhd
-- Author     :   <ltran@WDPHY064Z>
-- Company    : 
-- Created    : 2023-05-11
-- Last update: 2023-05-19
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

  signal clk_period     : time := 100ns;
  signal clk10_period   : time := 10ns;
  signal stop_the_clock : boolean;

begin  -- architecture bench

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
    
   procedure write_AXI4S(
     tvalid  : in  std_logic;
     tlast   : in  std_logic;
     tdata   : in  std_logic_vector;
     tkeep   : in  std_logic_vector;
     terror  : in  std_logic;

     signal o_tvalid : out std_logic;
     signal o_tlast : out std_logic;
     signal o_tdata : out std_logic_vector;
     signal o_tkeep : out std_logic_vector;
     signal o_terror : out std_logic
) is
begin
  o_tvalid <= tvalid;
  o_tlast <= tlast;
  o_tdata <= tdata;
  o_tkeep <= tkeep;
  o_terror <= terror;
  
end procedure write_AXI4S;

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

    
    write_AXI4S('1','0', x"ABCDDCEF00080001", b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);
    
    write_AXI4S('1','1', x"00000000630d658d",  b"00001111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);
    
    write_AXI4S('1','0', x"045de506000e0002",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"0388956084130858",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"854680520008a5b0",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','1', x"00000000d845a30c",  b"00001111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"6262626200080008",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"6868000c62626262",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"6868686868686868",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"70707070000a6868",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"000f707070707070",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"7a7a7a7a7a7a7a7a",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"0e7a7a7a7a7a7a7a",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"4d4d4d4d4d4d4d00",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"114d4d4d4d4d4d4d",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"3838383838383800",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"3838383838383838",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"31313131000b3838",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"0931313131313131",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','0', x"5a5a5a5a5a5a5a00",  b"11111111", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    write_AXI4S('1','1', x"0000000000005a5a",  b"00000011", '0', s_tvalid, s_tlast, s_tdata, s_tkeep, s_tuser);
    wait until rising_edge(clk);

    s_tlast <= '0';
    
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
