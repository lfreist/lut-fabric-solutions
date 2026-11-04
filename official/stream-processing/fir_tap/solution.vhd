library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity fir_tap is
  generic (
    X_WIDTH     : positive := 16;
    COEFF_WIDTH : positive := 18;
    ACC_WIDTH   : positive := 40;
    COEFF       : integer := 1
  );
  port (
    clk     : in  std_logic;
    rst     : in  std_logic;
    en      : in  std_logic;
    x       : in  signed(X_WIDTH-1 downto 0);
    acc_in  : in  signed(ACC_WIDTH-1 downto 0);
    acc_out : out signed(ACC_WIDTH-1 downto 0)
  );
end entity fir_tap;

architecture rtl of fir_tap is
begin
  process (clk)
  begin
    if rising_edge(clk) then
      if rst = '1' then
        acc_out <= (others => '0');
      else
        if en = '1' then
          acc_out <= acc_in + to_signed(COEFF, COEFF_WIDTH) * x;
        end if;
      end if;
    end if;
  end process;
end architecture rtl;
