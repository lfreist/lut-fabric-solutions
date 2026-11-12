library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sync_2ff is
  generic (
    STAGES : positive := 2
  );
  port (
    clk : in  std_logic;
    d   : in  std_logic;
    q   : out std_logic
  );
end entity sync_2ff;

architecture rtl of sync_2ff is
  signal sync_regs : unsigned(4 downto 0) := (others => '0');
  signal prev : std_logic := '0';
  attribute ASYNC_REG : string;
  attribute ASYNC_REG of sync_regs : signal is "TRUE";
begin
  process (clk)
  begin
    if rising_edge(clk) then
      prev <= d;
      sync_regs <= sync_regs + 1;
      if sync_regs > 0 and prev /= d then
        sync_regs <= (others => '0');
      end if;
      if sync_regs >= STAGES - 1 then 
        sync_regs <= (others => '0');
        q <= prev;
      end if;
    end if;
  end process;
end architecture rtl;
