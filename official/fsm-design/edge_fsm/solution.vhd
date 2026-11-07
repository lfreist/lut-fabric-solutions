library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edge_fsm is
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    d     : in  std_logic;
    mealy : out std_logic;
    moore : out std_logic
  );
end entity edge_fsm;

architecture rtl of edge_fsm is
  type state_t is (LOW, EDGE, HIGH);
  signal state : state_t;
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        state <= LOW;
      else
        if d = '1' then
          case state is
            when LOW => state <= EDGE;
            when EDGE => state <= HIGH;
            when HIGH => state <= HIGH;
          end case;
        else
          state <= LOW;
        end if;
      end if;
    end if;
  end process;

  moore <= '1' when state = EDGE else '0';
  mealy <= '1' when state = LOW and d = '1' else '0';
end architecture rtl;
