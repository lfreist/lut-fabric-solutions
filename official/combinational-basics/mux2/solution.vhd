library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux2 is
  generic (
    WIDTH : positive := 8
  );
  port (
    a   : in  std_logic_vector(WIDTH-1 downto 0);
    b   : in  std_logic_vector(WIDTH-1 downto 0);
    sel : in  std_logic;
    y   : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity mux2;

architecture rtl of mux2 is

begin
  y <= a when sel = '0' else b;
end architecture rtl;
