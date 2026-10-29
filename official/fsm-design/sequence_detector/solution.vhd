library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sequence_detector is
  port (
    clk       : in  std_logic;
    rst       : in  std_logic;
    din       : in  std_logic;
    din_valid : in  std_logic;
    detected  : out std_logic
  );
end entity sequence_detector;

architecture rtl of sequence_detector is
  type state_t is (S_IDLE, S_1, S_10, S_101, S_1011);
  signal state : state_t := S_IDLE;
  signal next_state : state_t := S_IDLE;
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= S_IDLE;
      else
        state <= next_state;
      end if;
    end if;
  end process;

  process (all)
  begin
    next_state <= state;
    if din_valid = '1' then
      case state is
        when S_IDLE => next_state <= S_1 when din = '1' else S_IDLE;
        when S_1 => next_state <= S_10 when din = '0' else S_IDLE;
        when S_10 => next_state <= S_101 when din = '1' else S_IDLE;
        when S_101 => next_state <= S_1011 when din = '1' else S_10;
        when S_1011 => next_state <= S_1 when din = '1' else S_10;
      end case;
    else
      if state = S_1011 then
        next_state <= S_1;
      end if;
    end if;
  end process;

  detected <= '1' when state = S_1011 else '0';
end architecture rtl;
