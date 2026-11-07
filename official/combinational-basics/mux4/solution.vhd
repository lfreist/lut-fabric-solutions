library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity mux4 is
  generic (
    WIDTH : positive := 8
  );
  port (
    a   : in  std_logic_vector(WIDTH-1 downto 0);
    b   : in  std_logic_vector(WIDTH-1 downto 0);
    c   : in  std_logic_vector(WIDTH-1 downto 0);
    d   : in  std_logic_vector(WIDTH-1 downto 0);
    sel : in  std_logic_vector(1 downto 0);
    y   : out std_logic_vector(WIDTH-1 downto 0)
  );
end entity mux4;

architecture rtl of mux4 is
  signal o0 : std_logic_vector(WIDTH-1 downto 0);
  signal o1 : std_logic_vector(WIDTH-1 downto 0);
begin
  u_mux2_0 : entity work.mux2
    generic map (
      WIDTH => WIDTH
    )
    port map(
      a => a,
      b => b,
      sel => sel(0),
      y => o0
    );
  
  u_mux2_1 : entity work.mux2
    generic map (
      WIDTH => WIDTH
    )
    port map (
      a => c,
      b => d,
      sel => sel(0),
      y => o1
    );

  u_mux_out : entity work.mux2
    generic map (
      WIDTH => WIDTH
    )
    port map (
      a => o0,
      b => o1,
      sel => sel(1),
      y => y
    );
end architecture rtl;
