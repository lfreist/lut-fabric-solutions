library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity full_adder is
  port (
    a    : in  std_logic;
    b    : in  std_logic;
    cin  : in  std_logic;
    sum  : out std_logic;
    cout : out std_logic
  );
end entity full_adder;

architecture rtl of full_adder is
  signal carry_0 : std_logic := '0';
  signal carry_1 : std_logic := '0';
  signal sum_0 : std_logic := '0';
begin
  u_add_0 : entity work.half_adder
    port map (
      a => a,
      b => b,
      sum => sum_0,
      carry => carry_0
    );
  u_add_1 : entity work.half_adder
    port map (
      a => sum_0,
      b => cin,
      sum => sum,
      carry => carry_1
    );
  cout <= carry_0 or carry_1;
end architecture rtl;
