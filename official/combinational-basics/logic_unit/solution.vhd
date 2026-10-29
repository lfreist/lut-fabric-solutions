library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity logic_unit is
  generic (
    WIDTH : positive := 8
  );
  port (
    a  : in  std_logic_vector(WIDTH-1 downto 0);
    b  : in  std_logic_vector(WIDTH-1 downto 0);
    op : in  std_logic_vector(1 downto 0);
    y  : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity logic_unit;

architecture rtl of logic_unit is

begin
  with op select
    y <= a and b when "00",
         a or b when "01",
         a xor b when "10",
         not a when others;
end architecture rtl;
