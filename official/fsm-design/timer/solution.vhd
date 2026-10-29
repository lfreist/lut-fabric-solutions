library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity timer is
  generic (
    WIDTH : positive := 16
  );
  port (
    clk   : in  std_logic;
    rst   : in  std_logic;
    start : in  std_logic;
    len   : in  std_logic_vector(WIDTH-1 downto 0);
    busy  : out std_logic;
    done  : out std_logic
  );
end entity timer;

architecture rtl of timer is
  signal remaining : unsigned(WIDTH-1 downto 0) := (others => '0');
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        remaining <= (others => '0');
      elsif start = '1' then
        remaining <= unsigned(len);
      elsif remaining > 0 then
        remaining <= remaining-1;
      end if;
    end if;
  end process;

  busy <= '1' when remaining > 0 else '0';
  done <= '1' when remaining = 1 else '0';
end architecture rtl;
