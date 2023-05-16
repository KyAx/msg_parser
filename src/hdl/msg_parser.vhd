-------------------------------------------------------------------------------
-- Title      : msg_parser
-- Project    : 
-------------------------------------------------------------------------------
-- File       : msg_parser.vhd
-- Author     : Tran Leon  
-- Company    : 
-- Created    : 2023-05-04
-- Last update: 2023-05-16
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
      clk : in std_logic;
      rst : in std_logic;

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

  --  constant C_STAGES : positive := log2ceilnz(32);

  -- pipeline
  signal r_s_tdata : std_logic_vector(C_AXI_WIDTH-1 downto 0);

  -- used to shift
  signal r_s_tvalid  : std_logic;
  -- used to trigger concat
  signal r2_s_tvalid : std_logic;
  -- used for msg_valid
  signal r_s_tlast  : std_logic;
  signal r2_s_tlast : std_logic;

  -- fsm
  type t_parser is (begin_packet, mid_packet, end_packet, send_packet);
  signal fsm_parser : t_parser;

  -- shifted data
  signal r_shift_payload : std_logic_vector(C_AXI_WIDTH-1 downto 0);
  signal r_shift_length  : std_logic_vector(C_AXI_WIDTH-1 downto 0);

  -- concat data
  signal r_cat_data   : std_logic_vector(8*MAX_MSG_BYTES-1 downto 0);
  signal r_cat_length : std_logic_vector(C_FIELD_LEN_WIDTH-1 downto 0);

  -- take out fields
  signal r_msg_count  : std_logic_vector(C_FIELD_CNT_WIDTH-1 downto 0);
  signal r_msg_length : std_logic_vector(C_FIELD_LEN_WIDTH-1 downto 0);

  -- shift amount
  signal shift_len : integer := C_FIELD_CNT_WIDTH;
  signal shift_pay : integer := C_FIELD_CNT_WIDTH + C_FIELD_LEN_WIDTH;

  signal r_loaded_len        : integer;
  signal r_rmng_data         : std_logic_vector(C_FIELD_LEN_WIDTH-1 downto 0);
  signal r_sent_payload_size : integer := 32;

  -- sof
  signal r_sof         : std_logic;
  signal r_ip_activate : std_logic;



  function barrel_shifter(input_vector : std_logic_vector;
                          shift_amount : integer)
    return std_logic_vector is
    variable shifted_vector : std_logic_vector(input_vector'range);
  begin
    -- Initialize the shifted vector to the original input vector
    shifted_vector := input_vector;

    -- Shift the vector based on the shift amount
    for i in input_vector'range loop
      if i+shift_amount > input_vector'high then
        shifted_vector(i) := '0';       -- pad with zeros on the left
      else
        shifted_vector(i) := input_vector(i+shift_amount);
      end if;
    end loop;

    return shifted_vector;
  end function;


  -- loaded_len = size that there is already in the packet
  function concat (
    reg         : std_logic_vector;
    concat_with : std_logic_vector;
    loaded_len  : integer) return std_logic_vector is

    variable concat_vec : std_logic_vector(reg'range);
  begin
    for i in 0 to reg'length-1 loop
      if i > loaded_len-1 and i < loaded_len+C_AXI_WIDTH-1 then
        concat_vec(i) := concat_with(i - loaded_len);
      else
        concat_vec(i) := reg(i);
      end if;
    end loop;

    return concat_vec;
  end function concat;


begin

  -- axi data is 8 BYTES
  -- payload is between 8 to 32   [BYTES]
  -- payload is between 64 to 256 [BITS]

  -- general controller : ip activation, msg_valid ctrl, msg_count reader
  p_general_ctrl : process(clk)
  begin
    if(rst = '1') then

      r_ip_activate <= '0';
      r_sof         <= '0';
    elsif rising_edge(clk) then

      r_s_tdata <= s_tdata;

      -- for shift and for concat
      r_s_tvalid  <= s_tvalid;
      r2_s_tvalid <= r_s_tvalid;
      
      -- tlast is used for msg_valid : to not take into account the very first
      -- tlast, we use a r_ip_activate signal
      if(r_ip_activate = '1') then
        r_s_tlast  <= s_tlast;
        r2_s_tlast <= r_s_tlast;
      end if;

      -- msg_valid, we use r_ip_activate to avoid sending a valid on the very
      -- first tlast
      if(r2_s_tlast = '1') then
        msg_valid <= '1';
      else
        msg_valid <= '0';
      end if;

      -- sof allows to take msg_count and msg_length
      if (s_tlast = '1') then
        r_sof         <= '1';
        r_ip_activate <= '1';
      elsif(s_tvalid = '1') then
        r_sof <= '0';
      end if;

      if(s_tvalid = '1' and r_sof = '1') then
        r_msg_count <= s_tdata(C_FIELD_CNT_WIDTH-1 downto 0);
      end if;

    end if;
  end process;

  -- shifting data
  p_shifter : process (clk)
  begin
    if (rst = '1') then
      r_shift_length  <= (others => '0');
      r_shift_payload <= (others => '0');
    elsif rising_edge(clk) then
      if(s_tvalid = '1') then
        r_shift_length <= barrel_shifter(s_tdata, shift_len);
      end if;
      if(r_s_tvalid = '1') then
        r_shift_payload <= barrel_shifter(r_s_tdata, shift_pay);
      end if;
    end if;
  end process;

  p_concat : process(clk, rst) is
  begin
    if (rst = '1') then
      r_cat_data <= (others => '0');

    elsif rising_edge(clk) then



      if(r2_s_tvalid = '1') then
        r_cat_data <= concat(r_cat_data, r_shift_payload, r_loaded_len);
      -- r_cat_length <= concat(msg_length, r_cat_length(r_cat_length'range), 16);
      end if;


    end if;
  end process;

  p_rmng_msg : process(clk, rst) is
  begin
    if (rst = '1') then
      r_rmng_data  <= (others => '0');
      r_loaded_len <= 0;
    elsif rising_edge(clk) then

      if(r2_s_tlast = '1') then
        r_loaded_len <= 0;
      elsif (r2_s_tvalid = '1') then
        r_loaded_len <= r_loaded_len + r_sent_payload_size;
      end if;

      if(r_s_tvalid = '1') then
        -- when less than 12 bytes to send, only two data and 1 msg_count
        if(r_shift_length(C_FIELD_LEN_WIDTH-1 downto 0) < x"000C" and r_msg_count = x"0001") then  -- < and msg_count < ;
          r_msg_length <= r_shift_length(C_FIELD_LEN_WIDTH-1 downto 0);
          --  r_rmng_data <= std_logic_vector(unsigned(r_shift_length(C_FIELD_LEN_WIDTH-1 downto 0)) - r_loaded_len);
          shift_pay    <= 0;
        elsif(r_shift_length(C_FIELD_LEN_WIDTH-1 downto 0) > x"000C" 
        end if;

      end if;
    end if;
  end process;

  msg_data   <= r_cat_data;
  msg_length <= r_msg_length;

end rtl;
