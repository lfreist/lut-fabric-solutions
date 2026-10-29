library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ripple_adder is
  generic (
    WIDTH : positive := 8
  );
  port (
    a    : in  std_logic_vector(WIDTH-1 downto 0);
    b    : in  std_logic_vector(WIDTH-1 downto 0);
    cin  : in  std_logic;
    sum  : out std_logic_vector(WIDTH-1 downto 0);
    cout : out std_logic
  );
end entity ripple_adder;

architecture rtl of ripple_adder is
  signal cins : std_logic_vector(WIDTH downto 0) := (0 => cin, others => '0');
begin
  gen_bit_adder : for i in 0 to WIDTH-1 generate
    u_adder : entity work.full_adder
      port map (
        a => a(i),
        b => b(i),
        cin => cins(i),
        sum => sum(i),
        cout => cins(i+1)
      );
  end generate;
  cout <= cins(WIDTH-1);
end architecture rtl;
