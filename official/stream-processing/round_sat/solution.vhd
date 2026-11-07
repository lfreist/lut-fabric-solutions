library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity round_sat is
  generic (
    IN_WIDTH  : positive := 40;
    OUT_WIDTH : positive := 16;
    SHIFT     : natural  := 15
  );
  port (
    d   : in  signed(IN_WIDTH-1 downto 0);
    q   : out signed(OUT_WIDTH-1 downto 0);
    sat : out std_logic
  );
end entity round_sat;

architecture rtl of round_sat is
  -- wide enough for d + half and for both output limits
  constant WW : positive := IN_WIDTH + OUT_WIDTH + 1;
  constant MAX_OUT : signed(WW-1 downto 0) := shift_left(to_signed(1, WW), OUT_WIDTH - 1) - 1;
  constant MIN_OUT : signed(WW-1 downto 0) := -shift_left(to_signed(1, WW), OUT_WIDTH - 1);
begin

  process (d)
    variable t : signed(WW-1 downto 0);
  begin
    t := resize(d, WW);
    if SHIFT > 0 then
      t := t + shift_left(to_signed(1, WW), SHIFT - 1);  -- add half an LSB
      t := shift_right(t, SHIFT);                         -- arithmetic shift = floor
    end if;
    if t > MAX_OUT then
      q   <= resize(MAX_OUT, OUT_WIDTH);
      sat <= '1';
    elsif t < MIN_OUT then
      q   <= resize(MIN_OUT, OUT_WIDTH);
      sat <= '1';
    else
      q   <= resize(t, OUT_WIDTH);
      sat <= '0';
    end if;
  end process;

end architecture rtl;