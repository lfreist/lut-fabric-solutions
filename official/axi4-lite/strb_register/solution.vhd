library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity strb_register is
  generic (
    DATA_WIDTH : positive := 32
  );
  port (
    clk  : in  std_logic;
    rst  : in  std_logic;
    we   : in  std_logic;
    strb : in  std_logic_vector(DATA_WIDTH/8-1 downto 0);
    d    : in  std_logic_vector(DATA_WIDTH-1 downto 0);
    q    : out std_logic_vector(DATA_WIDTH-1 downto 0)
  );
end entity strb_register;

architecture rtl of strb_register is

begin
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        q <= (others => '0');
      elsif we = '1' then
        for i in 0 to DATA_WIDTH/8-1 loop
          if strb(i) = '1' then
            q(8*i+7 downto 8*i) <= d(8*i+7 downto 8*i);
          end if;
        end loop;
      end if;
    end if;
  end process;
end architecture rtl;
