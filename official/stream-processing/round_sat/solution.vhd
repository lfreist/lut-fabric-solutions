library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity round_sat is
  generic (
    IN_WIDTH  : positive := 40;
    OUT_WIDTH : positive := 16;
    SHIFT     : natural := 15
  );
  port (
    d   : in  signed(IN_WIDTH-1 downto 0);
    q   : out signed(OUT_WIDTH-1 downto 0);
    sat : out std_logic
  );
end entity round_sat;

architecture rtl of round_sat is
  constant W : positive := IN_WIDTH + 1;

  function half_lsb return signed is
  begin
    if SHIFT = 0 then
      return to_signed(0, W);
    else
      return shift_left(to_signed(1, W), SHIFT - 1);
    end if;
  end function;

  constant HALF : signed(W-1 downto 0) := half_lsb;
begin
  process (d)
    variable r : signed(W-1 downto 0);
  begin
    r := shift_right(resize(d, W) + HALF, SHIFT);   -- round half up

    if OUT_WIDTH >= W then
      q   <= resize(r, OUT_WIDTH);                  -- always fits: sign-extend
      sat <= '0';
    elsif resize(resize(r, OUT_WIDTH), W) = r then  -- survives the round trip
      q   <= resize(r, OUT_WIDTH);
      sat <= '0';
    elsif r(W-1) = '1' then                         -- too negative
      q   <= (OUT_WIDTH-1 => '1', others => '0');
      sat <= '1';
    else                                            -- too positive
      q   <= (OUT_WIDTH-1 => '0', others => '1');
      sat <= '1';
    end if;
  end process;
end architecture rtl;
