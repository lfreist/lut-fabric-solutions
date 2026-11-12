library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity edge_detector is
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;
    d    : in  std_logic;
    rise : out std_logic;
    fall : out std_logic
  );
end entity edge_detector;

architecture rtl of edge_detector is
  signal prev : std_logic := '0';
begin
  process (clk)
  begin
    if rising_edge(clk) then
      rise <= '0';
      fall <= '0';
      if rst = '1' then
        prev <= '0';
      else
        prev <= d;
        rise <= '1' when d = '1' and prev = '0';
        fall <= '1' when d = '0' and prev = '1';
      end if;
    end if;
  end process;
end architecture rtl;
