library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity comparator is
  generic (
    WIDTH : positive := 8
  );
  port (
    a         : in  std_logic_vector(WIDTH-1 downto 0);
    b         : in  std_logic_vector(WIDTH-1 downto 0);
    is_signed : in  std_logic;
    eq        : out std_logic;
    lt        : out std_logic;
    gt        : out std_logic
  );
end entity comparator;

architecture rtl of comparator is
  function is_gt(
    i_a: std_logic_vector(WIDTH-1 downto 0);
    i_b: std_logic_vector(WIDTH-1 downto 0);
    i_is_signed: std_logic
  ) return boolean is
  begin
    if i_is_signed = '1' then
      return signed(i_a) > signed(i_b);
    else
      return unsigned(i_a) > unsigned(i_b);
    end if;
  end function;
begin
  eq <= '1' when unsigned(a) = unsigned(b) else '0';
  gt <= '1' when eq = '0' and is_gt(a, b, is_signed) else '0';
  lt <= not gt;
end architecture rtl;
