-------------------------------------------------------------------------------
-- Title      : Testbench for design "msg_parser"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : msg_parser_tb.vhd
-- Author     :   <ltran>
-- Company    : 
-- Created    : 2023-05-11
-- Last update: 2023-05-21
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

  -- msg_parser declaration
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

--------------------------------------------------------------------------

-- p_stimulus : sends packet to the msg_parser

--------------------------------------------------------------------------
  p_stimulus : process

	-- procedure to send the samples stored in a csv into signals
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

	-- send samples
    read_test_file;
    s_tvalid <= '0';
    s_tlast  <= '0';
    s_tdata  <= (others => '0');
    s_tkeep  <= (others => '0');
    s_tuser  <= '0';
    wait;


  end process;

--------------------------------------------------------------------------

-- p_clocking : clock management

--------------------------------------------------------------------------
  
  -- slower clock (input data)
  p_clocking_clk : process
  begin
    while not stop_the_clock loop
      clk <= '0', '1' after clk_period / 2;
      wait for clk_period;
    end loop;
    wait;
  end process;

  -- faster clock (decoding)
  p_clocking_clk10 : process
  begin
    while not stop_the_clock loop
      clk10 <= '0', '1' after clk10_period / 2;
      wait for clk10_period;
    end loop;
    wait;
  end process;


--------------------------------------------------------------------------

-- p_selfcheck : Self check each message payload and length

--------------------------------------------------------------------------
  p_selfcheck : process

	-- procedure for selfchecking IP output with reference data
	-- report [OK] or [ERROR]
    procedure selfcheck (
      constant ref_data     : in std_logic_vector;
      constant input_data   : in std_logic_vector;
      constant ref_length   : in std_logic_vector;
      constant input_length : in std_logic_vector;
      constant packet_nb    : in integer
      ) is
    begin
      if(input_data = ref_data and input_length = ref_length) then
        report "Packet Number :" & integer'image(packet_nb) severity note;
        report "Reference Data  :" & to_hex_string(unsigned(ref_data));
        report "_______ [OK] _______";
      else
        report "Packet Number :" & integer'image(packet_nb);
        report "Reference Data  :" & to_hex_string(unsigned(ref_data));
        report "_______ [ERROR] _______" severity failure;
      end if;
    end procedure selfcheck;

  begin

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"000000000000000000000000000000000000000000000000630D658DABCDDCEF", msg_data, x"0008", msg_length, 0);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"000000000000000000000000000000000000A5B00388956084130858045DE506", msg_data, x"000E", msg_length, 1);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"000000000000000000000000000000000000000000000000d845a30c85468052", msg_data, x"0008", msg_length, 2);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"0000000000000000000000000000000000000000000000006262626262626262", msg_data, x"0008", msg_length, 3);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"0000000000000000000000000000000000000000686868686868686868686868", msg_data, x"000C", msg_length, 4);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"0000000000000000000000000000000000000000000070707070707070707070", msg_data, x"000A", msg_length, 5);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"00000000000000000000000000000000007a7a7a7a7a7a7a7a7a7a7a7a7a7a7a", msg_data, x"000F", msg_length, 6);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"0000000000000000000000000000000000004d4d4d4d4d4d4d4d4d4d4d4d4d4d", msg_data, x"000E", msg_length, 7);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"0000000000000000000000000000003838383838383838383838383838383838", msg_data, x"0011", msg_length, 8);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"0000000000000000000000000000000000000000003131313131313131313131", msg_data, x"000B", msg_length, 9);

    wait until rising_edge(clk10) and msg_valid = '1';
    selfcheck(x"00000000000000000000000000000000000000000000005A5A5A5A5A5A5A5A5A", msg_data, x"0009", msg_length, 10);

    wait;
  end process;

end architecture bench;
