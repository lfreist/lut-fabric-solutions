library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity seven_seg_decoder is
  port (
    digit : in  std_logic_vector(3 downto 0);
    seg   : out std_logic_vector(6 downto 0)
  );
end entity seven_seg_decoder;

architecture rtl of seven_seg_decoder is

begin
  process (all)
  begin
    case digit is
      when x"0" => seg <= 7x"3F";
      when x"1" => seg <= 7x"06";
      when x"2" => seg <= 7x"5B";
      when x"3" => seg <= 7x"4F";
      when x"4" => seg <= 7x"66";
      when x"5" => seg <= 7x"6D";
      when x"6" => seg <= 7x"7D";
      when x"7" => seg <= 7x"07";
      when x"8" => seg <= 7x"7F";
      when x"9" => seg <= 7x"6F";
      when x"A" => seg <= 7x"77";
      when x"B" => seg <= 7x"7C";
      when x"C" => seg <= 7x"39";
      when x"D" => seg <= 7x"5E";
      when x"E" => seg <= 7x"79";
      when x"F" => seg <= 7x"71";
      when others => seg <= 7x"0";
    end case;
  end process;
end architecture rtl;
