library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity alu_4bit is
  port (
    a     : in  std_logic_vector(3 downto 0);
    b     : in  std_logic_vector(3 downto 0);
    op    : in  std_logic_vector(2 downto 0);
    y     : out std_logic_vector(3 downto 0);
    carry : out std_logic;
    zero  : out std_logic;
    seg   : out std_logic_vector(6 downto 0)
  );
end entity alu_4bit;

architecture rtl of alu_4bit is
  signal b_add : std_logic_vector(3 downto 0);
  signal sum : std_logic_vector(3 downto 0);
  signal c : std_logic;
  signal lt, gt : std_logic;
  signal min : std_logic_vector(3 downto 0);
  signal slt : std_logic_vector(3 downto 0);
  signal logic : std_logic_vector(3 downto 0);
  signal arith : std_logic_vector(3 downto 0);
  signal y_int : std_logic_vector(3 downto 0);
begin
  b_add <= b xor (b'range => op(0));

  -- add/sub
  u_adder : entity work.ripple_adder
    generic map (
      WIDTH => 4
    )
    port map (
      a => a,
      b => b_add,
      cin => op(0),
      sum => sum,
      cout => c
    );

  u_cmp : entity work.comparator
  generic map (
    WIDTH => 4
  )
  port map (
    a => a,
    b => b,
    is_signed => op(0),
    eq => open,
    lt => lt,
    gt => gt
  );

  u_min : entity work.mux2
    generic map (WIDTH => 4)
    port map (
      a => a, b => b,
      sel => gt,
      y => min
    );

  u_slt : entity work.mux2
    generic map (WIDTH => 4)
    port map (
      a => "0001", b => "0000",
      sel => gt,
      y => slt
    );
  
  u_logic : entity work.logic_unit
    generic map (
      WIDTH => 4
    )
    port map (
      a => a,
      b => b,
      op => op(1 downto 0),
      y => logic
    );

  u_arith : entity work.mux4
    generic map (WIDTH => 4)
    port map (
      a => sum, b => sum, c => min, d => slt,
      sel => op(1 downto 0),
      y => arith
    );

  u_y : entity work.mux2
    generic map (WIDTH => 4)
    port map (
      a => arith, b => logic,
      sel => op(2),
      y => y_int
    );
  
  u_seg : entity work.seven_seg_decoder
    port map (
      digit => y_int,
      seg => seg
    );
  
  y <= y_int;
  carry <= c when op(2 downto 1) = "00" else '0';
  zero <= '1' when y_int = "0000" else '0';

end architecture rtl;
